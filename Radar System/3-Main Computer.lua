require("Libs.Attitude")
require("Libs.Quaternion")
require("Libs.PID")
require("Libs.Average")
require("Libs.RC_Filter")

function createTableFromString(str)
	local t = {}
	for w in string.gmatch(str, "[-0-9.]+") do
		local num = tonumber(w)
		if num ~= nil then
			t[#t + 1] = tonumber(num)
		end
	end
	return t
end

function clamp(value, max, min)
	if value < min then
		value = min
	elseif value > max then
		value = max
	end
	return value
end

function positionToTurn(vector)
	return math.atan(vector[3], vector[1]), math.atan(vector[2], math.sqrt(vector[1] ^ 2 + vector[3] ^ 2))
end

--TIMELAG = property.getNumber("Position Averaging Tick")
TIMELAG = 3
PURE_TIMELAG = 6
--VELOCITY_AVERAGING_TICK = property.getNumber("Velocity Averaging Tick")
GPS_POSITION_DIFF = createTableFromString(property.getText("GPS Position Diff"))
ALTITUDE_POSITION_DIFF = createTableFromString(property.getText("Altitude Position Diff"))

ATTITUDE_BASE = Attitude:new(0, 0, 0)
ATTITUDE_RADAR = Attitude:new(0, 0, 0)

TARGET_POS = { 0, 0, 0 }
TARGET_G_POS_P = { 0, 0, 0 }
TARGET_G_POS_AVE = Average:new(TIMELAG + 1, 3)
--TARGET_G_VEL_AVE = Average:new(VELOCITY_AVERAGING_TICK * 2 + 1, 3)
TARGET_G_VEL_F = RC_Filter:new(0.965, 3)
SELF_GPS_POS_P = { 0, 0, 0 }
SELF_GPS_SPEED = { 0, 0, 0 }
RADAR_GPS_POS_P = { 0, 0, 0 }
IS_TRACKING = false

PIVOT_V = 0
PIVOT_H = 0
PivotPID = PID:new(7, 0.007, 0.2, 0.05)

INC = property.getNumber("Rotate Sensitivity") * .0001

function onTick()
	---input target position
	TARGET_POS = { input.getNumber(1), input.getNumber(2), input.getNumber(3) }

	---zero initialization
	local gPosRaw, gPosFuture, gVel, distance, laserDistance =
	{ 0, 0, 0 },
	{ 0, 0, 0 },
	{ 0, 0, 0 },
	math.sqrt(TARGET_POS[1] ^ 2 + TARGET_POS[2] ^ 2 + TARGET_POS[3] ^ 2),
	input.getNumber(17)

	
	---use laser distance if available.
	if (laserDistance ~= 4000) and (math.abs(distance - laserDistance + 2) < 10*distance/100) then
		local a, e = positionToTurn(TARGET_POS)
		local d = (distance + laserDistance) / 2
		TARGET_POS = { d * math.cos(e) * math.cos(a), d * math.sin(e), d * math.cos(e) * math.sin(a) }
	end

	---update self attitude
	ATTITUDE_BASE:update(input.getNumber(4), input.getNumber(5), input.getNumber(6))
	ATTITUDE_RADAR:update(input.getNumber(7), input.getNumber(8), input.getNumber(9), input.getNumber(10))

	---rotate self attitude
	local gpsPos, altPos, selfGPS =
		ATTITUDE_BASE:rotateVectorLocalToWorld(GPS_POSITION_DIFF),
		ATTITUDE_BASE:rotateVectorLocalToWorld(ALTITUDE_POSITION_DIFF),
		{ input.getNumber(11), input.getNumber(12), input.getNumber(13) }

	---calculate target position in global coordinate
	local radarGPS = { selfGPS[1] - gpsPos[1], selfGPS[2] - altPos[2], selfGPS[3] - gpsPos[3] }
	SELF_GPS_SPEED = { selfGPS[1] - SELF_GPS_POS_P[1], selfGPS[2] - SELF_GPS_POS_P[2], selfGPS[3] - SELF_GPS_POS_P[3] }

	if input.getBool(1) and input.getBool(2) then ---tracking mode

		gPosRaw = ATTITUDE_RADAR:rotateVectorLocalToWorld(TARGET_POS)
		TARGET_G_POS_AVE:update(gPosRaw)
		local averagedTargetPos, lPos = TARGET_G_POS_AVE:getAveragedTable(), { 0, 0, 0 }

		if IS_TRACKING then ---if tracking is continuous
			---calculate target speed
			for i = 1, 3 do
				gVel[i] = (gPosRaw[i] + radarGPS[i]) - (TARGET_G_POS_P[i] + RADAR_GPS_POS_P[i])
			end

			---update target averaged speed
			--TARGET_G_VEL_AVE:update(gVel)
			TARGET_G_VEL_F:update(gVel)

			---calculate future target position
			for i = 1, 3 do
				if --[[TARGET_G_VEL_AVE:isStockFull()]] TARGET_G_VEL_F.caledNumber > 20 then
					gPosFuture[i] = averagedTargetPos[i] + TARGET_G_VEL_F.lastValueTable[i] * (PURE_TIMELAG + TIMELAG)
				else
					gPosFuture[i] = averagedTargetPos[i]
				end
			end
			---calculate target future position in local coordinate
			lPos = ATTITUDE_BASE:getFutureAttitude(PURE_TIMELAG):rotateVectorWorldToLocal(gPosFuture)
		else
			---calculate target current position in local coordinate
			lPos = ATTITUDE_BASE:getFutureAttitude(PURE_TIMELAG):rotateVectorWorldToLocal(TARGET_G_POS_AVE:getAveragedTable())
		end

		---calculate radar angle
		PIVOT_H, PIVOT_V = positionToTurn(lPos)
		PIVOT_H, PIVOT_V = PIVOT_H / math.pi / 2, 2 * PIVOT_V / math.pi

		---store target position
		TARGET_G_POS_P = gPosRaw
		IS_TRACKING = true
	else ---manual radar operate mode

		---zero initialization of target position
		TARGET_G_POS_P = { 0, 0, 0 }
		TARGET_G_POS_AVE:resetTable()
		--TARGET_G_VEL_AVE:resetTable()
		TARGET_G_VEL_F:reset()

		---calculate radar angle
		if input.getNumber(15) == -1 then
			PIVOT_H = PIVOT_H + INC
		elseif input.getNumber(15) == 1 then
			PIVOT_H = PIVOT_H - INC
		end
		if input.getNumber(16) == 1 then
			PIVOT_V = clamp(PIVOT_V + INC, 1, -1)
		elseif input.getNumber(16) == -1 then
			PIVOT_V = clamp(PIVOT_V - INC, 1, -1)
		end
		IS_TRACKING = false
	end
	---store self gps position
	SELF_GPS_POS_P = selfGPS
	RADAR_GPS_POS_P = radarGPS

	---output target position and velocity
	for i = 1, 3 do
		output.setNumber(i + 3, radarGPS[i] + TARGET_G_POS_AVE:getAveragedTable()[i])
		output.setNumber(i + 9, --[[TARGET_G_VEL_AVE:getAveragedTable()[i]] TARGET_G_VEL_F.lastValueTable[i])
	end

	---output lag of this system and is tracking
	output.setNumber(20, TIMELAG + PURE_TIMELAG)
	output.setBool(1, IS_TRACKING)

	---output radar angle
	output.setNumber(31, PIVOT_V)
	output.setNumber(32, PivotPID:update((PIVOT_H - input.getNumber(14) + 1.5) % 1 - 0.5, 0))
end

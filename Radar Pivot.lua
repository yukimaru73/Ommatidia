require("Libs.Attitude")
require("Libs.Quaternion")
require("Libs.PID")
require("Libs.Average")

function createTableFromString(str)
	local t, num = {}, nil
	for w in string.gmatch(str, "[-0-9.]+") do
		num = tonumber(w)
		if num ~= nil then
			t[#t + 1] = tonumber(num)
		end
	end
	return t
end

TIMELAG = property.getNumber("Position Averaging Tick")
PURE_TIMELAG = property.getNumber("Pure Time Lag")
VELOCITY_AVERAGING_TICK = property.getNumber("Velocity Averaging Tick")
GPS_POSITION_DIFF = createTableFromString(property.getText("GPS Position Diff"))
ALTITUDE_POSITION_DIFF = createTableFromString(property.getText("Altitude Position Diff"))

ATTITUDE_BASE = Attitude:new(0, 0, 0)
ATTITUDE_RADAR = Attitude:new(0, 0, 0)

TARGET_POS = { 0, 0, 0 }
TARGET_G_POS_P = { 0, 0, 0 }
TARGET_G_POS_AVE = Average:new(TIMELAG * 2 + 1, 3)
TARGET_G_VEL_AVE = Average:new(VELOCITY_AVERAGING_TICK * 2 + 1, 3)
IS_TRACKING = false

PIVOT_V = 0
PIVOT_H = 0
PivotPID = PID:new(5, 0.007, 0.1, 0.05)

INC = 0.003

function onTick()
	TARGET_POS = { input.getNumber(1), input.getNumber(2), input.getNumber(3) }
	local distance, laserDistance = math.sqrt(TARGET_POS[1] ^ 2 + TARGET_POS[2] ^ 2 + TARGET_POS[3] ^ 2),
		input.getNumber(17)

	if (laserDistance ~= 4000) and (math.abs(distance - laserDistance + 2) < 8) then
		local a, e = positionToRadian(TARGET_POS)
		TARGET_POS = { distance * math.cos(e) * math.cos(a), distance * math.sin(e), distance * math.cos(e) * math.sin(a) }
	end

	ATTITUDE_BASE:update(input.getNumber(4), input.getNumber(5), input.getNumber(6))
	ATTITUDE_RADAR:update(input.getNumber(7), input.getNumber(8), input.getNumber(9), input.getNumber(10))
	local gPosRaw, gPosFuture, gVel = { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }
	local gpsPos, altPos = ATTITUDE_BASE:rotateVectorLocalToWorld(GPS_POSITION_DIFF),
		ATTITUDE_BASE:rotateVectorLocalToWorld(ALTITUDE_POSITION_DIFF)
	local radarGPS = { input.getNumber(11) - gpsPos[1], input.getNumber(12) - altPos[2], input.getNumber(13) - gpsPos[3] }
	if input.getBool(1) and input.getBool(2) then --tracking on and target found
		local lPos = { 0, 0, 0 }
		gPosRaw = ATTITUDE_RADAR:rotateVectorLocalToWorld(TARGET_POS)
		TARGET_G_POS_AVE:update(gPosRaw)
		local averagedTargetPos = TARGET_G_POS_AVE:getAveragedTable()

		if IS_TRACKING then
			gVel = { gPosRaw[1] - TARGET_G_POS_P[1], gPosRaw[2] - TARGET_G_POS_P[2], gPosRaw[3] - TARGET_G_POS_P[3] }
			TARGET_G_VEL_AVE:update(gVel)
			for i = 1, 3 do
				if TARGET_G_VEL_AVE:isStockFull() then
					gPosFuture[i] = averagedTargetPos[i] + TARGET_G_VEL_AVE:getAveragedTable()[i] * (PURE_TIMELAG + TIMELAG)
				else
					gPosFuture[i] = averagedTargetPos[i]
				end
			end
			lPos = ATTITUDE_BASE:getFutureAttitude(PURE_TIMELAG):rotateVectorWorldToLocal(gPosFuture)
		else
			lPos = ATTITUDE_BASE:getFutureAttitude(PURE_TIMELAG):rotateVectorWorldToLocal(TARGET_G_POS_AVE:getAveragedTable())
		end
		
		PIVOT_H, PIVOT_V = positionToRadian(lPos)
		PIVOT_H, PIVOT_V = PIVOT_H / math.pi / 2, 2 * PIVOT_V / math.pi
		TARGET_G_POS_P = gPosRaw
		IS_TRACKING = true
	else --manual radar operate
		TARGET_G_POS_P = { 0, 0, 0 }
		TARGET_G_POS_AVE:resetTable()
		TARGET_G_VEL_AVE:resetTable()
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
	for i = 1, 3 do
		output.setNumber(i + 3, radarGPS[i] + TARGET_G_POS_AVE:getAveragedTable()[i])
		output.setNumber(i + 6, TARGET_G_VEL_AVE:getAveragedTable()[i])
	end
	output.setBool(1, IS_TRACKING)

	output.setNumber(30, TARGET_G_POS_AVE:getAveragedTable()[2])
	output.setNumber(31, PIVOT_V)
	output.setNumber(32, PivotPID:update((PIVOT_H - input.getNumber(14) + 1.5) % 1 - 0.5, 0))
end

function clamp(value, max, min)
	if value < min then
		value = min
	elseif value > max then
		value = max
	end
	return value
end

---comment out the following line if you want to use this script as a library
---@param vector table
---@return number azimuth
---@return number elevation
function positionToRadian(vector)
	local azimuth, elevation
	azimuth = math.atan(vector[3], vector[1])
	elevation = math.atan(vector[2], math.sqrt(vector[1] ^ 2 + vector[3] ^ 2))
	return azimuth, elevation
end

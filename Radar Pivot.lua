require("Libs.Attitude")
require("Libs.Quaternion")
require("Libs.PID")
require("Libs.Average")

TIMELAG = property.getNumber("Time Lag Radar")

ATTITUDE_BASE = Attitude:new(0, 0, 0)
ATTITUDE_RADAR = Attitude:new(0, 0, 0)

TARGET_POS = { 0, 0, 0 }
TARGET_G_POS_P = { 0, 0, 0 }
TARGET_G_POS_AVE = Average:new(5)
TARGET_G_VEL_AVE = Average:new(31)
IS_TRACKING = false

PIVOT_V = 0
PIVOT_H = 0
DISTANCE = 0
PivotPID = PID:new(5, 0.007, 0.1, 0.05)

INC = 0.005

function onTick()
	TARGET_POS = { input.getNumber(1), input.getNumber(2), input.getNumber(3) }
	ATTITUDE_BASE:update(input.getNumber(4), input.getNumber(5), input.getNumber(6), 0.25)
	ATTITUDE_RADAR:update(input.getNumber(7), input.getNumber(8), input.getNumber(9), input.getNumber(10))
	local gPosRaw = { 0, 0, 0 }
	local gPosFuture = { 0, 0, 0 }
	local gVel = { 0, 0, 0 }
	if input.getBool(1) and input.getBool(2) then --tracking on and target found
		local lPos = { 0, 0, 0 }
		gPosRaw = ATTITUDE_RADAR:rotateVectorLocalToWorld(TARGET_POS)
		TARGET_G_POS_AVE:update(gPosRaw)
		local averagedTargetPos = TARGET_G_POS_AVE:getAveragedTable()

		--debug.log("TST:->," ..averagedTargetPos[1] .. "," .. averagedTargetPos[2] .. "," .. averagedTargetPos[3] .. ",")
		--debug.log("TST:->," .. math.sqrt(averagedTargetPos[1] ^ 2 + averagedTargetPos[2] ^ 2 + averagedTargetPos[3] ^ 2) .. ",")

		if IS_TRACKING then
			gVel = { gPosRaw[1] - TARGET_G_POS_P[1], gPosRaw[2] - TARGET_G_POS_P[2], gPosRaw[3] - TARGET_G_POS_P[3] }
			TARGET_G_VEL_AVE:update(gVel)
			for i = 1, 3 do
				if TARGET_G_VEL_AVE:isStockFull() then
					local gVelNorm = math.sqrt(gVel[1] ^ 2 + gVel[2] ^ 2 + gVel[3] ^ 2)
					gPosFuture[i] = averagedTargetPos[i] + TARGET_G_VEL_AVE:getAveragedTable()[i] * TIMELAG
				else
					gPosFuture[i] = averagedTargetPos[i]
				end
			end
			--debug.log("TST:->," ..math.floor(10000*gVel[1])/10000 ..","..math.floor(10000*gVel[2])/10000 ..","..math.floor(10000*gVel[3])/10000 ..",")
		end
		lPos = ATTITUDE_BASE:getFutureAttitude(10):rotateVectorWorldToLocal(gPosFuture)
		PIVOT_H, PIVOT_V = getAngle(lPos)
		DISTANCE = math.sqrt(averagedTargetPos[1] ^ 2 + averagedTargetPos[2] ^ 2 + averagedTargetPos[3] ^ 2)
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
		output.setNumber(i, TARGET_G_POS_AVE:getAveragedTable()[i])
		output.setNumber(i + 3, TARGET_G_VEL_AVE:getAveragedTable()[i])
	end
	output.setNumber(7, ATTITUDE_BASE.rotation.x)
	output.setNumber(8, ATTITUDE_BASE.rotation.y)
	output.setNumber(9, ATTITUDE_BASE.rotation.z)
	output.setNumber(10, ATTITUDE_BASE.rotation.w)
	
	output.setBool(1, IS_TRACKING)

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

function getAngle(vector)
	local azimuth, elevation
	azimuth = math.atan(vector[3], vector[1])
	elevation = math.atan(vector[2], math.sqrt(vector[1] ^ 2 + vector[3] ^ 2))
	return azimuth / math.pi / 2, 2 * elevation / math.pi
end

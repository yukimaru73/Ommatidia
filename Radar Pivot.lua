require("Libs.Attitude")
require("Libs.Quaternion")
require("Libs.PID")
require("Libs.Average")

TIMELAG = property.getNumber("Time Lag Radar")

ATTITUDE_BASE = Attitude:new(0, 0, 0)
ATTITUDE_RADAR = Attitude:new(0, 0, 0)

TARGET_POS = { 0, 0, 0 }
TARGET_G_POS_AVE = Average:new(5)
TARGET_G_POS_AVE_P = Average:new(5)
IS_TRACKING = false

PIVOT_V = 0
PIVOT_H = 0
PivotPID = PID:new(6, 0.005, 0.1, 0.05)

INC = 0.005

function onTick()
	TARGET_POS = { input.getNumber(1), input.getNumber(2), input.getNumber(3) }
	ATTITUDE_BASE:update(input.getNumber(4), input.getNumber(5), input.getNumber(6), 0.25)
	ATTITUDE_RADAR:update(input.getNumber(7), input.getNumber(8), input.getNumber(9), input.getNumber(10))
	local gPosRaw = { 0, 0, 0 }
	local gVel = { 0, 0, 0 }
	if input.getBool(1) and input.getBool(2) then --tracking on and target found
		local lPos = { 0, 0, 0 }
		gPosRaw = ATTITUDE_RADAR:rotateVectorLocalToWorld(TARGET_POS)
		TARGET_G_POS_AVE:update(gPosRaw)
		local averagedTargetPos = TARGET_G_POS_AVE:getAveragedTable()
		debug.log("TST:->," ..averagedTargetPos[1] .. "," .. averagedTargetPos[2] .. "," .. averagedTargetPos[3] .. ",")
		if IS_TRACKING then
			local pos_now = TARGET_G_POS_AVE:getAveragedTable()
			local pos_prev = TARGET_G_POS_AVE_P:getAveragedTable()
			gVel = { pos_now[1] - pos_prev[1], pos_now[2] - pos_prev[2], pos_now[3] - pos_prev[3] }
			for i = 1, 3 do
				gPosRaw[i] = gPosRaw[i] + gVel[i] * (TIMELAG+6)
			end
		end
		lPos = ATTITUDE_BASE:getFutureAttitude(10):rotateVectorWorldToLocal(averagedTargetPos)
		PIVOT_H, PIVOT_V = getAngle(lPos)
		TARGET_G_POS_AVE_P = TARGET_G_POS_AVE
		if TARGET_G_POS_AVE_P:isStockFull() then
			IS_TRACKING = true
		end
	else --manual radar operate
		TARGET_G_POS_AVE:resetTable()
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
		output.setNumber(i, gPosRaw[i])
		output.setNumber(i+3, gVel[i])
	end
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

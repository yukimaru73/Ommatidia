require("Libs.Attitude")
require("Libs.Quaternion")
require("Libs.PID")

TIMELAG = property.getNumber("Time Lag Radar")

ATTITUDE_BASE = Attitude:new(0, 0, 0)
ATTITUDE_RADAR = Attitude:new(0, 0, 0)

TARGET_POS = { 0, 0, 0 }
TARGET_G_POS_P = { 0, 0, 0 }
IS_TRACKING = false

PIVOT_V = 0
PIVOT_H = 0
PivotPID = PID:new(6, 0, 0.3, 0)

INC = 0.005

function onTick()
	TARGET_POS = { input.getNumber(1), input.getNumber(2), input.getNumber(3) }
	ATTITUDE_BASE:update(input.getNumber(4), input.getNumber(5), input.getNumber(6))
	ATTITUDE_RADAR:update(input.getNumber(7), input.getNumber(8), input.getNumber(9), input.getNumber(10))
	local gPos = { 0, 0, 0 }
	if input.getBool(1) and input.getBool(2) then
		local lPos = { 0, 0, 0 }
		gPos = ATTITUDE_RADAR:rotateVectorLocalToWorld(TARGET_POS)
		if IS_TRACKING then
			local gVel = { gPos[1] - TARGET_G_POS_P[1], gPos[2] - TARGET_G_POS_P[2], gPos[3] - TARGET_G_POS_P[3] }
			for i = 1, 3 do
				gPos[i] = gPos[i] + gVel[i] * TIMELAG
			end
		end
		lPos = ATTITUDE_BASE:getFutureAttitude(TIMELAG):rotateVectorWorldToLocal(gPos)
		PIVOT_H, PIVOT_V = getAngle(lPos)
		TARGET_G_POS_P = TARGET_POS
		IS_TRACKING = true
	else
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
	output.setNumber(1, PIVOT_V)
	output.setNumber(2, PivotPID:update((PIVOT_H / math.pi / 2 - input.getNumber(14) + 1.5) % 1 - 0.5, 0))
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
	return azimuth, 2 * elevation / math.pi
end
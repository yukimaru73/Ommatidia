require("Libs.Attitude")
require("Libs.PID")

GUN_BASE_ATTITUDE = Attitude:new()

PIVOT_H = 0
PIVOT_V = 0
PivotPID = PID:new(5, 0.007, 0.1, 0.05)

function onTick()
	
	GUN_BASE_ATTITUDE:update(input.getNumber(4), input.getNumber(5), input.getNumber(6), 0.25)

	if input.getBool(1) then
		local t, e, a = input.getNumber(1), input.getNumber(2), input.getNumber(3)
		local pos = angleToPosition(a, e)
		local posL = GUN_BASE_ATTITUDE:getFutureAttitude(8):rotateVectorWorldToLocal(pos)
		PIVOT_H, PIVOT_V = positionToRadian(posL)

	end
	output.setNumber(1, PivotPID:update((PIVOT_H - input.getNumber(7) + 1.5) % 1 - 0.5, 0))
	output.setNumber(2, 4 * PIVOT_V)
end

function angleToPosition(azimuth, elevation)
	local x = math.cos(elevation) * math.cos(azimuth)
	local y = math.sin(elevation)
	local z = math.cos(elevation) * math.sin(azimuth)
	return { x, y, z }
end

function positionToRadian(vector)
	local azimuth, elevation
	azimuth = math.atan(vector[3], vector[1])
	elevation = math.atan(vector[2], math.sqrt(vector[1] ^ 2 + vector[3] ^ 2))
	return azimuth / math.pi / 2, elevation / math.pi / 2
end
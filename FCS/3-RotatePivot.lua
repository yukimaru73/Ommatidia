require("Libs.Attitude")
require("Libs.PID")

MAXIMUM_HORIZONTAL_ANGLE = -property.getNumber("Minimum Horizontal Angle") / 360
MAXIMUM_VERTICAL_ANGLE = property.getNumber("Maximum Vertical Angle") / 90
MINIMUM_HORIZONTAL_ANGLE = -property.getNumber("Maximum Horizontal Angle") / 360
MINIMUM_VERTICAL_ANGLE = property.getNumber("Minimum Vertical Angle") / 90

IS_HORIZONTAL_PIVOT_VELOCITY = property.getBool("Horizontal Pivot")

GUN_BASE_ATTITUDE = Attitude:new()

PIVOT_H = 0
PIVOT_V = 0
PivotPID = PID:new(20, 0.005, 0.3, 0.08)

function onTick()

	GUN_BASE_ATTITUDE:update(input.getNumber(14), input.getNumber(15), input.getNumber(16), 0.25)

	if input.getBool(1) then
		local t, e, a = input.getNumber(1), input.getNumber(2), input.getNumber(3)
		local pos = angleToPosition(a, e)
		local posL = GUN_BASE_ATTITUDE:getFutureAttitude(8):rotateVectorWorldToLocal(pos)
		PIVOT_H, PIVOT_V = positionToRadian(posL)

	end
	output.setNumber(3, PIVOT_H)
	if IS_HORIZONTAL_PIVOT_VELOCITY then
		PIVOT_H = clamp(PivotPID:update((clamp(PIVOT_H, MINIMUM_HORIZONTAL_ANGLE, MAXIMUM_HORIZONTAL_ANGLE) - input.getNumber(13) + 1.5) % 1 - 0.5, 0), -0.37, 0.37)
	else
		PIVOT_H = clamp(4 * PIVOT_H, MINIMUM_HORIZONTAL_ANGLE * 4, MAXIMUM_HORIZONTAL_ANGLE * 4)
	end
	output.setNumber(1,PIVOT_H)
	output.setNumber(2, clamp(4 * PIVOT_V, MINIMUM_VERTICAL_ANGLE, MAXIMUM_VERTICAL_ANGLE))
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

function clamp(value, min, max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

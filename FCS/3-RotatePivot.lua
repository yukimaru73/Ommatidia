require("Libs.Attitude")
require("Libs.PID")
require("Libs.UpDownCounter")

MAX_HORIZONTAL_ANGLE = -property.getNumber("Max Left Horizontal Angle") / 360
MAX_VERTICAL_ANGLE = property.getNumber("Max Vertical Angle") / 90
MIN_HORIZONTAL_ANGLE = -property.getNumber("Max Right Horizontal Angle") / 360
MIN_VERTICAL_ANGLE = property.getNumber("Min Vertical Angle") / 90
HORIZONTAL_SPEED = property.getNumber("Horizontal Speed") / 100
VERTICAL_SPEED = property.getNumber("Vertical Speed") / 100

HORIZONTAL_CONTINUOUS = (MAX_HORIZONTAL_ANGLE + MIN_HORIZONTAL_ANGLE == 0) and (MAX_HORIZONTAL_ANGLE == 0.5)

HORIZONTAL_UDC = UpDownCounter:new(HORIZONTAL_SPEED/100, MIN_HORIZONTAL_ANGLE*4, MAX_HORIZONTAL_ANGLE*4)
VERTICAL_UDC = UpDownCounter:new(VERTICAL_SPEED/100, MIN_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)

IS_HORIZONTAL_PIVOT_VELOCITY = property.getBool("Horizontal Pivot")

GUN_BASE_ATTITUDE = Attitude:new()

PIVOT_H = 0
PIVOT_H_OUT = 0
PIVOT_V = 0
PivotPID = PID:new(20, 0.005, 0.3, 0.08)

function onTick()
	---update self attitude
	GUN_BASE_ATTITUDE:update(input.getNumber(14), input.getNumber(15), input.getNumber(16), 0.25)

	---if balistic calculator is solved, get pivot angle
	if input.getBool(1) then
		local t, e, a = input.getNumber(1), input.getNumber(2), input.getNumber(3)
		local pos = angleToPosition(a, e)
		local posL = GUN_BASE_ATTITUDE:getFutureAttitude(8):rotateVectorWorldToLocal(pos)
		PIVOT_H, PIVOT_V = positionToTurn(posL)
	end

	---output pivot angle
	if IS_HORIZONTAL_PIVOT_VELOCITY then
		local clampedHorizontal, pidValue = clamp(PIVOT_H, MIN_HORIZONTAL_ANGLE, MAX_HORIZONTAL_ANGLE), 0
		if HORIZONTAL_CONTINUOUS then
			pidValue = PivotPID:update((clampedHorizontal - input.getNumber(13) + 1.5) % 1 - 0.5, 0)
		else
			pidValue = PivotPID:update(clampedHorizontal - input.getNumber(13), 0)
		end
		PIVOT_H_OUT = clamp(pidValue, -HORIZONTAL_SPEED, HORIZONTAL_SPEED)
	else
		PIVOT_H_OUT = HORIZONTAL_UDC:update(PIVOT_H*4)
	end
	output.setNumber(1, PIVOT_H_OUT)
	output.setNumber(2, VERTICAL_UDC:update(PIVOT_V*4))
end

function angleToPosition(azimuth, elevation)
	local x = math.cos(elevation) * math.cos(azimuth)
	local y = math.sin(elevation)
	local z = math.cos(elevation) * math.sin(azimuth)
	return { x, y, z }
end

function posiionToTurn(vector)
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

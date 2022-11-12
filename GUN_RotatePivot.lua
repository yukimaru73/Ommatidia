require("Libs.Quaternion")

PIVOT_H = 0
PIVOT_V = 0

function onTick()
	local q = Quaternion:_new()
	q.x = input.getNumber(4)
	q.y = input.getNumber(5)
	q.z = input.getNumber(6)
	q.w = input.getNumber(7)

	if input.getBool(1) then
		local t, e, a = input.getNumber(1), input.getNumber(2), input.getNumber(3)
		local pos = { math.cos(e) * math.cos(a), math.sin(e), math.cos(e) * math.sin(a) }
		local posL = q:getConjugateQuaternion():rotateVector(pos)
		PIVOT_H, PIVOT_V = getAngle(posL)

	end
	output.setNumber(1, PIVOT_H)
	output.setNumber(2, PIVOT_V)
end

function getAngle(vector)
	local azimuth, elevation
	azimuth = math.atan(vector[3], vector[1])
	elevation = math.atan(vector[2], math.sqrt(vector[1] ^ 2 + vector[3] ^ 2))
	return 2 * azimuth / math.pi, 2 * elevation / math.pi
end
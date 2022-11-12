require("Libs.Quaternion")

DIFF = {property.getNumber("X"), property.getNumber("Y"), property.getNumber("Z")}
GX,GY,GZ = 0,0,0

function onTick()
	local q = Quaternion:_new()
	q.x = input.getNumber(7)
	q.y = input.getNumber(8)
	q.z = input.getNumber(9)
	q.w = input.getNumber(10)
	local diff = q:rotateVector(DIFF)
	if input.getBool(1) then
		GX = diff[1]
		GY = diff[2]
		GZ = diff[3]
		output.setBool(1, true)
		--debug.log("TST:-> gotData")
	else
		output.setBool(1, false)
	end
	output.setNumber(1, GX)
	output.setNumber(2, GY)
	output.setNumber(3, GZ)
	for i = 4, 13 do
		output.setNumber(i, input.getNumber(i-3))
	end
end
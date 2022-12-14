require("Libs.Vector3")
INPUT_TARGETS = {}
BASE_LENGTH = 0.25
FOUND = false


function onTick()
	---zero initialization
	local xt, yt, zt = 0, 0, 0
	FOUND = false
	for i = 1, 9 do
		local x, y, z = input.getNumber(3 * i), input.getNumber(3 * i + 1), input.getNumber(3 * i + 2)
		INPUT_TARGETS[i] = Vector3:new(x, y, z)
	end

	---subtract to the base position
	for i = 1, 3 do
		for j = 1, 3 do
			if INPUT_TARGETS[i].x ~= 0 and INPUT_TARGETS[i].y ~= 0 and INPUT_TARGETS[i].z ~= 0 then
				local subVec = Vector3:new(BASE_LENGTH, (j - 2) * BASE_LENGTH, (i - 2) * BASE_LENGTH)
				INPUT_TARGETS[i] = Vector3.sub(INPUT_TARGETS[i], subVec)
				FOUND = true
			end
		end
	end

	---calculate the average of max and min positions of near targets
	if #INPUT_TARGETS > 0 then
		local xmax, xmin, ymax, ymin, zmax, zmin = INPUT_TARGETS[1].x, INPUT_TARGETS[1].x, INPUT_TARGETS[1].y,
			INPUT_TARGETS[1].y, INPUT_TARGETS[1].z, INPUT_TARGETS[1].z
		for i = 1, #INPUT_TARGETS do
			if INPUT_TARGETS[i].x ~= 0 and INPUT_TARGETS[i].y ~= 0 and INPUT_TARGETS[i].z ~= 0 then
				if INPUT_TARGETS[i].x > xmax then xmax = INPUT_TARGETS[i].x end
				if INPUT_TARGETS[i].x < xmin then xmin = INPUT_TARGETS[i].x end
				if INPUT_TARGETS[i].y > ymax then ymax = INPUT_TARGETS[i].y end
				if INPUT_TARGETS[i].y < ymin then ymin = INPUT_TARGETS[i].y end
				if INPUT_TARGETS[i].z > zmax then zmax = INPUT_TARGETS[i].z end
				if INPUT_TARGETS[i].z < zmin then zmin = INPUT_TARGETS[i].z end
			end
		end
		xt, yt, zt = (xmax + xmin) / 2, (ymax + ymin) / 2, (zmax + zmin) / 2
	end

	---output target position
	output.setNumber(1, xt)
	output.setNumber(2, yt)
	output.setNumber(3, zt)
	output.setBool(1, FOUND)

	---transfer seat input
	output.setBool(2, input.getBool(1))
	output.setNumber(15, input.getNumber(1))
	output.setNumber(16, input.getNumber(2))

end

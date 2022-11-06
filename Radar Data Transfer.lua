require("Libs.Vector3")

BASE_DISTANCE = 2
INPUT_TARGETS = {}

function onTick()
	INPUT_TARGETS = {}
	FOUND = false
	local found, distance, azimuth, elevation
	local x, y, z = 0, 0, 0
	for i = 1, 8 do
		found = input.getBool(i)
		if found then
			distance = input.getNumber(4 * i - 3)
			azimuth = input.getNumber(4 * i - 2) * 2 * math.pi
			elevation = input.getNumber(4 * i - 1) * 2 * math.pi
			INPUT_TARGETS[#INPUT_TARGETS + 1] = { Vector3:newFromPolar(distance, azimuth, elevation), {}, distance }
		end
	end
	if #INPUT_TARGETS ~= 0 then
		for i = 1, #INPUT_TARGETS do
			for j = #INPUT_TARGETS, i + 1, -1 do
				local noize_distance = BASE_DISTANCE * (INPUT_TARGETS[i][3] + INPUT_TARGETS[j][3]) * 0.005
				if Vector3.getDistanceBetween2Vectors(INPUT_TARGETS[i][1], INPUT_TARGETS[j][1]) < noize_distance then
					INPUT_TARGETS[i][2][#INPUT_TARGETS[i][2] + 1] = j
					INPUT_TARGETS[j][2][#INPUT_TARGETS[j][2] + 1] = i
				end
			end
		end
		table.sort(INPUT_TARGETS, function(a, b) return #a[2] > #b[2] end)
		local xmax, xmin, ymax, ymin, zmax, zmin = INPUT_TARGETS[1][1].x, INPUT_TARGETS[1][1].x, INPUT_TARGETS[1][1].y, INPUT_TARGETS[1][1].y, INPUT_TARGETS[1][1].z, INPUT_TARGETS[1][1].z
		for i, v in ipairs(INPUT_TARGETS[1][2]) do
			if INPUT_TARGETS[v][1].x > xmax then xmax = INPUT_TARGETS[v][1].x end
			if INPUT_TARGETS[v][1].x < xmin then xmin = INPUT_TARGETS[v][1].x end
			if INPUT_TARGETS[v][1].y > ymax then ymax = INPUT_TARGETS[v][1].y end
			if INPUT_TARGETS[v][1].y < ymin then ymin = INPUT_TARGETS[v][1].y end
			if INPUT_TARGETS[v][1].z > zmax then zmax = INPUT_TARGETS[v][1].z end
			if INPUT_TARGETS[v][1].z < zmin then zmin = INPUT_TARGETS[v][1].z end
		end
		x = (xmax + xmin) * 0.5
		y = (ymax + ymin) * 0.5
		z = (zmax + zmin) * 0.5
	end
	output.setNumber(1, x)
	output.setNumber(2, y)
	output.setNumber(3, z)
	--debug.log("TST: X->,"..x..", Y->,"..y..", Z->,"..z..",")
end

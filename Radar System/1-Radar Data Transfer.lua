require("Libs.Vector3")

MAXIMUM_DISTANCE = property.getNumber("Maximum Distance")

BASE_DISTANCE = 5
INPUT_TARGETS = {}

function onTick()
	---zero initialization
	INPUT_TARGETS = {}
	FOUND = false
	local found, distance, azimuth, elevation
	local x, y, z = 0, 0, 0

	---get all targets if found
	for i = 1, 8 do
		found = input.getBool(i)
		if found then
			distance = input.getNumber(4 * i - 3)
			azimuth = input.getNumber(4 * i - 2) * 2 * math.pi
			elevation = input.getNumber(4 * i - 1) * 2 * math.pi
			if distance > 15 and distance < MAXIMUM_DISTANCE
			 then
				INPUT_TARGETS[#INPUT_TARGETS + 1] = { Vector3:newFromPolar(distance, azimuth, elevation), {}, distance }
			end
		end
	end

	---calculate the average position of near targets
	if #INPUT_TARGETS ~= 0 then
		if #INPUT_TARGETS>1 then
			for i = 1, #INPUT_TARGETS do
				for j = #INPUT_TARGETS, i + 1, -1 do
					local noize_distance = BASE_DISTANCE * INPUT_TARGETS[i][3] * 0.01
					if Vector3.getDistanceBetween2Vectors(INPUT_TARGETS[i][1], INPUT_TARGETS[j][1]) < noize_distance then
						INPUT_TARGETS[i][2][#INPUT_TARGETS[i][2] + 1] = j
						INPUT_TARGETS[j][2][#INPUT_TARGETS[j][2] + 1] = i
					end
				end
			end
			table.sort(INPUT_TARGETS, function(a, b) return #a[2] > #b[2] end)
		end
		x,y,z = INPUT_TARGETS[1][1].x, INPUT_TARGETS[1][1].y, INPUT_TARGETS[1][1].z
		for i, v in ipairs(INPUT_TARGETS[1][2]) do
			x = x + INPUT_TARGETS[v][1].x
			y = y + INPUT_TARGETS[v][1].y
			z = z + INPUT_TARGETS[v][1].z
		end
		local target_number = #INPUT_TARGETS[1][2] + 1
		x = x / target_number
		y = y / target_number
		z = z / target_number
	end

	---output target position
	output.setNumber(1, x)
	output.setNumber(2, y)
	output.setNumber(3, z)
end

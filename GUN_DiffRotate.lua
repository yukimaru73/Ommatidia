require("Libs.Attitude")

function createTableFromString(str)
	local t, num = {}, nil
	for w in string.gmatch(str, "[-0-9.]+") do
		num = tonumber(w)
		if num ~=nil then
			t[#t+1] = tonumber(num)
		end
	end
	return t
end

GPS_POSITION_DIFF = createTableFromString(property.getText("GPS Position Diff"))
ALTITUDE_POSITION_DIFF = createTableFromString(property.getText("Altitude Position Diff"))
GUN_BASE_ATTITUDE = Attitude:new()
GUN_POS = { 0, 0, 0 }

function onTick()
	GUN_BASE_ATTITUDE:update(input.getNumber(21), input.getNumber(22), input.getNumber(23), 0.25)
	local gpsPos, altPos = GUN_BASE_ATTITUDE:rotateVectorLocalToWorld(GPS_POSITION_DIFF), GUN_BASE_ATTITUDE:rotateVectorLocalToWorld(ALTITUDE_POSITION_DIFF)
	GUN_POS = {input.getNumber(25) - gpsPos[1], input.getNumber(26) - altPos[2], input.getNumber(27) - gpsPos[3]}

	if input.getBool(1) then
		output.setBool(1, true)
		--debug.log("TST:-> gotData")
	else
		output.setBool(1, false)
	end
	output.setNumber(1, GUN_POS[1])
	output.setNumber(2, GUN_POS[2])
	output.setNumber(3, GUN_POS[3])
	for i = 4, 9 do
		output.setNumber(i, input.getNumber(i))
	end
	output.setNumber(10, input.getNumber(21))
	output.setNumber(11, input.getNumber(22))
	output.setNumber(12, input.getNumber(23))

	output.setNumber(30, GUN_POS[1])
	output.setNumber(31, GUN_POS[2])
	output.setNumber(32, GUN_POS[3])
end
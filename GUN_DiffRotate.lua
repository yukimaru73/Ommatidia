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
	GUN_BASE_ATTITUDE:update(input.getNumber(14), input.getNumber(15), input.getNumber(16), 0.25)
	local gpsPos = GUN_BASE_ATTITUDE:rotateVectorLocalToWorld(GPS_POSITION_DIFF)
	local altPos = GUN_BASE_ATTITUDE:rotateVectorLocalToWorld(ALTITUDE_POSITION_DIFF)
	GUN_POS[1] = input.getNumber(17) - gpsPos[1]
	GUN_POS[2] = input.getNumber(18) - altPos[2]
	GUN_POS[3] = input.getNumber(19) - gpsPos[3]
	
	output.setBool(1,input.getBool(1))

	output.setNumber(1, GUN_POS[1])
	output.setNumber(2, GUN_POS[2])
	output.setNumber(3, GUN_POS[3])
	for i = 4, 12 do
		output.setNumber(i, input.getNumber(i))
	end
	output.setNumber(13, input.getNumber(13))
	output.setNumber(14, input.getNumber(14))
	output.setNumber(15, input.getNumber(15))
	output.setNumber(16, input.getNumber(16))
end
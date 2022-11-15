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
	GUN_BASE_ATTITUDE:update(input.getNumber(11), input.getNumber(12), input.getNumber(13), 0.25)
	local gpsPos = GUN_BASE_ATTITUDE:rotateVectorLocalToWorld(GPS_POSITION_DIFF)
	local altPos = GUN_BASE_ATTITUDE:rotateVectorLocalToWorld(ALTITUDE_POSITION_DIFF)
	GUN_POS[1] = input.getNumber(14) - gpsPos[1]
	GUN_POS[2] = input.getNumber(15) - altPos[2]
	GUN_POS[3] = input.getNumber(16) - gpsPos[3]
	
	output.setBool(1,input.getBool(1))

	output.setNumber(1, GUN_POS[1])
	output.setNumber(2, GUN_POS[2])
	output.setNumber(3, GUN_POS[3])
	for i = 4, 9 do
		output.setNumber(i, input.getNumber(i))
	end
	output.setNumber(10, input.getNumber(11))
	output.setNumber(11, input.getNumber(12))
	output.setNumber(12, input.getNumber(13))
	output.setNumber(13, input.getNumber(10))
end
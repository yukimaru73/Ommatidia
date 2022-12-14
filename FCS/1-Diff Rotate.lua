require("Libs.Attitude")
SELF_GPS_POS_P = { 0, 0, 0 }
SELF_GPS_SPEED= {0,0,0}

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
	---uprade self attitude
	GUN_BASE_ATTITUDE:update(input.getNumber(14), input.getNumber(15), input.getNumber(16), 0.25)

	---rotate self position
	local gpsPos = GUN_BASE_ATTITUDE:rotateVectorLocalToWorld(GPS_POSITION_DIFF)
	local altPos = GUN_BASE_ATTITUDE:rotateVectorLocalToWorld(ALTITUDE_POSITION_DIFF)

	---update self GPS position
	GUN_POS[1] = input.getNumber(17) - gpsPos[1]
	GUN_POS[2] = input.getNumber(18) - altPos[2]
	GUN_POS[3] = input.getNumber(19) - gpsPos[3]

	---calculate self GPS speed
	local selfGPSPos = {input.getNumber(17), input.getNumber(18), input.getNumber(19)}
	SELF_GPS_SPEED[1] = (selfGPSPos[1] - SELF_GPS_POS_P[1])
	SELF_GPS_SPEED[2] = (selfGPSPos[2] - SELF_GPS_POS_P[2])
	SELF_GPS_SPEED[3] = (selfGPSPos[3] - SELF_GPS_POS_P[3])

	---store self GPS position
	SELF_GPS_POS_P = selfGPSPos

	---check target is not self
	local dx, dy, dz = GUN_POS[1] - input.getNumber(4), GUN_POS[2] - input.getNumber(5), GUN_POS[3] - input.getNumber(6)
	local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
	if distance < 20 then
		output.setBool(1,false)
	else
		output.setBool(1,input.getBool(1))
	end
	
	for i = 1, 3 do
		output.setNumber(i, GUN_POS[i] + SELF_GPS_SPEED[i] * 5)--turret position
		output.setNumber(i+3, input.getNumber(i+3))--target position
		output.setNumber(i+6, SELF_GPS_SPEED[i])--bullet additional muzzle velocity
		output.setNumber(i+9, input.getNumber(i+9))--target velocity
		output.setNumber(i+13, input.getNumber(i+13))--turret attitude
	end
	output.setNumber(13, input.getNumber(13))--turret pivot(horizontal) current rotation
	output.setNumber(20, input.getNumber(20))--radar data latency
end
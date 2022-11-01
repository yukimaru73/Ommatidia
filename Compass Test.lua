require("Libs.CompassSensor")

CS = CompassSensor:new()

function onTick()
	CS:update(input.getNumber(1))
	debug.log("TST:->"..CS:getCompassSensorVelocity())
	output.setNumber(1, CS:getCompassSensorVelocity())
end
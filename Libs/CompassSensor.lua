require("LifeBoatAPI.Utils.LBCopy")

---@section CompassSensor 1 CompassSensor
---@class CompassSensor
---@field pastCompassValue number
---@field compassSensorVelocity number
CompassSensor = {

	---@param cls CompassSensor
	---@overload fun(cls:CompassSensor):CompassSensor creates a new zero-initialized CompassSensor
	---@return CompassSensor
	new = function(cls)
		return LifeBoatAPI.lb_copy(cls, { pastCompassValue = 0, compassSensorVelocity = 0 })
	end;

	---@section update
	---@param self CompassSensor
	---@param compassValue number -0.5~0.5(south~west~north~east~south)
	---@return nil
	update = function(self, compassValue)
		local cs = self
		local velA = 0
		velA = compassValue - cs.pastCompassValue
		if math.abs(velA) < 0.5 then
			cs.compassSensorVelocity = velA
		else
			cs.compassSensorVelocity = (compassValue - cs.pastCompassValue+1.5)%1-0.5
		end
		cs.pastCompassValue = compassValue
	end;
	---@endsection

	---@section getCompassSensorVelocity
	---@param self CompassSensor
	---@return number
	getCompassSensorVelocity = function(self)
		return self.compassSensorVelocity
	end;
	---@endsection

	---@section getCompassSensorValue
	---@param self CompassSensor
	---@return number
	getCompassSensorValue = function(self)
		return self.pastCompassValue
	end;
	---@endsection
	
}
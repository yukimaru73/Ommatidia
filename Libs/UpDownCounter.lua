require("LifeBoatAPI.Utils.LBCopy")

---@section UpDownCounter 1 UpDownCounter
---@class UpDownCounter
---@field currentValue number
---@field targetValue number
---@field stepSize number
---@field minValue number
---@field maxValue number
UpDownCounter = {

	---@param cls UpDownCounter
	---@param stepSize number
	---@param minValue number
	---@param maxValue number
	---@overload fun(cls:UpDownCounter):UpDownCounter creates a new zero-initialized UpDownCounter
	---@return UpDownCounter
	new = function(cls, stepSize, minValue, maxValue)
		local o = {
			currentValue = 0,
			targetValue = 0,
			stepSize = stepSize,
			minValue = minValue,
			maxValue = maxValue
		}
		
		return LifeBoatAPI.lb_copy(cls, o)
	end;

	---@section update
	---@param self UpDownCounter
	---@param targetValue number
	---@return number
	update = function(self, targetValue)
		self.targetValue = targetValue
		if self.currentValue < self.targetValue then
			self.currentValue = math.min(self.currentValue + self.stepSize, self.targetValue)
		elseif self.currentValue > self.targetValue then
			self.currentValue = math.max(self.currentValue - self.stepSize, self.targetValue)
		end
		if self.currentValue < self.minValue then
			self.currentValue = self.minValue
		elseif self.currentValue > self.maxValue then
			self.currentValue = self.maxValue
		end
		return self.currentValue
	end;
	---@endsection
	
	---@section reset
	---@param self UpDownCounter
	---@return nil
	reset = function(self)
		self.currentValue = 0
		self.targetValue = 0
	end;
	---@endsection

}
---@endsection
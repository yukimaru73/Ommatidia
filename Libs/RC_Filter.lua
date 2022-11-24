require("LifeBoatAPI.Utils.LBCopy")

---@section RC_Filter 1 RC_Filter
---@class RC_Filter
---@field alpha number
---@field caledNumber number
---@field lastValueTable table<number>
RC_Filter = {

	---@param cls RC_Filter
	---@param alpha number
	---@param tableNumber number
	---@return RC_Filter
	new = function(cls, alpha, tableNumber)
		local obj = {
			alpha = alpha,
			caledNumber = 0,
			lastValueTable = {}
		}
		for i = 1, tableNumber do
			obj.lastValueTable[i] = 0
		end
		return LifeBoatAPI.lb_copy(cls, obj)
	end;

	---@section update
	---@param self RC_Filter
	---@param values table
	---@return nil
	---@overload fun(self:RC_Filter, values:number):nil
	update = function(self, values, alpha)
		alpha = alpha or self.alpha
		self.caledNumber = self.caledNumber + 1
		for i = 1, #values do
			--[[
			local difference, buf = math.abs(values[i] - self.lastValueTable[i]), alpha
			if difference > 7 then
				alpha = alpha * 0.995
			elseif difference > 5 then
				alpha = 1
			end
			]]
			self.lastValueTable[i] = alpha * self.lastValueTable[i] + (1 - alpha) * values[i]
			--alpha = buf
		end
	end;
	---@endsection

	---@section reset
	---@param self RC_Filter
	---@return nil
	reset = function(self)
		self.caledNumber = 0
		for i = 1, #self.lastValueTable do
			self.lastValueTable[i] = 0
		end
	end;
	---@endsection
}
---@endsection
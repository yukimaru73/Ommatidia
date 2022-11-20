require("LifeBoatAPI.Utils.LBCopy")

---@section RC_Filter 1 RC_Filter
---@class RC_Filter
---@field alpha number
---@field caledNumber number
---@field lastValueTable table
RC_Filter = {

	---@param cls RC_Filter
	---@param alpha number
	---@param tableNumber number
	---@return RC_Filter
	new = function(cls, alpha, tableNumber)
		local obj = {}
		obj.alpha = alpha
		obj.caledNumber = 0
		obj.lastValueTable = {}
		for i = 1, tableNumber do
			obj.lastValueTable[i] = 0
		end
		return LifeBoatAPI.lb_copy(cls, obj)
	end;

	---@section update
	---@param self RC_Filter
	---@param values table
	---@return nil
	update = function(self, values)
		self.caledNumber = self.caledNumber + 1
		for i = 1, #values do
			self.lastValueTable[i] = self.alpha * self.lastValueTable[i] + (1 - self.alpha) * values[i]
		end
	end;
	---@endsection

	---@section getTable
	---@param self RC_Filter
	---@return table
	getTable = function(self)
		return self.lastValueTable
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
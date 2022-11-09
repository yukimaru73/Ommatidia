

---@class Average 1 Average
---@field length number
---@field stock table
---@field average table
Average = {
	---@param cls Average
	---@param length number
	---@return Average
	new = function(cls, length)
		return LifeBoatAPI.lb_copy(cls, {
			length = length,
			stock = {},
			average = {}
		})
	end;

	---@section update
	---@param self Average
	---@param value table
	update = function(self, value)
		table.insert(self.stock, value)
		if #self.stock > self.length then
			table.remove(self.stock, 1)
		end
		for i = 1, #self.stock do
			for k, v in pairs(self.stock[i]) do
				if self.average[k] == nil then
					self.average[k] = 0
				end
				self.average[k] = self.average[k] + v
			end
		end
		for k, v in pairs(self.average) do
			self.average[k] = v / #self.stock
		end
	end;
	---@endsection

	---@section getAveragedTable
	---@param self Average
	---@return table
	getAveragedTable = function(self)
		return self.average
	end;
	---@endsection

	---@section resetTable
	---@param self Average
	resetTable = function(self)
		self.stock = {}
		self.average = {}
	end;
	---@endsection

	---@section isStockFull
	---@param self Average
	---@return boolean
	isStockFull = function(self)
		return #self.stock == self.length
	end;
}
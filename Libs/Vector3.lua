--require("LifeBoatAPI.Utils.LBCopy")
require("Libs.LBCopy")

---@section Vector3 1 Vector3  {x,y,z}
---@class Vector3
---@field x number
---@field y number
---@field z number
Vector3 = {

	---@param cls Vector3
	---@overload fun(cls:Vector3):Vector3 creates a new zero-initialized Vector3
	---@return Vector3
	new = function(cls, x, y, z)
		return LifeBoatAPI.lb_copy(cls, { x = x or 0, y = y or 0, z = z or 0 })
	end;

	---@section newFromPolar
	---@param cls Vector3
	---@param l number distance
	---@param a number azimuth
	---@param e number elevation
	---@return Vector3
	newFromPolar = function(cls, l, a, e)
		return Vector3:new(l * math.cos(e) * math.cos(a), l * math.sin(e), l * math.cos(e) * math.sin(a))
	end;
	---@endsection


	---@section getVectorTable
	---@param self Vector3
	---@return table
	getVectorTable = function(self)
		return { self.x, self.y, self.z }
	end;
	---@endsection

	---@section setVectorTable
	---@param self Vector3
	---@param t table
	---@return nil
	setVectorTable = function(self, t)
		self.x = t[1]
		self.y = t[2]
		self.z = t[3]
	end;

	---@section getNorm
	---@param self Vector3
	---@return number
	getNorm = function(self)
		local _a = self
		return math.sqrt(_a.x * _a.x + _a.y * _a.y + _a.z * _a.z)
	end;
	---@endsection

	---@section getNormalizedVector
	---@param self Vector3
	---@return Vector3
	getNormalizedVector = function(self)
		local _a = self
		local norm = _a:getNorm()
		return _a:new(_a.x / norm, _a.y / norm, _a.z / norm)
	end;
	---@endsection

	---@section add
	---@param v1 Vector3
	---@param v2 Vector3
	---@return Vector3
	add = function(v1, v2)
		return Vector3:new(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z)
	end;
	---@endsection

	---@section sub
	---@param v1 Vector3
	---@param v2 Vector3
	---@return Vector3
	sub = function(v1, v2)
		return Vector3:new(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z)
	end;
	---@endsection

	---@section getDistanceBetween2Vectors
	---@param v1 Vector3
	---@param v2 Vector3
	---@return number
	getDistanceBetween2Vectors = function(v1, v2)
		return v1:sub(v2):getNorm()
	end;
	---@endsection

}
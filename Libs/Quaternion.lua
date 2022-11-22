require("LifeBoatAPI.Utils.LBCopy")
--require("Libs.LBCopy")

---@section Quaternion 1 Quaternion  {x,y,z; w}
---@class Quaternion
---@field x number
---@field y number
---@field z number
---@field w number
Quaternion = {

	---@param cls Quaternion
	---@overload fun(cls:Quaternion):Quaternion creates a new zero-initialized Quaternion
	---@return Quaternion
	_new = function(cls, x, y, z, w)
		return LifeBoatAPI.lb_copy(cls, { x = x or 0, y = y or 0, z = z or 0, w = w or 0 })
	end;

	---@section getConjugateQuaternion
	---@param self Quaternion
	---@return Quaternion
	getConjugateQuaternion = function(self)
		return self:_new(-self.x, -self.y, -self.z, self.w)
	end;
	---@endsection

	---@section product calculate A⊗B
	---@param self Quaternion A
	---@param target Quaternion B
	---@return Quaternion
	product = function(self, target)
		return self:_new(
			target.x * self.w - target.y * self.z + target.z * self.y + target.w * self.x,
			target.x * self.z + target.y * self.w - target.z * self.x + target.w * self.y,
			-target.x * self.y + target.y * self.x + target.z * self.w + target.w * self.z,
			-target.x * self.x - target.y * self.y - target.z * self.z + target.w * self.w
		)
	end;
	---@endsection

	---@section newRotateQuaternion
	---@param cls Quaternion
	---@param angle number Turn(0 to 1, correspond to 0 to 2π)
	---@param vector table {x, y, z}
	---@return Quaternion
	newRotateQuaternion = function(cls, angle, vector)
		angle = angle / 2
		local sine, norm = math.sin(angle), math.sqrt(vector[1] ^ 2 + vector[2] ^ 2 + vector[3] ^ 2)
		for i = 1, 3 do
			vector[i] = vector[i] / norm
		end
		local r = cls:_new(vector[1], vector[2], vector[3], 0)
		r.x = sine * r.x
		r.y = sine * r.y
		r.z = sine * r.z
		r.w = math.cos(angle)
		return r
	end;
	---@endsection

	---@section rotateVector
	---@param self Quaternion Rotation Quaternion
	---@param vector table Vector3
	---@return table
	rotateVector = function(self, vector)
		local result = {}
		local q = self:product(self:_new(vector[1], vector[2], vector[3], 0):product(self:getConjugateQuaternion()))
		result[1] = q.x
		result[2] = q.y
		result[3] = q.z
		return result
	end;
	---@endsection

	---@section newFromEuler
	---@param cls Quaternion
	---@param pitch number radian
	---@param roll number radian
	---@param yaw number radian
	---@return Quaternion
	newFromEuler = function(cls, pitch, roll, yaw)
		local v, q = {1,0,0}, cls:newRotateQuaternion(yaw, { 0, -1, 0 })--yaw

		v = q:rotateVector({0,0,1})
		q = cls:newRotateQuaternion(pitch,v):product(q)--pitch

		v = q:rotateVector({-1,0,0})
		q = cls:newRotateQuaternion(roll,v):product(q)--roll

		return q
	end
	---@endsection
}
---@endsection
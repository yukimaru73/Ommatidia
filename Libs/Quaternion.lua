require("LifeBoatAPI.Utils.LBCopy")

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
	new = function(cls, x, y, z, w)
		return LifeBoatAPI.lb_copy(cls, { x = x or 0, y = y or 0, z = z or 0, w = w or 0 })
	end;

	---@section getConjugateQuaternion
	---@param self Quaternion
	---@return Quaternion
	getConjugateQuaternion = function(self)
		local q = self
		return q:new(-q.x, -q.y, -q.z, q.w)
	end;
	---@endsection

	---@section product calculate A⊗B
	---@param self Quaternion A
	---@param target Quaternion B
	---@return Quaternion
	product = function(self, target)
		local a = self
		return a:new(
			target.x * a.w - target.y * a.z + target.z * a.y + target.w * a.x,
			target.x * a.z + target.y * a.w - target.z * a.x + target.w * a.y,
			-target.x * a.y + target.y * a.x + target.z * a.w + target.w * a.z,
			-target.x * a.x - target.y * a.y - target.z * a.z + target.w * a.w
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
		local s, norm = math.sin(angle), math.sqrt(vector[1] ^ 2 + vector[2] ^ 2 + vector[3] ^ 2)
		for i = 1, 3 do
			vector[i] = vector[i] / norm
		end
		local r = cls:new(vector[1], vector[2], vector[3], 0)
		r.x = s * r.x
		r.y = s * r.y
		r.z = s * r.z
		r.w = math.cos(angle)
		return r
	end;
	---@endsection

	---@section rotateVector
	---@param self Quaternion Rotation Quaternion
	---@param vector table Vector3
	rotateVector = function(self, vector)
		local result, a = {}, self
		local q = a:product(a:new(vector[1], vector[2], vector[3], 0):product(a:getConjugateQuaternion()))
		result[1] = q.x
		result[2] = q.y
		result[3] = q.z
		return result
	end;
	---@endsection

	---@section createPitchRollYawQuaternion
	---@param cls Quaternion
	---@param pitch number
	---@param roll number
	---@param yaw number
	---@return Quaternion
	createPitchRollYawQuaternion = function(cls, pitch, roll, yaw)
		pitch = 2 * pitch * math.pi
		roll = math.asin(math.sin(2 * roll * math.pi)/math.cos(pitch))
		yaw = -2 * ((yaw + 1.75) % 1 - 0.5) * math.pi
		local v, q = {1,0,0}, cls:newRotateQuaternion(yaw, { 0, 1, 0 })--yaw

		v = q:rotateVector({0,0,1})
		q = cls:newRotateQuaternion(pitch,v):product(q)--pitch

		v = q:rotateVector({1,0,0})
		q = cls:newRotateQuaternion(roll,v):product(q)--roll
		return q
	end
	---@endsection
}

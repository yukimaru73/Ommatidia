require("LifeBoatAPI.Utils.LBCopy")
require("Libs.Quaternion")

---@section Attitude 1 Attitude
---@class Attitude
---@field pitch number
---@field roll number
---@field yaw number
---@field rotation Quaternion
---@field pitchSpeed number
---@field rollSpeed number
---@field yawSpeed number
Attitude = {

	---@section new
	---@param cls Attitude
	---@overload fun(cls:Attitude):Attitude creates a new zero-initialized Attitude
	---@return Attitude
	new = function(cls, pitch, roll, yaw)
		local self = setmetatable({}, cls)
		self.pitch = pitch or 0
		self.roll = roll or 0
		self.yaw = yaw or 0
		self.rotation = Quaternion:_new()
		self.pitchSpeed = 0
		self.tiltLeftSpeed = 0
		self.tiltUpSpeed = 0
		self.compassSpeed = 0
		return self
	end;
	---@endsection

	---@section update
	---@param self Attitude
	---@param tiltFront number
	---@param tiltLeft number
	---@param compass number
	---@param tiltUp number
	update = function(self, tiltFront, tiltLeft, compass, tiltUp)
		local getRotationalSpeed = function(current, past)
			return (current - past + 3 * math.pi / 2) % math.pi - math.pi / 2
		end
		tiltUp = tiltUp or 0.25
		compass = ((compass + 1.75) % 1 - 0.5) * 2 * math.pi
		tiltLeft = 2 * math.pi * tiltLeft
		tiltFront = math.asin(math.sin(2 * math.pi * tiltFront) / math.cos(tiltLeft))
		if tiltUp < 0 then
			if tiltFront > 0 then
				tiltFront = math.pi - tiltFront
			elseif tiltFront < 0 then
				tiltFront = -math.pi - tiltFront
			elseif tiltUp == 0 then
				tiltFront = math.pi / 2
			end
		end
		self.pitchSpeed = getRotationalSpeed(tiltFront, self.pitch)
		self.rollSpeed = getRotationalSpeed(tiltLeft, self.roll)
		self.yawSpeed = getRotationalSpeed(compass, self.yaw)
		self.pitch = tiltFront
		self.roll = tiltLeft
		self.yaw = compass
		self.rotation = Quaternion:newFromEuler(self.pitch, self.roll, self.yaw)
	end;
	---@endsection

	---@section rotateVectorLocalToWorld
	---@param self Attitude
	---@param vector table {x,y,z}
	---@return table {x,y,z}
	rotateVectorLocalToWorld = function(self, vector)
		return self.rotation:rotateVector(vector)
	end;
	---@endsection

	---@section rotateVectorWorldToLocal
	---@param self Attitude
	---@param vector table {x,y,z}
	---@return table {x,y,z}
	rotateVectorWorldToLocal = function(self, vector)
		return self.rotation:getConjugateQuaternion():rotateVector(vector)
	end;
	---@endsection
}

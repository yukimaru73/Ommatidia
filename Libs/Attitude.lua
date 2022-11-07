--require("LifeBoatAPI.Utils.LBCopy")
require("Libs.LBCopy")
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

	---@param cls Attitude
	---@param pitch number
	---@param roll number
	---@param yaw number
	---@overload fun(cls:Attitude):Attitude creates a new zero-initialized Attitude
	---@return Attitude
	new = function(cls, pitch, roll, yaw)
		return LifeBoatAPI.lb_copy(cls, {
			pitch = pitch or 0,
			roll = roll or 0,
			yaw = yaw or 0,
			rotation = Quaternion:_new(pitch or 0, roll or 0, yaw or 0),
			pitchSpeed = 0,
			rollSpeed = 0,
			yawSpeed = 0
		})
	end;

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
		tiltFront = 2 * math.pi * tiltFront
		tiltLeft = math.asin(math.sin(2 * math.pi * tiltLeft)/math.cos(tiltFront))
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

	---@section getFutureAttitude
	---@param self Attitude
	---@param time number
	---@return Attitude
	getFutureAttitude = function(self, time)
		return Attitude:new(self.pitch + self.pitchSpeed * time, self.roll + self.rollSpeed * time, self.yaw + self.yawSpeed * time)
	end;
	---@endsection


}

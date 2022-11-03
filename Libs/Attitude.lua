require("LifeBoatAPI.Utils.LBCopy")
require("Libs.Quaternion")

---@section Attitude 1 Attitude
---@class Attitude
---@field pitch number
---@field roll number
---@field yaw number
---@field pitchSpeed number
---@field rollSpeed number
---@field yawSpeed number
---@field rotation Quaternion
Attitude = {
	---@param cls Attitude
	---@overload fun(cls:Attitude):Attitude creates a new zero-initialized Attitude
	---@return Attitude
	new = function(cls, pitch, roll, yaw)
		return LifeBoatAPI.lb_copy(cls, { pitch = pitch or 0, roll = roll or 0, yaw = yaw or 0, rotation = Quaternion:new() })
	end;

	---@section update
	---@param self Attitude
	---@param tiltFront number 
	---@param tiltLeft number
	---@param tiltUp number
	---@param compass number
	---@return nil
	update = function(self, tiltFront, tiltLeft, tiltUp, compass)

	end;
	---@endsection
}

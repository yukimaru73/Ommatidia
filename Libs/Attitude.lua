require("LifeBoatAPI.Utils.LBCopy")
require("Libs.Quaternion")

---@section Attitude 1 Attitude
---@class Attitude
---@field pitch number
---@field roll number
---@field yaw number
---@field rotation Quaternion
---@field private tiltFrontPast number
---@field private tiltLeftPast number
---@field private tiltUpPast number
---@field private compassPast number
---@field private tiltFrontSpeed number
---@field private tiltLeftSpeed number
---@field private tiltUpSpeed number
---@field private compassSpeed number
Attitude = {
	---@param cls Attitude
	---@overload fun(cls:Attitude):Attitude creates a new zero-initialized Attitude
	---@return Attitude
	new = function(cls, pitch, roll, yaw)
		local self = setmetatable({}, cls)
		self.pitch = pitch or 0
		self.roll = roll or 0
		self.yaw = yaw or 0
		self.rotation = Quaternion:new()
		self.tiltFrontPast = 0
		self.tiltLeftPast = 0
		self.tiltUpPast = 0
		self.compassPast = 0
		self.tiltFrontSpeed = 0
		self.tiltLeftSpeed = 0
		self.tiltUpSpeed = 0
		self.compassSpeed = 0
		return self
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

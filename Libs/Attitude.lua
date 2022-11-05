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
	---@param compass number
	---@param tiltUp number
	---@return nil
	update = function(self, tiltFront, tiltLeft, compass, tiltUp)
		tiltUp = tiltUp or 0
		compass = ((compass + 1.75) % 1 - 0.5) * 2 * math.pi
		tiltLeft = 2 * math.pi * tiltLeft
		tiltFront = math.asin(math.sin(2 * math.pi * tiltFront) / math.cos(tiltLeft))
		if tiltUp < 0 then
			if tiltFront > 0 then
				tiltFront = math.pi - tiltFront
			elseif tiltFront < 0 then
				tiltFront = -math.pi - tiltFront
			elseif tiltUp == 0 then
				tiltFront = math.pi/2
			end
			
		end


	end;
	---@endsection
}

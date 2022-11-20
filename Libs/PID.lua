-- Author: TAK4129
-- GitHub: https://github.com/yukimaru73
-- Workshop: https://steamcommunity.com/profiles/76561198174258594/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey
require("LifeBoatAPI.Utils.LBCopy")

---@section PID 1 PID
---@class PID
---@field Kp number
---@field Ki number
---@field Kd number
---@field iMax number
---@field e0 number
---@field e1 number
---@field int number
---@field dt number
---@field mat table
PID = {
	---@param cls PID
	---@param Kp number
	---@param Ki number
	---@param Kd number
	---@param iMax number
	---@return PID
	new = function(cls, Kp, Ki, Kd, iMax)
		return LifeBoatAPI.lb_copy(cls, { Kp = Kp, Ki = Ki, Kd = Kd, iMax = iMax, e0 = 0, e1 = 0, int = 0, dt = 1 / 60 })
	end;

	---@section update
	---@param value number
	---@param target number
	update = function(self,value,target)
		local a = self
        a.e0 = a.e1
        a.e1 = value - target
        a.int = a.int + (a.e1 + a.e0) / 2 * a.dt
        local p, i, d =
            a.Kp * a.e1,
            a.Ki * a.int,
            a.Kd * (a.e1 - a.e0) / a.dt
        if i > a.iMax then
            a.int = a.iMax / a.Ki
            i = a.iMax
        elseif i < -a.iMax then
            a.int = -a.iMax / a.Ki
            i = -a.iMax
        end
        return p + i + d
	end;
	---@endsection

	---@section reset
	---@param self PID
	reset = function(self)
		self.e0 = 0
		self.int = 0
	end
	---@endsection
}
---@endsection
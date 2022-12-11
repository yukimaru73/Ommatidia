require("LifeBoatAPI.Utils.LBCopy")

---@class Button
---@field Buttons table
Button = {
	Buttons = {};

	---@section new
	---@param cls Button
	---@param id number
	---@param x number
	---@param y number
	---@param size table
	---@param color table
	---@param isToggle boolean
	---@param callback function
	---@return nil
	new = function(cls, id, x, y, size, color, isToggle, callback)
		local borderColor = {}
		for i, v in ipairs(color) do
			borderColor[#borderColor+1] = {v[1]/1.5, v[2]/1.5, v[3]/1.5, v[4]}
		end
		cls.Buttons[#cls.Buttons+1] = LifeBoatAPI.lb_copy(cls, {
			id = id;
			x = x;
			y = y;
			width = size[1];
			height = size[2];
			color = color;
			borderColor = borderColor;
			selectedColor = 1;
			isPressed = false;
			isFirstContact = false;
			isLightOn = false;
			isToggle = isToggle;
			callback = callback;
		})
	end;
	---@endsection

	---@section update_In_onTick
	---@param self Button
	---@param touch_x number
	---@param touch_y number
	---@param isPressed boolean
	---@return nil
	update_In_onTick = function(self, touch_x, touch_y, isPressed)
		for i, v in ipairs(self.Buttons) do
			if isPressed then
				if touch_x >= v.x and
					touch_x <= v.x + v.width and
					touch_y >= v.y and
					touch_y <= v.y + v.height
				then
					if not v.isFirstContact then
						v.isFirstContact = true
						v.isPressed = not v.isPressed
						v.callback()
					end
				else
					v.isFirstContact = false
					if not v.isToggle then
						v.isPressed = false
					end
				end
			else
				v.isFirstContact = false
				if not v.isToggle then
					v.isPressed = false
				end
			end
		end
	end;
	---@endsection

	---@section update_In_onDraw
	---@param self Button
	---@return nil
	update_In_onDraw = function(self)
		for i, v in ipairs(self.Buttons) do
			local button = self.Buttons[i]
			local baseColor, borderColor = button.color[button.color_Number], button.borderColor[button.color_Number]
			if button.isPressed then
				baseColor = button.borderColor[button.color_Number]
				borderColor = button.color[button.color_Number]
			end
			screen.setColor(table.unpack(borderColor))
			screen.drawRectF(button.x, button.y, button.width, button.height)
			screen.setColor(table.unpack(baseColor))
			screen.drawRectF(button.x, button.y, button.width-1, button.height-1)
		end
	end;
	---@endsection

	---@section setColor
	---@param self Button
	---@param id number
	---@param selectedColor number
	---@return nil
	setColor = function(self, id, selectedColor)
		for i, v in ipairs(self.Buttons) do
			if v.id == id then
				v.color_Number = selectedColor
			end
		end
	end;
	---@endsection
	
}
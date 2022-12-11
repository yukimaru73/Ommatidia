require("Libs.Display")

--[[
Button = {
	Buttons = {};
	CurrentButton = nil;

	addNewButton = function(self, id, x, y, size, color, callback)
		Button.Buttons[#Button.Buttons + 1] = {
			id = id,
			x = x,
			y = y,
			width = size[1],
			height = size[2],
			color = color,
			color_Number = 1,
			callback = callback,
			isPushed = false,
			pushedOveride = false,
			isPulse = false,
			isToggle = false
		}
	end;

	setColor = function(id, colorNumber)
		for i = 1, #Button.Buttons do
			if Button.Buttons[i].id == id then
				Button.Buttons[i].color_Number = colorNumber
			end
		end
	end;

	updateIn_onTick = function(self, touch_x, touch_y, touch_down)
		for i = 1, #Button.Buttons do
			if touch_x >= Button.Buttons[i].x and
				touch_x <= Button.Buttons[i].x + Button.Buttons[i].width and
				touch_y >= Button.Buttons[i].y and
				touch_y <= Button.Buttons[i].y + Button.Buttons[i].height and
				touch_down
			then
				if not Button.Buttons[i].isPushed then
					Button.Buttons[i].isPulse = true
				else
					Button.Buttons[i].isPulse = false
				end
				Button.Buttons[i].isPushed = true
			else
				Button.Buttons[i].isPushed = false
				Button.Buttons[i].isPulse = false
			end
			if Button.Buttons[i].isPulse then
				Button.Buttons[i].isToggle = not Button.Buttons[i].isToggle
				Button.CurrentButton = Button.Buttons[i].id
				Button.Buttons[i].callback()
			end
		end
	end;

	updateIn_onDraw = function(self)
		for i = 1, #Button.Buttons do
			local button = Button.Buttons[i]
			local color = button.color[button.color_Number]
			if not(button.isPushed or button.pushedOveride) then
				color = { color[1], color[2], color[3], color[4] / 2 }
			end
			screen.setColor(table.unpack(color))
			screen.drawRectF(button.x, button.y, button.width, button.height)
		end
	end;

}
]]
BASE_COLOR = { 0, 30, 0, 255 }
EQUIP_COLOR = { 30, 180, 30, 255 }
HARDPOINT_SIZE = { 2, 10 }
COLOR = { BASE_COLOR, EQUIP_COLOR }

SELECTED_HARDPOINT = {}
for i = 11, 30 do
	SELECTED_HARDPOINT[i] = false
end

CALLBACK_BAY = function(self)
	if self == nil then
		return
	end
	SELECTED_HARDPOINT[21] = false
	SELECTED_HARDPOINT[self.id] = not SELECTED_HARDPOINT[self.id]
end
CALLBACK_AIM9 = function(self)
	if self == nil then
		return
	end
	for i = 11, 30 do
		if i ~= 21 then
			SELECTED_HARDPOINT[i] = false
		end
	end
	SELECTED_HARDPOINT[self.id] = not SELECTED_HARDPOINT[self.id]
end
BUTTON_LIST = {
	{ 21, 15, 7, {2, 3}, COLOR, CALLBACK_AIM9 },

	{ 11, 6, 10, HARDPOINT_SIZE, COLOR, CALLBACK_BAY },
	{ 13, 9, 9, HARDPOINT_SIZE, COLOR, CALLBACK_BAY },
	{ 15, 12, 10, HARDPOINT_SIZE, COLOR, CALLBACK_BAY },

	{ 16, 18, 10, HARDPOINT_SIZE, COLOR, CALLBACK_BAY },
	{ 14, 21, 9, HARDPOINT_SIZE, COLOR, CALLBACK_BAY },
	{ 12, 24, 10, HARDPOINT_SIZE, COLOR, CALLBACK_BAY },
}
for i, v in ipairs(BUTTON_LIST) do
	Button:new(v[1], v[2], v[3], v[4], v[5], true, v[6])
end

TRIGGER = false
FIRE = false
FIRE_HARDPOINT = 0

function onTick()
	FIRE_HARDPOINT = 0
	for i, v in ipairs(Button.Buttons) do
		if input.getNumber(v.id) ~= 0 or v.id == 21  then
			Button:setColor(v.id, 2)
		else
			Button:setColor(v.id, 1)
		end
		if SELECTED_HARDPOINT[v.id] then
			v.isLightOn = true
		else
			v.isLightOn = false
		end
	end

	Button:update_In_onTick(input.getNumber(3), input.getNumber(4), input.getBool(1))

	if input.getBool(10) then
		if TRIGGER then
			FIRE = true
		else
			FIRE = false
		end
		TRIGGER = true
	else
		TRIGGER = false
	end
	if SELECTED_HARDPOINT[21] then
		FIRE_HARDPOINT = 21
	else
		for i = 11, 30 do
			if SELECTED_HARDPOINT[i] and input.getNumber(i)~=0 then
				FIRE_HARDPOINT = i
				break
			end
		end
	end
	output.setBool(1, FIRE)
	output.setNumber(1, FIRE_HARDPOINT)
end

function onDraw()
	Button:update_In_onDraw()
	screen.setColor(30, 255, 30, 255)
	local text = ""
	if SELECTED_HARDPOINT[21] then
		text = "9X"
	else
		for i = 11, 30 do
			if SELECTED_HARDPOINT[i] then
				text = "MSL"
				break
			end
		end
	end
	screen.drawText(1,1,text)
end

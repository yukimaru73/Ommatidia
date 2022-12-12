--[[
PI_HALF = math.pi/2
PI_2 = math.pi*2

function sin(theta)
	theta = (theta+PI_2)%PI_2
	if theta > math.pi then
		theta = math.pi - theta
	end
	if theta > PI_HALF then
		theta = math.pi - theta
	end
	local theta_2 = theta * theta
	local sum, t = theta,theta
	for i = 1, 6 do
		t = -t*theta_2/(2*i*(2*i+1))
		sum = sum + t
	end
	return sum
end

PI_HALF = math.pi/2
debug.log("$$ START")
for i = 1, 100000 do
	local x = math.random()*math.pi*2
	local y = math.sin(x)
	local z = math.sqrt(1-x*x)
end

debug.log("$$ END")
]]
a = {}
a[1] = 1
a[20] = 2
a[30] = 3
for i, v in pairs(a) do
	print(v)
end
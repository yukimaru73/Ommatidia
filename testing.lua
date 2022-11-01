function bitBool2Num()
	local sign, exp, mantissa = input.getBool(32) and -1 or 1, 0, 0
	for i = 1, 8 do
		exp = exp + (input.getBool(32 - i) and 1 or 0) * (1 << (8 - i))
	end
	for i = 1, 23 do
		mantissa = mantissa + (input.getBool(24 - i) and 1 or 0) * 2 ^ (-i)
	end
	return sign * 2 ^ (exp - 127) * (1 + mantissa)
end

function bitBool2NumNoSign()
	local exp, mantissa = 0, 0
	for i = 1, 8 do
		exp = exp + (input.getBool(32 - i) and 1 or 0) * 2 ^ (8 - i)
	end
	for i = 1, 23 do
		mantissa = mantissa + (input.getBool(24 - i) and 1 or 0) * 2 ^ (-i)
	end
	return 2 ^ (exp - 127) * (1 + mantissa)
end

function bitBool2Numv2()
	local sign, exp, mantissa = input.getBool(32) and -1 or 1, 0, 0
	for i = 1, 8 do
		exp = exp << 1 | input.getBool(32 - i) and 1 or 0
	end
	for i = 1, 23 do
		mantissa = mantissa + (input.getBool(24 - i) and 1 or 0) * 2 ^ (-i)
	end
	return sign * 2 ^ (exp - 127) * (1 + mantissa)
end

function bitBool2Numv2NoSign()
	local exp, mantissa = 0, 0
	for i = 1, 8 do
		exp = (exp << 1) | (input.getBool(32 - i) and 1 or 0)
	end
	for i = 1, 23 do
		mantissa = mantissa + (input.getBool(24 - i) and 1 or 0) * 2 ^ (-i)
	end
	return 2 ^ (exp - 127) * (1 + mantissa)
end

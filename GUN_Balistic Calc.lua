require("Libs.LightMatrix")

---@section FJ 1 FJ
---@param mf LMatrix
---@param mj LMatrix
---@param gX number
---@param gY number
---@param gZ number
---@param tX number
---@param tY number
---@param tZ number
---@param Vx number
---@param Vy number
---@param Vz number
---@param V0 number
---@param d number
---@param L number
---@param pt number
---@param pth number
---@param pp number
---@return LMatrix,LMatrix
function FJ(gX, gY, gZ, tX, tY, tZ, Vx, Vy, Vz, V0, d, L, pt, pth, pp, mf, mj)
	local d1 = 1 - d
	local logD60, dpt1, ptL, sth, cth, sp, cp = 60 * math.log(d1), d1 ^ pt - 1, pt + L, math.sin(pth), math.cos(pth), math.sin(pp), math.cos(pp)
	mf:set(1, 1, ((tY - gY) + Vy * ptL) - (V0 * sth + .5 / d) * dpt1 / logD60 + pt / 120 / d)
	mf:set(2, 1, ((tX - gX) + Vx * ptL) - V0 * cth * cp * dpt1 / logD60)
	mf:set(3, 1, ((tZ - gZ) + Vz * ptL) - V0 * cth * sp * dpt1 / logD60)

	mj:set(1, 1, Vy - (d1 ^ pt * (V0 * sth + 0.5 / d)) / 60 + 1 / 120 / d)
	mj:set(1, 2, -(V0 * dpt1 * cth) / logD60)
	mj:set(2, 1, Vx - (V0 * d1 ^ pt * cth * cp) / 60)
	mj:set(2, 2, (V0 * dpt1 * sth * cp) / logD60)
	mj:set(2, 3, (V0 * dpt1 * cth * sp) / logD60)
	mj:set(3, 1, Vz - (V0 * d1 ^ pt * cth * sp) / 60)
	mj:set(3, 2, (V0 * dpt1 * sth * sp) / logD60)
	mj:set(3, 3, -(V0 * dpt1 * cth * cp) / logD60)
	return mf, mj
end

---@endsection

---@section Balistic 1 Balistic
---@param x LMatrix
---@param gX number
---@param gY number
---@param gZ number
---@param tX number
---@param tY number
---@param tZ number
---@param Vx number
---@param Vy number
---@param Vz number
---@param V0 number
---@param d number
---@param L number
---@param dt number
---@param im number
---@param em number
function Balistic(gX, gY, gZ, tX, tY, tZ, Vx, Vy, Vz, V0, d, L, dt, im, em)
	local p0, v0, f = LMatrix:new(3, 1), LMatrix:new(3, 1), false
	local pt = math.sqrt((tX - gX) ^ 2 + (tY - gY) ^ 2 + (tZ - gZ) ^ 2) / (V0 / 60)
	v0:set(1, 1, pt)
	v0:set(2, 1, math.atan(tY - gY + Vy * pt, math.sqrt((tX - gX + Vx * pt) ^ 2 + (tZ - gZ + Vz * pt) ^ 2)))
	v0:set(3, 1, math.atan(tZ - gZ + Vz * pt,tX - gX + Vx * pt))
	local F0, J0 = LMatrix:new(3, 1), LMatrix:new(3, 3)
	for i = 1, im do
		F0, J0 = FJ(gX, gY, gZ, tX, tY, tZ, Vx, Vy, Vz, V0, d, L, v0:get(1, 1), v0:get(2, 1), v0:get(3, 1), F0, J0)
		local er = 0
		er = F0:norm()
		if er < em then
			f = true
			break
		end

		local Q, R = J0:transpose():qr()
		local srcp = p0:mul(-2):sub(R:transpose():solve(F0))
		local srcx = Q:dot(p0)
		v0, p0 = v0:add(srcx:mul(dt)), p0:add(srcp:mul(dt))
	end
	return v0, f
end
---@endsection

VALMAT, TICK, ELEV, AZIM, FLAG = LMatrix:new(3,1), 0, 0, 0, false
SOLVED = false
function onTick()
	if not input.getBool(1) then
		FLAG = false
	else
		--debug.log("TST:-> Calculate X: "..input.getNumber(4).." Y: "..input.getNumber(5).." Z: "..input.getNumber(6))
		VALMAT, FLAG = Balistic(
			input.getNumber(1),
			input.getNumber(2),
			input.getNumber(3),
			input.getNumber(4),
			input.getNumber(5),
			input.getNumber(6),
			input.getNumber(7),
			input.getNumber(8),
			input.getNumber(9),
			property.getNumber("Muzzle Velocity"),
			property.getNumber("Air Resistance"),
			17,--timelag
			0.7,
			30,
			0.01
		)
	end
	if VALMAT:get(1, 1) > 0 and FLAG then
		TICK, ELEV, AZIM = VALMAT:get(1, 1), VALMAT:get(2, 1), VALMAT:get(3, 1)
		SOLVED = true
		--debug.log("TST:-> TICK: " .. TICK .. " ELEV: " .. 180*ELEV/math.pi .. " AZIM: " .. 180*AZIM/math.pi)
	else
		SOLVED = false
	end
	output.setNumber(1, TICK)
	output.setNumber(2, ELEV)
	output.setNumber(3, AZIM)

	output.setBool(1, SOLVED)

	for i = 1, 4 do
		output.setNumber(i+3,input.getNumber(i+9))
	end

end
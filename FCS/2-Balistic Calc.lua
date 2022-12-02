require("Libs.LightMatrix")

BALISTIC_NUMBERS = {
	{ 1000, 0.02, 0.5, 300}, --light auto cannon
	{ 1000, 0.01, 0.7, 300}, --rotary auto cannon
	{ 900, 0.005, 0.85, 600}, --heavy auto cannon
	{ 800, 0.002, 0.9, 3600}, --battle cannon
	{ 700, 0.001, 0.9, 3600}, --artillery cannon
	{ 600, 0.0005, 0.9, 3600} --bertha cannon
}


ADDITIONAL_DATA_LAG = property.getNumber("Additional Data Lag")
BALISTIC_NUMBER = BALISTIC_NUMBERS[property.getNumber("Gun Type")]

D1 = 1 - BALISTIC_NUMBER[2]
LOG_D60 = 60 * math.log(D1)

---calculate bullet position at the time and which jacobian matrix to use
---@section FJ 1 FJ
---@param mf LMatrix
---@param mj LMatrix
---@param dX number
---@param dY number
---@param dZ number
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
function FJ(dX, dY, dZ, bVx, bVy, bVz, Vx, Vy, Vz, V0, d, L, pt, pth, pp, mf, mj)
	local dpt1, ptL, sth, cth, sp, cp = D1 ^ pt - 1, pt + L, math.sin(pth), math.cos(pth), math.sin(pp), math.cos(pp)
	local V0dpt1 = V0 * dpt1
	local V0dpt1SLOG_D60 = V0dpt1 / LOG_D60
	mf:set(1, 1, (dY + Vy * ptL) - (bVy + V0 * sth + .5 / d) * dpt1 / LOG_D60 + pt / (120 * d))
	mf:set(2, 1, (dX + Vx * ptL) - (bVx + V0dpt1 * cth * cp) / LOG_D60)
	mf:set(3, 1, (dZ + Vz * ptL) - (bVz + V0dpt1 * cth * sp) / LOG_D60)

	mj:set(1, 1, Vy - (D1 ^ pt * (bVy + V0 * sth + 0.5 / d)) / 60 + 1 / (120 * d))
	mj:set(1, 2, -cth * V0dpt1SLOG_D60)
	mj:set(2, 1, Vx - (V0 * D1 ^ pt * cth * cp) / 60)
	mj:set(2, 2, sth * cp * V0dpt1SLOG_D60)
	mj:set(2, 3, cth * sp * V0dpt1SLOG_D60)
	mj:set(3, 1, Vz - (V0 * D1 ^ pt * cth * sp) / 60)
	mj:set(3, 2, sth * sp * V0dpt1SLOG_D60)
	mj:set(3, 3, -cth * cp * V0dpt1SLOG_D60)
	return mf, mj
end

---@endsection

---Balistic Solver using W4LH method
---W4 method documentation: https://hir0ok.github.io/w4/index.html
---@section Balistic 1 Balistic
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
---@param v LMatrix
---@param continuous boolean
---@return LMatrix, boolean
function Balistic(gX, gY, gZ, tX, tY, tZ, bVx, bVy, bVz, Vx, Vy, Vz, V0, d, L, dt, im, em, v, continuous)
	local p0, v0, f = LMatrix:new(3, 1), LMatrix:new(3, 1), false
	local dx, dy, dz = tX - gX, tY - gY, tZ - gZ
	if continuous then
		v0 = v
	else
		local pt = math.sqrt(dx * dx + dy * dy + dz * dz) / (V0 / 60)
		v0:set(1, 1, pt)
		v0:set(2, 1, math.atan(dy + Vy * pt, math.sqrt((dx + Vx * pt) * (dx + Vx * pt) + (dz + Vz * pt) * (dz + Vz * pt))))
		v0:set(3, 1, math.atan(dz + Vz * pt, dx + Vx * pt))
	end
	local F0, J0 = LMatrix:new(3, 1), LMatrix:new(3, 3)
	for i = 1, im do
		F0, J0 = FJ(dx, dy, dz, bVx, bVy, bVz, Vx, Vy, Vz, V0, d, L, v0:get(1, 1), v0:get(2, 1), v0:get(3, 1), F0, J0)
		local er = 0
		er = F0:get(1, 1)
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

VALMAT, TICK, ELEV, AZIM, FLAG, CONTINUOUS = LMatrix:new(3, 1), 0, 0, 0, false, false
SOLVED = false
function onTick()
	SOLVED, CONTINUOUS = false, false
	if not input.getBool(1) then
		FLAG = false
	else
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
			input.getNumber(10),
			input.getNumber(11),
			input.getNumber(12),
			BALISTIC_NUMBER[1],
			BALISTIC_NUMBER[2],
			input.getNumber(20) + 5 + ADDITIONAL_DATA_LAG, --timelag
			BALISTIC_NUMBER[3],
			20,
			0.06,
			VALMAT,
			CONTINUOUS
		)
	end
	if VALMAT:get(1, 1) > 0 and VALMAT:get(1, 1) < BALISTIC_NUMBER[4] and FLAG then
		TICK, ELEV, AZIM = VALMAT:get(1, 1), VALMAT:get(2, 1), VALMAT:get(3, 1)
		SOLVED, CONTINUOUS = true, true
	end
	output.setNumber(1, TICK)
	output.setNumber(2, ELEV)
	output.setNumber(3, AZIM)
	output.setNumber(4, input.getNumber(17))

	output.setBool(1, SOLVED)

	for i = 1, 4 do
		output.setNumber(i + 12, input.getNumber(i + 12))
	end

end

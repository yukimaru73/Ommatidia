require("Libs.LightMatrix")

BALISTIC_NUMBERS = {
	{ 1000, 0.02, 0.3, 300}, --light auto cannon
	{ 1000, 0.01, 0.3, 300}, --rotary auto cannon
	{ 900, 0.005, 0.3, 600}, --heavy auto cannon
	{ 800, 0.002, 0.3, 3600}, --battle cannon
	{ 700, 0.001, 0.3, 3600}, --artillery cannon
	{ 600, 0.0005, 0.3, 3600} --bertha cannon
}


ADDITIONAL_DATA_LAG = property.getNumber("Additional Data Lag")
BALISTIC_NUMBER = BALISTIC_NUMBERS[property.getNumber("Gun Type")]

VEL = BALISTIC_NUMBER[1]/60
D1 = 1 - BALISTIC_NUMBER[2]
LOG_D=math.log(D1)
G = 30 /(60^2)

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
---@param D number
---@param L number
---@param pt number
---@param pth number
---@param pp number
---@return LMatrix,LMatrix
function FJ(dX, dY, dZ, bVx, bVy, bVz, Vx, Vy, Vz, V0, D, L, pt, pth, pp, mf, mj)
	local ptL, sth, sp = pt+L, math.sin(pth), math.sin(pp)
	local dpt1, cth, cp = D1^ptL-1, math.sqrt(1-sth*sth), math.sqrt(1-sp*sp)
	local dpt1_l1d = dpt1/math.log(D1)

	mf:set(1, 1, dY + Vy*ptL - (bVy + V0*sth + G/D)*dpt1_l1d + G*ptL/D)
	mf:set(2, 1, dX + Vx*ptL - (bVx + V0*cp*cth)*dpt1_l1d)
	mf:set(3, 1, dZ + Vz*ptL - (bVz + V0*sp*cth)*dpt1_l1d)

	mj:set(1, 1, Vy - dpt1*(bVy + V0*sth + G/D) + G/D)
	mj:set(1, 2, -V0*cth*dpt1_l1d)
	mj:set(1, 3, 0)

	mj:set(2, 1, Vx - dpt1*(bVx + V0*cp*cth))
	mj:set(2, 2, V0*sth*cp*dpt1_l1d)
	mj:set(2, 3, V0*sp*cth*dpt1_l1d)

	mj:set(3, 1, Vz - dpt1*(bVz + V0*sp*cth))
	mj:set(3, 2, V0*sp*sth*dpt1_l1d)
	mj:set(3, 3, -V0*cp*cth*dpt1_l1d)
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
		local pt = math.sqrt(dx * dx + dy * dy + dz * dz) / V0
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
	if f then
		debug.log("$$=> TICK:,"..v0:get(1,1)..", ELEV:,".. 180*v0:get(2,1)/math.pi..", AZIM:,".. 180*v0:get(3,1)/math.pi..",")
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
			VEL,
			BALISTIC_NUMBER[2],
			input.getNumber(20) + 5 + ADDITIONAL_DATA_LAG, --timelag
			BALISTIC_NUMBER[3],
			20,
			0.01,
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

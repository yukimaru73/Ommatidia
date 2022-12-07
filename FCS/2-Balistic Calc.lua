require("Libs.LightMatrix")

BALISTIC_NUMBERS = {
	{ 1000, 0.02, 0.7, 300 }, --light auto cannon
	{ 1000, 0.01, 0.7, 300 }, --rotary auto cannon
	{ 900, 0.005, 0.7, 600 }, --heavy auto cannon
	{ 800, 0.002, 0.7, 3600 }, --battle cannon
	{ 700, 0.001, 0.7, 3600 }, --artillery cannon
	{ 600, 0.0005, 0.7, 3600 } --bertha cannon
}


ADDITIONAL_DATA_LAG = property.getNumber("Additional Data Lag")
BALISTIC_NUMBER = BALISTIC_NUMBERS[property.getNumber("Gun Type")]

VEL = BALISTIC_NUMBER[1] / 60
D = BALISTIC_NUMBER[2]
D1 = 1 - BALISTIC_NUMBER[2]
DIV_LOG_D = 1/math.log(D1)
G = 30 / (60 ^ 2)
PI_HALF = math.pi / 2

---calculate target-bullet position at the time and which jacobian matrix to use
---@section FJ 1 FJ
---@param mf LMatrix
---@param mj LMatrix
---@param dX number
---@param dY number
---@param dZ number
---@param Vx number
---@param Vy number
---@param Vz number
---@param L number
---@param pt number
---@param pth number
---@param pp number
---@return LMatrix,LMatrix
function FJ(dX, dY, dZ, bVx, bVy, bVz, Vx, Vy, Vz, L, pt, pth, pp, mf, mj)
	local ptL, sth, sp, cth, cp, D1T = pt + L, math.sin(pth), math.sin(pp), math.cos(pth), math.cos(pp) , D1 ^ pt
	local GD, D1T1LD1 = G / D, (D1T - 1) * DIV_LOG_D

	mf:set(1, 1, dY + Vy * ptL - (bVy + VEL * sth + GD) * D1T1LD1 + GD * pt)
	mf:set(2, 1, dX + Vx * ptL - (bVx + VEL * cp * cth) * D1T1LD1)
	mf:set(3, 1, dZ + Vz * ptL - (bVz + VEL * sp * cth) * D1T1LD1)

	mj:set(1, 1, Vy - D1T * (bVy + VEL * sth + GD) + GD)
	mj:set(1, 2, -VEL * cth * D1T1LD1)
	mj:set(1, 3, 0)

	mj:set(2, 1, Vx - D1T * (bVx + VEL * cp * cth))
	mj:set(2, 2, VEL * sth * cp * D1T1LD1)
	mj:set(2, 3, VEL * sp * cth * D1T1LD1)

	mj:set(3, 1, Vz - D1T * (bVz + VEL * sp * cth))
	mj:set(3, 2, VEL * sp * sth * D1T1LD1)
	mj:set(3, 3, -VEL * cp * cth * D1T1LD1)
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
---@param L number
---@param dt number
---@param im number
---@param em number
---@param v LMatrix
---@param continuous boolean
---@return LMatrix, boolean
function Balistic(gX, gY, gZ, tX, tY, tZ, bVx, bVy, bVz, Vx, Vy, Vz, L, dt, im, em, v, continuous)
	local p0, v0, f = LMatrix:new(3, 1), LMatrix:new(3, 1), false
	local dx, dy, dz = tX - gX, tY - gY, tZ - gZ
	if continuous then
		v0 = v
	else
		local pt = math.sqrt(dx * dx + dy * dy + dz * dz) / VEL
		local ddx, ddy, ddz = dx + Vx * pt, dy + Vy * pt, dz + Vz * pt
		v0:set(1, 1, pt)
		v0:set(2, 1, math.atan(ddy, math.sqrt(ddx * ddx + ddz * ddz)))
		v0:set(3, 1, (math.atan(ddz, ddx) + math.pi*2)%(math.pi*2))
	end
	local F0, J0, ii = LMatrix:new(3, 1), LMatrix:new(3, 3), 0
	for i = 1, im do
		F0, J0 = FJ(dx, dy, dz, bVx, bVy, bVz, Vx, Vy, Vz, L, v0:get(1, 1), v0:get(2, 1), v0:get(3, 1), F0, J0)
		local er = 0
		for j = 1, 3 do
			er = math.max(er, math.abs(F0:get(j, 1)))
		end
		if er < em and v0:get(1,1)>0 then
			f = true
			ii = i
			break
		end

		local Q, R = J0:transpose():qr()
		local srcp = p0:mul(-2):add(R:transpose():solve(F0),-1)
		local srcx = Q:dot(p0)
		v0, p0 = v0:add(srcx:mul(dt)), p0:add(srcp:mul(dt))
	end
	if f then
		debug.log("$$: ".. ii)
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
			input.getNumber(1), --self X
			input.getNumber(2), --self Y
			input.getNumber(3), --self Z
			input.getNumber(4), --target X
			input.getNumber(5), --target Y
			input.getNumber(6), --target Z
			input.getNumber(7), --additional bullet speed X
			input.getNumber(8), --additional bullet speed Y
			input.getNumber(9), --additional bullet speed Z
			input.getNumber(10), --target speed X
			input.getNumber(11), --target speed Y
			input.getNumber(12), --target speed Z
			input.getNumber(20) + 5 + ADDITIONAL_DATA_LAG, --timelag
			BALISTIC_NUMBER[3], --delta tau
			20, --max iteration
			0.01, --min error
			VALMAT,
			CONTINUOUS --is continuous
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

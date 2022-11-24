bc = false
aV = tonumber
aE = nil
aK = table
as = pairs
C = math
aD = property
aS = input
bd = output
J = bd.setNumber
aN = aS.getBool
d = aS.getNumber
aH = aD.getText
aI = aD.getNumber
bh = C.atan
l = C.pi
M = C.cos
aj = C.sqrt
ah = C.sin
D = D or {}
D.K = function(bl, P, bw) P = P or {}
	for s, n in as(bl) do
		P[s] = not bw and P[s] or n
	end
	return P
end;
bi = { X = function(f, g, j, h, i) return D.K(f, { g = g or 0, j = j or 0, h = h or 0, i = i or 0 }) end;
	aT = function(_) return _:X(-_.g, -_.j, -_.h, _.i) end;
	ac = function(_, e) return _:X(e.g * _.i - e.j * _.h + e.h * _.j + e.i * _.g, e.g * _.h + e.j * _.i - e.h * _.g +
		e.i * _.j, -e.g * _.j + e.j * _.g + e.h * _.i + e.i * _.h, -e.g * _.g - e.j * _.j - e.h * _.h + e.i * _.i) end;
	aB = function(f, T, c) T = T / 2
		local au, bo = ah(T), aj(c[1] ^ 2 + c[2] ^ 2 + c[3] ^ 2)
		for a = 1, 3 do
			c[a] = c[a] / bo
		end
		local z = f:X(c[1], c[2], c[3], 0)
		z.g = au * z.g
		z.j = au * z.j
		z.h = au * z.h
		z.i = M(T)
		return z
	end;
	S = function(_, c) local Y = {}
		local m = _:ac(_:X(c[1], c[2], c[3], 0):ac(_:aT()))
		Y[1] = m.g
		Y[2] = m.j
		Y[3] = m.h
		return Y
	end;
	aR = function(f, t, p, q) local n, m = { 1, 0, 0 }, f:aB(q, { 0, -1, 0 })
	n = m:S({ 0, 0, 1 })
	m = f:aB(t, n):ac(m)
	n = m:S({ -1, 0, 0 })
	m = f:aB(p, n):ac(m)
	return m
	end }
ao = { r = function(f, t, p, q) return D.K(f, { t = t or 0, p = p or 0, q = q or 0, av = bi:aR(t or 0, p or 0, q or 0),
	aC = 0, aW = 0, be = 0 }) end;
	w = function(_, k, af, ai, ab) ab = ab or .25
		ai = ((ai + 1.75) % 1 - .5) * 2 * l
		k = 2 * l * k
		af = C.asin(ah(2 * l * af) / M(k))
		if ab < 0 then
			if k > 0 then
				k = l - k
			elseif k < 0 then
				k = -l - k
			elseif ab == 0 then
				k = l / 2
			end
		end
		_.aC = k - _.t
		_.aW = af - _.p
		_.be = (ai - _.q + 3 * l) % (2 * l) - l
		_.t = k
		_.p = af
		_.q = ai
		_.av = bi:aR(_.t, _.p, _.q)
	end;
	at = function(_, c) return _.av:S(c) end;
	bg = function(_, c) return _.av:aT():S(c) end;
	aP = function(_, al) return ao:r(_.t + _.aC * al, _.p + _.aW * al, _.q + _.be * al) end }
bv = { r = function(f, aw, H, ar, u) return D.K(f, { aw = aw, H = H, ar = ar, u = u, ag = 0, L = 0, G = 0, aZ = 1 / 60 }) end;
	w = function(_, o, e) local b = _
		b.ag = b.L
		b.L = o - e
		b.G = b.G + (b.L + b.ag) / 2 * b.aZ
		local bu, a, bn = b.aw * b.L, b.H * b.G, b.ar * (b.L - b.ag) / b.aZ
		if a > b.u then
			b.G = b.u / b.H
			a = b.u
		elseif a < -b.u then
			b.G = -b.u / b.H
			a = -b.u
		end
		return bu + a + bn
	end;
	aU = function(_) _.ag = 0
		_.G = 0
	end }
bp = { r = function(f, ap, an) local b = {}
	for a = 1, an do
		b[a] = 0
	end
	return D.K(f, { ap = ap, E = {}, x = b })
end;
	w = function(_, o) aK.insert(_.E, o)
		if #_.E > _.ap then
			aK.remove(_.E, 1)
		end
		_.x = {}
		for a = 1, #_.E do
			for s, n in as(_.E[a]) do
				if _.x[s] == aE then
					_.x[s] = 0
				end
				_.x[s] = _.x[s] + n
			end
		end
		for s, n in as(_.x) do
			_.x[s] = n / #_.E
		end
	end;
	aA = function(_) return _.x
	end;
	bt = function(_) _.E = {} end }
bm = { r = function(f, Z, an) local I = {}
	I.Z = Z
	I.ae = 0
	I.F = {}
	for a = 1, an do
		I.F[a] = 0
	end
	return D.K(f, I)
end;
	w = function(_, aY) _.ae = _.ae + 1
		for a = 1, #aY do
			_.F[a] = _.Z * _.F[a] + (1 - _.Z) * aY[a]
		end
	end;
	aL = function(_) return _.F
	end;
	aU = function(_) _.ae = 0
		for a = 1, #_.F do
			_.F[a] = 0
		end
	end }
function ba(bk) local ax = {}
	for i in string.gmatch(bk, "[-0-9.]+") do
		local aQ = aV(i)
		if aQ ~= aE then
			ax[#ax + 1] = aV(aQ)
		end
	end
	return ax
end

function aG(o, max, min) if o < min then
		o = min
	elseif o > max then
		o = max
	end
	return o
end

function b_(c) local aM, aF
	aM = bh(c[3], c[1])
	aF = bh(c[2], aj(c[1] ^ 2 + c[3] ^ 2))
	return aM, aF
end

ay = aI("Position Averaging Tick")
R = 10
bs = ba(aH("GPS Position Diff"))
by = ba(aH("Altitude Position Diff"))
Q = ao:r(0, 0, 0)
bj = ao:r(0, 0, 0)
A = { 0, 0, 0 }
ak = { 0, 0, 0 }
O = bp:r(ay * 2 + 1, 3)
N = bm:r(.965, 3)
aa = { 0, 0, 0 }
aX = { 0, 0, 0 }
U = bc
y = 0
v = 0
br = bv:r(7, .007, .2, .05)
ad = aI("Rotate Sensitivity") * .0001
function onTick() local V, am, bb = { 0, 0, 0 }, { 0, 0, 0 }, { 0, 0, 0 }
	A = { d(1), d(2), d(3) }
	local W, bf = aj(A[1] ^ 2 + A[2] ^ 2 + A[3] ^ 2), d(17)
	if (bf ~= 4000) and (C.abs(W - bf + 2) < 8) then
		local b, aq = b_(A)
		A = { W * M(aq) * M(b), W * ah(aq), W * M(aq) * ah(b) }
	end
	Q:w(d(4), d(5), d(6))
	bj:w(d(7), d(8), d(9), d(10))
	local aO, bx, B = Q:at(bs), Q:at(by), { d(11), d(12), d(13) }
	local bq = { B[1] - aO[1], B[2] - bx[2], B[3] - aO[3] }
	aX = { B[1] - aa[1], B[2] - aa[2], B[3] - aa[3] }
	if aN(1) and aN(2) then
		local az = { 0, 0, 0 }
		V = bj:at(A)
		O:w(V)
		local aJ = O:aA()
		if U then
			for a = 1, 3 do
				bb[a] = V[a] + aX[a] - ak[a]
			end
			N:w(bb)
			for a = 1, 3 do
				if N.ae > 20 then
					am[a] = aJ[a] + N:aL()[a] * (R + ay)
				else
					am[a] = aJ[a]
				end
			end
			az = Q:aP(R):bg(am)
		else
			az = Q:aP(R):bg(O:aA())
		end
		v, y = b_(az)
		v, y = v / l / 2, 2 * y / l
		ak = V
		U = true
	else
		ak = { 0, 0, 0 }
		O:bt()
		N:aU()
		if d(15) == -1 then
			v = v + ad
		elseif d(15) == 1 then
			v = v - ad
		end
		if d(16) == 1 then
			y = aG(y + ad, 1, -1)
		elseif d(16) == -1 then
			y = aG(y - ad, 1, -1)
		end
		U = bc
	end
	aa = B
	for a = 1, 3 do
		J(a + 3, bq[a] + O:aA()[a])
		J(a + 9, N:aL()[a])
	end
	J(20, ay + R)
	bd.setBool(1, U)
	J(31, y)
	J(32, br:w((v - d(14) + 1.5) % 1 - .5, 0))
end

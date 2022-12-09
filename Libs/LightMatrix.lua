---@section LIGHTMATRIXBOILERPLATE
-- Author: TAK4129
-- GitHub: https://github.com/yukimaru73
-- Workshop: https://steamcommunity.com/profiles/76561198174258594/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
---@endsection

require("LifeBoatAPI.Utils.LBCopy")

---@section LMatrix 1 LMATRIX
---@class LMatrix
---@field row number
---@field col number
---@field mat table
LMatrix = {

	---@section new
	---@param cls LMatrix
	---@param row number row of matrix
	---@param col number column of matrix
	---@return LMatrix
	new = function(cls, row, col)
		local matmat = {}
		for i = 1, row do
			matmat[i] = {}
			for j = 1, col do
				matmat[i][j] = 0
			end
		end
		return LifeBoatAPI.lb_copy(cls, { row = row, col = col, mat = matmat })
	end;
	---@endsection
	
	---@section newFromTable
	---@param cls LMatrix
	---@param array table
	---@return LMatrix
	newFromTable = function(cls, array)
		local row, col, matmat = #array, #array[1], {}
		for i = 1, row do
			matmat[i] = {}
			for j = 1, col do
				matmat[i][j] = array[i][j]
			end
		end
		return LifeBoatAPI.lb_copy(cls, { row = row, col = col, mat = matmat })
	end;
	---@endsection
	
	---@section newDiagMatrix
	---@param cls LMatrix
	---@param array table
	---@return LMatrix
	newDiagMatrix = function(cls, array)
		local n = #array
		local mat = LMatrix:new(n, n)
		for i = 1, n do
			mat:set(i, i, array[i])
		end
		return mat
	end;
	---@endsection
	
	---@section get
	---@param self LMatrix
	---@param row number
	---@param col number
	---@return number
	get = function(self, row, col)
		return self.mat[row][col]
	end;
	---@endsection

	---@section set
	---@param self LMatrix
	---@param row number
	---@param col number
	---@param value number
	set = function(self, row, col, value)
		self.mat[row][col] = value
	end;
	---@endsection

	---@section eye
	---@param self LMatrix
	---@return LMatrix
	eye = function(self)
		for i = 1, self.row do
			self:set(i, i, 1)
		end
		return self
	end;
	---@endsection

	---@section copy
	---@param self LMatrix
	copy = function(self)
		local m = LMatrix:new(self.row, self.col)
		for i = 1, self.row do
			for j = 1, self.col do
				m:set(i, j, self:get(i, j))
			end
		end
		return m
	end;
	---@endsection

	---@section add
	--- Calculate addition of 2 matrix. Both Matrix are must be same shape.
	---@param self LMatrix
	---@param mat LMatrix
	---@param scalar number
	---@return LMatrix
	---@overload fun(self:LMatrix, mat:LMatrix):LMatrix
	add = function(self, mat,scalar)
		scalar = scalar or 1
		local amat = LMatrix:new(self.row, self.col)
		for ir = 1, self.row do
			for ic = 1, self.col do
				amat:set(ir, ic, self:get(ir, ic) + mat:get(ir, ic)*scalar)
			end
		end
		return amat
	end;
	---@endsection

	---@section sub
	--- Calculate subtraction of 2 matrix. Both Matrix are must be same shape.
	---@param self LMatrix
	---@param mat LMatrix
	---@return LMatrix
	sub = function(self, mat)
		local a = self
		local amat = LMatrix:new(a.row, a.col)
		for ir = 1, a.row do
			for ic = 1, a.col do
				amat:set(ir, ic, a:get(ir, ic) - mat:get(ir, ic))
			end
		end
		return amat
	end;
	---@endsection

	---@section mat
	--- Calculate dot product of 2 matrix.
	---@param self LMatrix
	---@param scalar number
	---@return LMatrix
	mul = function(self, scalar)
		local m = self:copy()
		for i = 1, m.row do
			for j = 1, m.col do
				m:set(i, j, m:get(i, j) * scalar)
			end
		end
		return m
	end;
	---@endsection

	---@section mat
	--- Calculate dot product of 2 matrix(A・B). B column must be equals to A row.
	---@param self LMatrix
	---@param mat LMatrix
	---@return LMatrix
	dot = function(self, mat)
		local mmat = LMatrix:new(self.row, mat.col)
		for ir = 1, self.row do
			for ic = 1, mat.col do
				for ic2 = 1, self.col do
					mmat:set(ir, ic, mmat:get(ir, ic) + self:get(ir, ic2) * mat:get(ic2, ic))
				end
			end
		end
		return mmat
	end;
	---@endsection

	---@section cross
	--- Calculate cross product of 2 matrix(A×B). A and B must be 3x1 matrix.
	---@param self LMatrix A
	---@param mat LMatrix B
	---@return LMatrix M A×B
	cross = function(self, mat)
		local a = self
		local mmat = LMatrix:new(3, 1)
		mmat:set(1, 1, a:get(2, 1) * mat:get(3, 1) - a:get(3, 1) * mat:get(2, 1))
		mmat:set(2, 1, a:get(3, 1) * mat:get(1, 1) - a:get(1, 1) * mat:get(3, 1))
		mmat:set(3, 1, a:get(1, 1) * mat:get(2, 1) - a:get(2, 1) * mat:get(1, 1))
		return mmat
	end;
	---@endsection

	---@section rank
	--- Get rank of a matrix.
	---@param self LMatrix
	---@return number rank
	rank = function(self)
		local n = self.row
		local a = self:copy()
		local rank = 0
		local eps = 1e-10
		for i = 1, n do
			local flag = true
			for j = 1, n do
				if math.abs(a:get(i, j)) > eps then
					flag = false
					break
				end
			end
			if not flag then
				rank = rank + 1
				for j = i + 1, n do
					if math.abs(a:get(j, i)) > eps then
						local t = a:get(i, i) / a:get(j, i)
						for k = i, n do
							a:set(j, k, a:get(j, k) * t - a:get(i, k))
						end
					end
				end
			end
		end
		return rank
	end;
	---@endsection

	---@section det
	--- Calculate determinant of the Matrix. Matrix must be square.
	---@param self LMatrix
	---@return number
	det = function(self)
		local n = self.row
		local bmat = LMatrix:new(n, n)
		for ir = 1, n do
			for ic = 1, n do
				bmat:set(ir, ic, self:get(ir, ic))
			end
		end
		local det, buf = 1, 0
		for ic = 1, n do
			for ir = 1, n do
				if ic < ir then
					buf = bmat:get(ir, ic) / bmat:get(ic, ic)
					for i = 1, n do
						bmat:set(ir, i, bmat:get(ir, i) - bmat:get(ic, i) * buf)
					end
				end
			end
		end
		for i = 1, n do
			det = det * bmat:get(i, i)
		end
		return det
	end;
	---@endsection

	---@section inv
	--- Calculate inverse of the Matrix (A^-1). Matrix must be a regular matrix(det(A) not equals to 0).
	---@param self LMatrix
	---@return LMatrix
	inv = function(self)
		local n = self.row
		local inv = LMatrix:new(n, n)
		local sweep = LMatrix:new(n, n * 2)
		local a = 0
		for i = 1, n do
			for j = 1, n do
				sweep:set(i, j, self:get(i, j))
				if i == j then
					sweep:set(i, n + j, 1)
				else
					sweep:set(i, n + j, 0)
				end
			end
		end
		for k = 1, n do
			local max = math.abs(sweep:get(k, k))
			local max_i = k
			for i = k + 1, n do
				local b = math.abs(sweep:get(i, k))
				if b > max then
					max = b
					max_i = i
				end
			end
			if k ~= max_i then
				for j = 1, n * 2 do
					local tmp = sweep:get(max_i, j)
					sweep:set(max_i, j, sweep:get(k, j))
					sweep:set(k, j, tmp)
				end
			end
			a = 1 / sweep:get(k, k)
			for j = 1, n * 2 do
				sweep:set(k, j, sweep:get(k, j) * a)
			end
			for i = 1, n do
				if i ~= k then
					a = -sweep:get(i, k)
					for j = 1, n * 2 do
						sweep:set(i, j, sweep:get(i, j) + sweep:get(k, j) * a)
					end
				end
			end
		end
		for i = 1, n do
			for j = 1, n do
				inv:set(i, j, sweep:get(i, n + j))
			end
		end
		return inv
	end;
	---@endsection

	---@section transpose
	--- Calculate transpose of the Matrix (A^T).
	---@param self LMatrix
	---@return LMatrix
	transpose = function(self)
		local t = LMatrix:new(self.col, self.row)
		for i = 1, self.row do
			for j = 1, self.col do
				t:set(j, i, self:get(i, j))
			end
		end
		return t
	end;
	---@endsection

	---@section eigvals
	--- Get eigenvalues of a matrix.
	---@param self LMatrix
	---@return table eigenvalues
	eigvals = function(self)
		local n = self.row
		local a = self:copy()
		local b = LMatrix:new(n, n):eye()
		local eps = 1e-10
		local maxiter = 1000
		local iter = 0
		local eigvals = {}
		while iter < maxiter do
			local q, r = a:qr()
			a = r:dot(q)
			b = b:dot(q)
			local flag = true
			for i = 1, n - 1 do
				for j = i + 1, n do
					if math.abs(a:get(i, j)) > eps then
						flag = false
						break
					end
				end
				if not flag then
					break
				end
			end
			if flag then
				break
			end
			iter = iter + 1
		end
		for i = 1, n do
			eigvals[i] = a:get(i, i)
		end
		return eigvals
	end;
	---@endsection

	---@section eigvecs
	--- Get eigenvectors of a matrix.
	---@param self LMatrix
	---@return table eigenvectors
	eigvecs = function(self)
		local eigvals, n, eigvecs  = self:eigvals() , self.row, {}
		for i = 1, n do
			local a = self:copy()
			for j = 1, n do
				a:set(j, j, a:get(j, j) - eigvals[i])
			end
			local x = LMatrix:new(n, 1)
			x:set(1, 1, 1)
			local eps = 1e-10
			local maxiter = 1000
			local iter = 0
			while iter < maxiter do
				local y = a:dot(x)
				local norm = 0
				for j = 1, n do
					norm = norm + y:get(j, 1) * y:get(j, 1)
				end
				norm = math.sqrt(norm)
				for j = 1, n do
					y:set(j, 1, y:get(j, 1) / norm)
				end
				local flag = true
				for j = 1, n do
					if math.abs(x:get(j, 1) - y:get(j, 1)) > eps then
						flag = false
						break
					end
				end
				if flag then
					break
				end
				x = y
				iter = iter + 1
			end
			eigvecs[i] = x
		end
		return eigvecs
	end;
	---@endsection
	
	---@section lu
	---calculate LU decomposition of the Matrix with partial pivot (PA = LU).
	---@param self LMatrix
	---@return LMatrix P, LMatrix L, LMatrix U
	lu = function(self)
		local n = self.row
		local pmat, lmat, umat, sweep, a = LMatrix:new(n, n), LMatrix:new(n, n), LMatrix:new(n, n), LMatrix:new(n, n), 0
		for i = 1, n do
			for j = 1, n do
				sweep:set(i, j, self:get(i, j))
				if i == j then
					pmat:set(i, j, 1)
					lmat:set(i, j, 1)
				else
					pmat:set(i, j, 0)
					lmat:set(i, j, 0)
				end
			end
		end
		for k = 1, n do
			local max, max_i = math.abs(sweep:get(k, k)), k
			for i = k + 1, n do
				local b = math.abs(sweep:get(i, k))
				if b > max then
					max = b
					max_i = i
				end
			end
			if k ~= max_i then
				for j = 1, n do
					local tmp = sweep:get(max_i, j)
					sweep:set(max_i, j, sweep:get(k, j))
					sweep:set(k, j, tmp)
					tmp = pmat:get(max_i, j)
					pmat:set(max_i, j, pmat:get(k, j))
					pmat:set(k, j, tmp)
				end
			end
			for i = k + 1, n do
				a = sweep:get(i, k) / sweep:get(k, k)
				lmat:set(i, k, a)
				for j = k, n do
					sweep:set(i, j, sweep:get(i, j) - sweep:get(k, j) * a)
				end
			end
		end
		for i = 1, n do
			for j = 1, n do
				umat:set(i, j, sweep:get(i, j))
			end
		end
		return pmat, lmat, umat
	end;
	---@endsection

	---@section qr
	--- Do QR decomposition(A(m*n)=Q(m*n)R(m*m)) with Householder transformation.
	---@param self LMatrix
	---@return LMatrix Q, LMatrix R
	qr = function(self)
		local m = self.row
		local r, q, u = self:copy(), LMatrix:new(m, m):eye(), LMatrix:new(1, m)
		for k = 1, m - 1 do
			local absx = 0
			for i = k, m do
				absx = absx + r:get(i, k) * r:get(i, k)
			end
			absx = math.sqrt(absx)
			if absx ~= 0 then
				u:set(1, k, r:get(k, k) + (r:get(k, k)<0 and -1 or 1) * absx)
				local absu = u:get(1, k) * u:get(1, k)
				for i = k + 1, m do
					u:set(1, i, r:get(i, k))
					absu = absu + u:get(1, i) * u:get(1, i)
				end
				local h, div_absu = LMatrix:new(m, m):eye(), 1 / absu
				for i = k, m do
					for j = k, m do
						h:set(i, j, h:get(i, j) - 2 * u:get(1, i) * u:get(1, j) * div_absu)
					end
				end
				r = h:dot(r)
				q = q:dot(h)
			end
		end
		return q, r
	end;
	---@endsection

	---@section solve
	--- Solve AX=Y for X with LU decomposition.
	--- A(n x n), X(n x 1), Y(n x 1)
	---@param self LMatrix
	---@param y LMatrix
	---@return LMatrix
	solve = function(self, y)
		local a = self:copy()
		local p, n = { 0, 0 }, a.row
		for i = 1, n do
			p[i - 1] = i - 1
		end
		for k = 1, n - 1 do
			local pivot, amax = k - 1, math.abs(a:get(k, k))
			for i = k + 1, n do
				if math.abs(a:get(i, k)) > amax then
					pivot = i - 1
					amax = math.abs(a:get(k, k))
				end
			end
			if pivot + 1 ~= k then
				for i = 1, n do
					local tmp = a:get(k, i)
					a:set(k, i, a:get(pivot + 1, i))
					a:set(pivot + 1, i, tmp)
					tmp = p[k - 1]
					p[k - 1] = p[pivot]
					p[pivot] = tmp
				end
			end
			for i = k + 1, n do
				a:set(i, k, a:get(i, k) / a:get(k, k))
				for j = k + 1, n do
					a:set(i, j, a:get(i, j) - a:get(i, k) * a:get(k, j))
				end
			end
		end
		local x = LMatrix:new(n, 1)
		for i = 1, n do
			x:set(i, 1, y:get(p[i - 1] + 1, 1))
		end
		for i = 2, n do
			for j = 1, i - 1 do
				x:set(i, 1, x:get(i, 1) - a:get(i, j) * x:get(j, 1))
			end
		end
		for i = n, 1, -1 do
			for j = i + 1, n do
				x:set(i, 1, (x:get(i, 1) - a:get(i, j) * x:get(j, 1)))
			end
			x:set(i, 1, x:get(i, 1) / a:get(i, i))
		end
		return x
	end;
	---@endsection

	---@section norm
	--- Get norm of a matrix.
	---@param self LMatrix
	norm = function(self)
		local n = self.row
		local m = self.col
		local norm = 0
		for i = 1, n do
			for j = 1, m do
				norm = norm + self:get(i, j) * self:get(i, j)
			end
		end
		return math.sqrt(norm)
	end;
	---@endsection

};

---@endsection LMatrix 1 LMATRIX

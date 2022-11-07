require("Libs.Attitude")

A1 = Attitude:new()
A1:update(0.125, 0, -0.25,0.25)
vec = { 1, 0, 0 }
vec2 = A1:rotateVectorWorldToLocal(vec)
a = 0

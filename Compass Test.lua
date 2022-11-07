require("Libs.Attitude")

A1 = Attitude:new()
A1:update(0.125, 0.125, -0.25,0.25)
vec = { 0, 0, 1 }
vec2 = A1:rotateVectorLocalToWorld(vec)
a = 0

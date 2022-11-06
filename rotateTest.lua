require("Libs.Quaternion")
require("Libs.Vector3")

pitch = 0.25 * 2 * math.pi
roll = 0.25 * 2 * math.pi
yaw = 0 * 2 * math.pi

vec = Vector3:new(10, 0, 0)
q = Quaternion:newFromEuler(pitch, roll, yaw)
vec2 = q:rotateVector(vec:getVectorTable())
vec3 = q:getConjugateQuaternion():rotateVector(vec2)
a = 0
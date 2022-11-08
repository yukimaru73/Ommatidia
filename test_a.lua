current =0.3
past = -0.1
yaw = 0.51
x = 0.1--past
y = 0.9--current
print((current-past+1.5)%1-0.5)
print(current-past)--just get velocity
print(((yaw + 1.75) % 1 - 0.5))--compass value to yaw(east~north~west~south~east)WTF?
print((y-x+1.5)%1-0.5)
compass = 0.01 * math.pi * 2
yaw2 = -0.49 * math.pi * 2
print(((compass - yaw2 + 3 * math.pi ) % (2*math.pi) - math.pi)/math.pi/2)
print(nil or 3)
current =0.3
past = -0.1
yaw = 0.51
x = 0.1--taeget
y = -0.1--compass
print((current-past+1.5)%1-0.5)
print(current-past)--just get velocity
print(((yaw + 1.75) % 1 - 0.5))--compass value to yaw(east~north~west~south~east)WTF?
print((y-x+1.5)%1-0.5)
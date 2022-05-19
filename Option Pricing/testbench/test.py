w = 133
epsilons = [6882, 3374, 2447, 6606, 4925, 246, 6202, 7581]
S0 = 615
q = 699

neg = []
for i in range(8):
    if epsilons[i] > 4096:
        neg.append(1)
        epsilons[i] -= 4096
    else:
        neg.append(0)
        
        
out0s = []
out1s = []
out2s = []
operand2 = S0
for i in range(8):
    # out0
    epsilon = epsilons[i]
    out0 = ((w*epsilon) // 16) % 4096
    # out1
    if (neg[i] == 1):
        out1 = (q - out0) % 4096
    else:
        out1 = (q+out0) % 4096
    # out2
    out2 = ((out1*operand2) // 16) % 4096
    operand2 = out2
        
    out0s.append(out0)
    out1s.append(out1)
    out2s.append(out2)
    
print(out0s)
print(out1s)
print(out2s)

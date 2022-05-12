import time
import random


# val: the value for generating the characteristic function, num: the number of direction vectors that will be generated
def generate_DVA(val=487, num=32):
    # find a series
    bin_val = bin(val)[2:]
    dimension = len(bin_val) - 1
    a = []
    for char in bin_val[1:-1]:
        if char == '0':
            a.append(0)
        else:
            a.append(1)
    a.append(1)
            
    # find first m series
    m = []
    for i in range(dimension):
        low_limit = 1
        high_limit = pow(2, i)
        m.insert(0, 2*random.randrange(low_limit, high_limit + 1) - 1)
    # print(m)
    
    # find xor operational coefficient
    coeff = []
    for i in range(dimension):
        if a[i] == 1:
            coeff.append(pow(2, i+1))
        else:
            coeff.append(0)
    # print(coeff)
    
    xor_list = []
    for i in range(dimension):
        xor_list.append(m[i] * coeff[i])
    # print(xor_list)
    
    # find the remaining m series
    for i in range(num - dimension):
        new_m = 0
        for j in range(len(xor_list)):
            new_m ^= (xor_list[j])
        new_m ^= m[len(xor_list) - 1]
        m.insert(0, new_m)
    # print(m)
    
    # find v series
    v = []
    v_int = []
    for i in range(len(m)):
        v.append(m[len(m) - 1 - i] / pow(2, i+1))
        v_int.append(m[len(m) - 1 - i] * pow(2, len(m) - (i+1)))
    print(v)
    print(v_int)
    
    # write DVA
    with open('DVA.txt', 'w') as f:
        cnt = 0
        for val in reversed(v_int):
            f.write("32'b"  + (num - len(bin(val)[2:])) * '0' + bin(val)[2:] + ',')
            f.write('\n')
            cnt += 1
    
    
    

# def Sobol(L):
#     r = [0]
#     for i in range(L-1):
#         k = lsz(i)
#         r.append(r[-1] ^ DVA[k])
#     return r
    
# def lsz(n):
#     k = 0
#     while (n % 2 != 0):
#         n >>= 1
#         k += 1
#     return k

# res = Sobol(1048576)
# print(bin(res[1]))

dao = generate_DVA()

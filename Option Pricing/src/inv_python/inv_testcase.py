import numpy as np
import random
from fxpmath import Fxp


iteration = 5
for i in range(iteration):
    sig0 = random.randrange(255)
    sig1 = 1024*random.uniform(0, 1)
    sig2 = 4096*random.uniform(0, 1)
    sig0b = Fxp(sig0, True, 9, 0).bin()
    sig1b = Fxp(sig1, True, 17, 4).bin()
    sig2b = Fxp(sig2, True, 25, 8).bin()

    matrix = np.array([[sig0, sig1], [sig1, sig2]])
    det = np.linalg.det(matrix)
    detb = Fxp(det, True, 10, 6).bin()
    inv_matrix = np.linalg.inv(matrix)
    with open('./inv_test.dat', 'a') as f:
        f.write(str(sig0b)+"\n")
        f.write(str(sig1b)+"\n")
        f.write(str(sig2b)+"\n")
        f.write(str(detb)+"\n")
        # f.write("\n")

    out0b = Fxp(inv_matrix[0][0], True, 22, 10).bin()
    out1b = Fxp(inv_matrix[0][1], True, 12, 8).bin()
    out2b = Fxp(inv_matrix[1][1], True, 15, 6).bin()
    with open('./inv_test_ans.dat', 'a') as f:
        f.write(str(inv_matrix[0][0])+"\n")
        f.write(str(inv_matrix[0][1])+"\n")
        f.write(str(inv_matrix[1][1])+"\n")
        # f.write("\n")

from random import random
from sobol import *
from time import time
skip = 1024
def gen(n, skip):
    # Generate n numbers in the scope of [0, 1]

    # seq = []
    # for i in range(n):
    #     seq.append(random())
    # return seq
    skip += n
    return i4_sobol_generate(1, n, skip)[0]

if __name__ == "__main__":
    print(gen(10, 2000))
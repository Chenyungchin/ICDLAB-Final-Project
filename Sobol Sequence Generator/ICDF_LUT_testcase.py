import random
from scipy.stats import norm
import struct
import numpy as np

def gen_cdf():
    cdf = random.randrange(0, pow(2, 32))
    # print(cdf)
    return cdf

def calc_icdf(cdf):
    prob = cdf / pow(2, 32)
    # print(prob)
    if (prob < 0.5):
        prob = prob / (0.5 / 64)
        prob = int(prob)
        icdf = norm.ppf((prob+0.5)/64*0.5, loc=0, scale=1)
    else:
        prob = 1 - prob
        prob = prob / (0.5 / 64)
        prob = int(prob)
        icdf = norm.ppf((prob+0.5)/64*0.5, loc=0, scale=1) * -1
    return icdf

def toFP16(num):
    hexa = struct.unpack('H', struct.pack('e', num))[0]
    hexa = hex(hexa)
    hexa = hexa[2:]
    # print(hexa)
    
    y = struct.pack('H', int(hexa, 16))
    fl = np.frombuffer(y, dtype = np.float16)[0]
    # print(fl)
    
    return hexa
        
    
def wf(f_cdf, f_icdf, cdf, icdf):
    cdf_str = hex(cdf)[2:]
    f_cdf.write('0'*(8-len(cdf_str)) + cdf_str + '\n')
    icdf_str = toFP16(icdf)
    f_icdf.write('0'*(4-len(icdf_str)) + icdf_str + '\n')
    
            
            
def gen_testcase(n = 100):
    with open('pattern/ICDF_LUT_pattern/cdf.dat', 'w+') as f_cdf:
        with open('pattern/ICDF_LUT_pattern/icdf.dat', 'w+') as f_icdf:
            for i in range(n):
                cdf = gen_cdf()
                icdf = calc_icdf(cdf)
                wf(f_cdf, f_icdf, cdf, icdf)
    
    
if __name__ == '__main__':
    gen_testcase()
    
    # cdf = 0x118e9e7d
    # icdf = calc_icdf(cdf)
    # print(toFP16(icdf))

    
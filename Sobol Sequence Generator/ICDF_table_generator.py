from scipy.stats import norm
import struct
import numpy as np

def gen_table(mean = 0, std = 1, level = 64):
    cdf = []
    for i in range(level):
        cdf.append(0.5 / level * (i+0.5))
        
    # print(cdf)
    icdf = norm.ppf(cdf, loc=mean, scale=std)
    # print(icdf)
    
    # icdf_FP16 = []
    icdf_FP12 = []
    for val in icdf:
        # icdf_FP16.append(toFP16(val))
        icdf_FP12.append(toFP12(val))
        
    # print(icdf_FP16)
    # return icdf_FP16
    return icdf_FP12

def toFP12(num):
    # 8 bit integer and 4 bit decimal
    Is_neg = False
    if num < 0:
        Is_neg = True
        num = -1 * num
    
    num = int(num * 16) % 4096
    num = num + Is_neg * 4096
    # print(num)
    hexa = hex(num)
    hexa = hexa[2:]
    
    return hexa
    
    
def toFP16(num):
    hexa = struct.unpack('H', struct.pack('e', num))[0]
    hexa = hex(hexa)
    hexa = hexa[2:]
    # print(hexa)
    
    y = struct.pack('H', int(hexa, 16))
    fl = np.frombuffer(y, dtype = np.float16)[0]
    # print(fl)
    
    return hexa

def write_val(icdf_FP16):
    icdf_FP16.reverse()
    with open('ICDF_LUT.txt', 'w+') as f:
        f.write('{\n')
        for i in range(len(icdf_FP16)):
            if i == len(icdf_FP16) - 1:
                f.write('13\'h%s\n' % icdf_FP16[i])
            else:
                f.write('13\'h%s,\n' % icdf_FP16[i])
        f.write('};')
    
if __name__ == '__main__':
    table = gen_table()
    write_val(table)
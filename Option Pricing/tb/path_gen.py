import random
with open('path.dat', 'w') as f:
    for i in range(8):
        for j in range(2048):
            a = random.randint(4, 64)
            a_str = str(hex(a))[2:]
            if a < 16:
                f.write("00")
            elif a < 256:
                f.write("0")

            f.write(a_str)
            f.write('\n')

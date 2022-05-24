import random
with open('path.dat', 'w') as f:
    for i in range(8):
        for j in range(256):
            a = random.randint(256, 4095)
            a = str(hex(a))[2:]

            f.write(a)
            f.write('\n')

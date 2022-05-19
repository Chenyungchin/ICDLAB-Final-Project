import random

def gen_pattern(bits):
    if isinstance(bits, list):
        ans = []
        for bit in bits:
            ans.append(random.randrange(0, pow(2, bit)))
        return ans
    else:
        return random.randrange(0, pow(2, bits))
    
def gen_init_par():
    [w, q, S0] = gen_pattern([12, 12, 12])
    return [w, q, S0]
    
def gen_epsilons():
    epsilons = []
    for i in range(8):
        epsilon = gen_pattern(13)
        epsilons.append(epsilon)
    return epsilons

def calc_path(epsilons, init_par):
    [w, q, S0] = init_par
    operand2 = S0
    path = []
    for i in range(8):
        epsilon = epsilons[i]
        # extract sign bit
        neg, epsilon = epsilon // 4096, epsilon % 4096
        # FP12 mult
        out0 = ((w*epsilon) // 16) % 4096
        # FP12 add or minus
        if (neg == 1):
            out1 = (q - out0) % 4096
        else:
            out1 = (q+out0) % 4096
        # FP12 mult
        out2 = ((out1*operand2) // 16) % 4096
        operand2 = out2
        path.append(out2)
    return path
    
def wf(f_epsilon, f_init_par, f_path, epsilons, init_par, paths):
    # epsilon
    for epsilon in epsilons:
        epsilon_str = hex(epsilon)[2:]
        f_epsilon.write('0'*(4-len(epsilon_str)) + epsilon_str + '\n')
    # init par
    [w, q, S0] = init_par
    w_str = hex(w)[2:]
    q_str = hex(q)[2:]
    S0_str = hex(S0)[2:]
    init_par_str = w_str + q_str + S0_str
    f_init_par.write('0'*(9-len(init_par_str)) + init_par_str + '\n')
    # path
    for path in paths:
        path_str = hex(path)[2:]
        f_path.write('0'*(3-len(path_str)) + path_str + '\n')
    
def gen_testcase(n = 100):
    with open('pattern/Path_Gen_pattern/epsilon.dat', 'w+') as f_epsilon:
        with open('pattern/Path_Gen_pattern/initial_parameters.dat', 'w+') as f_init_par:
            with open('pattern/Path_Gen_pattern/path.dat', 'w+') as f_path:
                for i in range(n):
                    epsilons = gen_epsilons()
                    init_par = gen_init_par()
                    paths = calc_path(epsilons, init_par)
                    wf(f_epsilon, f_init_par, f_path, epsilons, init_par, paths)
    
if __name__ == '__main__':
    dao = gen_testcase(100)
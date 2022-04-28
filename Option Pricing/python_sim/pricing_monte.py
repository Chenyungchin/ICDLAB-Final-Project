from scipy.stats import norm
from num_gen import gen
from regression import regression
import numpy as np
import math
from time import time


N = 1024 # number of Monte-Carlo simulation cases
DAY = 8 # length of simulation cases
INI_PRICE = 200 # Initial stock price
K = 200 # strike price
RET = 0.06912 # expected return
VOL = 0.6501 # volatility
RF = 0.00379/DAY # risk-free rate
SEED = 1234 # Random seed

def gen_path(ini_price, ret, vol, mean = 0, std = 1, N = 10, DAY = 3):
    path = []
    for i in range(N):
        path.append([])

    ran = []
    for d in range(DAY):
        ran.append(gen(N, SEED+10*d))
    # print(ran)
    for n in range(N):
        for d in range(DAY):
            eps = norm.ppf(ran[d][n], loc=mean, scale=std)
            if d == 0:
                next_price = round(ini_price * (1 + (ret - (vol**2) / 2) * 1/360 + eps * vol * math.sqrt(1/360)), 2)
                path[n].append(next_price)
            else:
                next_price = round(path[n][d-1] * (1 + (ret - (vol**2) / 2) * 1/360 + eps * vol * math.sqrt(1/360)), 2)
                path[n].append(next_price)
                
    return path


def cal_cash_flow(path, K, rf=0.05):
    # discount = 1 / (1 + rf)
    discount = 1
    N = len(path)
    DAY = len(path[0])

    cf_mat = []
    profit_mat = []
    for p in path:
        cf_mat.append(p)
        profit_mat.append(p)   
    cf_tmp = []
    for i in range(N):
        cf_tmp.append(0)

    for d in reversed(range(DAY)):
        X = []
        Y = []
        for n in range(N):
            profit_mat[n][d] = round(max(path[n][d] - K, 0), 3)
            if profit_mat[n][d] > 0:
                # X.append(round(path[n][d], 0))
                # Y.append(round(cf_tmp[n] * discount, 0))
                X.append(path[n][d])
                Y.append(cf_tmp[n] * discount)
        if len(X) != 0:
            b = regression(X, Y)
            # print("Day ", d+1)
            # print("X: ",)
            # for i in range(len(X)):
            #     print(X[i])
            # print("Y: ", Y)
            # print("b: ", b)
            Y = np.matmul(X, b)
            # print("Y after regression: ", Y)
        for n in range(N):
            if profit_mat[n][d] > 0:
                if profit_mat[n][d] > Y[0]:
                    cf_tmp[n] = profit_mat[n][d]
                    cf_mat[n][d] = profit_mat[n][d]
                else:
                    cf_tmp[n] = cf_tmp[n] * discount
                    cf_mat[n][d] = 0
                np.delete(Y, 0)
            else:
                cf_mat[n][d] = 0
                cf_tmp[n] = cf_tmp[n] * discount

    return cf_mat, cf_tmp

def pricing(cf_matrix_discount):
    sum = 0
    for i in range(len(cf_matrix_discount)):
        sum += cf_matrix_discount[i]
    price = round(sum / len(cf_matrix_discount), 3)

    return price

if __name__ == "__main__":
    # print("Call option with stock price", INI_PRICE, "and strike price ", K)
    # print("N =", N, ", DAY =", DAY)
    start = time()
    path = gen_path(INI_PRICE, RET, VOL, N=N, DAY=DAY)
    print("get path time: ", time() - start)
    path_cp = gen_path(INI_PRICE, RET, VOL, N=N, DAY=DAY)
    # print("Path: ")
    # for i in range(N):
    #     print(path[i])
    # print("-------------------------")
    start = time()
    cf_mat, cf_mat_dis = cal_cash_flow(path, K, rf=RF)
    # print("-------------------------")
    # print("Cash flow matrix: ")
    # for i in range(N):
    #     print(cf_mat[i])
    # print("-------------------------")
    # print("Cash flow matrix (discount): ")
    # for i in range(N):
    #     print(cf_mat_dis[i])
    # print("-------------------------")
    price = pricing(cf_mat_dis)
    print("cal time: ", time() - start)
    print("Option price: ", price)

    with open("matrix.txt", "w") as f:
        f.write("Path \n")
        for i in range(N):
            for j in range(DAY):
                f.write(str(path_cp[i][j]))
                f.write(", ")
            f.write("\n")
        f.write("cash flow matrix \n")
        for i in range(N):
            for j in range(DAY):
                f.write(str(cf_mat[i][j]))
                f.write(", ")
            f.write("\n")
        f.write("discount cash flow matrix \n")
        for i in range(N):
            f.write(str(cf_mat_dis[i]))
            f.write(", ")
        f.write("\n")
        f.write("Option price \n")
        f.write(str(price))
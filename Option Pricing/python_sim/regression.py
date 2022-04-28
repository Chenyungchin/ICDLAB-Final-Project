import numpy as np


def regression(X, Y):
    # Linear regression Y = b0 + b1X + b2X^2
    # X, Y are n*1 matrices
    # Output b is 3*1 matrix
    for i in range(len(X)):
        # X[i] = [1, X[i], X[i]**2]
        X[i] = [1, X[i]]

    X = np.array(X)
    X_t = np.transpose(X)
    Y = np.array(Y)
    Y = np.transpose(Y)
    X_t_X = np.matmul(X_t, X)
    X_t_Y = np.matmul(X_t, Y)
    try:
        X_t_X_inv = np.linalg.inv(X_t_X)
    except:
        X_t_X_inv = np.linalg.pinv(X_t_X)
        
    b = np.matmul(X_t_X_inv, X_t_Y)

    return b
    

if __name__ == "__main__":
    X = [1, 2, 3, 4, 5, 6, 7, 8]
    Y = [4, 3, 5, 6, 2, 5, 6, 1]
    b = regression(X, Y)
    print(b)

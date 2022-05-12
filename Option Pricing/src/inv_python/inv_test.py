import numpy as np

iteration = 5
# for i in range(iteration):
with open("inv_test_ans.dat", "r") as ans_py:
    answer = ans_py.readlines()

with open("inv_tb.dat", "r") as ans_v:
    answer_v = ans_v.readlines()

answer_v[0] = int(answer_v[0], 2)/(2**10)
answer_v[1] = int(answer_v[1], 2)/(2**8)
answer_v[2] = int(answer_v[2], 2)/(2**6)
for i, ans in enumerate(answer):
    print(answer[i])
    print(answer_v[i])
    diff = float(answer[i]) - float(answer_v[i])
    # if(i % 4 == 3):
    #     if(diff == 0):
    #         print("det"+str(i//4)+"is correct")
    #     else:
    #         print("det"+str(i//4)+"is wrong")
    # else:
    err = diff*100/float(answer_v[i])
    print("sig"+str(i % 4)+"in matrix "+str(i//4)+"="+str(err)+"%")

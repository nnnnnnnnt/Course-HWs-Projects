#!/usr/bin/env python
# coding: utf-8

# In[1]:


import numpy as np
import sys

# In[3]:


def main(predictions_file):
    predictions = np.loadtxt(predictions_file,delimiter=",",dtype=int)
    matrix = np.zeros(121,dtype=int).reshape(11,11)
    for i in range(10): 
        matrix[0,i+1]=i
        matrix[i+1,0]=i
    for i,j in predictions: matrix[j+1,i+1]+=1
    print("Column:ground truth, Row:predictions")
    print(np.array2string(matrix))
    sum=0
    for i in range(11):
        sum += matrix[i,i]
    print("accuracy:",100*sum/predictions.shape[0],'%')

if __name__ == '__main__':
    predictions_file = sys.argv[1]
    main(predictions_file)


# In[ ]:





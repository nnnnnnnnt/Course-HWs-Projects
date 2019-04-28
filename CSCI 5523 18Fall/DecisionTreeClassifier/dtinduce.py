#!/usr/bin/env python
# coding: utf-8

# In[37]:


import numpy as np
import pandas as pd
import time
import sys


# In[38]:


class Node:
    def __init__(self):
        self.label = None
        self.best_cond = None
        self.split_value = None
        self.left = None
        self.right = None
    


# In[39]:


class DecisionTreeClassifier:
    def __init__(self):
        self.root = None
        pass
    
    def fit(self,X,y,minfreq):
        self.X = X
        self.y = y
        self.num_features = X.shape[1]
        self.minfreq = int(minfreq)
        self.num_labels = np.unique(y).size
        self.features_used = []
        self.tree_structure = []
        imgIDs = np.arange(X.shape[0])
        features = np.arange(X.shape[1])
        # grow!
        self.root = self.tree_growth(imgIDs,features,0)
        

    def tree_growth(self,imgIDs,features,dpt):
        if self.stop_cond(imgIDs,features) == True:
            leaf = Node()
            leaf.label = self.classify(imgIDs)
            print("depth:",dpt,", This is a leaf!")
            self.tree_structure.append((-2,leaf.label))
            return leaf
        else:
            root = Node()
            root.best_cond,root.split_value = self.find_best_split(imgIDs,features)
            left_imgIDs = np.array([i for i in imgIDs if self.X[i,root.best_cond] < root.split_value],dtype=int)
            right_imgIDs = np.array([i for i in imgIDs if self.X[i,root.best_cond] >= root.split_value],dtype=int)
            if left_imgIDs.size == 0 or right_imgIDs.size == 0: 
                print("depth:",dpt,", This is a special leaf! leaf size:",imgIDs.size)
                root.label = self.classify(imgIDs)
                self.tree_structure.append((-2,root.label))
                return root
            print("depth:",dpt,", This is an intermediate node!")
            self.features_used.append(root.best_cond)
            self.tree_structure.append((root.best_cond,root.split_value))
            root.left = self.tree_growth(left_imgIDs,features,dpt+1)
            root.right = self.tree_growth(right_imgIDs,features,dpt+1)
        return root
    
    def classify(self,imgIDs):
        labels,counts = np.unique(self.y[imgIDs],return_counts=True)
        return labels[counts.argmax()]
            
    def stop_cond(self,imgIDs,features):
        if np.unique(self.y[imgIDs]).size == 1:
            print("pure leaf! leaf size:",imgIDs.size)
            return True
        elif imgIDs.size < self.minfreq:
            print("size smaller than minfreq! leaf size:",imgIDs.size)
            return True
        elif np.unique(self.features_used).size==self.num_features:
            print("run out of features!")
            return True
        else:
            return False
        
    def GINI(self,gini_table):
        gini_smaller = 1.0
        gini_greater = 1.0
        smaller_sum = np.sum(gini_table[:,0])
        greater_sum = np.sum(gini_table[:,1])
        total_sum = smaller_sum + greater_sum
        for tpl in gini_table:
            if smaller_sum != 0 :
                gini_smaller -= (tpl[0]/smaller_sum)**2
            if greater_sum != 0 :
                gini_greater -= (tpl[1]/greater_sum)**2
        return (smaller_sum * gini_smaller + greater_sum * gini_greater)/total_sum
    
    def find_best_split(self,imgIDs,features):
        timet=time.time()
        MIN_GINI = 1.0
        BEST_COND = features[0]
        BEST_SPLIT_VALUE = self.X[0][0]
        for i in features:
            # get current sorted index
            index_sorted = self.X[imgIDs,i].argsort()
            
            # initialize gini table
            gini_table = np.zeros((self.num_labels,2),dtype='int16')
            labels,counts = np.unique(self.y[imgIDs],return_counts=True)
            for j in range(labels.size):
                gini_table[labels[j],1] = counts[j]
            
            # scan all possible split value for i-th feature, find the one with least gini index
            min_gini_i = self.GINI(gini_table)
            best_split_value_i = -1
            pre=-1
            values = np.unique(self.X[index_sorted,i])
            for s in range(values.size):
                if s+1<values.size:
                    value = (values[s]+values[s+1])/2.0
                else:
                    value = values[s]+0.5
                focus = imgIDs[self.X[imgIDs,i]<value]
                focus = focus[self.X[focus,i]>=pre]
                label,count=np.unique(self.y[focus],return_counts=True)
                gini_table[label,0] += count
                gini_table[label,1] -= count
                pre=value
                gini = self.GINI(gini_table)
                if gini < min_gini_i:
                    min_gini_i = gini
                    best_split_value_i = value      
                     
            # compare to the current global MIN_GINI
            if min_gini_i < MIN_GINI:
                BEST_COND = i
                BEST_SPLIT_VALUE = best_split_value_i
                MIN_GINI = min_gini_i         
        print("time cost to find the best split:",time.time()-timet)
        return (BEST_COND,BEST_SPLIT_VALUE)
    
    def predict(self,img):
        checking_node = self.root
        path=[]
        while checking_node.label == None:
            if img[checking_node.best_cond] < checking_node.split_value:
                path.append((checking_node.best_cond,0,checking_node.split_value))
                checking_node = checking_node.left
            else:
                path.append((checking_node.best_cond,1,checking_node.split_value))
                checking_node = checking_node.right
        return checking_node.label,path
    
    def write_tree(self,model_file):
        np.savetxt(model_file,self.tree_structure,delimiter=",", fmt="%f")

                


# In[13]:


def main(train_file, minfreq, model_file):
    train_data = pd.read_csv(train_file,header=None).values
    trainX = train_data[:,1:]
    trainy = train_data[:,0]
    clf = DecisionTreeClassifier()
    clf.fit(trainX,trainy,minfreq)
    clf.write_tree(model_file)

if __name__ == '__main__':
    train_file = sys.argv[1]
    minfreq = sys.argv[2]
    model_file = sys.argv[3]
    main(train_file, minfreq, model_file)


# In[27]:


#train_data = pd.read_csv("./data/rep1/train.csv",header=None).values
#test_data = pd.read_csv("./data/rep1/test.csv",header=None).values


# In[28]:


#trainX = train_data[:,1:]
#trainy = train_data[:,0]
#testX = test_data[:,1:]
#testy = test_data[:,0]
#trainy = trainy.astype(int)


# In[33]:


#clf=DecisionTreeClassifier()
#clf.fit(trainX[:1000],trainy[:1000],20)


# In[36]:





# In[ ]:





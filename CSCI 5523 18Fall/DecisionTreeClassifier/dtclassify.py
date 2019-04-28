#!/usr/bin/env python
# coding: utf-8

# In[77]:


import numpy as np
import pandas as pd
import sys


# In[79]:


class Node:
    def __init__(self):
        self.label = None
        self.best_cond = None
        self.split_value = None
        self.left = None
        self.right = None


# In[75]:


class tree:
    def __init__(self,tree_structure):
        self.i = 0
        self.tree_structure = tree_structure
        self.root = self.tree_growth()
        
    def tree_growth(self):
        if(self.tree_structure[self.i,0] == -2):
            leaf = Node()
            leaf.label = self.tree_structure[self.i,1]
            self.i += 1
            return leaf
        else:
            root = Node()
            root.best_cond = self.tree_structure[self.i,0]
            root.split_value = self.tree_structure[self.i,1]
            self.i += 1
            root.left = self.tree_growth()
            root.right = self.tree_growth()
            return root
    
    def predict(self,testX):
        predicted_labels=[]
        for img in testX:
            checking_node = self.root
            while checking_node.label == None:
                if img[int(checking_node.best_cond)] < checking_node.split_value:
                    checking_node = checking_node.left
                else:
                    checking_node = checking_node.right
            predicted_labels.append(checking_node.label)
        return np.array(predicted_labels)
        


# In[80]:


def main(model_file,test_file,prediction):
    tree_structure = np.loadtxt(model_file,delimiter=",")
    test_data = pd.read_csv(test_file,header=None).values
    testX = test_data[:,1:]
    testy = test_data[:,0]
    
    new_tree = tree(tree_structure)
    predicted_labels = new_tree.predict(testX)
    outcome = []
    for truth,predict in zip(testy,predicted_labels):
        outcome.append((truth,predict))
    outcome=np.array(outcome,dtype=int)
    np.savetxt(prediction,outcome,delimiter=",", fmt="%d")

if __name__ == '__main__':
    model_file = sys.argv[1]
    test_file = sys.argv[2]
    prediction = sys.argv[3]
    main(model_file,test_file,prediction)


# In[ ]:





#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun May  7 15:03:47 2017

@author: mes
"""

import matplotlib.pyplot as plt
import numpy as np
import random
from custom_math_functions import *
#import scipy.stats

y = [np.random.normal() for i in range(10000)]
plt.hist(y, bins = 100)
plt.yticks(np.arange(0))

x = [random.uniform(-1,1) for __ in range(5)]
y = [random.uniform(-1,1) for __ in range(5)]

def cov(x,y):
    if len(x)!=len(y):
        return -999
    
    cov = 0
    for i in range(len(x)):
        cov = cov + (x[i] - np.mean(x)) * (y[i] - np.mean(y))
    return cov/len(x)

def pearsons_coef(x,y):
        
    varx = np.var(x)
    vary = np.var(y)
    mix = np.sqrt(varx*vary)
    
    coef = np.array([[cov(x,x)/varx, cov(x,y)/mix],[cov(x,y)/mix,cov(y,y)/vary]])
    print coef
    return coef
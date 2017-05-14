#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon May  8 09:29:12 2017

@author: mes
"""

def auto_correlate(x,tau):
    xlag = np.concatenate((x[tau:],np.zeros(tau)),axis=0)
    return np.corrcoef(x,xlag)

def auto_correlate_other(x,tau):
    xlag = np.concatenate((x[tau:],np.zeros(tau)),axis=0)
    return np.correlate(x,xlag)

def cov(x,y):
    if len(x)!=len(y):
        return -999
    
    cov = 0
    for i in range(len(x)):
        cov = cov + (x[i] - np.mean(x)) * (y[i] - np.mean(y))
    return cov/len(x)/(np.std(x)*np.std(y))

def pearsons_coef(x,y):    
    coef = np.array([[cov(x,x), cov(x,y)],[cov(x,y),cov(y,y)]])
    return coef
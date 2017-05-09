#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon May  8 13:41:34 2017

@author: mes
"""

### Compute daily return value for bitcoin
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from custom_financial_functions.py import return_rate
#dataset = 'data/btceUSD.csv'
#df = pd.read_csv(dataset, names = ['timestamp','price','amount'])
dataset = '/data/data/bitcoin/btce_daily.csv'
df = pd.read_csv(dataset, index_col=0)
    
tau = [1,5,10,15,30,60,90,120,365]
plt.plot(df.timestamp[tau:],np.array(return_rate(df.price,tau)))
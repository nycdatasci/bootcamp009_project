#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue May  9 22:05:13 2017

@author: mes
"""
"""
Analyze further the non-normal distribution of the daily return rate by 
plotting the rate versus the log of the cdf which should be a straight line
for a normal distribution.

"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import cauchy,norm,probplot
from math import sqrt, floor
from financial_functions import return_rate
import os

"""
Read in daily price data of btc-e which is created from the total data
in another python script
"""
dataset = '/data/data/bitcoin/btce_daily.csv'
df = pd.read_csv(dataset, index_col=0)
"""
For a set of offsets compute the return rate
"""

taus = [1,3,7,14,30,60,90,180,365]
return_rates = [return_rate(df.price,tau) for tau in taus]

measurements = np.random.normal(loc = 20, scale = 5, size=1000)   
probplot(return_rates[0], dist="t", plot=plt)

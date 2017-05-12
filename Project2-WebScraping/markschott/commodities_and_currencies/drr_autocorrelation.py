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
from financial_functions import return_rate
#dataset = 'data/btceUSD.csv'
#df = pd.read_csv(dataset, names = ['timestamp','price','amount'])
dataset = '/data/data/bitcoin/btce_daily.csv'
df = pd.read_csv(dataset, index_col=0)
    
taus = [1,5,10,15,30,60,90,120,365]
return_rates = [return_rate(df.price,tau) for tau in taus] 

plt.figure(figsize=(28,16))
plt.subplot(241)
plt.plot(df.timestamp[1:],np.array(return_rates[0]))
plt.title('{x} Day Return Rate Over Time'.format(x = taus[0]), fontsize = 'xx-large')
plt.ylabel('Return Rate', fontsize = 'x-large')


plt.subplot(242)
plt.plot(df.timestamp[10:],np.array(return_rates[2]))
plt.yticks(np.arange(0))
plt.title('{x} Day Return Rate Over Time'.format(x = taus[2]), fontsize = 'xx-large')


plt.subplot(243)
plt.plot(df.timestamp[30:],np.array(return_rates[4]))
plt.yticks(np.arange(0))
plt.title('{x} Day Return Rate Over Time'.format(x = taus[4]), fontsize = 'xx-large')

plt.subplot(244)
plt.plot(df.timestamp[90:],np.array(return_rates[6]))
plt.yticks(np.arange(0))
plt.title('{x} Day Return Rate Over Time'.format(x = taus[6]), fontsize = 'xx-large')


plt.subplot(245)
plt.acorr(return_rates[0], normed=True, maxlags = None)
plt.xlim(0,1500)
plt.ylim(-.2,.5)
plt.xlabel('Lag in # of Days', fontsize = 'x-large')
plt.ylabel('Correlation', fontsize = 'x-large')

plt.subplot(246)
plt.acorr(return_rates[2], normed=True, maxlags = None)
plt.yticks(np.arange(0))
plt.xlim(0,1500)
plt.ylim(-.2,.5)

plt.subplot(247)
plt.acorr(return_rates[4], normed=True, maxlags = None)
plt.yticks(np.arange(0))
plt.xlim(0,1500)
plt.ylim(-.2,.5)

plt.subplot(248)
plt.acorr(return_rates[6], normed=True, maxlags = None)
plt.yticks(np.arange(0))
plt.xlim(0,1500)
plt.ylim(-.2,.5)

plt.savefig('autocorrelationplots.png',format='png')

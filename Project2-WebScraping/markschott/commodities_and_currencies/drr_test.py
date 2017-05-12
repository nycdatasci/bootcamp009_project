#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon May  8 11:03:56 2017

@author: mes
"""
"""
Compute return value for bitcoin with specified lag time
Some of the datasets timestamp's are in epoch time which requires
some special handling/conversion.
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
"""
Scipy is for the fitting functions but in the future it would be better to
use scipy.odr module because it actually returns quality of fit parameters
which the scipy.stats functions do not do confoundingly. 
"""
from scipy.stats import *

### Total exchange history on btce exchange. The csv is a big boy at 1.3 GB.
dataset = '/data/data/bitcoin/btceUSD.csv'
df = pd.read_csv(dataset, names = ['timestamp','price','amount'])

### Small data file scraped from 99bitcoins.com
#dataset = '../bitcoin/data/daily_price_history.csv'
df = pd.read_csv(dataset, index_col=0)

daily_return = [(df.price[i] - df.price[i-1])*100/df.price[i-1] for i in range(1,len(df.price))]
plt.plot(df.timestamp[1:],np.array(daily_return))


fig, ax = plt.subplots(figsize=(14,8))
 
ax.set_xlabel('Daily Return Rate (DRR)',fontsize=16)
ax.set_title(r'Bitcoin Daily Return Rate PDF', fontsize=20)
plt.ylim((0,0.35))
plt.xlim((-20,20))

# grid labels y=Constant
for ymaj in ax.yaxis.get_majorticklocs():
    ax.axhline(y=ymaj,ls='-', linewidth=0.4)
    
shape,loc1,scale1 = t.fit(daily_return)
df1,df2,loc,scale = f.fit(daily_return)
xdom = np.linspace(-40,40,1000)
distt = t.pdf(xdom,shape,loc1,scale1)
distf = f.pdf(xdom,df1,df2,loc,scale)

ax.hist(daily_return, bins = 200, normed=True)


ax.plot(xdom,distt,label='T Distribution\nMedian={d}\nScale={e}'.format(d=round(loc1,3),e=round(scale1,3)))
ax.plot(xdom,distf,label="\nF Distribution\nMu={d}\nSigma={e}".format(d=round(loc,3),e=round(scale,3)))

ax.legend(loc=0,fontsize='large',fancybox=True, shadow=True)
ax.set_facecolor('white')

#fig.savefig("bitcoin_daily_return.svg",format='svg')

#plt.show()
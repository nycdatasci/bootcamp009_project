#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun May  7 12:14:15 2017

@author: mes
"""

import matplotlib.pyplot as plt
import numpy as np
#import pandas as pd
from scipy.stats import norm,cauchy

### My custom daily return rate time series calculation
def plot_DRR_TS(df, tau=1):
    if 'Price' in df:
        price = df.Price
    elif 'Mid' in df:
        price = df.Mid
    elif 'Settlement Price' in df:
        price = df.iloc[:,2]
    else:
        return
    daily_return = [(price[i] - price[i-tau])*100/price[i-tau] for i in range(tau,len(price))]
    #plt.close('all')
    #plt.figure()
    plt.plot(df.Date[tau:],daily_return)


### Fit the daily return rate histogram with a gaussian and a cauchy to compare
def fit_func(df, col_num, title = 'Plot', xlims=None, ylims=None, no_bins = 100):
    
    plt.figure()
    #plt.subplot(211)
    plt.title(title)
        
# Grab the desired column while removing np.nan values and grab within the xrange
    x = df.loc[~np.isnan(df.iloc[:,col_num]),:].iloc[:,col_num]
    
        ### Populate this function variable
    if not xlims:
        xlims = (min(x),max(x))
    if ylims:
        plt.ylim(ylims)
        
    x = x[x > xlims[0]]
    x = x[x < xlims[1]]
    
    plt.hist(x,no_bins,normed=True)
    
    ### Cauchy Fit
    xdom = np.linspace(xlims[0],xlims[1],1000)
    loc,scale = cauchy.fit(x)
    plt.plot(xdom,cauchy.pdf(xdom,loc,scale), label = 'Cauchy')
    
    ### Gaussian Fit
    mu,sigma = norm.fit(x)
    plt.plot(xdom,norm.pdf(xdom,mu,sigma), label = 'Gaussian')
    plt.legend()
    
    #plt.subplot(212)
    #plot_DRR_TS(df)
    title = "".join(title.split()) + '.png'
    plt.savefig(title,format='png')
        
def plot_hists(num_of_plots):
    xdom = np.linspace(-40,40,1000)
    x = float(sqrt(num_of_plots))
    
    if x != floor(x):
        print 'make plot number a rational square root'
        return
    
    if num_of_plots > len(return_rates):
         print 'Warning: number of plots greater than list size. Ending now'
         return
        
    plt.figure(2, figsize=(18,18))
    bins_no = 150
    normal = True
    count = int(100*x + 10*x + 1)
    
    for i in range(num_of_plots):
        plt.subplot(count)
        
        if i < len(return_rates):
            df1,df2,loc,scale = f.fit(return_rates[i])
            distf = f.pdf(xdom,df1,df2,loc,scale)
            #loc,scale = cauchy.fit(return_rates[i])
            #distcauchy = cauchy.pdf(xdom,loc,scale)
            plt.hist(return_rates[i], bins = bins_no, normed = normal)
            #plt.plot(xdom, distcauchy)
            plt.plot(xdom, distf)
            
        count = count + 1
        
    
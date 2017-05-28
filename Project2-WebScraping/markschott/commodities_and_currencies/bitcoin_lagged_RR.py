#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon May  8 11:03:56 2017

@author: mes
"""
"""
BITCOIN LAGGED RETURN RATES
Compute return value for bitcoin with specified lag time
Some of the datasets timestamp's are in epoch time which requires
some special handling/conversion.
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import cauchy
from math import sqrt, floor
from financial_functions import return_rate
import os

"""
Scipy is for the fitting functions but in the future it would be better to
use scipy.odr module because it actually returns quality of fit parameters
which the scipy.stats functions do not do confoundingly. 
import scipy.odr
"""
"""
Read in daily price data of btc-e which is created from the total data
in another python script
"""
dataset = '/data/data/bitcoin/btce_daily.csv'
df = pd.read_csv(dataset, index_col=0)
"""
For a set of offsets compute the return rate
"""
SAVE_FIGS = False

taus = [1,3,7,14,30,60,90,180,365]
return_rates = [return_rate(df.price,tau) for tau in taus]

xdom = np.linspace(-50,50,1000)
    
def plot_hists(num_of_plots):
    x = float(sqrt(num_of_plots))
    
    if x != floor(x):
        print 'make plot number a rational square root'
        return
    
    if num_of_plots > len(return_rates):
         print 'Warning: number of plots greater than list size. Ending now'
         return
        
    plt.figure(2, figsize=(15,15))
    bins_no = 150
    normal = True
    
    ## Hacky way to plot multiple plots in a for loop
    count= int(100*x + 10*x + 1)
    
    for i in range(num_of_plots):
        plt.subplot(count)
        
        ## Be safe to make sure not to index out of bounds
        if i < len(return_rates):
            #plt.hist(return_rates[i], bins = bins_no, normed = normal)
            plt.plot(df.timestamp[taus[i]:], return_rates[i])
            plt.title('{x} Day Return Rate'.format(x = taus[i]), fontsize = 'x-large')
            
            # Only fit the first seven plots in my specific case
            """
            if i < 4:
                loc,scale = cauchy.fit(return_rates[i])
                distcauchy = cauchy.pdf(xdom,loc,scale)
         
                plt.plot(xdom, distcauchy, label = 'Cauchy Fit', lw = 1.3)
                plt.legend()
            """                       
        count = count + 1
               
    #plt.show()

    #### Change into the directory where I want to save the figure
    if SAVE_FIGS:
        os.chdir("/home/mes/Projects/nycdsa/personal/projects/project2-webscraping/bitcoin/figures/")
        savestr1 = "bitcoin_multi_DRR.png"   
        savestr2 = "bitcoin_multi_DRR.svg" 
        plt.savefig(savestr1,format='png') 
        plt.savefig(savestr2,format='svg')

plot_hists(9)


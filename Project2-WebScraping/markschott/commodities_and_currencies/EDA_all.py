#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun May  7 11:37:36 2017

@author: mes
"""

#import matplotlib.pyplot as plt
#import numpy as np
#from scipy.stats import norm,cauchy
from specific_plot_func import fit_func

"""
x = Daluminum.loc[~np.isnan(Daluminum.iloc[:,3]),:].iloc[:,3]
plt.hist(x,bins=200,normed=True)
xdom = np.linspace(-10,10,500)
loc,scale = cauchy.fit(x)
plt.plot(xdom,cauchy.pdf(xdom,loc,scale))
mu,sigma = norm.fit(x)
plt.plot(xdom,norm.pdf(xdom,mu,sigma))
"""

import pandas as pd
import os

#### Change into the directory where the data resides
os.chdir("/data/data/commodities_and_currencies")

DPPD = pd.read_csv('Daily_Pounds_per_Dollar.csv',thousands=',', parse_dates = ['Date'])
DCPPD = pd.read_csv('Daily_ChileanPeso_per_Dollar.csv', thousands=',', parse_dates = ['Date'])
DDPJY = pd.read_csv('Daily_Dollar_per_JapYen.csv', thousands=',', parse_dates = ['Date'])
Daluminum = pd.read_csv('Daily_Aluminum_LME_DollarperMT.csv', thousands=',', parse_dates = ['Date'])
Dcotton = pd.read_csv('Daily_CottonNo2_DollarperPound.csv', thousands=',', parse_dates = ['Date'])
DCuNYMEX = pd.read_csv('Daily_CopperNYMEX.csv', thousands=',', parse_dates = ['Date'])
DSoyCBT = pd.read_csv('Daily_Soy_CBT_DollarperBushel.csv', thousands=',', parse_dates = ['Date'])
DDPMP = pd.read_csv('Daily_Dollar_per_MexicanPeso.csv', thousands=',', parse_dates = ['Date'])
DDPSF = pd.read_csv('Daily_Dollar_per_SwissFranc.csv', thousands=',', parse_dates = ['Date'])
DDPAD = pd.read_csv('Daily_Dollar_per_AussieDollar.csv', thousands=',', parse_dates = ['Date'])
DDPIR = pd.read_csv('Daily_Dollar_per_IndianRupee.csv', thousands=',', parse_dates = ['Date'])
DAussieCoal = pd.read_csv('Daily_AustralianThermalCoalFOBNewcastle_DollarperMT.csv', thousands=',', parse_dates = ['Date'])
DBDPB = pd.read_csv('Daily_Brent_DollarperBarrel.csv', thousands=',', parse_dates = ['Date'])

fit_func(DPPD,5, 'Pound vs. Dollar',xlims=(-1,1), ylims=(0,3), no_bins=200)
fit_func(DCPPD, 5, 'Chilean Peso vs. Dollar',(-1.2,1.2))
fit_func(DDPJY, 5, 'Dollar vs. Yen',(-1.4,1.4))
fit_func(Daluminum,3, 'Daily Aluminum USD per MT',(-5,5),no_bins=200)
fit_func(Dcotton, 3, 'Daily Cotton USD per pound',(-5,5))
fit_func(DCuNYMEX, 3, 'Daily Copper NYMEX',(-7.5,7.5))
fit_func(DSoyCBT, 3, 'Daily Soy CBT USD per bushel',(-0.4,0.4))
fit_func(DDPMP, 5, 'Daily USD per Mexican Peso',(-1.5,1.5))
fit_func(DDPSF, 5, 'Daily USD per Swiss Franc',(-2,2))
fit_func(DDPAD, 5, 'Daily USD per Aussie Dollar',(-1.5,1.5))
fit_func(DDPIR, 5, 'Daily USD per Rupee',(-1,1))
fit_func(DAussieCoal, 3, 'Daily Aussie Thermal Coal',(-2.5,2.5),no_bins=500)
fit_func(DBDPB, 3, 'Daily Brent Dollar Per Barrel',xlims=(-5,5))

"""
plot_DRR_TS(DPPD)
plot_DRR_TS(DCPPD)
plot_DRR_TS(DDPJY)
plot_DRR_TS(Daluminum)
plot_DRR_TS(Dcotton)
plot_DRR_TS()
"""
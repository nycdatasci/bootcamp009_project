#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun May  7 14:32:54 2017

@author: mes
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
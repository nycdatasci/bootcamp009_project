#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon May  8 23:22:12 2017

@author: mes
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
"""
Retrieve the daily prices from btc-e from the overall dataset
Read in btc-e data from another file
"""

### Total exchange history on btce exchange. The csv is a big boy at 1.3 GB.
dataset = '/data/data/bitcoin/btceUSD.csv'
btce = pd.read_csv(dataset, names = ['timestamp','price','amount'])

# The time is in epoch seconds so I want to access by seconds
secs_in_a_day = 60*60*24

# Compute the number of days in the data set
total_days = (btce.timestamp[len(btce.timestamp)-1] - btce.timestamp[0])/secs_in_a_day + 1

### Create the new numpy arrays to hold the data which will later become a DF
btce_daily_price = np.zeros(total_days)
btce_daily_timestamp = np.zeros(total_days)

### Create a list of the by-day timestamps
ts_list = [btce.timestamp[0] + i*secs_in_a_day for i in range(total_days)]

"""
Function which given a timestamp finds the closest observation in
the data
"""

def find_index(t, tracker):
    while btce.timestamp[tracker] <= t:
        # Sacrifice some resolution for the sake of speed but there 
        # are 14392 trades per day in this data set
        tracker = tracker + 100
    return tracker

"""
Loop through the daily timestamps and find the price and timestamp once a day
in the btce data. Use the index variable to keep track of our place in the 
data so not to start from the beginning each time which would be O(n^2). 
Instead this is an O(n) operation
"""

index = 0
for i in range(len(ts_list)):
    if i%100 == 0:
        print i, index, btce_daily_timestamp[i]
    index = find_index(ts_list[i], index)
    btce_daily_price[i] = btce.price[index]
    btce_daily_timestamp[i] = btce.timestamp[index]

btce_daily = pd.DataFrame([btce_daily_timestamp, btce_daily_price]).T
btce_daily.columns = ['timestamp','price']

# Check the viability
#plt.plot(btce_daily_timestamp, btce_daily_price)

btce_daily.to_csv('/data/data/bitcoin/btce_daily.csv')
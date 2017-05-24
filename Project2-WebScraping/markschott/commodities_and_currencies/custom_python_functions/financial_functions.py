#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon May  8 13:58:28 2017

@author: mes

Here I'll assemble any functions that I end up writing and using 
consistently which relate to finanial analysis
"""


def return_rate(price, tau):
    #[(data.price[i] - data.price[i-1])*100/data.price[i-1] for i in range(1,len(data.price))]
    return [(price[i] - price[i-tau])*100/price[i-tau] for i in range(tau,len(price))]
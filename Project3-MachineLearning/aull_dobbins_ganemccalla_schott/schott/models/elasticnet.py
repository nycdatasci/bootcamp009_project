#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue May 23 00:43:22 2017

@author: mes
"""

from sklearn import linear_model
lasso = linear_model.ElasticNet(alpha = 1, l1_ratio = 1.0)
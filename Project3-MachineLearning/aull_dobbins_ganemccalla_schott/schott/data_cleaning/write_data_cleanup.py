#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue May 16 21:20:30 2017

@author: mes
"""

import numpy as np
import pandas as pd
import os

#DIR_PATH = '/data/data/kaggle/sberbank_housing/'
DIR_PATH = '../data/'

train = pd.read_csv(os.path.join(DIR_PATH, 'train.csv'), 
                        header='infer', 
                        index_col='id',
                        parse_dates=['timestamp'])
test = pd.read_csv(os.path.join(DIR_PATH, 'test.csv'), 
                       header='infer', 
                       index_col='id',
                       parse_dates=['timestamp'])
macro = pd.read_csv(os.path.join(DIR_PATH, 'macro.csv'), 
                    header='infer')

# Move case threes to np.nan
train.loc[train['material'] == 3, 'material'] = np.nan
test.loc[test['material'] == 3, 'material'] = np.nan

## change 33 to 3
train.loc[train['state'] == 33, 'state'] = 3

## max_floor outliers
col = 'max_floor'
train.loc[train['max_floor'] == 117, col] = 17
train.loc[train['max_floor'] > 60, col] = np.nan

## floor outliers
col = 'floor'
train.loc[train['floor'] == 77, col] = 7

## build year outliers
train.loc[train['build_year'] == 20052009, 'build_year'] = 2009
train.loc[train['build_year'] == 4965, 'build_year'] = 1965
train.loc[train['build_year'] == 71, 'build_year'] = 1971
train.loc[train['build_year'] < 1800, 'build_year'] = np.nan

## build year outliers test set
test.loc[test['build_year'] < 1800, 'build_year'] = np.nan

## num of rooms outliers?
train.loc[train['num_room'] > 9, 'num_room'] = np.nan
test.loc[test['num_room'] > 9, 'num_room'] = np.nan

# Fixing potential order problems in the full_sq
train.loc[train['full_sq'] > 1000, 'full_sq'] = train.loc[train['full_sq'] > 1000, 'full_sq']/100
train.loc[train['full_sq'] > 310, 'full_sq'] = train.loc[train['full_sq'] > 310, 'full_sq']/10

## life_sq
train.loc[13549, 'life_sq'] = train.loc[13549, 'life_sq'] / 100
rows = (test['full_sq'] < test['life_sq']) & (test['life_sq'] > 110)
test.loc[rows, 'life_sq'] = test.loc[rows, 'life_sq'] / 10

## Fixing where full_sq is less than life_sq
rows = (train['full_sq'] < train['life_sq']) & (train['life_sq'] > 100)
train.loc[rows, 'life_sq'] = train.loc[rows, 'life_sq'] / 10

## full_sq 
test.loc[test['full_sq'] > 400, 'full_sq'] = test.loc[test['full_sq'] > 400, 'full_sq'] / 10  

train.loc[13120, 'build_year'] = 1970
train.loc[11523, 'kitch_sq'] = train.loc[11523, 'kitch_sq'] / 100
rows = (train['kitch_sq'] > train['full_sq']) & (train['kitch_sq'] > 100)
train.loc[rows, 'kitch_sq'] = np.nan

rows = (test['kitch_sq'] > test['full_sq']) & (test['kitch_sq'] > 100)
test.loc[rows, 'kitch_sq'] = np.nan

## property square meters
#train.loc[:, 'sq_metr'] = train.loc[:, ['full_sq','life_sq']].max(axis=1)
#train.loc[train['sq_metr'] < 6, 'sq_metr'] = np.nan

## Adding log transformation of price
#train.loc[:, 'log_price_doc'] = np.log(train['price_doc'] + 1)

train.to_csv('train_mod.csv')
test.to_csv('test_mod.csv')
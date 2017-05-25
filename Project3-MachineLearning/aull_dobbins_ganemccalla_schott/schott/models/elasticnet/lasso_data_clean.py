#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Wed May 24 16:44:37 2017

@author: mes
"""
#%%
import os
import numpy as np
import pandas as pd

#%%
def lasso_clean(subset = 'base'):
    DIR_PATH = '~/Projects/nycdsa/communal/bootcamp009_project/Project3-MachineLearning/aull_dobbins_ganemccalla_schott/schott/data/'
    train_file = 'train_clean.csv'
    test_file = 'test_clean.csv'
    feature_file = 'feature_types.csv'

## loading data as Pandas dataframes
    train_raw = pd.read_csv(os.path.join(DIR_PATH, train_file), 
                        header='infer', 
                        index_col='id',
                        parse_dates=['timestamp'])
    test_raw = pd.read_csv(os.path.join(DIR_PATH, test_file), 
                       header='infer', 
                       index_col='id',
                       parse_dates=['timestamp'])
    
    feature_types = 
#%%
"""
Define variable subsets
"""
base = ['price_doc','full_sq','floor','kremlin_km','basketball_km',
        'state']
extra1 = ['area_m']
#%%
## Trim down the sub_area levels to the top 25 and put all others as there
## own separate level
    freq_area = np.array(train_raw.loc[:, 'sub_area'].value_counts()[:30].index)

train_raw.loc[~train_raw['sub_area'].isin(freq_area), 'sub_area'] = 'other'
test_raw.loc[~test_raw['sub_area'].isin(freq_area), 'sub_area'] = 'other'

## time features, the timestamp as is makes this decomposition fail
train_raw.timestamp = train_raw.timestamp.astype('datetime64')
test_raw.timestamp = test_raw.timestamp.astype('datetime64')
train_raw.loc[:, 'year'] = train_raw.loc[:, 'timestamp'].apply(lambda x: x.strftime('%Y'))
train_raw.loc[:, 'month'] = train_raw.loc[:, 'timestamp'].apply(lambda x: x.strftime('%m'))

test_raw.loc[:, 'year'] = test_raw.loc[:, 'timestamp'].apply(lambda x: x.strftime('%Y'))
test_raw.loc[:, 'month'] = test_raw.loc[:, 'timestamp'].apply(lambda x: x.strftime('%m'))

## This allows the model to run over a subset of the entire data
if SUBSET:
    features = ['month', 'year', 'full_sq', 'life_sq', 'floor', 
                    'max_floor', 'material', 'build_year', 'num_room',
                    'kitch_sq', 'state', 'radiation_km', 'basketball_km',
                    'museum_km'] 
    train = train_raw[features]
    test = test_raw[features]
else:
    train = train_raw.copy()
    test = test_raw.copy()
    features = list(train.columns)
    
if 'timestamp' in features:
    train.drop('timestamp', inplace = True, axis = 1)
    test.drop('timestamp', inplace = True, axis = 1)
    features.remove('timestamp')
if 'price_doc' in features:
    train.drop('price_doc', inplace = True, axis = 1)
    features.remove('price_doc')
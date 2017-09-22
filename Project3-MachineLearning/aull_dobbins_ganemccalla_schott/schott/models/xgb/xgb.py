#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun May 21 20:25:04 2017

@author: mes

Implement an XGBoost model for the Sberbank Housing Kaggle Competition.
It must be flexible in the sense of bringing in data
"""
#%%
import pandas as pd
import numpy as np
import os
import sys
sys.path.append('/home/mes/venv/lib/python2.7/site-packages/')
import xgboost as xgb
## label encoding
import sklearn
import matplotlib.pyplot as plt
import time

SUBSET = True

#%%
DIR_PATH = '../../../data/imputed/'
train_file = 'train_total.csv'
test_file = 'test_total.csv'

## loading data as Pandas dataframes
train_raw = pd.read_csv(os.path.join(DIR_PATH, train_file), 
                        header='infer', 
                        parse_dates=['timestamp'])
test_raw = pd.read_csv(os.path.join(DIR_PATH, test_file), 
                       header='infer', 
                       parse_dates=['timestamp'])

macro = pd.read_csv(os.path.join(DIR_PATH, '../macro/RE_Macro_Index.csv'),
                    parse_dates = ['timestamp'])

macro_big = pd.read_csv(os.path.join(DIR_PATH, '../raw/macro.csv'),
                        parse_dates=['timestamp'])

#%%
"""
Merge on timestamp to bring in the macro and set the indexes
"""
train_raw = pd.merge(train_raw, macro, on = 'timestamp')
test_raw = pd.merge(test_raw, macro, on = 'timestamp')

#%%
"""
Create a couple other columns from the macro
"""
macro_big['brent_rub'] = macro_big.brent * macro_big.usdrub
mini_mac = macro_big[['timestamp','brent_rub','rent_price_2room_bus']].copy()
#mini_mac = pd.DataFrame([macro_big.timestamp, brent_rub, macro_big.rent_price_2room_bus]).T
#mini_mac.columns = ['timestamp','brent_rub','rent_price_2room_bus']

#%%
"""
Merge these columns in
"""

train_raw = pd.merge(train_raw, mini_mac, on = 'timestamp')
test_raw = pd.merge(test_raw, mini_mac, on = 'timestamp')
train_raw.index = train_raw.id
test_raw.index = test_raw.id

#%%
## Trim down the sub_area levels to the top 25 and put all others as there
## own separate level
freq_area = np.array(train_raw.loc[:, 'sub_area'].value_counts()[:25].index)

train_raw.loc[~train_raw['sub_area'].isin(freq_area), 'sub_area'] = 'other'
test_raw.loc[~test_raw['sub_area'].isin(freq_area), 'sub_area'] = 'other'

## time features, the timestamp as is makes the xgboost fail
train_raw.loc[:, 'year'] = train_raw.loc[:, 'timestamp'].apply(lambda x: x.strftime('%Y'))
train_raw.loc[:, 'month'] = train_raw.loc[:, 'timestamp'].apply(lambda x: x.strftime('%m'))

test_raw.loc[:, 'year'] = test_raw.loc[:, 'timestamp'].apply(lambda x: x.strftime('%Y'))
test_raw.loc[:, 'month'] = test_raw.loc[:, 'timestamp'].apply(lambda x: x.strftime('%m'))

## This allows the model to run over a subset of the entire data
if SUBSET:
    features = ['month', 'year', 'full_sq', 'life_sq', 'floor', 
                    'max_floor', 'material', 'build_year', 'num_room',
                    'kitch_sq', 'state', 'radiation_km', 'basketball_km',
                    'museum_km', 'metro_km_walk', 'water_km',
                    'sub_area', 'kremlin_km', 'kindergarten_km',
                    'public_transport_station_min_walk', 'sadovoe_km',
                    'railroad_km']
    """ 
    ###Best feature set so far
    features = ['month', 'year', 'full_sq', 'life_sq', 'floor', 
                    'max_floor', 'material', 'build_year', 'num_room',
                    'kitch_sq', 'state', 'radiation_km', 'basketball_km',
                    'museum_km', 'metro_km_walk', 'water_km',
                    'sub_area', 'RE_Macro_Index', 'kremlin_km', 'kindergarten_km',
                    'public_transport_station_min_walk', 'sadovoe_km',
                    'thermal_power_plant_km','railroad_km','big_road1_km',
                    'big_market_km']
    #maybe green_zone_km
    
    # Actually this is the best (2.14552e6)
        features = ['month', 'year', 'full_sq', 'life_sq', 'floor', 
                    'max_floor', 'material', 'build_year', 'num_room',
                    'kitch_sq', 'state', 'radiation_km', 'basketball_km',
                    'museum_km', 'metro_km_walk', 'water_km',
                    'sub_area', 'kremlin_km', 'kindergarten_km',
                    'public_transport_station_min_walk', 'sadovoe_km',
                    'railroad_km','big_road1_km','big_market_km']
    """
    
    train = train_raw[features]
    test = test_raw[features]
else:
    train = train_raw.copy()
    test = train_raw.copy()
    features = list(test.columns)

#%%    
## Must encode object columns for the model
for f in train.columns:
    if train[f].dtype=='object':
        print('encoding training feature: {}'.format(f))
        lbl = sklearn.preprocessing.LabelEncoder()
        train.loc[:,f] = lbl.fit_transform(train.loc[:,f])
        
for f in test.columns:
    if test[f].dtype=='object':
        print('encoding test feature: {}'.format(f))
        lbl = sklearn.preprocessing.LabelEncoder()
        test.loc[:,f] = lbl.fit_transform(test.loc[:,f])

#%%
# Convert data frames to numpy arrays
X_train = train.values
Y_train = train_raw['price_doc'].values
X_test = test.values

#%%
# Subset to tune XGB 'num_boost_rounds'
size_ = 7000
X_train_sub, Y_train_sub = X_train[:-size_],  Y_train[:-size_]
X_val, Y_val = X_train[-size_:],  Y_train[-size_:]

dtrain = xgb.DMatrix(X_train, 
                    Y_train, 
                    feature_names=features)
dtrain_sub = xgb.DMatrix(X_train_sub, 
                        Y_train_sub, 
                        feature_names=features)
d_val = xgb.DMatrix(X_val, 
                    Y_val, 
                    feature_names=features)
dtest = xgb.DMatrix(X_test, 
                    feature_names=features)

#%%
# hyperparameters
xgb_params = {
    'eta': 0.02,
    'max_depth': 5,
    'subsample': .8,
    'colsample_bytree': 0.7,
    'objective': 'reg:linear',
    'eval_metric': 'rmse',
    'silent': 1
}

XGBGS = True

if XGBGS:
    from datetime import datetime
    from sklearn.grid_search import GridSearchCV
    xgb_params = {
            'max_depth' : [5,6,7],
            'min_child_weight' : [3,5],
            'learning_rate' : [0.01,0.02,0.03],
            'objective': ['reg:linear'],
            }
    print(datetime.now())
## Now let's run a grid search:
    global xgb_model
    xgb_model = xgb.XGBRegressor()
    opt_GBM = GridSearchCV(xgb_model,xgb_params, cv = 5, verbose = 1) 
    opt_GBM.fit(X_train, Y_train)  
    print(opt_GBM.grid_scores_)
    print(opt_GBM.best_estimator_)
    print(opt_GBM.best_score_)
    print(opt_GBM.best_params_)
    xgb_params = opt_GBM.best_params_

    print(datetime.now())

"""
gridsearch_params = {'colsample_bytree': [0.8], 
                     'silent': [1], 
                     'learning_rate': [0.4], 
                     'min_child_weight': [5], 
                     'n_estimators': [250], 
                     'subsample': [0.8], 
                     'objective': ['reg:linear'], 
                     'max_depth': [3]
                     }

"""

# Tune the model
sub_model = xgb.train(xgb_params, 
                      dtrain_sub, 
                      num_boost_round=4000,
                      evals=[(d_val, 'val')],
                      early_stopping_rounds=20, 
                      verbose_eval=50)

#%%
# Train the model
full_model = xgb.train(xgb_params,
                       dtrain, 
                       num_boost_round=sub_model.best_iteration,
                       verbose_eval=20)

#%%
"""
Plot importance
"""
plt.figure(figsize=(14,14))
xgb.plot_importance(full_model)
plt.savefig('xgb_importance.png')

#%%
# predict the prices from the test data
y_pred = full_model.predict(dtest)

#Retransfrom the prices from ln(price)
#y_pred = np.exp(y_pred)

#%%
# Write them to csv for submission
submit = pd.DataFrame({'id': np.array(test.index), 'price_doc': y_pred})
savefile = 'submissions/submission_xgb_' + time.strftime('%Y%m%d-%H%M') + '.csv'
submit.to_csv(savefile, index=False)

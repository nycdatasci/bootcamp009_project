#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun May 21 20:25:04 2017
Modified on Wed May 24 @ around midnight

@author: mes & wes (humble research assistant)

Implement an XGBoost model for the Sberbank Housing Kaggle Competition.
It must be flexible in the sense of bringing in data
"""
#%%
from datetime import datetime
import pandas as pd
import numpy as np
import os
import sys
sys.path.append('/home/mes/venv/lib/python2.7/site-packages/')
import xgboost as xgb
## label encoding
import sklearn
from sklearn.grid_search import GridSearchCV   #Perforing grid search



SUBSET = True

#%%
DIR_PATH = '../../data/'
train_file = 'train_total.csv'
test_file = 'test_total.csv'

## loading data as Pandas dataframes
train_raw = pd.read_csv(os.path.join(DIR_PATH, train_file), 
                        header='infer', 
                        index_col='id',
                        parse_dates=['timestamp'])
test_raw = pd.read_csv(os.path.join(DIR_PATH, test_file), 
                       header='infer', 
                       index_col='id',
                       parse_dates=['timestamp'])

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
    features = ['log_fullsq', 'log_lifesq', 'floor', 
                    'max_floor', 'material', 'build_year', 'num_room',
                    'kitch_sq', 'state', 'radiation_km', 'basketball_km',
                    'museum_km','kremlin_km','metro_min_walk','cafe_count_1000','ecology','water_km','park_km','sub_area','product_type'] 
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
Y_train = train_raw['log_price'].values
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
#hyperparameters
xgb_params = {
    'eta': 0.3,
    'max_depth': 6,
    'subsample': .8,
    'colsample_bytree': 0.7,
    'objective': 'reg:linear',
    'eval_metric': 'rmse',
    'silent': 1
}

#Tune the model
#sub_model = xgb.train(xgb_params, 
#                      dtrain_sub, 
#                      num_boost_round=2000,
#                      evals=[(d_val, 'val')],
#                      early_stopping_rounds=20, 
#                      verbose_eval=50)
print(datetime.now())

#cv = xgb.cv(xgb_params, dtrain, num_boost_round = 5000, nfold = 5, metrics = {"rmse"})
#output.write(str(cv))
#print(cv)



## Now let's run a grid search:

cv_params = {'max_depth': [3,4,5,6,7,8], 'min_child_weight': [1,2,3,4,5]}
ind_params = {'learning_rate': 0.2, 'n_estimators': 1000, 'seed':0, 'subsample': 0.8, 'colsample_bytree': 0.8, 
             'objective': 'reg:linear'}
xgb_model = xgb.XGBRegressor()
opt_GBM = GridSearchCV(xgb_model,ind_params, cv_params, scoring = 'rmse', cv = 5, verbose = 1) 
opt_GBM.fit(X_train, y_train)  
opt_GBM.grid_scores
opt_GBM.best_model_
opt_GBM.best_score_
opt_GBM.best_params_

#print(clf.best_score_)
#print(clf.best_params_)
print(datetime.now())

#%%
# Train the model
#full_model = xgb.train(xgb_params,
#                       dtrain, 
#                       num_boost_round=sub_model.best_iteration,
#                       verbose_eval=20)

# predict the prices from the test data
#y_pred = full_model.predict(dtest)

#%%
# Write them to csv for submission
#submit = pd.DataFrame({'id': np.array(test.index), 'price_doc': y_pred})
#submit.to_csv('submissions/submission_xgb3.csv', index=False)
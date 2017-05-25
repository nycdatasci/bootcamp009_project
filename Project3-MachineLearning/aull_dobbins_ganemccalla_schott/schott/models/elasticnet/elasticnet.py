#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun May 21 20:25:04 2017

@author: mes

Implement an ElasticNet model for the Sberbank Housing Kaggle Competition.
It must be flexible in the sense of bringing in data. The cleaning of data
for this model may be moved to another file entirely. 
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
from math import log
from sklearn import linear_model, preprocessing
from sklearn.metrics import mean_squared_error
import time

#%%
"""
Must create custom mean squared error function to pass to the grid search
because this function doesn't exist by default.

Also creating AIC and BIC to compare different models
"""
# Instead of creating a new function can import make_scorer 
# from sklearn.metrics import make_scorer

def AIC(estimator, x, y):
    k = x.shape[1]
    predictions = estimator.predict(x)
    rss = sum((predictions - y)**2)
    return 2*k - 2*log(rss)
    
    
def BIC(estimator, x, y):
    n,k = x.shape
    predictions = estimator.predict(x)
    rss = sum((predictions - y)**2)
    return k*log(n) - 2*log(rss)
    
    
def mse(estimator, x, y):
    predictions = estimator.predict(x)
    return mean_squared_error(y, predictions)

def adj_Rsq(estimator, x, y):
    n,k = x.shape
    val = estimator.score(x, y) * (n-1)/(n-k-1)
    return val

DIR_PATH = '/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project3-MachineLearning/aull_dobbins_ganemccalla_schott/data/'
train_file = 'train_clean.csv'
test_file = 'test_clean.csv'
feature_file = 'feature_types.npy'

## loading data as Pandas dataframes
train_raw = pd.read_csv(os.path.join(DIR_PATH, train_file), 
                    header='infer', 
                    index_col='id',
                    parse_dates=['timestamp'])
test_raw = pd.read_csv(os.path.join(DIR_PATH, test_file), 
                    header='infer', 
                    index_col='id',
                    parse_dates=['timestamp'])
    
feature_types = np.load(os.path.join(DIR_PATH, feature_file)).item()
    
#%%
"""
Define variable subsets
"""
#base = ['timestamp', 'full_sq','floor','kremlin_km','basketball_km',
#        'state','sub_area']
#base = ['timestamp', 'full_sq','kremlin_km','basketball_km',
#        'state']
base = ['timestamp', 'full_sq','kremlin_km','basketball_km', 'state']
sub_area = ['sub_area']
extra1 = ['area_m', 'cemetery_km', 'catering_km', 'ecology']
extra2 = ['workplaces_km', 'office_km', 'market_shop_km', 'raion_popul']
extra3 = ['museum_km', 'build_year']
floats = []
ints = []
objects = []
for i in range(len(feature_types)):
    if feature_types.values()[i] == 'int64':
        ints.append(feature_types.keys()[i])
    elif feature_types.values()[i] == 'float64':
        floats.append(feature_types.keys()[i])
    elif feature_types.values()[i] == 'object':
        objects.append(feature_types.keys()[i])

#%%
"""
Decide what the features space will include.
"""
random_floats = list(np.random.choice(floats,35,replace = False))
features = list(np.unique(base + random_floats))

#%%
"""
Drop feature columns with missing values. Will match train and test columns
later. 
"""
tmp = features[:]
for feat in tmp: 
    if feat == 'timestamp':
        continue
    val = sum(pd.isnull(train_raw[feat]))
    if val > 0:
        print 'removing ' + feat
        features.remove(feat)

#%%
price = train_raw.price_doc
train = train_raw[features]
test = test_raw[features]

#%%
"""
Handle case features
## Trim down the sub_area levels to the top 25 and put all others as there
       own separate level
## Break down timestamp into year month components, then update the dtype
    dictionary and features list
"""
if 'sub_area' in features:
    freq_area = np.array(train.loc[:, 'sub_area'].value_counts()[:30].index)
    train_raw.loc[~train['sub_area'].isin(freq_area), 'sub_area'] = 'other'
    test_raw.loc[~test['sub_area'].isin(freq_area), 'sub_area'] = 'other'

if 'timestamp' in features:
    if not train.timestamp.dtype == 'datetime64[ns]':
        train.timestamp = train.timestamp.astype('datetime64[ns]')
    if not test.timestamp.dtype == 'datetime64[ns]':
        test.timestamp = test.timestamp.astype('datetime64[ns]')
    train.loc[:, 'yearmonth'] = train.loc[:, 'timestamp'].apply(lambda x: x.strftime('%Y%m'))
    test.loc[:, 'yearmonth'] = test.loc[:, 'timestamp'].apply(lambda x: x.strftime('%Y%m'))
    train.drop('timestamp', inplace = True, axis = 1)
    test.drop('timestamp', inplace = True, axis = 1)
    features.remove('timestamp')
    features.append('yearmonth')
    feature_types['yearmonth'] = 'int64'
    del feature_types['timestamp']

#%%
"""
Go through each feature. Find its dtype in the dictionary and convert it
if it doesn't match.

Do this for the training and test set
"""
for feat in features:
    if not train[feat].dtype == feature_types[feat]:
        train[feat] = train[feat].astype(feature_types[feat])
    if not test[feat].dtype == feature_types[feat]:
        test[feat] = test[feat].astype(feature_types[feat])
    
        
#%%
"""
Must transfer categorical columns into dummy variables if they exist.
Then update the features to reflect the expanded columns.
"""
train = pd.get_dummies(train)
test = pd.get_dummies(test)

#%%
"""
If for some reason the column number between the test and training set aren't
equal, then drop the columns in the test set that don't match in the training
set.
"""

if train.shape[1] > test.shape[1]:
    train = train[test.columns]
else:
    test = test[train.columns]
    
features = list(train.columns)

#%%
# Scale the train and test data for the regression and subsequent prediction
scaler_Xtrain = preprocessing.StandardScaler().fit(train)
Xtrain = scaler_Xtrain.transform(train)
Xtest = scaler_Xtrain.transform(test)
Ytrain = train_raw.price_doc

#%%
### Coarse search for the correct hyperparamater for the elasticnet regression
alphas_elastic = np.logspace(-7, 16, 100)
coef_elastic = []
elastic = linear_model.ElasticNet(l1_ratio = 1.0)

for i in alphas_elastic:
    elastic.set_params(alpha = i)
    elastic.fit(Xtrain, Ytrain)
    coef_elastic.append(elastic.coef_)

#%%
# Plot how the coefficients change over the alpha range
df_coef = pd.DataFrame(coef_elastic, index=alphas_elastic, columns=features)
#df_coef = pd.DataFrame(coef_elastic)
title = 'Lasso coefficients as a function of the regularization'
df_coef.plot(logx=True, title=title, figsize=(13, 13))
plt.xlabel('alpha')
plt.ylabel('coefficients')
plt.legend(loc=1)
plt.savefig('runs/lasso_coefs' + time.strftime('%Y%m%d-%H%M') + '.png')
plt.show()

#%%
from sklearn.model_selection import GridSearchCV
## set the possible parameters from 3 to 30

## 'alpha' must match an actual parameter name
grid_param = [{'alpha': np.logspace(-5,10,100),
               'l1_ratio': [0.7, 0.9, 1.0]}]

## fit all models with grid search to find optimal alpha
para_search = GridSearchCV(estimator=elastic, param_grid=grid_param, 
                           scoring=mse, cv=10).fit(Xtrain, Ytrain)

#%%
"""
Retrieve and fit best estimator
"""
elastic = para_search.best_estimator_
elastic.fit(Xtrain, Ytrain)

#%%
"""
Visualize the evolution of the errors over the alpha range
"""


#%%
"""
Write all the important information to a file
"""
coefs = list(elastic.coef_)
file_name = 'runs/lasso_run' + time.strftime('%Y%m%d-%H%M.log')
with open(file_name, 'w') as outfile:
    for f in features:
        outfile.write(str(train[f].dtype) + ':' + f + ':' + str(coefs[features.index(f)]))
        outfile.write('\n')
    outfile.write('best CV score:' + str(para_search.best_score_))
    outfile.write('\n')
    outfile.write('best params:' + str(para_search.best_params_))
    outfile.write('\n')
    outfile.write('train MSE:' + str(mean_squared_error(elastic.predict(Xtrain), Ytrain)))
    outfile.write('\n')
    determination = "Adjusted R^2:%.4f" %adj_Rsq(elastic, Xtrain, Ytrain)
    outfile.write(determination)
    outfile.write('\n')
    outfile.write("AIC:" + str(AIC(elastic, Xtrain, Ytrain)))
    outfile.write('\n')
    outfile.write("BIC:" + str(BIC(elastic, Xtrain, Ytrain)))
#%%
"""
Specifically looking at the coefficients
"""
#sum(abs(elastic.coef_[:]) < 10)

#%%
"""
In order to predict prices from the standardized coefficients,
I must scale the test data using the mean and sd from the training data
"""
# Predict some prices
y_pred = elastic.predict(Xtest)

#%%
# Flip negative values (not ideal)
print 'flipping {} negative values'.format(np.sum(y_pred < 0))
y_pred[y_pred < 0] = y_pred[y_pred < 0] * -1

#%%
# Write them to csv for submission
submit = pd.DataFrame({'id': np.array(test.index), 'price_doc': y_pred})
submit.to_csv('submissions/submission_elasticnet.csv', index=False)
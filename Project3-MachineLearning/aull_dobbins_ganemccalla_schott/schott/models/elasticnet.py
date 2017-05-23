#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue May 23 00:43:22 2017

@author: mes
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os
from sklearn import linear_model
from sklearn.preprocessing import LabelEncoder
from sklearn import preprocessing

SUBSET = False

#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun May 21 20:25:04 2017

@author: mes

Implement an ElasticNet model for the Sberbank Housing Kaggle Competition.
It must be flexible in the sense of bringing in data
"""
#%%
DIR_PATH = '../../data/'
train_file = 'imputedTrainLimitedVariables.csv'
test_file = 'imputedTestLimitedVariables.csv'

## loading data as Pandas dataframes
"""
train_raw = pd.read_csv(os.path.join(DIR_PATH, train_file), 
                        header='infer', 
                        index_col='id',
                        parse_dates=['timestamp'])
test_raw = pd.read_csv(os.path.join(DIR_PATH, test_file), 
                       header='infer', 
                       index_col='id',
                       parse_dates=['timestamp'])
"""

train_raw = pd.read_csv(os.path.join(DIR_PATH, train_file), 
                        header='infer')
test_raw = pd.read_csv(os.path.join(DIR_PATH, test_file), 
                       header='infer')

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
    test = train_raw.copy()
    features = list(test.columns)
    
if 'timestamp' in features:
    train.drop('timestamp', inplace = True, axis = 1)
    test.drop('timestamp', inplace = True, axis = 1)
    features.remove('timestamp')
if 'price_doc' in features:
    train.drop('price_doc', inplace = True, axis = 1)
    test.drop('price_doc', inplace = True, axis = 1)
    features.remove('price_doc')

#%%    
## Must encode object columns for the model
for f in train.columns:
    if train[f].dtype=='object':
        print('encoding training feature: {}'.format(f))
        lbl = LabelEncoder()
        train.loc[:,f] = lbl.fit_transform(train.loc[:,f])
        
for f in test.columns:
    if test[f].dtype=='object':
        print('encoding test feature: {}'.format(f))
        lbl = LabelEncoder()
        test.loc[:,f] = lbl.fit_transform(test.loc[:,f])

#%%
# Scale the data for the regression
scaler_Xtrain = preprocessing.StandardScaler().fit(train)
scaler_Ytrain = preprocessing.StandardScaler().fit(train_raw.price_doc)
scaler_test = preprocessing.StandardScaler().fit(test)
Xtrain = scaler_Xtrain.transform(train)
Ytrain = scaler_Ytrain.transform(train_raw.price_doc)
Xtest = scaler_test.transform(test)

#%%
### Coarse search for the correct hyperparamater for the elasticnet regression
alphas_elastic = np.logspace(-20, 20, 100)
coef_elastic = []

for i in alphas_elastic:
    elastic = linear_model.ElasticNet(l1_ratio =1.0)
    elastic.set_params(alpha = i)
    elastic.fit(Xtrain, Ytrain)
    coef_elastic.append(elastic.coef_)

# Plot how the coefficients change over the alpha range
df_coef = pd.DataFrame(coef_elastic, index=alphas_elastic, columns=features)
#df_coef = pd.DataFrame(coef_elastic)
title = 'Lasso coefficients as a function of the regularization'
df_coef.plot(logx=True, title=title)
plt.xlabel('alpha')
plt.ylabel('coefficients')
plt.legend(loc=1)
plt.show()

#%%
"""
Must create custom mean squared error function to pass to the grid search
because this function doesn't exist by default.
"""

from sklearn.metrics import mean_squared_error

def mse(estimator, X_test, y_test):
    predictions = estimator.predict(X_test)
    return mean_squared_error(y_test, predictions)

#%%
from sklearn.model_selection import GridSearchCV
## set the possible parameters from 3 to 30

## 'alpha' must match an actual parameter name
grid_param = [{'alpha': np.logspace(-5,2,100)}]
## fit all models
para_search = GridSearchCV(estimator=elastic, param_grid=grid_param, scoring=mse, cv=10).fit(Xtrain, Ytrain)

#%%
# Retrieve the alpha corresponding to the minimum mse
scores = para_search.cv_results_['mean_test_score']
min_alpha = np.where(scores == np.min(scores))
bestalpha = para_search.cv_results_['param_alpha'][min_alpha][0]

#%%
# Fit the new model 
lasso = linear_model.ElasticNet(alpha = bestalpha, l1_ratio = 1.0)
lasso.fit(train, train_raw.price_doc)
# determination
print("The determination of ElasticNet is: %.4f" %lasso.score(train, train_raw.price_doc))
y_pred = lasso.predict(test)
# Flip negative values (not ideal)
print 'flipping {} negative values'.format(np.sum(y_pred < 0))
y_pred[y_pred < 0] = y_pred[y_pred < 0] * -1

#%%
# Write them to csv for submission
submit = pd.DataFrame({'id': np.array(test.index), 'price_doc': y_pred})
submit.to_csv('submissions/submission_elasticnet.csv', index=False)
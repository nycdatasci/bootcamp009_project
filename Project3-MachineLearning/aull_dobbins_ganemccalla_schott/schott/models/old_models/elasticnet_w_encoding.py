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
from math import log
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
It must be flexible in the sense of bringing in data. The cleaning of data
for this model may be moved to another file entirely. 
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
    test = test_raw.copy()
    features = list(train.columns)
    
if 'timestamp' in features:
    train.drop('timestamp', inplace = True, axis = 1)
    test.drop('timestamp', inplace = True, axis = 1)
    features.remove('timestamp')
if 'price_doc' in features:
    train.drop('price_doc', inplace = True, axis = 1)
    features.remove('price_doc')

#%% 
"""
Must transfer categorical columns into dummy variables
"""
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
# Scale the train and test data for the regression and subsequent prediction
scaler_Xtrain = preprocessing.StandardScaler().fit(train)
Xtrain = scaler_Xtrain.transform(train)
Xtest = scaler_Xtrain.transform(test)
Ytrain = train_raw.price_doc

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
plt.savefig('lasso_coefs' + time.strftime('%Y%m%d-%H%M') + '.png')
plt.show()

#%%
"""
Must create custom mean squared error function to pass to the grid search
because this function doesn't exist by default.

Also creating AIC and BIC to compare different models
"""

from sklearn.metrics import mean_squared_error
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

#%%
from sklearn.model_selection import GridSearchCV
## set the possible parameters from 3 to 30

## 'alpha' must match an actual parameter name
grid_param = [{'alpha': np.logspace(-5,2,100)}]

## fit all models with grid search to find optimal alpha
para_search = GridSearchCV(estimator=elastic, param_grid=grid_param, 
                           scoring=mse, cv=10).fit(Xtrain, Ytrain)

#%%
"""
Write all the important information to a file

"""

file_name = 'runs/lasso_run' + time.strftime('%Y%m%d-%H%M.log')
with open(file_name, 'w') as outfile:
    for f in features:
        #l = train[f].dtype + ':' + f
        outfile.write(str(train[f].dtype) + ':' + f)
        outfile.write('\n')
    outfile.write('best CV score:' + str(para_search.best_score_))
    outfile.write('\n')
    outfile.write('best params:' + str(para_search.best_params_))
    outfile.write('\n')
    outfile.write('train MSE:' + str(mean_squared_error(lasso.predict(Xtrain), Ytrain)))
    outfile.write('\n')
    determination = "Adjusted R^2:%.4f" %adj_Rsq(lasso, Xtrain, Ytrain)
    outfile.write(determination)
    outfile.write('\n')
    outfile.write("AIC:" + str(AIC(lasso, Xtrain, Ytrain)))
    outfile.write('\n')
    outfile.write("BIC:" + str(BIC(lasso, Xtrain, Ytrain)))
#%%
"""
Specifically looking at the coefficients
"""
sum(abs(lasso.coef_[:]) < 1e-4)

#%%
"""
In order to predict prices from the standardized coefficients,
I must scale the test data using the mean and sd from the training data
"""
# Predict some prices
y_pred = lasso.predict(Xtest)

#%%
# Flip negative values (not ideal)
print 'flipping {} negative values'.format(np.sum(y_pred < 0))
y_pred[y_pred < 0] = y_pred[y_pred < 0] * -1

#%%
# Write them to csv for submission
submit = pd.DataFrame({'id': np.array(test.index), 'price_doc': y_pred})
submit.to_csv('submissions/submission_elasticnet.csv', index=False)
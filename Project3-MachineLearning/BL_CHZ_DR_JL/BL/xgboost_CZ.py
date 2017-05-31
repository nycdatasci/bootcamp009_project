
import pandas as pd
import seaborn as sns
import numpy as np
import scipy as sp
import os
import xgboost as xgb
import matplotlib.pyplot as plt
import matplotlib

# load data
trainNew=pd.read_csv(r'C:\Users\qiube\Documents\Data Science Academy\Machine Learning\Project\test2\trainnew.csv')
testNew=pd.read_csv(r'C:\Users\qiube\Documents\Data Science Academy\Machine Learning\Project\test2\testnew.csv')


train=pd.read_csv(r'C:\Users\qiube\Documents\Data Science Academy\Machine Learning\Project\test2\train.csv')
test=pd.read_csv(r'C:\Users\qiube\Documents\Data Science Academy\Machine Learning\Project\test2\test.csv')
macro=pd.read_csv(r'C:\Users\qiube\Documents\Data Science Academy\Machine Learning\Project\test2\macro.csv')

trainNew=pd.merge(train, macro, how='left', on ='timestamp')
testNew=pd.merge(test, macro, how='left', on ='timestamp')

# some EDA ##########################################################################
# plot transaction volumn ======================================================
import datetime
import matplotlib.dates as mdates

trainNew['date']=pd.to_datetime(trainNew['timestamp'])  
testNew['date']=pd.to_datetime(testNew['timestamp'])  

years = mdates.YearLocator()   # every year
yearsFmt = mdates.DateFormatter('%Y')
ts_vc_train = trainNew['date'].value_counts()
ts_vc_test = testNew['date'].value_counts()

f, ax = plt.subplots(figsize=(12, 6))
plt.bar(left=ts_vc_train.index, height=ts_vc_train)
plt.bar(left=ts_vc_test.index, height=ts_vc_test)
ax.xaxis.set_major_locator(years)
ax.xaxis.set_major_formatter(yearsFmt)
ax.set(title='Number of transactions by day', ylabel='count')


## label encoding ##############################################################
from sklearn.preprocessing import LabelEncoder

label_encoder = dict()

for feature in (['product_type', 'sub_area','big_road1_1line','thermal_power_plant_raion','incineration_raion',\
                 'oil_chemistry_raion','radiation_raion','railroad_terminal_raion','nuclear_reactor_raion','detention_facility_raion',\
                'culture_objects_top_25','big_market_raion','ecology','water_1line','railroad_1line']):
    print('encoding feature: {}'.format(feature))
    label_encoder[feature] = LabelEncoder()
    label_encoder[feature].fit(trainNew[feature])
    trainNew.loc[:, feature] = label_encoder[feature].transform(trainNew[feature])
    testNew.loc[:, feature] = label_encoder[feature].transform(testNew[feature])


# add density
trainNew['density'] = trainNew['raion_popul'] / trainNew['area_m']
testNew['density'] = testNew['raion_popul'] / testNew['area_m']
trainNew['date']=pd.to_datetime(trainNew['timestamp'])  
testNew['date']=pd.to_datetime(testNew['timestamp'])  
 
# Add month-year
month_year = (trainNew.month + trainNew.year * 100)
month_year_cnt_map = month_year.value_counts().to_dict()
trainNew['month_year_cnt'] = month_year.map(month_year_cnt_map)

month_year = (testNew.month + testNew.year * 100)
month_year_cnt_map = month_year.value_counts().to_dict()
testNew['month_year_cnt'] = month_year.map(month_year_cnt_map)

 
#Add week-year count
week_year = (trainNew.date.dt.weekofyear + trainNew.date.dt.year * 100)
week_year_cnt_map = week_year.value_counts().to_dict()
trainNew['week_year_cnt'] = week_year.map(week_year_cnt_map)

week_year = (testNew.date.dt.weekofyear + testNew.date.dt.year * 100)
week_year_cnt_map = week_year.value_counts().to_dict()
testNew['week_year_cnt'] = week_year.map(week_year_cnt_map)

# Add month and day-of-week 
trainNew['dow'] = trainNew.date.dt.dayofweek
testNew['dow'] = testNew.date.dt.dayofweek
       
# Other feature engineering
trainNew['rel_floor'] = trainNew['floor'] / trainNew['max_floor'].astype(float)
testNew['rel_floor'] = testNew['floor'] / testNew['max_floor'].astype(float)


trainNew['rel_kitch_sq'] = trainNew['kitch_sq'] / trainNew['full_sq'].astype(float)
testNew['rel_kitch_sq'] = testNew['kitch_sq'] / testNew['full_sq'].astype(float)

# =============================================================================
# EDA with engineered features

f, ax = plt.subplots(figsize=(10, 6))
sa_price = trainNew.groupby('sub_area')[['density', 'price_doc']].median()
sns.regplot(x="density", y="price_doc", data=sa_price, scatter=True, truncate=True)
ax.set(title='Median home price by raion population density (people per sq. km)')

f, ax = plt.subplots(figsize=(10, 6))
sa_price = trainNew.groupby('sub_area')[['trc_sqm_5000', 'price_doc']].median()
sns.regplot(x="trc_sqm_5000", y="price_doc", data=sa_price, scatter=True, truncate=True)
ax.set(title='Median home price by The square of shopping mall')

f, ax = plt.subplots(figsize=(10, 6))
sa_price = trainNew.groupby('sub_area')[['rel_floor', 'price_doc']].median()
sns.regplot(x="rel_floor", y="price_doc", data=sa_price, scatter=True, truncate=True)
ax.set(title='Median home price by Rel Floor')
  
# ================================================================================
# load selected features from csv file       
selected = pd.read_csv(r'C:\Users\qiube\Documents\Data Science Academy\Machine Learning\Project\test2\key_features.csv')
selected_predictors = list(selected['Predictors'])

# additional feature selections
add_features=selected_predictors
add_features.append('year')
add_features.append('month')
add_features.append('density')
add_features.append('cpi')
add_features.append('ppi')
#selected_predictors.append('gdp_deflator')
#selected_predictors.append('eurrub')
#selected_predictors.append('mortgage_value')
                             

add_features.append('month_year_cnt')
add_features.append('week_year_cnt')
add_features.append('dow')
add_features.append('rel_floor')
add_features.append('rel_kitch_sq')

# remove features
add_features.remove('incineration_raion')
add_features.remove('timestamp')

#selected_predictors.remove('male_f')
#selected_predictors.remove('16_29_female')
#selected_predictors.remove('0_17_female')


add_features.remove('price_doc')
         
# Convert to numpy values #####################################################
model_features =add_features

X_train = trainNew[model_features].values
Y_train = train['log_price_doc'].values
X_test = testNew[model_features].values


# train vs val data set split (without cv)#####################################
size_ = 7000  # select around 30% as val dataset
X_train_sub, Y_train_sub = X_train[:-size_],  Y_train[:-size_]
X_val, Y_val = X_train[-size_:],  Y_train[-size_:]

# check no. of rows and columsn
X_train_sub.shape
Y_train_sub.shape
X_val.shape
Y_val.shape
# ================================================================


# Create DMatrix for xgboost
dtrain = xgb.DMatrix(X_train, 
                    Y_train,feature_names=model_features)


dtest = xgb.DMatrix(X_test,feature_names=model_features)

dtrain_sub = xgb.DMatrix(X_train_sub, 
                        Y_train_sub, 
                        feature_names=model_features)
d_val = xgb.DMatrix(X_val, 
                    Y_val, 
                    feature_names=model_features)


# hyperparameters
#xgb_params = {
#    'eta': 0.02,
#    'max_depth': 5,
#    'subsample': .8,
#    'colsample_bytree': 0.7,
#    'objective': 'reg:linear',
#    'eval_metric': 'rmse',
#    'silent': 1
#}

# Cross Validation ############################################################

#xgb_params = {
#    'eta': 0.01,
#    'max_depth': 7,
#    'subsample': .8,
#    'colsample_bytree': 0.8,
#    'objective': 'reg:linear',
#    'eval_metric': 'rmse',
#    'silent': 0
#}

# customize error evaluation for xgboost with Kaggle formula 
import math
def evalerror(preds, dtrain):
    labels = dtrain.get_label()
    labels = labels.tolist()
    preds = preds.tolist()
    terms_to_sum = [(math.log(labels[i] + 1) - math.log(preds[i] + 1)) ** 2.0 for i,pred in enumerate(labels)]
    return 'error', (sum(terms_to_sum) * (1.0/len(preds))) ** 0.5

# set up xgboost parameters
xgb_params = {
    'eta': 0.02,
    'max_depth': 5,
    'subsample': .8,
    'colsample_bytree': 0.7,
    'objective': 'reg:linear',
    'silent': 1
}

sub_model = xgb.train(xgb_params, 
                      dtrain_sub, 
                      num_boost_round=3000,
                      evals=[(d_val, 'val')],
                      # assign customized evalution of error
                      feval=evalerror,
                      early_stopping_rounds=50, 
                      verbose_eval=20)

# other trials of parameters
#sub_model = xgb.train(xgb_params, 
#                      dtrain_sub, 
#                      num_boost_round=3000,
#                      evals=[(d_val, 'val')],
#                      early_stopping_rounds=50, 
#                      verbose_eval=20)

# xgboost cross validation ( not as good as the test val split)################
#model = xgb.cv(xgb_params,
#               dtrain=dtrain, 
#               num_boost_round=3000,
#                      nfold=5,
#                      early_stopping_rounds=20,
#                              verbose_eval=50)

#sub_model[['train-rmse-mean', 'test-rmse-mean']].plot()
#best_boost_rounds = len(model)
#best_model = xgb.train(dict(xgb_params, silent=0), 
#                       dtrain, num_boost_round= best_boost_rounds)
#
#fig, ax = plt.subplots(1, 1, figsize=(8, 13))
#pd.DataFrame(best_model.get_fscore().items(), columns=['feature','importance']).sort_values('importance', ascending=False)
# ==============================================================================

# plot the importance of features
fig, ax = plt.subplots(figsize=(60, 80))
xgb.plot_importance(sub_model,ax=ax)
matplotlib.rcParams.update({'font.size': 30})
plt.rc('xtick', labelsize=22)    # fontsize of the tick labels
plt.rc('ytick', labelsize=22)    # fontsize of the tick labels
plt.rc('figure', titlesize=30)  # fontsize of the figure title

full_model = xgb.train(xgb_params,
                       dtrain, 
                       num_boost_round=sub_model.best_iteration,
                       verbose_eval=20)

log_y_pred = full_model.predict(dtest)
y_pred = np.exp(log_y_pred) - 1
                              
submit = pd.DataFrame({'id': np.arange(30474,38136), 'price_doc': y_pred})
submit.to_csv(r'C:\Users\qiube\Documents\Data Science Academy\Machine Learning\Project\test2\no_incin_Bo_param.csv', index=False)



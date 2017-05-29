from sklearn import linear_model
from sklearn.grid_search import GridSearchCV
from sklearn.ensemble import RandomForestRegressor
from sklearn.cross_validation import train_test_split
import xgboost as xgb
from sklearn import metrics
from external_helper_luigi import custom_out, forward_selected, auto_grid
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import Imputer, StandardScaler
from sklearn.model_selection import cross_val_score
import pandas as pd
import numpy as np
import sys, os
sys.path.insert(0, os.path.join(os.getcwd(),'userInput/'))
from user_input import *


target_variable = ["price_doc"]
cv_all = 10

def train_xg_boost(dataframe, xgb_param_dict = 'predefined'):
    np.random.seed(0)
    #X_train, X_test, y_train, y_test = train_test_split(dataframe.drop(target_variable, axis=1),
    #                                                    dataframe[target_variable[0]])
                                                        
    #custom_out('Shape of split training dataset = {}'.format(X_train.shape))
    df_columns = dataframe.columns
    #dtrain = xgb.DMatrix(X_train, y_train, feature_names=df_columns)
    dtrain_all = xgb.DMatrix(dataframe.drop(target_variable,axis=1), dataframe[target_variable[0]])
    #dval = xgb.DMatrix(X_test, y_test, feature_names=df_columns)

    if xgb_param_dict =='predefined':
        xgb_params = user_xgb_param()
    else:
        xgb_params = xgb_param_dict
        xgb_params['eval_metric']='rmse'

    for param in xgb_params:
        custom_out('XGB Parameter {} = {}'.format(param, xgb_params[param]))
                                                                    
    cv_output = xgb.cv(xgb_params, dtrain_all, num_boost_round=user_xgb_cv()['num_boost_round'],
                       early_stopping_rounds=user_xgb_cv()['early_stopping_round'],
                       verbose_eval=20, show_stdv=False)

    nround = cv_output.shape[0]
    custom_out('CV XGBoost best RMSE = {}'.format(min(cv_output['test-rmse-mean'])))
    custom_out('CV XGBoost output nround = {}'.format(nround))
    
    xgb_out = xgb.train(xgb_params, dtrain_all, num_boost_round=nround)

    cv_test_pred = xgb_out.predict(xgb.DMatrix(dataframe.drop(target_variable,axis=1)))
    ### test your predictions
    mse = metrics.mean_squared_error(dataframe[target_variable[0]], cv_test_pred)
    r2 = metrics.r2_score(dataframe[target_variable[0]], cv_test_pred)
    ### and print the report
    custom_out('XGBoost Final RMSE = {}\nXGBoost Final R2 = {}'.format(mse**0.5, r2))

    feature_importance = xgb_out.get_fscore()
    df_features = pd.DataFrame({'names':feature_importance.keys(),'values':feature_importance.values()})
    print df_features.sort_values('values', ascending=False)[:]
    #custom_out('Feature importance: {}.format()')

    return xgb_out

def train_xg_boost2(dataframe, xgb_param_dict = 'predefined'):
    np.random.seed(0)
    #X_train, X_test, y_train, y_test = train_test_split(dataframe.drop(target_variable, axis=1),
    #                                                    dataframe[target_variable[0]])
                                                        
    #custom_out('Shape of split training dataset = {}'.format(X_train.shape))
    df_columns = dataframe.columns
    #dtrain = xgb.DMatrix(X_train, y_train, feature_names=df_columns)
    dtrain_all = xgb.DMatrix(dataframe.drop(target_variable,axis=1), dataframe[target_variable[0]])
    #dval = xgb.DMatrix(X_test, y_test, feature_names=df_columns)

    if xgb_param_dict =='predefined':
        xgb_params = user_xgb_param()
    else:
        xgb_params = xgb_param_dict
        xgb_params['eval_metric']='rmse'

    for param in xgb_params:
        custom_out('XGB Parameter {} = {}'.format(param, xgb_params[param]))
    
    xgb_out = xgb.train(xgb_params, dtrain_all, num_boost_round=980)

    cv_test_pred = xgb_out.predict(xgb.DMatrix(dataframe.drop(target_variable,axis=1)))
    ### test your predictions
    mse = metrics.mean_squared_error(dataframe[target_variable[0]], cv_test_pred)
    r2 = metrics.r2_score(dataframe[target_variable[0]], cv_test_pred)
    ### and print the report
    custom_out('XGBoost Final RMSE = {}\nXGBoost Final R2 = {}'.format(mse**0.5, r2))

    feature_importance = xgb_out.get_fscore()
    df_features = pd.DataFrame({'names':feature_importance.keys(),'values':feature_importance.values()})
    print df_features.sort_values('values', ascending=False)[0:5]
    #custom_out('Feature importance: {}.format()')

    return xgb_out

def train_random_forest(dataframe):
    np.random.seed(0)
    X_train = dataframe.drop(target_variable, axis=1)
    y_train = dataframe[target_variable[0]]
    parameter_grid = user_forest_param()
    custom_out("Training Random Forest")
    pipeline = Pipeline([("imputer", Imputer(strategy="median",
                                              axis=0)),
                          ("scaler", StandardScaler()),
                          ("forest", RandomForestRegressor(random_state=0,
                                                           n_estimators=100))])
    grid_search = GridSearchCV(estimator=pipeline,
                               param_grid=parameter_grid,
                               cv=cv_all,
                               verbose=2,
                               n_jobs=5,
                               refit=True)
    return auto_grid(grid_search, X_train, y_train, 'RF')

def train_forward_selected(dataframe):
    #I'm assuming we're only being fed numeric valued-columns
    #Leaving cross-validation up to Yabin
    custom_out("Training LinReg Forward Selection")

    linreg_model = forward_selected(dataframe, target_variable[0])
    print linreg_model.summary()
    return linreg_model

def train_model_ridge(dataframe):
    np.random.seed(0)
    X_train = dataframe.drop(target_variable, axis=1)
    y_train = dataframe[target_variable[0]]
    parameter_grid = user_ridge_param()
    custom_out("Training Ridge Regression")
    pipeline = Pipeline([("imputer", Imputer(strategy="median",
                                              axis=0)),
                          ("scaler", StandardScaler()),
                          ("ridge", linear_model.Ridge())])
    grid_search = GridSearchCV(estimator=pipeline,
                               param_grid=parameter_grid,
                               cv=cv_all,
                               verbose=2,
                               n_jobs=5,
                               refit=True)
    return auto_grid(grid_search, X_train, y_train, 'RLR')


def train_model_xgb_grid(dataframe):
    X_train = dataframe.drop(target_variable, axis=1)
    y_train = dataframe[target_variable[0]]

    print "Training XGB Grid Search"
    estimator = xgb.XGBRegressor(n_estimators=980)
    parameter_grid = user_xgbgrid_param()
    
    grid_search = GridSearchCV(estimator=estimator,
                               param_grid=parameter_grid,
                               cv=5,
                               verbose=2,
                               n_jobs=-1,
                               refit=False)
    
    grid_search.fit(X_train, y_train)
    custom_out('Best score {}: {}'.format('XGB', grid_search.best_score_))
    custom_out('Best parameters {}: {}'.format('XGB', grid_search.best_params_))
    print '\n All grid results: \n'
    print grid_search.grid_scores_
    xgb_param_dict = grid_search.best_params_
    return train_xg_boost2(dataframe, xgb_param_dict)

def train_Huber(dataframe):
    custom_out("Training Huber Regression")
    np.random.seed(0)
    X_train = dataframe.drop(target_variable, axis=1)
    y_train = dataframe[target_variable[0]]

    pipeline = Pipeline([("imputer", Imputer(strategy="median",
                                              axis=0)),
                          ("scaler", StandardScaler()),
                          ("huber", linear_model.HuberRegressor())])

    parameter_grid = user_huber_param()

    grid_search = GridSearchCV(estimator=pipeline,
                               param_grid=parameter_grid,
                               cv=cv_all,
                               verbose=2,
                               n_jobs=5,
                               refit=True,
                               seed=0)
    return auto_grid(grid_search, X_train, y_train, 'HLR')

def train_elastic_model(dataframe):
    custom_out("Training EN Regression")
    np.random.seed(0)
    X_train = dataframe.drop(target_variable, axis=1)
    y_train = dataframe[target_variable[0]]

    pipeline = Pipeline([("imputer", Imputer(strategy="median",
                                              axis=0)),
                          ("scaler", StandardScaler()),
                          ("en", linear_model.ElasticNet())])

    parameter_grid = user_en_param()

    grid_search = GridSearchCV(estimator=pipeline,
                               param_grid=parameter_grid,
                               cv=cv_all,
                               verbose=2,
                               n_jobs=5,
                               refit=True,
                               seed=0)
    return auto_grid(grid_search, X_train, y_train, 'EN')

if __name__ == '__main__':
    pass

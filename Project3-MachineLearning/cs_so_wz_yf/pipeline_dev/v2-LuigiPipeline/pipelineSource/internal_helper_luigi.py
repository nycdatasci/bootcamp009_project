import time
import pandas as pd
from regressor import *
import xgboost as xgb
import sys
import numpy as np
from external_helper_luigi import custom_out
import os
import pickle

def function_mappings():
	return {'xgb':train_xg_boost,
						'rf':train_random_forest,
						'flr':train_forward_selected,
						'rlr':train_model_ridge,
						'xgbgrid':train_model_xgb_grid,
						'en':train_elastic_model,
						'hlr':train_Huber}

def column_mappings():
	return {'xgb':'xgb',
			'rf':'xgb',
			'flr':'lr',
			'rlr':'lr',
			'xgbgrid':'xgb',
			'hlr':'lr',
            'en':'lr'}

def preprocess_data(dataframe, model_str, test_train):
    data_str = column_mappings()[model_str]
    if test_train == 'train':
        if data_str == 'lr':
            df = col_select(dataframe, model_str, test_train)
            df['price_doc'] = np.log(df['price_doc']+1)
        else:
            df = col_select(dataframe, model_str, test_train)
            #If we're dropping full_sq, need to have addl column selected from dataframe
            #df = col_select(dataframe, model_str, test_train, 'full_sq')
            df['price_doc'] = df['price_doc']/df['full_sq']
            #Keeping full_sq in feature list
            #df = df.drop('full_sq', axis=1)
    else:
        df = col_select(dataframe, model_str, test_train)
    return df

def prediction_to_submission(dataframe, predictions, model_string):
    #Post processing from log(price+1) to price
    #Replace with regex search for 'lr' in model_string
    data_str = column_mappings()[model_string]
    debug = False
    if debug:
    	pass
    else:
    	if data_str == 'lr':
    		predictions = np.exp(predictions) - 1
    		custom_out('Transformed back from log(price)')
    	#Post processing for price/sqft to price
    	else:
    		predictions = dataframe['full_sq']*predictions
    return pd.DataFrame({ 'id': dataframe['id'],
    					  'price_doc': predictions})

def model_choice(model_string, dataframe):
	return function_mappings()[model_string](dataframe)

def test_postprocess(model_string, dataframe):
    data_str = column_mappings()[model_string]
    if model_string == 'rf':
        return dataframe
    elif data_str == 'xgb':
        return xgb.DMatrix(dataframe)
    else:
        return dataframe

def col_select(dataframe, model_str, test_train, addl_col=None):
    data_str = column_mappings()[model_str]
    with open(os.path.join(os.getcwd(), "data", "{}_col.pkl".format(data_str)), "rb") as fp:
        col_names = pickle.load(fp)
    if test_train == 'train':
    	if addl_col == None:
        	frames = [dataframe['price_doc'], dataframe[col_names]]
        else:
        	frames = [dataframe['price_doc'], dataframe[col_names], dataframe[addl_col]]
        return pd.concat(frames, axis=1)
    else:
        return test_postprocess(model_str, dataframe[col_names])

def xgb_lr():
	pass
	#Convert price_doc to price/sq

    #Split dataframe

    #Train XGB

    #Append predicted price/sq to dataframe

    #Convert price_doc (original) to log(price+1)

    #Split dataframe

    #Train linear model

    #Return fit

if __name__ == '__main__':
    pass
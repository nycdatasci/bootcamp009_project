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
						#'en':train_elastic_model,
						'hlr':train_Huber}

def column_mappings():
	return {'xgb':'xgb',
			'rf':'xgb',
			'flr':'lr',
			'rlr':'lr',
			'xgbgrid':'xgb',
			'hlr':'lr'}

def preprocess_data(dataframe, model_str, test_train):
	data_str = column_mappings()[model_str]

	if data_str == 'lr':
		df = col_select(dataframe, model_str, test_train)
		df['price_doc'] = np.log(df['price_doc']+1)
	else:
		df = col_select(dataframe, model_str, test_train, 'totalsq')
		df['price_doc'] = df['price_doc']/df['totalsq']
		df.drop('totalsq', axis=1)
	return df

def prediction_to_submission(dataframe, predictions, model_string):
    #Post processing from log(price+1) to price
    #Replace with regex search for 'lr' in model_string
    debug = False
    if debug:
    	pass
    else:
    	if (model_string == 'flr') | (model_string == 'rlr') | (model_string == 'hlr'):
    		predictions = np.exp(predictions) - 1
    		custom_out('Transformed back from log(price)')
    	#Post processing for price/sqft to price
    	else:
    		predictions = dataframe['totalsq']*predictions
    return pd.DataFrame({ 'id': dataframe['id'],
    					  'price_doc': predictions})

def model_choice(model_string, dataframe):
	return function_mappings()[model_string](dataframe)

def test_postprocess(model_string, dataframe):
	if (model_string == 'xgb') | (model_string == 'xgbgrid'):
		return xgb.DMatrix(col_select(dataframe, model_string, 'test', 'totalsq'))
	else:
		return col_select(dataframe.drop('id', axis=1), model_string, 'test')

def col_select(dataframe, model_str, test_train, addl_col=None):
    #with open(os.path.join(os.getcwd(), "data", data_str, "_col.pkl"), "rb") as fp:
    data_str = column_mappings()[model_str]
    with open(os.path.join(os.getcwd(), "data", "{}_col_debug.pkl".format(data_str)), "rb") as fp:
        col_names = pickle.load(fp)

    if test_train == 'train':
    	if addl_col == None:
        	frames = [dataframe['price_doc'], dataframe[col_names]]
        else:
        	frames = [dataframe['price_doc'], dataframe[col_names], dataframe[addl_col]]
        return pd.concat(frames, axis=1)
    else:
        if addl_col == None:
        	return dataframe[col_names]
        else:
        	return pd.concat([dataframe[col_names], dataframe[addl_col]], axis=1)

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
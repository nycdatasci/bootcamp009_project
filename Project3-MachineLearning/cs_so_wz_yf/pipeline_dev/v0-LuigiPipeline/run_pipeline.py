import logging
import time
import pandas as pd
import subprocess
import xgboost as xgb
from sklearn import model_selection
from sklearn.pipeline import Pipeline
from sklearn.model_selection import GridSearchCV
import os
import numpy as np

def data_in():
    #import data in model ready format
    try:
        train_x = pd.read_csv('./data/train_x.csv')
        logging.info('Import of training X successful, shape: {}'.format(train_x.shape))
        train_y = pd.read_csv('./data/train_y.csv')
        logging.info('Import of training Y successful, shape: {}'.format(train_y.shape))
        test_x = pd.read_csv('./data/test_x.csv')
        logging.info('Import of testing X successful, shape: {}'.format(test_x.shape))
        return train_x, train_y, test_x
    except:
        logging.warning('data read in failed')

def preprocess():
    try:
        random.seed(0)
        X_train, X_val, Y_train, Y_val = model_selection.train_test_split(train_x,
                                                                          train_y,
                                                                          test_size=0.2,
                                                                          random_state=seed)
        logging.info('Cross validation successful')
        logging.info('Shape of training shape (X): {}'.format(X_train.shape))
        logging.info('Shape of CV-test shape (X): {}'.format(X_val.shape))
        logging.info('Shape of training shape (Y): {}'.format(Y_train.shape))
        logging.info('Shape of CV-test shape (Y): {}'.format(Y_val.shape))
        return [1,2,3,4]
        #return [X_train, X_val, Y_train, Y_val]
    except:
        logging.warning('Cross validation failed')


def submission_out(test_df, predictions, timestr):
    try:
        submission = pd.DataFrame({ 'id': test_df['id'],
                                    'price_doc': predictions})
        submission.to_csv("./logs/submission{}.csv".format(timestr), index=False)
        logging.info('Write of submission to csv successful')
    except:
        logging.warning('Write of submission to csv failed')

def main(pipeline_list=['xgb']):
    if not os.path.exists('./logs/'):
        os.makedirs('./logs/')
    
    timestr = time.strftime("%Y%m%d-%H%M%S")
    logging.basicConfig(filename='./logs/{}.log'.format(timestr),
                        format='%(asctime)s %(levelname)s:%(message)s',
                        datefmt='%m/%d/%Y %I:%M:%S %p',
                        level=logging.DEBUG)

    #Start the log file
    logging.info('*START* run_pipeline initiated.')

    #Import of data
    [train_x, train_y, test_x] = data_in()

    #Preprocess for pipeline
    #preprocess()

    #XGB Parameter set call

    #The default values are:
    #max_depth=3,
    #learning_rate=0.1,
    #n_estimators=100,
    #silent=True,
    #objective='reg:linear',
    #nthread=-1,
    #gamma=0,
    #min_child_weight=1,
    #max_delta_step=0,
    #subsample=1,
    #colsample_bytree=1,
    #colsample_bylevel=1,
    #reg_alpha=0,
    #reg_lambda=1,
    #scale_pos_weight=1,
    #base_score=0.5,
    #seed=0,
    #missing=None
    xgb_param = [
        {'subsample':1.0},
        {'colsample_bytree':0.7},
        {'objective':'reg:linear'},
        {'silent': True}
        ]
    xgb_estimator = ('xgb', xgb.XGBRegressor())
    for el in xgb_param:
        xgb_estimator[1].set_params(**el)
        logging.info('Fixed XGB parameter: {}'.format(el))
    
    #pipeline definition            
    estimators = []
    estimators.append(xgb_estimator)
    
    parameters = [{
    'xgb__learning_rate': [0.05, 0.10, 0.15],
    'xgb__max_depth':[3,5,7]
    }]

    for parameter in parameters:
        [logging.info('Pipeline parameter: {} = {}'.format(x, parameter[x])) for x in parameter]
    
    grid_search = GridSearchCV(estimator=Pipeline(estimators), param_grid=parameters, verbose=1, cv = 2)

    grid_search.fit(train_x, train_y)

    logging.info('Accuracy of pipeline (training): {}'.format(grid_search.score(train_x, train_y)))

    logging.info('All results:')
    logging.info('Full CV_Results_\n\n {}\n'.format(grid_search.cv_results_))
    
    logging.info('Best Params: {}\n Best Score: {}'.format(
        grid_search.best_params_,
        grid_search.best_score_))

    log_predictions = grid_search.predict(test_x)
    predictions = np.exp(log_predictions) - 1

    #Commit to git
    #try:
    #    exit_code = subprocess.call("./git_autocommit.sh", shell=True)
    #    logging.info('auto-commit to git successful')
    #except:
    #    logging.warning('auto-commit to git failed')

    #Final write to csv for submission
    submission_out(test_x, predictions, timestr)

    #End the log file
    logging.info('*FINISH* run_pipeline completed.')
    

if __name__ == '__main__':
    main()


###Note: Keras has sklearn Regressor available -- KerasRegressor

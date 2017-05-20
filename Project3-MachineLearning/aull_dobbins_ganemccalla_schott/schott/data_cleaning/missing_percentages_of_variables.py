import numpy as np
import pandas as pd
import os
import csv

DIR_PATH = '../data/'

## loading data as Pandas dataframes
train = pd.read_csv(os.path.join(DIR_PATH, 'train.csv'), 
                        header='infer', 
                        index_col='id',
                        parse_dates=['timestamp'])
macro = pd.read_csv(os.path.join(DIR_PATH, 'macro.csv'), 
                    header='infer')

train_pers = np.round(train.isnull().sum(0)/train.shape[0],3)
macro_pers = np.round(macro.isnull().sum(0)/macro.shape[0],3)

with open('main_percentages.txt','w') as f:
    for i in train_pers:
        f.write(str(i))
        f.write('\n')

with open('macro_percentages.txt','w') as f:
    for j in macro_pers:
        f.write(str(j))
        f.write('\n')

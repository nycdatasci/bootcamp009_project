from os.path import dirname, join

import pandas as pd
import numpy as np
from matplotlib import pyplot as plt

%matplotlib

train = pd.read_csv('./train.csv')
test = pd.read_csv('/Users/rezarad/Code/nyc_data_science_academy/bootcamp009_project/Project3-MachineLearning/rezarad/data/test.csv')

# train = pd.read_csv(join(dirname(__file__), 'train.csv'))
# test = pd.read_csv(join(dirname(__file__), 'test.csv'))

train.columns

plt.hist(train['school_km'], bins=60, range=(0,8))

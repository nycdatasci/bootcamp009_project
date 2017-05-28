# PCA on continuous numeric features

# load libraries
import pandas as pd
import numpy as np
from scipy.stats import skew
from sklearn.decomposition import PCA
from sklearn.preprocessing import scale


# Clean the data
#### This section will not be necessary once we have the fnalized, cleaned data

# Grab the raw data
train = pd.read_csv("train.csv", parse_dates=['timestamp']).drop(['id'],axis=1)
test_raw= pd.read_csv("test.csv", parse_dates=['timestamp']).drop(['id'],axis=1)
macro= pd.read_csv("macro.csv", parse_dates=['timestamp'])


# Merge the data (if we choose to merge a lag on the macro, this could be even better)
train['dataset'] = 'train'
test_raw['dataset'] = 'test'
df = pd.concat([train, test_raw])
df = pd.merge(df, macro, on = 'timestamp', how='left')


# Log transform skewed numeric features 
get_col = df.dtypes[(df.dtypes == "int64") | (df.dtypes == "float64")].index
get_skews = df[get_col].apply(lambda x: skew(x.dropna()))
get_skews = get_skews[get_skews>0.5]
get_skews = get_skews.index
df[get_skews] = np.log1p(df[get_skews])    # not really sure what this does...ask Pradeep


# log transform full_sq and life_sq and kitch_sq
df['full_sq_log'] = np.log1p(df['full_sq'])
df['life_sq_log'] = np.log1p(df['life_sq'])
df['kitch_sq_log'] = np.log1p(df['kitch_sq'])


# select continuous numeric columns
numerics = ['float16', 'float32', 'float64']
num_df = df.select_dtypes(include=numerics)
num_df.shape # 364 features


# normalize features
from sklearn.preprocessing import Imputer
imp = Imputer(missing_values='NaN', strategy='mean', axis=0)
imp.fit(num_df)
num_df = imp.transform(num_df)
num_df = scale(num_df)


# Perform PCA
pca = PCA()
pca.set_params(n_components = 30)   # 30 was arbitrary due to high dimensions...feel free to change
pca.fit(num_df)


# Transform/ project observations onto loading vectors
num_df2 = pca.transform(num_df)


# Join back with original data
num_df2 = pd.DataFrame(num_df2)
df_pc  = pd.concat([df, num_df2], axis = 1)


# Drop continuous numeric features in favor of the PCs
df = df_pc.drop(df.select_dtypes(include=numerics), axis = 1)

import os
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
import seaborn as sns
import numpy as np
import scipy as sp
import xgboost as xgb
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import TimeSeriesSplit, cross_val_score
from sklearn.model_selection import GridSearchCV, cross_val_score, KFold

train = pd.read_csv("/Users/rezarad/Code/nyc_data_science_academy/bootcamp009_project/Project3-MachineLearning/romi_reza_sean_pradeep_andrew/reza/data/train.csv", parse_dates = ['timestamp'])
test = pd.read_csv("/Users/rezarad/Code/nyc_data_science_academy/bootcamp009_project/Project3-MachineLearning/romi_reza_sean_pradeep_andrew/reza/data/test.csv", parse_dates = ['timestamp'])
macro = pd.read_csv("/Users/rezarad/Code/nyc_data_science_academy/bootcamp009_project/Project3-MachineLearning/romi_reza_sean_pradeep_andrew/reza/data/macro.csv", parse_dates = ['timestamp'])

# Merge the train and test with macro
train_full_set = pd.merge(train, macro, how = 'left', on = 'timestamp')
test_full_set = pd.merge(test, macro, how = 'left', on = 'timestamp')

pd.set_option('display.max_columns', None)

def features_selection(df):
    features = ['timestamp', 'full_sq', 'life_sq', 'floor',
                        'max_floor', 'material', 'build_year', 'num_room',
                        'kitch_sq', 'state', 'price_doc']
    df = df[features]
    return df

train_housing_features = features_selection(train_full_set)
test_features = ['timestamp', 'full_sq', 'life_sq', 'floor',
                        'max_floor', 'material', 'build_year', 'num_room',
                        'kitch_sq', 'state']
test_housing_features = test_full_set[test_features]
# Let's merge the entire macro set with the train/test feature sets
train_df = train_housing_features
test_df = test_housing_features

## Do some encoding to any categorical variables
def encode_object_features(train, test):
    train = pd.DataFrame(train)
    test = pd.DataFrame(test)
    cols_to_encode = train.select_dtypes(include=['object'], exclude=['int64', 'float64']).columns
    for col in cols_to_encode:
        le = LabelEncoder()
        #Fit encoder
        le.fit(list(train[col].values.astype('str')) + list(test[col].values.astype('str')))
        #Transform
        train[col] = le.transform(list(train[col].values.astype('str')))
        test[col] = le.transform(list(test[col].values.astype('str')))
    return train, test

train_df, test_df = encode_object_features(train_df, test_df)

def add_date_features(df):
    #Convert to datetime to make extraction easier
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    #Extract features
    df['month'] = df['timestamp'].dt.month
    df['day'] = df['timestamp'].dt.day
    df['year'] = df['timestamp'].dt.year
    week_year = df['timestamp'].dt.weekofyear + df['timestamp'].dt.year * 100
    week_year_map = week_year.value_counts().to_dict()
    df['week_year'] = week_year.map(week_year_map)
    df.drop('timestamp', axis=1, inplace=True)
    return df

train_df = add_date_features(train_df)
test_df = add_date_features(test_df)

# # Cross Validation

#Get Data
Y_train = np.log(train_df['price_doc']).values
X_train = train_df.ix[:, train_df.columns != 'price_doc'].values
X_test = test_df.values

print(Y_train.shape)
print(X_train.shape)
print(X_test.shape)

# Create a validation set, with last 20% of data
size_ = 7000
X_train_sub, Y_train_sub = X_train[:-size_],  Y_train[:-size_]
X_val, Y_val = X_train[-size_:],  Y_train[-size_:]

dtrain = xgb.DMatrix(X_train, Y_train)
dtrain_sub = xgb.DMatrix(X_train_sub, Y_train_sub)
d_val = xgb.DMatrix(X_val, Y_val)
dtest = xgb.DMatrix(X_test)

# hyperparameters
xgb_params = {
    'eta': 0.02,
    'max_depth': 5,
    'subsample': .8,
    'colsample_bytree': 0.7,
    'objective': 'reg:linear',
    'eval_metric': 'rmse',
    'silent': 1
}

# Number of random trials
NUM_TRIALS = 30

# Set up possible values of parameters to optimize over
p_grid = {
    #'eta': [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9],
    'max_depth': [5,10,20],
    'subsample': [0.5, 1],
    'colsample_bytree': [0.5, 0.6, 0.7, 0.8, 0.9]
    #'eval_metric': ['rmse', 'auc']
}

# model
xgmlr = xgb.XGBRegressor()

# Arrays to store scores
non_nested_scores = np.zeros(NUM_TRIALS)
nested_scores = np.zeros(NUM_TRIALS)

# Loop for each trial
for i in range(1, NUM_TRIALS):
    print "trial number: {0}".format(i)
    inner_cv = KFold(n_splits=4, shuffle=True, random_state=i)
    outer_cv = KFold(n_splits=4, shuffle=True, random_state=i)

    clf = GridSearchCV(xgmlr, param_grid=p_grid, cv=inner_cv, verbose=1)
    print inner_cv
    clf.fit(X_train, Y_train)
    non_nested_scores[i] = clf.best_score_
   # Nested CV with parameter optimization
    nested_score = cross_val_score(clf, X=X_train, y=Y_train, cv=outer_cv)
    nested_scores[i] = nested_score.mean()

score_difference = non_nested_scores - nested_scores

print "Average difference of {0:6f} with std. dev. of {1:6f}".format(score_difference.mean(), score_difference.std())

# Plot scores on each trial for nested and non-nested CV
plt.figure()
plt.subplot(211)
non_nested_scores_line, = plt.plot(non_nested_scores, color="red")
nested_line, = plt.plot(nested_scores, color="blue")
plt.ylabel("score", fontsize="14")
plt.legend([non_nested_scores_line, nested_line],
           ["Non-Nested CV", "Nested CV"],
           bbox_to_anchor=(0, .4, .5, 0))
plt.title("Non-Nested and Nested Cross Validation on Sberbank Dataset",
          x=.5, y=1.1, fontsize="15")

plt.subplot(212)
difference_plot = plt.bar(range(NUM_TRIALS), score_difference)
plt.xlabel("Individual Trial #")
plt.legend([difference_plot],
           ["Non-Nested CV - Nested CV Score"],
           bbox_to_anchor=(0, 1, .8, 0))
plt.ylabel("score difference", fontsize="14")

# Import Packages
# =============================
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
import seaborn as sns
import numpy as np
import scipy as sp
import os
import xgboost as xgb
# %matplotlib inline   # only in jupyter nb


# Cleaning Data 
# =============================
# Grab the raw data
train = pd.read_csv("train.csv", parse_dates=['timestamp']).drop(['id'],axis=1)
test_raw= pd.read_csv("test.csv", parse_dates=['timestamp']).drop(['id'],axis=1)
macro= pd.read_csv("macro.csv", parse_dates=['timestamp'])


# Merge the data
train['dataset'] = 'train'
test_raw['dataset'] = 'test'
df = pd.concat([train, test_raw])
df = pd.merge(df, macro, on = 'timestamp', how='left')


# Log transform price
df['price_doc_log'] = np.log1p(df['price_doc'])
df['price_doc_log10'] = np.log10(df['price_doc'])


# Log transform skewed numeric features 
get_col = df.dtypes[(df.dtypes == "int64") | (df.dtypes == "float64")].index
get_skews = df[get_col].apply(lambda x: skew(x.dropna()))
get_skews = get_skews[get_skews>0.5]
get_skews = get_skews.index
df[get_skews] = np.log1p(df[get_skews])    # not really sure what this does...ask Pradeep


# log transform full_sq and life_sq and kitch_sq
all_data['full_sq_log'] = np.log1p(all_data['full_sq'])
all_data['life_sq_log'] = np.log1p(all_data['life_sq'])
all_data['kitch_sq_log'] = np.log1p(all_data['kitch_sq'])


# adding full_sq squared and/or square root features


# Features with missing values
train_na = (train_df.isnull().sum() / len(train_df)) * 100
train_na = train_na.drop(train_na[train_na == 0].index).sort_values(ascending = False)



# Im pute missing values with mode
# currently all in train, but maybe do all at once?...or not.... or maybe by building age
from scipy.stats import mode
train['life_sq'].fillna(mode(train['life_sq']).mode[0], inplace=True)
train['floor'].fillna(mode(train['floor']).mode[0], inplace=True)
train['max_floor'].fillna(mode(train['max_floor']).mode[0], inplace=True)
train['material'].fillna(mode(train['material']).mode[0], inplace=True)
train['build_year'].fillna(mode(train['build_year']).mode[0], inplace=True)
train['num_room'].fillna(mode(train['num_room']).mode[0], inplace=True)
train['kitch_sq'].fillna(mode(train['kitch_sq']).mode[0], inplace=True)
train['state'].fillna(mode(train['state']).mode[0], inplace=True)
train['industrial_km'].fillna(mode(train['industrial_km']).mode[0], inplace=True)


# Grab only numeric columns
numerics = ['int16', 'int32', 'int64', 'float16', 'float32', 'float64']
newdf = new_df.select_dtypes(include=numerics)


# brings error down a lot by removing extreme price per sqm
print(df_train.shape)
df_train.loc[df_train.full_sq == 0, 'full_sq'] = 30
df_train = df_train[df_train.price_doc/df_train.full_sq <= 600000]
df_train = df_train[df_train.price_doc/df_train.full_sq >= 10000]
print(df_train.shape)


# Impute missing numeric values
newdf = newdf.apply(lambda x: x.fillna(x.mean()),axis=0) # newdf is the numeric columns
newdf['build_year']



# Feature Engineering 
# ==============================
# Basic dates
#Convert to datetime to make extraction easier
df['timestamp'] = pd.to_datetime(df['timestamp'])

df['month'] = df['timestamp'].dt.month
df['day'] = df['timestamp'].dt.day
df['year'] = df['timestamp'].dt.year


# Add month-year
month_year = (df_all.timestamp.dt.month + df_all.timestamp.dt.year * 100)
month_year_map = month_year.value_counts().to_dict()
df_all['month_year'] = month_year.map(month_year_map)


# Add week-year count
week_year = (df_all.timestamp.dt.weekofyear + df_all.timestamp.dt.year * 100)
week_year_map = week_year.value_counts().to_dict()
df_all['week_year'] = week_year.map(week_year_map)


# Add month and day-of-week
df_all['month'] = df_all.timestamp.dt.month
df_all['dow'] = df_all.timestamp.dt.dayofweek


# drop timestamp???? overfitting???
df.drop('timestamp', axis=1, inplace=True)


# floor ratios
df_all['rel_floor'] = df_all['floor'] / df_all['max_floor'].astype(float)
df_all['rel_kitch_sq'] = df_all['kitch_sq'] / df_all['full_sq'].astype(float)


# area and population density
train_df['area_km'] = train_df['area_m'] / 1000000
train_df['density'] = train_df['raion_popul'] / train_df['area_km']


# working population
train_df['work_share'] = train_df['work_all'] / train_df['raion_popul']


# Remove timestamp column (may overfit the model in train)
df_all.drop(['timestamp', 'timestamp_macro'], axis=1, inplace=True)


# andrew's oil_delta stuff????? and delta_usdrub
test['delta_oil'] = (test['oil_urals_y'] - test['oil_urals_x']) / test['oil_urals_y']
test['delta_usdrub'] = (test['usdrub_y'] - test['usdrub_x']) / test['usdrub_y']
test['delta_labor_force'] = (test['labor_force_y'] - test['labor_force_x']) / test['labor_force_y']



# Deal with categorical values by factorizing
df_numeric = df_all.select_dtypes(exclude=['object'])
df_obj = df_all.select_dtypes(include=['object']).copy()

for c in df_obj:
    df_obj[c] = pd.factorize(df_obj[c])[0]



# Categorize price by high and low
df = df.sort_values('price_doc', ascending = False) # is the merged df called df still?
n = int(round(df.shape[0] * 0.025))
df['high_price'] = 1
df.loc[df.price_doc < df.price_doc[n], 'high_price'] = 0


# 1 or 0 for oil_chemistry_raion
# change oil_chemistry_raion to 1 or 0 
df_important['oil_chem_raion'] = df_important['oil_chemistry_raion'].map(dict(yes=1, no=0))
df_important['oil_chemistry_raion'] = df_important['oil_chem_raion']
df_important.drop('oil_chem_raion', axis = 1, inplace=True)


# possible transformations to use
transformations = [np.log1p, np.log10, np.log, np.sqrt, np.square]
# although maybe box-cox would be better....or just log normalizing everything

# macro features that have less than 10% missing
macro_col_null = macro.isnull().mean(axis=0) < 0.10
macro_useful = macro_col_null[macro_col_null.values==True].index
macro_imp = macro[macro_useful] # gives about 20 features mostly present



# Subsets of Important features 
# =============================
# Random demo variables
demo_vars = ['area_m', 'raion_popul', 'full_all', 'male_f', 'female_f', 'young_all', 'young_female', 
             'work_all', 'work_male', 'work_female', 'price_doc']



# housing features
housing_features = ['timestamp', 'full_sq', 'life_sq', 'floor', 
                        'max_floor', 'material', 'build_year', 'num_room',
                        'kitch_sq', 'state']



# Most important from XGB # 1
df_important = df.loc[:, ['id', 'dataset', 'timestamp', 'full_sq', 
							'life_sq', 'floor', 'max_floor', 'material',
                          'build_year', 'num_room',
                          'kitch_sq', 'state',
                          'product_type', 'sub_area',
                          'indust_part', 'school_education_centers_raion',
                          'sport_objects_raion', 'culture_objects_top_25_raion',
                          'oil_chemistry_raion', 'metro_min_avto',
                          'green_zone_km', 'industrial_km',
                          'kremlin_km', 'radiation_km',
                          'ts_km', 'fitness_km',
                          'stadium_km', 'additional_education_km',
                          'cafe_count_1500_price_500', 'cafe_count_1500_price_high',
                          'cafe_count_2000_price_2500', 'trc_sqm_5000',
                          'cafe_count_5000', 'cafe_count_5000_price_high',
                          'gdp_quart', 'cpi',
                          'ppi', 'usdrub',
                          'eurrub', 'gdp_annual',
                          'rts', 'micex',
                          'micex_cbi_tr', 'deposits_rate',
                          'mortgage_rate', 'income_per_cap',
                          'salary', 'labor_force',
                          'unemployment', 'employment', 'price_doc']]

# Important features by light gbm
important_features = ['full_sq','oil_urals','stadium_km','floor',
'max_floor','metro_min_avto','build_year',
'cafe_count_5000_price_high','num_room',
'oil_chemistry_raion_yes','radiation_km',
'green_zone_km','industrial_km','indust_part',
'cpi','cafe_count_5000','cafe_count_1500_price_high',
'cafe_count_5000_price_500','cafe_count_2000_price_2500',
'kitch_sq']


# Important features from Random Forest
important_features = ['full_sq', 'life_sq', 'floor', 'max_floor',
'material', 'build_year', 'num_room', 'kitch_sq',
'state', 'product_type', 'sub_area', 'area_m',
'raion_popul', 'green_zone_part', 'indust_part', 'children_preschool',
'preschool_quota', 'preschool_education_centers_raion',
'children_school', 'school_quota']


# important features random forest (andrew) ?????
# the notebook only list feature numbers rather than actual features


# Important features from MLR
important_features = ['id', 'full_sq', 'life_sq', 'floor',
                      'max_floor', 'material', 'build_year',
                      'num_room', 'kitch_sq', 'state', 'area_m',
                      'price_doc', 'gdp_quart', 'deposits_value', 
                      'deposits_growth', 'deposits_rate', 'mortgage_value',
                      'mortgage_growth', 'mortgage_rate', 'salary',
                      'unemployment', 'employment',  'oil_urals',
                      'stadium_km', 'floor', 'max_floor', 'metro_min_avto',
                      'build_year', 'cafe_count_5000_price_high', 'num_room',
                      'radiation_km',
                      'green_zone_km', 'industrial_km', 'indust_part',
                      'cpi', 'cafe_count_5000', 'cafe_count_1500_price_high',
                      'cafe_count_5000_price_500', 'cafe_count_2000_price_2500',
                      'kitch_sq', 'max_floor', 'trc_sqm_5000', 
                      'office_sqm_1000', 'trc_sqm_1500', 'office_sqm_500', 'cpi', 
                      'office_sqm_5000', 'ID_railroad_terminal', 'office_sqm_1500', 
                      'ekder_male', 'raion_popul', 'price_doc']\


# grouped infrastructure features
inf_features = ['nuclear_reactor_km', 'thermal_power_plant_km', 'power_transmission_line_km', 'incineration_km',
                'water_treatment_km', 'incineration_km', 'railroad_station_walk_km', 'railroad_station_walk_min', 
                'railroad_station_avto_km', 'railroad_station_avto_min', 'public_transport_station_km', 
                'public_transport_station_min_walk', 'water_km', 'mkad_km', 'ttk_km', 'sadovoe_km','bulvar_ring_km',
                'kremlin_km', 'price_doc']


# green spaces
green = ['green_part_500', 'green_part_1000','green_part_1500',
         'green_part_2000','green_part_3000','green_part_5000']

# industrial zones
prom = ['prom_part_500','prom_part_1000','prom_part_1500',
        'prom_part_2000','prom_part_3000','prom_part_5000']
        

# office buildings
office = ['office_count_500','office_sqm_500','office_count_1000',
          'office_sqm_1000','office_count_1500', 'office_sqm_1500',
          'office_count_2000','office_sqm_2000','office_count_3000',
          'office_sqm_3000','office_count_5000','office_sqm_5000']
  

# grouped cultural characteristics
cult_chars = ['sport_objects_raion', 'culture_objects_top_25_raion', 'shopping_centers_raion', 'park_km', 'fitness_km', 
                'swim_pool_km', 'ice_rink_km','stadium_km', 'basketball_km', 'shopping_centers_km', 'big_church_km',
                'church_synagogue_km', 'mosque_km', 'theater_km', 'museum_km', 'exhibition_km', 'catering_km', 'price_doc']


# shopping malls
trc = ['trc_count_1000', 'trc_count_1500', 'trc_count_2000', 'trc_count_3000', 
       'trc_count_500', 'trc_count_5000', 'trc_sqm_1000', 'trc_sqm_1500',
       'trc_sqm_2000', 'trc_sqm_3000', 'trc_sqm_500', 'trc_sqm_5000', 'trc_count_1000', 'trc_sqm_1000']
       

# religious buildings       
church = ['big_church_count_500', 'church_count_500', 'mosque_count_500',
         'big_church_count_1000', 'church_count_1000', 'mosque_count_1000',
         'big_church_count_1500', 'church_count_1500', 'mosque_count_1500',
         'big_church_count_3000', 'church_count_3000', 'mosque_count_3000',
         'big_church_count_5000', 'church_count_5000', 'mosque_count_5000',
         'big_church_count_2000', 'church_count_2000', 'mosque_count_2000']


# sports facilities/arenas       
sport = ['sport_count_500','sport_count_1000','sport_count_2000', 
         'sport_count_5000','sport_count_1500','sport_count_3000']


# leisure facilities (????)
leisure = ['leisure_count_500','leisure_count_3000','leisure_count_1000',
           'leisure_count_1500','leisure_count_2000','leisure_count_5000']


# markets
market = ['market_count_500','market_count_5000', 'market_count_2000',
          'market_count_1000','market_count_1500','market_count_3000']    


# schools
school_chars = ['children_preschool', 'preschool_quota', 'preschool_education_centers_raion', 'children_school', 
                'school_quota', 'school_education_centers_raion', 'school_education_centers_top_20_raion', 
                'university_top_20_raion', 'additional_education_raion', 'additional_education_km', 'university_km', 'price_doc']


# all cafes & restaurants
cafe = ['cafe_sum_500_min_price_avg', 'cafe_sum_500_max_price_avg',
              'cafe_avg_price_500', 'cafe_sum_1000_min_price_avg','cafe_sum_1000_max_price_avg', 
              'cafe_avg_price_1000', 'cafe_sum_1500_min_price_avg', 'cafe_sum_1500_max_price_avg', 
              'cafe_avg_price_1500', 'cafe_sum_2000_min_price_avg', 'cafe_sum_2000_max_price_avg', 
              'cafe_avg_price_2000', 'cafe_sum_3000_min_price_avg', 'cafe_sum_3000_max_price_avg',
              'cafe_avg_price_3000',  'cafe_sum_5000_min_price_avg', 'cafe_sum_5000_max_price_avg',
              'cafe_avg_price_5000','cafe_count_5000_price_high','cafe_count_500', 'cafe_count_500_na_price',
       		'cafe_count_500_price_500', 'cafe_count_500_price_1000',
       'cafe_count_500_price_1500', 'cafe_count_500_price_2500',
       'cafe_count_500_price_4000', 'cafe_count_500_price_high', 'cafe_count_1000', 
       'cafe_count_1000_na_price', 'cafe_count_1000_price_500',
       'cafe_count_1000_price_1000', 'cafe_count_1000_price_1500',
       'cafe_count_1000_price_2500', 'cafe_count_1000_price_4000',
       'cafe_count_1000_price_high','cafe_count_1500',
       'cafe_count_1500_na_price',
       'cafe_count_1500_price_500', 'cafe_count_1500_price_1000',
       'cafe_count_1500_price_1500', 'cafe_count_1500_price_2500',
       'cafe_count_1500_price_4000', 'cafe_count_1500_price_high', 'cafe_count_2000', 
       'cafe_count_2000_na_price', 'cafe_count_2000_price_500',
       'cafe_count_2000_price_1000', 'cafe_count_2000_price_1500',
       'cafe_count_2000_price_2500', 'cafe_count_2000_price_4000',
       'cafe_count_2000_price_high', 'cafe_count_3000', 'cafe_count_3000_na_price',
       'cafe_count_3000_price_500', 'cafe_count_3000_price_1000',
       'cafe_count_3000_price_1500', 'cafe_count_3000_price_2500',
       'cafe_count_3000_price_4000', 'cafe_count_3000_price_high','cafe_count_5000',
       'cafe_count_5000_na_price', 'cafe_count_5000_price_500',
       'cafe_count_5000_price_1000', 'cafe_count_5000_price_1500',
       'cafe_count_5000_price_2500', 'cafe_count_5000_price_4000',
       'cafe_count_5000_price_high']


# cafes & restaurants counts
cafe_price = ['cafe_sum_500_min_price_avg', 'cafe_sum_500_max_price_avg',
              'cafe_avg_price_500', 'cafe_sum_1000_min_price_avg','cafe_sum_1000_max_price_avg', 
              'cafe_avg_price_1000', 'cafe_sum_1500_min_price_avg', 'cafe_sum_1500_max_price_avg', 
              'cafe_avg_price_1500', 'cafe_sum_2000_min_price_avg', 'cafe_sum_2000_max_price_avg', 
              'cafe_avg_price_2000', 'cafe_sum_3000_min_price_avg', 'cafe_sum_3000_max_price_avg',
              'cafe_avg_price_3000',  'cafe_sum_5000_min_price_avg', 'cafe_sum_5000_max_price_avg',
              'cafe_avg_price_5000','cafe_count_5000_price_high']      


# cafes & restaurants by prices    
cafe_count = ['cafe_count_500', 'cafe_count_500_na_price',
       'cafe_count_500_price_500', 'cafe_count_500_price_1000',
       'cafe_count_500_price_1500', 'cafe_count_500_price_2500',
       'cafe_count_500_price_4000', 'cafe_count_500_price_high', 'cafe_count_1000', 
       'cafe_count_1000_na_price', 'cafe_count_1000_price_500',
       'cafe_count_1000_price_1000', 'cafe_count_1000_price_1500',
       'cafe_count_1000_price_2500', 'cafe_count_1000_price_4000',
       'cafe_count_1000_price_high','cafe_count_1500',
       'cafe_count_1500_na_price',
       'cafe_count_1500_price_500', 'cafe_count_1500_price_1000',
       'cafe_count_1500_price_1500', 'cafe_count_1500_price_2500',
       'cafe_count_1500_price_4000', 'cafe_count_1500_price_high', 'cafe_count_2000', 
       'cafe_count_2000_na_price', 'cafe_count_2000_price_500',
       'cafe_count_2000_price_1000', 'cafe_count_2000_price_1500',
       'cafe_count_2000_price_2500', 'cafe_count_2000_price_4000',
       'cafe_count_2000_price_high', 'cafe_count_3000', 'cafe_count_3000_na_price',
       'cafe_count_3000_price_500', 'cafe_count_3000_price_1000',
       'cafe_count_3000_price_1500', 'cafe_count_3000_price_2500',
       'cafe_count_3000_price_4000', 'cafe_count_3000_price_high','cafe_count_5000',
       'cafe_count_5000_na_price', 'cafe_count_5000_price_500',
       'cafe_count_5000_price_1000', 'cafe_count_5000_price_1500',
       'cafe_count_5000_price_2500', 'cafe_count_5000_price_4000',
       'cafe_count_5000_price_high'] 


# real estate prices
price = ['price_doc', 'price_doc_log', 'price_doc_log10'] 


# important macro data
macro_imp = ['timestamp', 'oil_urals', 'cpi', 'usdrub', 'rts', 
			'mortgage_rate', 'balance_trade', 'brent', 'micex', 
			'micex_cbi_tr', 'micex_rgbi_tr', 'fixed_basket']


# macro features Pradeep found useful
macro_feat = ['timestamp', 'oil_urals', 'cpi', 'usdrub', 'rts', 
				'mortgage_rate', 'balance_trade', 'brent', 'micex', 
				'micex_cbi_tr', 'micex_rgbi_tr', 'fixed_basket']




# ???????????????????

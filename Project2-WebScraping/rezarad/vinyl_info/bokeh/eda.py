from os.path import dirname, join
import pandas as pd
import numpy as np
from fuzzywuzzy import fuzz
from fuzzywuzzy import process

df = pd.read_csv('/Users/rezarad/Code/nyc_data_science_academy/bootcamp009_project/Project2-WebScraping/rezarad/vinyl_info/bokeh/store_status.csv')

df['USD_price']

available_records = df.loc[df.in_stock == True ]
available_records.columns

available_records.loc[(available_records['USD_price'] > 10) & (available_records['USD_price'] < 30])]

available_records = available_records.drop(['tracks', 'genre', 'link', 'price', 'currency'], axis = 1)
available_records.to_csv('/Users/rezarad/Code/nyc_data_science_academy/bootcamp009_project/Project2-WebScraping/rezarad/vinyl_info/bokeh/store_status2.csv')
groupby = available_records.groupby(['store'])

groupby.mean()

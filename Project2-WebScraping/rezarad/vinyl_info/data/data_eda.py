import numpy as np
import pandas as pd

deejay = pd.read_csv('./tidy/deejay_tidy.csv')
decks = pd.read_csv('./tidy/decks_tidy.csv')
redeye = pd.read_csv('./tidy/redeye_tidy.csv')

tables = [deejay, decks, redeye]

# total observations per df
[len(data) for data in tables]

deejay['store'] = 'deejay.de'
decks['store'] = 'decks.de'
redeye['store'] = 'redeye'

deejay.columns

decks.columns

redeye.columns

len(deejay.columns)
len(decks.columns)
len(redeye.columns)
# decks in-stock
len(decks[decks.boolean_in_stock])

# redeye in-stock
redeye_bool = redeye['boolean_in_stock']
len(redeye_bool)
np.unique(redeye_bool)
# convert nan to False
redeye = redeye.dropna()

len(redeye)

# total in-stock per store
np.sum(redeye.boolean_in_stock)
np.sum(decks.boolean_in_stock)
np.sum(deejay.boolean_in_stock)


# update labels for price
deejay.sample(19)


df = decks.merge(redeye, how = 'inner', on = 'catalog_num', indicator = True)
# df.drop(['Unnamed: 0_x'])

df.sample(6)
df.columns


deejay.columns

redeye.columns

redeye.columns

merged_df = pd.concat(tables, ignore_index = True)

merged_df.head()


merged_df.describe()

merged_df.drop(['Unnamed: 0', 'artist_tidy', 'price_tidy', 'release_tidy'], axis = 1)

merged_df.sort_values('release_date', ascending = False)

cols = list(merged_df.columns)
cols
merged_df = merged_df[['release_date', 'artist', 'release', 'tracks', 'label', 'catalog_num', 'genre', 'section', 'store', 'price', 'currency', 'boolean_in_stock', 'link']]
merged_df = merged_df.set_index('release_date')
merged_df.sample(10)

len(merged_df)

merged_df.sample(10)

import datetime

merged_df.columns

# (merged_df.release_date > datetime.date(2017,1,1) | merged_df.release_date.isnull())]

type(merged_df)

df = merged_df.sort_index(ascending = False)

df

df['catalog_num'].describe()
df

df = df.drop_duplicates(['catalog_num', 'store', 'price', 'label'])

df[df.catalog_num ]

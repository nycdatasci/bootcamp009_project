import numpy as np
import pandas as pd
from currency_converter import CurrencyConverter
from datetime import date

tables = [deejay, decks, redeye]

deejay = pd.read_csv('./data/tidy/deejay_tidy.csv')
decks = pd.read_csv('./data/tidy/decks_tidy.csv')
redeye = pd.read_csv('./data/tidy/redeye_tidy.csv')

deejay['catalog_num'] = deejay['catalog_num'].str.upper().str.strip()
redeye['catalog_num'] = redeye['catalog_num'].str.upper().str.strip()
decks['catalog_num'] = decks['catalog_num'].str.upper().str.strip()

# remove rows missing release_date (48213-4750)
deejay = deejay.loc[deejay['release_date'].isnull() == False]

# convert release_date to date type frame
decks['release_date'] = pd.to_datetime(decks['release_date'])

# look for and clean null observations in datasets
decks.loc[decks.artist.isnull(), 'artist'] = "Na"
decks.loc[decks.price.isnull(), 'price'] = [139, 139.99]
decks.loc[decks.release.isnull(), 'release'] = "Null"
decks = decks.dropna()
decks['store'] = 'decks'
np.sum(decks.release.isnull())
deejay.loc[:, 'release_date'] = pd.to_datetime(deejay['release_date'])

len(deejay)

# total observations per df
[len(data) for data in tables]

deejay = deejay.drop_duplicates(['label', 'catalog_num', 'release'])
decks = decks.drop_duplicates(['label', 'catalog_num', 'release'])


deejay.columns
decks.columns
redeye.columns

len(deejay.columns)
len(decks.columns)
len(redeye.columns)

# total in-stock per store
np.sum(redeye.boolean_in_stock)
np.sum(decks.boolean_in_stock)
np.sum(deejay.boolean_in_stock)


np.sum(decks['catalog_num'].isin(deejay['catalog_num']))

decks.columns

# convert to USD (5/7/17 exchange  rate)
c = CurrencyConverter()
decks.loc[:, 'USD_price'] = decks.price.apply(lambda x: c.convert(x, 'EUR', 'USD'))

decks.columns
decks = decks.loc[:, ['artist', 'release', 'label', 'catalog_num', 'genre', 'price', 'currency', 'USD_price', 'boolean_in_stock', 'in_stock', 'store']]
decks = decks.sort_index(ascending = False)

decks.sample(5)

decks.to_csv('./data/tidy/decks_tidy.csv')

deejay.columns

deejay = deejay.drop(['Unnamed: 0', u'Unnamed: 0.1'], axis = 1)
c = CurrencyConverter()
deejay.loc[:, 'USD_price'] = deejay.price.apply(lambda x: c.convert(x, 'EUR', 'USD'))

deejay.sample(5)

redeye.sample(4)

redeye.columns
redeye = redeye.drop(['Unnamed: 0', 'Unnamed: 0.1', 'link', 'store'], axis = 1)
# redeye = redeye.rename(columns = {'price': 'redeye_price','boolean_in_stock' : 'redeye_in_stock'})
c = CurrencyConverter()
redeye.loc[:, 'USD_price'] = redeye.price.apply(lambda x: c.convert(x, 'GBP', 'USD'))

redeye.sample(5)

np.sum(redeye.catalog_num.isin(decks.catalog_num))

# redeye_only_releases = merged_df.loc[merged_df.both == "right_only", 'release_redeye']
# merged_df.loc[merged_df.both == "right_only", 'release'] = redeye_only_releases
# merged_df.loc[merged_df.both == "right_only", 'artist'] = merged_df.loc[merged_df.both == "right_only", 'artist_redeye']
# merged_df.loc[merged_df.both == "right_only", 'label'] = merged_df.loc[merged_df.both == "right_only", 'label_redeye']
# deejay_merge = pd.merge(merged_df, deejay, how = 'outer', on = 'catalog_num', suffixes = ['', '_deejay'], indicator = "both_deejay")
# deejay_merge.loc[deejay_merge.both_deejay == "right_only"]
# deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'release'] = deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'artist_deejay']
# deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'artist'] = deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'artist_deejay']
# deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'label'] = deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'label_deejay']

# deejay_merge  = deejay_merge.drop(['Unnamed: 0'], axis = 1)
# deejay_merge.set_index('catalog_num')

merged_df = pd.concat(tables, ignore_index = True)

merged_df.columns

merged_df = merged_df.drop(['Unnamed: 0', 'Unnamed: 0.1'], axis = 1)

merged_df = merged_df.loc[:, ['release_date', 'artist', 'release', 'label', 'catalog_num',
                                                        'tracks', 'genre', 'store', 'boolean_in_stock', 'price',
                                                        'currency', 'USD_price', 'in_stock', 'link']]



merged_df.loc[merged_df.store.isnull(), 'store'] = 'decks'
merged_df = merged_df.drop(['index'], axis =1)
merged_df.sort_values('release_date', ascending = False)
merged_df.loc[merged_df.USD_price.isnull(), 'USD_price'] = 0


df = df.drop(['Unnamed: 0'], axis =1)

c = CurrencyConverter()
df.loc[df.store == "redeye", 'USD_price'] = df.price.apply(lambda x: c.convert(x, 'GBP', 'USD'))
df.loc[df.store != "redeye", 'USD_price'] = df.price.apply(lambda x: c.convert(x, 'EUR', 'USD'))

df = df.rename(columns = {'in_stock' : 'percent_left',
                                                'boolean_in_stock' : 'in_stock'})

df.to_csv("./store_status.csv", index = False)

merged_df.isnull().describe()

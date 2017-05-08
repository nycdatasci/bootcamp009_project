import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from currency_converter import CurrencyConverter
import seaborn as sns
from datetime import date

%matplotlib

deejay = pd.read_csv('./tidy/deejay_tidy.csv')
decks = pd.read_csv('./tidy/decks_tidy.csv')
redeye = pd.read_csv('./tidy/redeye_tidy.csv')

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

np.sum(decks.release.isnull())
deejay.loc[:, 'release_date'] = pd.to_datetime(deejay['release_date'])

len(deejay)

tables = [deejay, decks, redeye]

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

decks = decks.set_index('release_date')
decks = decks.drop(['Unnamed: 0', 'section'], axis = 1)

# convert to USD (5/7/17 exchange  rate)
c = CurrencyConverter()
decks.loc[:, 'USD_price'] = decks.price.apply(lambda x: c.convert(x, 'EUR', 'USD'))

decks.columns
decks = decks[['artist', 'release', 'label', 'catalog_num', 'genre', 'price','currency', 'USD_price', 'boolean_in_stock', 'in_stock']]
decks = decks.sort_index(ascending = False)


decks.sample(5)

decks.to_csv('./tidy/decks_tidy.csv')

decks['genre'].value_counts()

subgenres = ['Techno', 'House', 'Techhouse', 'Deep House', 'Disco', 'Minimal', 'Detroit', 'Dub Techno', 'Chicago House', 'Detroit House']

subgenre_df = decks.loc[decks['genre'].isin(subgenres), :]

subgenre_df.sample(10)

unknown_artist = subgenre_df.loc[subgenre_df['artist'].str.match('.nknown')]

# "unknown_artist" releases
len(unknown_artist)
unknown_artist.groupby('genre')['boolean_in_stock'].count()

deejay.sample(5)

deejay.columns

deejay = deejay.drop(['Unnamed: 0', u'Unnamed: 0.1'], axis = 1)

deejay.sample(5)

redeye.sample(4)
redeye.columns
redeye = redeye.drop(['Unnamed: 0', 'Unnamed: 0.1', 'link', 'store'], axis = 1)
# redeye = redeye.rename(columns = {'price': 'redeye_price','boolean_in_stock' : 'redeye_in_stock'})
c = CurrencyConverter()
redeye.loc[:, 'USD_price'] = redeye.price.apply(lambda x: c.convert(x, 'GBP', 'USD'))

redeye.sample(5)

# redeye.catalog_num.str.findall('[(\w)]')

np.sum(redeye.catalog_num.str.lower().isin(decks.catalog_num.str.lower()))

merged_df = pd.merge(decks, redeye, how = 'outer', on = 'catalog_num', suffixes = ['', '_redeye'], indicator = "both")
merged_df.set_index('catalog_num')



# merged_df.loc[merged_df.both == "right_only","artist"] = merged_df.loc[merged_df.both == "right_only","artist_redeye"]

redeye_only_releases = merged_df.loc[merged_df.both == "right_only", 'release_redeye']
merged_df.loc[merged_df.both == "right_only", 'release'] = redeye_only_releases

merged_df.loc[merged_df.both == "right_only", 'artist'] = merged_df.loc[merged_df.both == "right_only", 'artist_redeye']
merged_df.loc[merged_df.both == "right_only", 'label'] = merged_df.loc[merged_df.both == "right_only", 'label_redeye']

merged_df

deejay_merge = pd.merge(merged_df, deejay, how = 'outer', on = 'catalog_num', suffixes = ['', '_deejay'], indicator = "both_deejay")

deejay_merge

merged_df

deejay_merge.loc[deejay_merge.both_deejay == "right_only"]

deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'release'] = deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'artist_deejay']
deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'artist'] = deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'artist_deejay']
deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'label'] = deejay_merge.loc[deejay_merge.both_deejay == "right_only", 'label_deejay']

deejay_merge.columns

deejay_merge.loc[:, 'artist': 'in_stock']
deejay_merge.boolean_in_stock_redeye
deejay_merge.USD_price_redeye
deejay_merge.boolean_in_stock_deejay
deejay_merge.USD_price_deejay
deejay_merge.release_date

final_df = pd.DataFrame(deejay_merge.loc[:, 'artist': 'in_stock'],
                                            deejay_merge.boolean_in_stock_redeye,
                                            deejay_merge.USD_price_redeye,
                                            deejay_merge.boolean_in_stock_deejay,
                                            deejay_merge.USD_price_deejay,
                                            deejay_merge.release_date
                                            )

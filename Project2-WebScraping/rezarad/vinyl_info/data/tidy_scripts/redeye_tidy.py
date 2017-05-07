import pandas as pd
import numpy as np

# import scraped data into panda dataframes
redeye = pd.read_csv('redeyerecords.csv')

# create a dictionary for the different currency's of each website
price_currency = {"redeye": "GBP", "decks": "EUR", "deejay": "EUR", "discogs": "USD"}

type(redeye)
type(redeye['price'])
# Redeye Data
redeye.info()
redeye.describe()

redeye.head()

# Remove duplicate entries
redeye = redeye.drop_duplicates()

redeye.describe()

# Cleaning up price column and adding currency column
redeye['price_tidy'] = redeye['price'].str.split("(")

print redeye.shape
print redeye['price_tidy'].shape

redeye_price_tidy = pd.DataFrame([price for price in redeye['price_tidy']])
redeye_price_tidy = redeye_price_tidy.loc[:, 1].str.findall('[0-9.]')
redeye_price_tidy = [''.join(price) for price in redeye_price_tidy]

print redeye_price_tidy[0:5]

redeye['price_tidy'] = pd.to_numeric(redeye_price_tidy)
redeye['currency'] = price_currency["redeye"]

# Convert available column to boolean values
redeye['available'].describe()

redeye['in_stock'] = [True if available == "Add To Basket" else False for available in redeye['available']]
redeye['in_stock'].value_counts()

# split artist and release field into seperate columns
redeye.head(3)

redeye['artist_tidy'] = redeye['artist'].str.split(',', n = 1).apply(pd.Series).astype(str)[0]
redeye['release_tidy'] = redeye['artist'].str.split(',', n = 1).apply(pd.Series).astype(str)[1]

redeye.head(5)

redeye_tidy = redeye[['release_tidy', 'artist_tidy', 'label', 'catalog_num', 'tracks', 'price_tidy', 'currency', 'in_stock', 'link']]

redeye_tidy.head()

redeye_tidy.to_csv("./tidy/redeye_tidy.csv")

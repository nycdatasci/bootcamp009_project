import pandas as pd
import numpy as np

# import scraped data into panda dataframes
decks_house = pd.read_csv('./untidy/decks_house.csv')
decks_techno = pd.read_csv('./untidy/decks_techno.csv')

# create a dictionary for the different currency's of each website
price_currency = {"redeye": "GBP", "decks": "EUR", "deejay": "EUR", "discogs": "USD"}

# add section column to dataframes and merge into one dataframe
decks_house['section'] = 'House'
decks_techno['section'] = 'Techno'
decks = pd.concat([decks_house, decks_techno], ignore_index = True)

# Remove duplicate entries
len(decks)

# Cleaning up price column and adding currency column
type(decks['available'][1])

label = decks['price'].str.split('/', n =1).apply(pd.Series)[0]
catalog_num = decks['price'].str.split('/', n =1).apply(pd.Series)[1]

decks['label'] = label

# Extract availability % from url using regex
availability = decks['release']
availability = decks['release'].str.findall('list\/(..{0,2})\.gif')

np.unique(availability)

availability = availability.apply(lambda x: x[0])
availability = pd.to_numeric(availability)

# convert release dates into date values
release_date = pd.to_datetime(decks['label_cat'], format='%d.%m.%Y')

currency = price_currency['decks']

decks_tidy = pd.DataFrame({'release_date': release_date,
                                                    'section': decks.section,
                                                    'genre': decks.genre,
                                                    'release': decks.release_date,
                                                    'artist': decks.artist,
                                                    'label': label,
                                                    'catalog_num': catalog_num,
                                                    'price': decks.available,
                                                    'currency': currency,
                                                    'in_stock': availability})

decks_tidy.head(10)

decks_tidy.shape

decks_tidy['in_stock'] = decks_tidy.in_stock.div(15)
pd.isnull(decks_tidy).sum()


decks_tidy[pd.isnull(decks_tidy['catalog_num'])]
decks_tidy.loc[pd.isnull(decks_tidy['catalog_num']), 'catalog_num'] = decks_tidy['label']
decks_tidy['boolean_in_stock'] = True

decks_tidy.sample(10)

decks_tidy['genre'] = decks_tidy['genre'].str.lstrip().str.rstrip()
decks_tidy['catalog_num'] = decks_tidy['catalog_num'].str.strip()
decks_tidy['release'] = decks_tidy['release'].str.lstrip().str.rstrip()
decks_tidy['label'] = decks_tidy['label'].str.lstrip().str.rstrip()

decks_tidy[decks_tidy['label'] == "Hostom"]

len(decks_tidy)
len(decks_tidy.drop_duplicates(['catalog_num', 'label', 'artist']))

decks_tidy = decks_tidy.drop_duplicates(['catalog_num', 'label', 'artist'])

decks_tidy.to_csv("./tidy/decks_tidy.csv")

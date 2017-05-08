import numpy as np
import pandas as pd

deejay = pd.read_csv('./tidy/deejay_tidy.csv')
decks = pd.read_csv('./tidy/decks_tidy.csv')
redeye = pd.read_csv('./tidy/redeye_tidy.csv')

deejay['catalog_num'] = deejay['catalog_num'].str.upper().str.strip()
redeye['catalog_num'] = redeye['catalog_num'].str.upper().str.strip()
decks['catalog_num'] = decks['catalog_num'].str.upper().str.strip()


tables = [deejay, decks, redeye]

# total observations per df
[len(data) for data in tables]

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

np.sum(redeye['catalog_num'].isin(decks['catalog_num']))

decks[decks['catalog_num'].isin(redeye['catalog_num'])]

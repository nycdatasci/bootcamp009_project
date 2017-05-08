import pandas as pd
import numpy as np

# import scraped data into panda dataframes
deejay = pd.read_csv('./untidy/deejay_releases.csv')

deejay.describe()

# Extract availability % from scarped column
deejay.available.drop_duplicates()
stock_status = deejay.available.str.findall('\d')

availability = [status[0] if len(status) > 0 else 0 for status in stock_status]
availability = pd.to_numeric(availability)

print np.unique(availability, return_counts = True)

deejay.head()

deejay['price'] = deejay['price'].str.replace(",", ".")

deejay.sample(5)

# find release date values that aren't dates
undates = deejay.release_date.str.findall('\D{3,}')

np.unique(undates, return_counts = True)

# set future release dates to NaN
release_date = pd.to_datetime(deejay['release_date'], format='%d.%m.%Y', errors = 'coerce')

currency = price_currency['deejay']

deejay_tidy = pd.DataFrame({'release_date': release_date,
                                                    'release': deejay.release,
                                                    'artist': deejay.artist,
                                                    'label': deejay.label,
                                                    'catalog_num': deejay.catalog_num,
                                                    'price': deejay.price,
                                                    'currency': currency,
                                                    'in_stock': availability})

deejay_tidy.sample(10)

deejay_tidy['boolean_in_stock'] = [False if stock == 0 else True for stock in deejay_tidy.in_stock]

deejay_tidy['in_stock'] = deejay_tidy.in_stock.div(10)

deejay_tidy.sample(10)


deejay_tidy.to_csv('./tidy/deejay_tidy.csv')

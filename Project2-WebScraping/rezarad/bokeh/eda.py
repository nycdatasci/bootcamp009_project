from os.path import dirname, join
import pandas as pd
import numpy as np
from fuzzywuzzy import fuzz, process
from bokeh.layouts import row, widgetbox
from bokeh.models import ColumnDataSource, CustomJS
from bokeh.models.widgets import Slider, DataTable, TableColumn, NumberFormatter, TextInput, CheckboxButtonGroup
from bokeh.io import curdoc

df = pd.read_csv('/Users/rezarad/Code/nyc_data_science_academy/bootcamp009_project/Project2-WebScraping/rezarad/vinyl_info/bokeh/store_status2.csv')

df['release'] = df.loc[df['release'].str.title(), df['release']]


df['USD_price']
def checkbox_button_group_handler(active):
    print("checkbox_button_group_handler: %s" % active)

checkbox_button_store = CheckboxButtonGroup(
                                            labels=["decks.de", "deejay.de", "redeyerecords.co.uk"],
                                            active=[0, 1, 2])

checkbox_button_store.on_click(checkbox_button_group_handler)



df = df.loc[df.in_stock == True ]
df.columns


search_text = "Sfire"
df.loc[(df['USD_price'] > 10) & df['USD_price'] < 30]

df.loc[: , df.dtypes == 'object']
# .str.contains(search_text) == True]
search = lambda x: fuzz.partial_ratio(artist_search.lower(), x)




process.extract('Sfire', (df['artist']))

process.extractWithoutOrder('Sfire', (df['artist']))


df = df.drop(['tracks', 'genre', 'link', 'price', 'currency'], axis = 1)
df.to_csv('/Users/rezarad/Code/nyc_data_science_academy/bootcamp009_project/Project2-WebScraping/rezarad/vinyl_info/bokeh/store_status2.csv')
groupby = df.groupby(['store'])

groupby.mean()

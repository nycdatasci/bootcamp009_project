from os.path import dirname, join
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from bokeh.charts import BoxPlot, Histogram, Line, output_file, show, Bar, output_file, show, Chart
from bokeh.plotting import curdoc, figure
from bokeh.palettes import Spectral5
from bokeh.models.widgets import Slider, Button, DataTable, TableColumn, NumberFormatter
from bokeh.layouts import row, widgetbox, column
from bokeh.models import Select, ColumnDataSource, Range1d, LabelSet, Label

# list of bokeh color attributes: ('aliceblue', 'antiquewhite', 'aqua', 'aquamarine', 'azure', 'beige', 'bisque', 'black', 'blanchedalmond', 'blue', 'blueviolet', 'brown', 'burlywood', 'cadetblue',
# 'chartreuse', 'chocolate', 'coral', 'cornflowerblue', 'cornsilk', 'crimson', 'cyan', 'darkblue', 'darkcyan', 'darkgoldenrod', 'darkgray', 'darkgreen', 'darkgrey', 'darkkhaki', 'darkmagenta',
# 'darkolivegreen', 'darkorange', 'darkorchid', 'darkred', 'darksalmon', 'darkseagreen', 'darkslateblue', 'darkslategray', 'darkslategrey', 'darkturquoise', 'darkviolet', 'deeppink', 'deepskyblue',
# 'dimgray', 'dimgrey', 'dodgerblue', 'firebrick', 'floralwhite', 'forestgreen', 'fuchsia', 'gainsboro', 'ghostwhite', 'gold', 'goldenrod', 'gray', 'green', 'greenyellow', 'grey', 'honeydew', 'hotpink',
# 'indianred', 'indigo', 'ivory', 'khaki', 'lavender', 'lavenderblush', 'lawngreen', 'lemonchiffon', 'lightblue', 'lightcoral', 'lightcyan', 'lightgoldenrodyellow', 'lightgray', 'lightgreen', 'lightgrey', 'lightpink',
# 'lightsalmon', 'lightseagreen', 'lightskyblue', 'lightslategray', 'lightslategrey', 'lightsteelblue', 'lightyellow', 'lime', 'limegreen', 'linen', 'magenta', 'maroon', 'mediumaquamarine',
# 'mediumblue', 'mediumorchid', 'mediumpurple', 'mediumseagreen', 'mediumslateblue', 'mediumspringgreen', 'mediumturquoise', 'mediumvioletred', 'midnightblue', 'mintcream',
# 'mistyrose', 'moccasin', 'navajowhite', 'navy', 'oldlace', 'olive', 'olivedrab', 'orange', 'orangered', 'orchid', 'palegoldenrod', 'palegreen', 'paleturquoise', 'palevioletred', 'papayawhip',
# 'peachpuff', 'peru', 'pink', 'plum', 'powderblue', 'purple', 'red', 'rosybrown', 'royalblue', 'saddlebrown', 'salmon', 'sandybrown', 'seagreen', 'seashell', 'sienna', 'silver', 'skyblue', 'slateblue',
#  'slategray', 'slategrey', 'snow', 'springgreen', 'steelblue', 'tan', 'teal', 'thistle', 'tomato', 'turquoise', 'violet', 'wheat', 'white', 'whitesmoke', 'yellow', 'yellowgreen')

# Import csv file containing scraped data
df = pd.read_csv(join(dirname(__file__), 'merged_tidy.csv'))
df = df.drop(['Unnamed: 0'], axis =1)
df = df.rename(columns = {'in_stock' : 'percent_left',
                                                'boolean_in_stock' : 'in_stock'})

df.columns

df.sample(10)

# COLORS = Spectral5
# ORIGINS =
# Calculate overall number of available records
available_records = df.loc[df.in_stock]
len(available_records)

# Bar chart for available_records per store
available_bar = Bar(df.loc[df.in_stock], label = 'store', title="# of Available Records", legend='top_right', color = 'mediumturquoise')

# Box plot of price distribution per store
price_box = BoxPlot(df.loc[df.in_stock], label = 'store', values = 'price', outliers=False, ygrid = True,
                                                                    title ="Price Distribution Per Store", legend='top_right',
                                                                    color = 'store', whisker_color = 'grey')

average_price = df.loc[df.in_stock, ['USD_price', 'store']].groupby('store').describe()

# decks_by_genre = df.loc[df.genre.notnull()].groupby(['genre']).agg(['mean', 'std', 'sum'])
# decks_by_genre['label'] = decks_by_genre.index
# decks_by_genre.columns
# decks_by_genre_bar = Bar(decks_by_genre, label = 'label', values ='sum', title="decks.de by genre (for records in stock)", legend='top_right', color = 'mediumturquoise')

source = ColumnDataSource(data=dict())

def update():
    current = available_records[available_records['USD_price'] <= slider.value].dropna()
    source.data = {
        'release'             : current.release,
        'artist'           : current.artist,
        'catalog_num' : current.catalog_num,
        'label' : current.label,
        'USD_price': current.USD_price
    }

slider = Slider(title="Available Records ", start=0, end=50, value=0, step=1)
slider.on_change('value', lambda attr, old, new: update())

columns = [
    TableColumn(field="release", title="Release Name"),
    TableColumn(field="artist", title="Artist"),
    TableColumn(field="catalog_num", title="Catalog Number"),
    TableColumn(field="label", title="Label"),
    TableColumn(field="USD_price", title="Price (in US dollars)", formatter=NumberFormatter(format="$00.00"))
    ]

data_table = DataTable(source=source, columns=columns, width=800)

controls = widgetbox(slider)
table = widgetbox(data_table)

curdoc().add_root(row(column(controls, table), available_bar, price_box))
curdoc().title = "Online Record Store Aggregator"

update()

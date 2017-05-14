from os.path import dirname, join
from fuzzywuzzy import  fuzz, process
import pandas as pd
from bokeh.layouts import row, widgetbox, column
from bokeh.charts import BoxPlot, Bar
from bokeh.models import ColumnDataSource
from bokeh.models.widgets import Slider, DataTable, TableColumn, NumberFormatter, TextInput, CheckboxButtonGroup
from bokeh.io import curdoc

df = pd.read_csv(join(dirname(__file__), 'store_status2.csv'))

source = ColumnDataSource(data=dict())

def update():
    # search = lambda x: fuzz.partial_ratio(text_input.value.lower(), x)
    current = df[(df['USD_price'] >= slider_min.value)
                        & (df['USD_price'] <= slider_max.value)
                        & ((df['artist'].str.lower().str.contains(search_text.value.strip().lower()))
                        | (df['label'].str.lower().str.contains(search_text.value.strip().lower()))
                        | (df['release'].str.lower().str.contains(search_text.value.strip().lower())))].sort_values(by = "USD_price")

    # of records
    totals = len(current)

    source.data = {
        'release': current.release,
        'artist' : current.artist,
        'label' : current.label,
        'catalog_num' : current.catalog_num,
        'USD_price' : current.USD_price,
        'store' : current.store,
        'percent_left': current.percent_left
    }

checkbox_button_store = CheckboxButtonGroup(labels=["decks.de", "deejay.de", "redeye"], active=[0, 1, 2])
checkbox_button_store.on_change('active', lambda attr, old, new: update())

slider_min = Slider(title="Minimum Price", start = 0, end = 25, value = 0, step = 1)
slider_max = Slider(title="Maximum Price", start = 0, end = 150, value = 20, step = 1)
slider_min.on_change('value', lambda attr, old, new: update())
slider_max.on_change('value', lambda attr, old, new: update())

search_text = TextInput(title="Search")
search_text.on_change('value', lambda attr, old, new: update())

columns = [
    TableColumn(field="release", title="Release Name"),
    TableColumn(field="artist", title="Artist"),
    TableColumn(field="label", title="Label"),
    TableColumn(field="catalog_num", title="Catalog Number"),
    TableColumn(field="USD_price", title="Price (in USD)", formatter= NumberFormatter(format = "$0.00")),
    TableColumn(field="percent_left", title="Percent Available", formatter= NumberFormatter(format = "‘0.00%")),
    TableColumn(field="store", title="Store Name")
    ]

data_table = DataTable(source=source,
                                        columns=columns,
                                        width=850,
                                        height=400,
                                        scroll_to_selection=True,
                                        fit_columns=True,
                                        row_headers=True)

# columns, css_classes, disabled, editable, fit_columns, height, js_event_callbacks, js_property_callbacks,
# name, row_headers, scroll_to_selection, selectable, sizing_mode, sortable, source, subscribed_events, tags or width

# Bar chart for available_records per store
# available_bar = Bar(df, label = 'store', title="# of Available Records", legend='top_right', color = 'mediumturquoise')
#
# # Box plot of price distribution per store
# price_box = BoxPlot(df, label = 'store', values = 'USD_price', outliers=False, ygrid = True,
#                                                                     title ="Price Distribution Per Store", legend='top_right',
#                                                                     color = 'store', whisker_color = 'grey')

controls = widgetbox(checkbox_button_store, slider_min, slider_max, search_text)
table = widgetbox(data_table)

update()

curdoc().add_root(row(controls, table))
# curdoc().add_root(column(available_bar, price_box))

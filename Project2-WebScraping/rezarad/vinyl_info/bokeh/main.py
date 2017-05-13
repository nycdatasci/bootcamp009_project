from os.path import dirname, join

import pandas as pd

from bokeh.layouts import row, widgetbox
from bokeh.models import ColumnDataSource, CustomJS
from bokeh.models.widgets import Slider, Button, DataTable, TableColumn, NumberFormatter
from bokeh.io import curdoc

df = pd.read_csv(join(dirname(__file__), 'store_status2.csv'))

source = ColumnDataSource(data=dict())

def update():
    current = df[df.USD_price > slider1.value]
    source.data = {
        'release': current.release,
        'artist' : current.artist,
        'label' : current.label,
        'catalog_num' : current.catalog_num,
        'USD_price' : current.USD_price,
        'store' : current.store,
    }


slider1 = Slider(title="Minimum Price:", start = 0, end = 25, value = 0, step = .1)
slider2 = Slider(title="Maximum Price:", start = 0, end = 150, value = 20, step = 1)
slider1.on_change('value', lambda attr, old, new: update())
# slider2.on_change('value', lambda attr, old, new: update())

button = Button(label="Download", button_type="success")
button.callback = CustomJS(args=dict(source=source))

columns = [
    TableColumn(field="release", title="Release Name"),
    TableColumn(field="artist", title="Artist"),
    TableColumn(field="label", title="Label"),
    TableColumn(field="catalog_num", title="Catalog Number"),
    TableColumn(field="USD_price", title="Price (in $)", formatter= NumberFormatter(format = "$0.00")),
    TableColumn(field="store", title="Store Name")
    ]

data_table = DataTable(source=source, columns=columns, width=800, scroll_to_selection = True, fit_columns = True)

controls1 = widgetbox(slider1, button)
controls2 = widgetbox(slider2, button)
table = widgetbox(data_table)

curdoc().add_root(row(controls1, table))
curdoc().title = "Export CSV"

update()

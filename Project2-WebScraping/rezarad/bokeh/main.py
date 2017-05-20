from os.path import dirname, join
from ConfigParser import SafeConfigParser

import discogs_client
import pandas as pd
from datetime import datetime
from bokeh.io import curdoc, show
from bokeh.layouts import row, widgetbox, column, layout
from bokeh.charts import  defaults
from bokeh.models import ColumnDataSource, Legend, Circle, Jitter, HoverTool, Range1d, NumeralTickFormatter, BoxZoomTool, ResetTool, DatetimeTickFormatter
from bokeh.plotting import figure, Figure, show, output_file
from bokeh.palettes import Oranges
from bokeh.models.widgets import Slider, DataTable, TableColumn, NumberFormatter
from bokeh.models.widgets import TextInput, CheckboxButtonGroup, Panel, Tabs, Select

# import discogs API key
config = SafeConfigParser()
config.read('./config.ini')
user_token = config.get('discogs', 'user_token')
user_agent = "MusicTrendsVisualization/0.1"

# Authorize access to discogs database
d = discogs_client.Client(user_agent, user_token = user_token)
df = pd.read_csv(join(dirname(__file__), 'decks_genre_filtered.csv'))
df['release_date'] = df.release_date.apply(lambda x: datetime.strptime(x, "%Y-%m-%d"))

source = ColumnDataSource(data=dict())

# Input Buttons
genre_filter = ['All', 'Acid', 'Ambient', 'Breaks',
                        'Chicago', 'Deep House',
                        'Detroit', 'Dub Techno',
                        'House', 'Minimal', 'Techhouse', 'Techno']
genre = Select(title="Filter by Genre", value="All", options= genre_filter)
slider_min = Slider(title="Minimum Price", start = 0, end = 150, value = 0, step = 1)
slider_max = Slider(title="Maximum Price", start = 0, end = 150, value = 150, step = 1)
search_text = TextInput(title="Filter by Release, Artist, or Label")

columns = [
    TableColumn(field="release_date", title="Release Date"),
    TableColumn(field="release", title="Release Name"),
    TableColumn(field="artist", title="Artist"),
    TableColumn(field="label", title="Label"),
    TableColumn(field="genre", title="Genre"),
    TableColumn(field="catalog_num", title="Catalog Number"),
    TableColumn(field="price", title="Price (in USD)", formatter= NumberFormatter(format = "$0.00")),
    TableColumn(field="in_stock", title="Percent Available", formatter= NumberFormatter(format = "‘0.00%"))
    ]

data_table = DataTable(source=source,
                                        columns=columns,
                                        width=900,
                                        height=200,
                                        scroll_to_selection=True)


hover = HoverTool(tooltips=[
    ('Label', '@label'),
    ('Artist', '@artist'),
    ('Genre', '@genre'),
    ('Catalog Number', '@catalog_num'),
    ('Price', '@price')
])

p = figure(plot_width=900, plot_height=400,
                tools=[hover, BoxZoomTool(), ResetTool()], toolbar_location="below",
                toolbar_sticky=False)
p.background_fill_color = 'beige'
p.background_fill_alpha = 0.1
p.select(name='release_click')
# p.x_axis_label = "Percent Remaining"
# p.y_axis_label = "Price (in US Dollars)"
p.y_range = Range1d(0,30)
# p.x_range = Range1d(df['release'].min(),df['release'].min())
p.xaxis.axis_label = "Release Date"
p.yaxis.axis_label = "Price (in US Dollars)"
p.xaxis[0].formatter = DatetimeTickFormatter(
        hours=["%d %B %Y"],
        days=["%d %B %Y"],
        months=["%d %B %Y"],
        years=["%d %B %Y"],
        )
p.yaxis[0].formatter = NumeralTickFormatter(format="$0.00")
p.yaxis.major_label_orientation = "vertical"
p.xgrid.grid_line_color = None
p.ygrid.grid_line_color = None
p.xaxis.axis_label_standoff = 10
p.yaxis.axis_label_standoff = 10

colors = Oranges[9]

initial_circle = Circle(x= "release_date", y='price', size = 7, name='release_click',
                                    fill_color = colors[0], fill_alpha = 0.3)
unselected_circle = Circle(size = 7, name='unselected_click',
                                            fill_color = colors[0], fill_alpha = 0.1)
selected_circle = Circle(size = 24, name='selected_click',
                                        fill_color = colors[0], fill_alpha = 0.3)

p.add_glyph(source, initial_circle,
            selection_glyph=selected_circle,
            nonselection_glyph=unselected_circle)

def select_releases():
    selected = df[(df['price'] >= slider_min.value)
                        & (df['price'] <= slider_max.value)
                        & ((df['artist'].str.lower().str.contains(search_text.value.strip().lower()))
                        | (df['label'].str.lower().str.contains(search_text.value.strip().lower()))
                        | (df['release'].str.lower().str.contains(search_text.value.strip().lower())))].sort_values(by = "price")
    genre_val = genre.value
    if (genre_val != "All"):
        selected = selected[selected.genre.str.contains(genre_val)==True]
    return selected

def update():
    # results = d.search(release_button.value, type='release', genre='Electronic', format='Vinyl')
    current = select_releases()
    p.title.text = "# of Records: %d" % len(current)
    source.data = {
        'release_date': current.release_date,
        'release': current.release,
        'artist' : current.artist,
        'label' : current.label,
        'genre' : current.genre,
        'catalog_num' : current.catalog_num,
        'price' : current.price,
        'in_stock': current.in_stock
    }

input_controls = [genre, slider_min, slider_max, search_text]
for control in input_controls:
    control.on_change('value', lambda attr, old, new: update())

controls = widgetbox(genre, slider_min, slider_max, search_text, sizing_mode='scale_both')
controls2 = widgetbox()

update()

curdoc().add_root(row(controls, p))
curdoc().add_root(row(controls2, data_table))



# scatter_plot = Scatter(df, x= 'in_stock',
#                                         y='price', color='genre',
#                                         xlabel='Percent Remaning',
#                                         ylabel="Price (in USD)",
#                                         tooltips=tooltips, height=500, width=700,
#                                         toolbar_location ='below', legend='top_right')

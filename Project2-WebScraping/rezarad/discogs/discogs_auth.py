from ConfigParser import SafeConfigParser
import discogs_client
import pandas as pd
from bokeh.charts import Line, show, output_file
import time
import csv

config = SafeConfigParser()
config.read('../config.ini')
user_token = config.get('discogs', 'user_token')

df = pd.read_csv('../bokeh/decks_genre_filtered.csv')

# Authorize access to discogs database
user_agent = "MusicTrendsVisualization/0.1"
d = discogs_client.Client(user_agent, user_token = user_token)

years = range(1987,2017)
releases_by_year = {}
for year in years:
     releases_by_year[year] = len(d.search(genre='Electronic', format = 'Vinyl', year=year))

with open('discogs_data.csv', 'wb') as csv_file:
    writer = csv.writer(csv_file).writerows(releases_by_year.items())

# releases_by_year_df  = pd.read_csv('/Users/rezarad/Code/nyc_data_science_academy/bootcamp009_project/Project2-WebScraping/rezarad/discogs/discogs_data.csv')
#
# line = Line(releases_by_year_df, title="Releases by Year (discogs.com)",
#                     ylabel = "# of Releases")
#
# output_file("line_single.html", title="line_single.py example")
# show(line)




# def release_info(result):
#     release_methods = [ 'artists', 'companies','country', 'credits', 'data_quality', 'delete', 'fetch',
#                                     'formats', 'genres','id','images', 'labels', 'master', 'notes', 'refresh',
#                                      'repr_str', 'save', 'status', 'styles', 'thumb', 'title', 'tracklist', 'url', 'videos',
#                                      'year']
#     return [result.release_method for release_method in release_methods]
#
#
#
# with open('discogs_data.csv', 'wb') as csv_file:
#     for release in enumerate(dfs['release']):
#         results = d.search(release[1], type='release', genre='Electronic', format='Vinyl')
#         for result in results:
#             print result
#             df['decks']] = release
#             discogs_info['artist'] = result.artists
#             discogs_info['companies'] = result.companies
#             discogs_info['country'] = result.country
#             discogs_info['labels'] =  result.labels
#             discogs_info['url'] = result.url
#             discogs_info['notes'] = result.notes
#             writer = csv.writer(csv_file).writerows(discogs_info.items())

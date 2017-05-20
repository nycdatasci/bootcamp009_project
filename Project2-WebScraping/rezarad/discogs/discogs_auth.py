import json
import sys
import urllib
import urlparse
from ConfigParser import SafeConfigParser


import discogs_client
import oauth2 as oauth
import pandas as pd
from bokeh.charts import Line, show, output_file
import time
import csv

config = SafeConfigParser()
config.read('../config.ini')

request_token_url = 'https://api.discogs.com/oauth/request_token'
authorize_url = 'https://www.discogs.com/oauth/authorize'
access_token_url = 'https://api.discogs.com/oauth/access_token'

# Authorize access to discogs database
user_agent = "MusicTrendsVisualization/0.1"
# user_token = config.get('discogs', 'user_token')
# d = discogs_client.Client(user_agent, user_token = user_token)
consumer_key = config.get('discogs', 'consumer_key')
consumer_secret = config.get('discogs', 'consumer_secret')
consumer = oauth.Consumer(consumer_key, consumer_secret)
client = oauth.Client(consumer)

resp, content = client.request(request_token_url, 'POST', headers={'User-Agent': user_agent})

# if verification is successful, the discogs oauth API will return an access token
# and access token secret. This is the final authentication phase. You should persist
# the oauth_token and the oauth_token_secret to disk, database or some
# other local store. All further requests to the discogs.com API that require authentication
# and must be made with these access_tokens.
access_token = dict(urlparse.parse_qsl(content))

print ' == Access Token =='
print '    * oauth_token        = {0}'.format(access_token['oauth_token'])
print '    * oauth_token_secret = {0}'.format(access_token['oauth_token_secret'])
print ' Authentication complete. Future requests must be signed with the above tokens.'
# We're now able to fetch an image using the application consumer key and secret,
# along with the verified oauth token and oauth token for this user.
token = oauth.Token(key=access_token['oauth_token'],
        secret=access_token['oauth_token_secret'])
client = oauth.Client(consumer, token)

# With an active auth token, we're able to reuse the client object and request
# additional discogs authenticated endpoints, such as database search.
resp, content = client.request('https://api.discogs.com/database/search?release_title=House+For+All&artist=Blunted+Dummies',
        headers={'User-Agent': user_agent})


# df = pd.read_csv('../bokeh/decks_genre_filtered.csv', index_col=False)
#
# result = d.search(df.iloc[i, 9], type='release', genre='Electronic', format='Vinyl')[0]
# result.id
# release = d.release(result.id)
#
# release.artists
# release.tracklist
# release.year
# release.master
# d.price(release.id)
# # df.iloc[:, 2] # artists
# # df.iloc[:, 3] # catalog_num
# # df.iloc[:, 7] # labels
# # df.iloc[:, 9] # release
# df['discogs_artist'] = ''
# df['discogs_country'] = ''
# df['discogs_labels'] =  ''
# df['discogs_url'] = ''
# df['discogs_tracklist'] = ''
# df['discogs_video'] = ''
# df['discogs_year'] = ''
# df['discogs_release_id'] = ''
#
# for i, release in enumerate(df['release']):
#     print(i, release)
#     result = d.search(df.iloc[i, 9], type='release', genre='Electronic', format='Vinyl')[0]
#     release_id = result.id
#     if release_id is not None:
#         df.iloc[i, 13] = result.artists[0].name
#         df.iloc[i, 15] = result.country[0]
#         df.iloc[i, 16] =  result.labels.name
#         df.iloc[i, 17] = result.url
#         df.iloc[i, 18] = result.tracklist
#         df.iloc[i, 19] = result.video
#         df.iloc[i, 20] = result.year
#         df.iloc[i, 21] = result.id
#
# df.to_csv('../bokeh/decks_genre_filtered_{0}.csv'.format(str(time.time())), index_col=False)
#
# # years = range(1987,2017)
# # releases_by_year = {}
# #     for year in years:
# #      releases_by_year[year] = len(d.search(genre='Electronic', format = 'Vinyl', year=year))
# #
# # with open('discogs_data.csv', 'wb') as csv_file:
# #     writer = csv.writer(csv_file).writerows(releases_by_year.items())
# #
# # releases_by_year_df  = pd.read_csv('/Users/rezarad/Code/nyc_data_science_academy/bootcamp009_project/Project2-WebScraping/rezarad/discogs/discogs_data.csv')
# #
# # line = Line(releases_by_year_df, title="Releases by Year (discogs.com)",
# #                     ylabel = "# of Releases")
# #
# # output_file("line_single.html", title="line_single.py example")
# # show(line)
#
#
# # def release_info(result):
# #     release_methods = [ 'artists', 'companies','country', 'credits', 'data_quality', 'delete', 'fetch',
# #                                     'formats', 'genres','id','images', 'labels', 'master', 'notes', 'refresh',
# #                                      'repr_str', 'save', 'status', 'styles', 'thumb', 'title', 'tracklist', 'url', 'videos',
# #                                      'year']
# #     return [result.release_method for release_method in release_methods]
# #
# #
# #
# dir(discogs_client)

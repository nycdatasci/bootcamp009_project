from ConfigParser import SafeConfigParser
import discogs_client
import pandas as pd
import numpy as np
import time

config = SafeConfigParser()
config.read('../config.ini')
user_token = config.get('discogs', 'user_token')

df = pd.read_csv('../bokeh/store_status2.csv')

# Authorize access to discogs database
user_agent = "MusicTrendsVisualization/0.1"
d = discogs_client.Client(user_agent, user_token = user_token)

for i, el in enumerate(df):
    print df.iloc[i,""]
    release_search = d.search(genre='Electronic', format='Vinyl',release=release)
    for search_result in release_search:
        print search_result.tracklist
        print search_result.artists
        print search_result.labels
        print search_result.master
    sleep(5)

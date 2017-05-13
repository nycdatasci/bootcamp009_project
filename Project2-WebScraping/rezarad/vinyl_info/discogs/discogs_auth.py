from ConfigParser import SafeConfigParser
import discogs_client
import pandas as pd

config = SafeConfigParser()
config.read('config.ini')
user_token = config.get('discogs', 'user_token')

releases = pd.read_csv('../discogs/store_status.csv')
releases.columns

# Authorize access to discogs database
user_agent = "MusicTrendsVisualization/0.1"
d = discogs_client.Client(user_agent, user_token = user_token)

for i in range(releases.shape[0]):
    print releases.loc[i, ("artist","release")]




search = d.search(genre='Electronic', style = 'House', label= "HOSTOM", format='Vinyl')
for release in search:
    # print release.artists
    # print release.labels
    # print release.genres
    for video in release.videos:
        print video.title
        print video.url

    # print release.year
    # print release.tracklist
    # print release.country

# print search[i].artists
# print search[i].labels
# print search[i].master
# print search[i].aliases

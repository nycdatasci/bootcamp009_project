from ConfigParser import SafeConfigParser
import discogs_client

config = SafeConfigParser()
config.read('config.ini')

user_agent = "MusicTrendsVisualization/0.1"
d = discogs_client.Client(user_agent)
consumer_key = config.get('discogs', 'consumer_key')
consumer_secret = config.get('discogs', 'consumer_secret')

d.set_consumer_key(consumer_key = 'consumer_key', consumer_secret = 'consumer_secret')
print d.get_authorize_url()

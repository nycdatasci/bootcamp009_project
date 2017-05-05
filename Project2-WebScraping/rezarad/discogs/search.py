import discogs_client
import oauth2 as oauth


consumer_key = 'LbIcqhcLUMWCxKnYmfoB'
consumer_secret = 'eeHDnTaPcvsqFSZVAIRvVPTgxPqpBzPC'

user_agent  = "MusicTrendsVisualization/0.1"
consumer = oauth.Consumer(consumer_key, consumer_secret)

discogsclient  =  discogs_client.Client(user_agent)

oauth_token  =  "tLtJFvRoJNQBVelElFOnFiywCgldzrUTcBvDejdR"
oauth_token_secret = " PwJGWFMzbYHSmeKURLkPrQianVkCPrnXzvZyKhMP"


token = oauth.Token(key=oauth_token, secret=oauth_token_secret)
client = oauth.Client(consumer, token)


user = discogsclient.identity()
print user


# search_results = discogsclient.search('HOSTOM', type='release')
#
# print search_results.page

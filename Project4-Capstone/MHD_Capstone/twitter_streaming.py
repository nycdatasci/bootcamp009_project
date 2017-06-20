# Import the necessary package to process data in JSON format
try:
    import json
except ImportError:
    import simplejson as json

# Import the necessary methods from "twitter" library
from twitter import Twitter, OAuth, TwitterHTTPError, TwitterStream

# Variables that contains the user credentials to access Twitter API 
ACCESS_TOKEN = ""
ACCESS_SECRET = ""
CONSUMER_KEY = ""
CONSUMER_SECRET = ""

oauth = OAuth(ACCESS_TOKEN, ACCESS_SECRET, CONSUMER_KEY, CONSUMER_SECRET)

# Initiate the connection to Twitter Streaming API
twitter_stream = TwitterStream(auth=oauth)

# Get a sample of the public data following through Twitter

#keywords = 'wedding, just married, newly wed, newly weds, newly-wed, newly-weds, newlywed, newlyweds, married, honeymoon' # wedding
#keywords = 'health, fitness, diet, workout, gym, healthy, strength training, cardio' # health & fitness
#keywords = 'travel, hotel, vacation, cruise, beach, getaway, get away, holidays, vacay' # travel
#keywords = 'graduate, graduation, class of 2017, freshmen, senioritis, grad, senior year' # graduation
#keywords = 'new job, career change, job promotion, new position, promoted' # new job/promotion
#keywords = 'sports, team, teams, basketball, baseball, football, soccer, sport, boxing, champion, champions, championship, championships, world series'
#keywords = 'gay, lesbian, lgbt, bisexual, transgender, love wins' # lifestyle
#keywords = 'news, politics, democrat, democrats, republican, republicans, congress, government, senate, house of representatives, senator, congressman, congresswoman, president, trump, clinton, sanders' # news/politcs
#keywords = 'FPS, RPG, multiplayer, gameplay, videogame, videogames, playstation, xbox, gaming, gamer, ps4, nintendo, console, consoles, minecraft' # videogames
#keywords = 'music, rap, rnb, jazz, hip hop, mp3, itunes, reggae, concert' # music
#keywords = 'art, museum, gallery, met, photography, painting, paintings' # art
#keywords = 'dating, relationship, relationships, tinder' # dating/relationship
#keywords = "baby, bewborn, babyshower, it's a boy, it's a girl, sonogram, pregnant" # baby 

iterator = twitter_stream.statuses.sample(language = 'en')

# Print each tweet in the stream to the screen 
# Here we set it to stop after getting 1000 tweets. 
# You don't have to set it to stop, but can continue running 
# the Twitter API to collect data for days or even longer. 
tweet_count = 500000
for tweet in iterator:
    tweet_count -= 1
    # Twitter Python Tool wraps the data returned by Twitter 
    # as a TwitterDictResponse object.
    # We convert it back to the JSON format to print/score
    print json.dumps(tweet)  
    
    # The command below will do pretty printing for JSON data, try it out
    # print json.dumps(tweet, indent=4)
       
    if tweet_count <= 0:
        break 

# coding: utf-8

# In[7]:

import pandas as pd
import numpy as np

import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')


# In[ ]:

from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener
import time

####input your credentials here
consumer_key = 'JKTbBC9Mfhy9Rt2Egq93zbfI3'
consumer_secret = 'UyDtLKAZHCtXKzgnt7BSRZkF7DcsB9V5N7pkps0VerfEUkaWIV'
access_token = '23561686-1VikNYEGafZ8BIlEsGKAlaCGrvIe4SoFuBsuTpVr4'
access_token_secret = 'vEhjlf0CSMlfxA8BfqnRwOk34FMRsAOnrwgLt3kv5GTyr'

class listener(StreamListener):

    def on_data(self, data):
        try:
            print data
            saveFile = open('twitDB.csv','a')
            saveFile.write(data)
            saveFile.write('\n')
            saveFile.close
            return True
        except BaseException as e:
            print 'failed ondata,',str(e)
            time.sleep(100)

    def on_error(self,status):
        print status

auth = OAuthHandler(consumer_key,consumer_secret)
auth.set_access_token(access_token,access_token_secret)
twitterStream = Stream(auth,listener())
twitterStream.filter(track=['bitcoin'])



# In[ ]:




# In[ ]:




# In[ ]:




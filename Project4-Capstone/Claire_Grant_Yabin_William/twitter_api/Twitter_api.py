#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
import tweepy
from tweepy import Stream
from tweepy.streaming import StreamListener
import time
import numpy as np
import pandas as pd
from google.cloud import language
import json
import boto3
import os
import uuid


#Grant Twitter Keys
consumer_key = 'xxx'
consumer_secret = 'xxx'
access_token = 'xxx'
access_token_secret = 'xxx'
#


def sentimentAnalysis(text):
    client = language.Client()
    document =  client.document_from_text(text)
    sent_analysis = document.analyze_sentiment()
    #print(dir(sent_analysis))
    sentiment = sent_analysis.sentiment
    ent_analysis = document.analyze_entities()
    entities = ent_analysis.entities
    return sentiment, entities


class StreamListener(tweepy.StreamListener):
    def __init__(self, boto_client, search_list):
        super(tweepy.StreamListener, self).__init__()
        self.kinesis = boto_client
        self.search_list = search_list

    def on_status(self, status):
        print status.txt

    def on_data(self, data):
        try:
            all_data = json.loads(data)
            tw_data = {}
            status_sent_entity = {}
            retweet_status_sent_entity = {}
            print "Collecting Tweet"

            if 'lang' in all_data and (all_data['lang'] == "en"):
                tw_data['status_created_at']   = str(all_data["created_at"])
                tw_data['status_id']           = str(all_data["id"])                                                
                tw_data['status_text']         = str(all_data["text"].encode('ascii', 'ignore').decode('ascii'))
                tw_data['status_geo']          = str(all_data['geo'])
                tw_data['status_retweeted']    = all_data['retweeted']
                tw_data['status_mention']      = [str(i['id']) for i in all_data['entities']['user_mentions']]      # list
                tw_data['status_num_mentions'] = str(len([i['id'] for i in all_data['entities']['user_mentions']])) # number of user mentions
                
                tw_data['status_truncated']                   = all_data['truncated']
                tw_data['status_retweet_count']               = str(all_data['retweet_count'])
                tw_data['status_favorite_count']              = str(all_data['favorite_count'])
                tw_data['status_hashtags']                    = [str(i['text']) for i in all_data['entities']['hashtags']] # list
                tw_data['status_num_hashtags']                = str(len(all_data['entities']['hashtags']))
                tw_data['status_in_reply_to_user_id_str_num'] = str(all_data['in_reply_to_user_id_str'])
                tw_data['status_in_reply_to_status_id_num']   = str(all_data['in_reply_to_status_id_str'])



                sentiment, entities               = sentimentAnalysis(tw_data['status_text'])
                tw_data['status_sentScore']       = sentiment.score
                tw_data['status_sentMag']         = sentiment.magnitude

                tw_data['user_id']          = str(all_data["user"]["id"]) 
                try:
                	tw_data['user_name']        = str(all_data["user"]["name"].encode('ascii', 'ignore').decode('ascii'))
                except:
                	tw_data['user_name']        = str(all_data["user"]["name"])
                tw_data['user_screen_name'] = str(all_data["user"]["screen_name"])
                tw_data['user_url']         = str(all_data["user"]["url"])
                tw_data['user_loc']         = str(all_data["user"]["location"])
                try:
                    tw_data['user_desc']    = str(all_data["user"]["description"].encode('ascii', 'ignore').decode('ascii'))
                except:
                    tw_data['user_desc']    = 'None'
                tw_data['user_followers_count'] = str(all_data["user"]["followers_count"])
                tw_data['user_friends_count']   = str(all_data["user"]["friends_count"])
                tw_data['user_listed_count']    = str(all_data["user"]["listed_count"])
                tw_data['user_favorite_count']  = str(all_data["user"]["favourites_count"])
                tw_data['user_statuses_count']  = str(all_data["user"]["statuses_count"])
                tw_data['user_created_at']      = str(all_data["user"]["created_at"])
                tw_data['user_time_zone']       = str(all_data["user"]["time_zone"])
                tw_data['user_img_url']         = str(all_data["user"]["profile_image_url"])


                try:
                    tw_data['rt_status_id']                          = str(all_data['retweeted_status']['id'])
                except:
                    tw_data['rt_status_id']                          = 'None'
                try:
                    tw_data['rt_status_retweet_count']               = str(all_data['retweeted_status']['retweet_count'])
                except:
                    tw_data['rt_status_retweet_count']               = 'None'
                try:
                    tw_data['rt_status_favorite_count']              = str(all_data['retweeted_status']['favorite_count'])
                except:
                    tw_data['rt_status_favorite_count']              = 'None'
                try:
                    tw_data['rt_status_in_reply_to_user_id_str_num'] = str(all_data['retweeted_status']['in_reply_to_user_id_str'])
                except:
                    tw_data['rt_status_in_reply_to_user_id_str_num'] = 'None'
                try:
                    tw_data['rt_status_in_reply_to_status_id_num']   = str(all_data['retweeted_status']['in_reply_to_status_id_str'])
                except:
                    tw_data['rt_status_in_reply_to_status_id_num']   = 'None'
                try:
                    tw_data['rt_status_text']                        = str(all_data['retweeted_status']['text'].encode('ascii', 'ignore').decode('ascii'))
                except:
                    tw_data['rt_status_text']                        = 'None'
                try:
                    tw_data['rt_status_truncated']              = all_data['retweeted_status']['truncated']
                except:
                    tw_data['rt_status_truncated']              = 'None'
                try:
                    tw_data['rt_status_retweeted']              = all_data['retweeted_status']['retweeted']
                except:
                    tw_data['rt_status_retweeted']              = 'None'
                try:
                    tw_data['rt_status_geo']                    = str(all_data['retweeted_status']['geo'])
                except:
                    tw_data['rt_status_geo']                    = 'None'
                try:
                    tw_data['rt_status_source']                 = str(all_data['retweeted_status']['source'])
                except:
                    tw_data['rt_status_source']                 = 'None'
                try:
                    tw_data['rt_status_created_at']             = str(all_data['retweeted_status']['created_at'])
                except: 
                    tw_data['rt_status_created_at']             = 'None'
                try:
                    tw_data['rt_status_favorited']              = all_data['retweeted_status']['favorited']
                except:
                    tw_data['rt_status_favorited']              = 'None'
                try:
                    tw_data['rt_status_entities_user_mentions'] = [str(i['id']) for i in all_data['retweeted_status']['extended_tweet']['entities']['user_mentions']] #list
                except: 
                    tw_data['rt_status_entities_user_mentions'] = []
                try:
                	tw_data['rt_status_num_user_mentions'] = str(len([str(i['id']) for i in all_data['retweeted_status']['extended_tweet']['entities']['user_mentions']]))
                except:
                	tw_data['rt_status_num_user_mentions'] = '0'
                try:
                    tw_data['rt_status_entities_hashtags']      = [str(i['text']) for i in all_data['retweeted_status']['hashtags']]		#list
                except:
                    tw_data['rt_status_entities_hashtags']      = []
                try: 
                    tw_data['rt_status_user_following']        = all_data['retweeted_status']['following']
                except:
                    tw_data['rt_status_user_following']        = 'None'
                try:
                    tw_data['rt_status_user_friends_count']    = str(all_data['retweeted_status']['user']['friends_count'])
                except:    
                    tw_data['rt_status_user_friends_count']    = 'None'
                try:
                    tw_data['rt_status_user_location']         = str(all_data['retweeted_status']['user']['location'])
                except:
                    tw_data['rt_status_user_location']         = 'None'
                try:
                    tw_data['rt_status_user_id']               = str(all_data['retweeted_status']['user']['id'])
                except:
                    tw_data['rt_status_user_id']               = 'None'
                try:
                    tw_data['rt_status_user_favourites_count'] = str(all_data['retweeted_status']['user']['favourites_count'])
                except:
                    tw_data['rt_status_user_favourites_count'] = 'None'
                try:
                    tw_data['rt_status_user_screen_name']      = str(all_data['retweeted_status']['user']['screen_name'])
                except:
                    tw_data['rt_status_user_screen_name']      = 'None'
                try:
                	tw_data['rt_status_user_profile_image']    = alldata['retweeted_status']['user']['profile_image_url']
                except:
                	tw_data['rt_status_user_profile_image']    = 'None'
                try: 
                	tw_data['rt_status_user_name']			   = all_data['retweeted_status']['user']['name']
                except:
                	tw_data['rt_status_user_name']             = 'None'
                try:
                    tw_data['rt_status_user_verified']         = all_data['retweeted_status']['user']['verified']
                except:
                    tw_data['rt_status_user_verified']         = 'None'
                try:
                    tw_data['rt_status_user_created_at']       = str(all_data['retweeted_status']['user']['created_at'])
                except:
                    tw_data['rt_status_user_created_at']       = 'None'
                try:
                    tw_data['rt_status_user_followers_count']  = str(all_data['retweeted_status']['user']['followers_count'])
                except:
                    tw_data['rt_status_user_followers_count']  = 'None'
                try:
                    tw_data['rt_status_user_lang']             = str(all_data['retweeted_status']['user']['lang'])
                except:
                    tw_data['rt_status_user_lang']             = 'None'
                try:
                    tw_data['rt_status_user_listed_count']     = str(all_data['retweeted_status']['user']['listed_count'])
                except:
                    tw_data['rt_status_user_listed_count']     = 'None'
                try:
                    tw_data['rt_status_user_statuses_count']   = str(all_data['retweeted_status']['user']['statuses_count'])
                except:
                    tw_data['rt_status_user_statuses_count']   = 'None'
                try:
                    tw_data['rt_status_user_time_zone']        = str(all_data['retweeted_status']['user']['time_zone'])
                except:
                    tw_data['rt_status_user_time_zone']        = 'None'
                
                tw_data['searched_names'] =  self.search_list[0]
                try:
                    rt_sentiment, rt_entities                   = sentimentAnalysis(tw_data['rt_status_text'])
                    tw_data['rt_status_sentScore']              = rt_sentiment.score
                    tw_data['rt_status_sentMag']                = rt_sentiment.magnitude
                except:
                    tw_data['rt_status_sentScore']              = 'None'
                    tw_data['rt_status_sentMag']                = 'None'

                # for e in entities:
                #     print "Name: {}, Entity Type: {}, Salience: {}".format(e.name, e.entity_type, e.salience)

                try:
                    #print(tw_data)
                    self.kinesis.put_record(DeliveryStreamName='project4_capstone_stream_3',
                                            Record={'Data': json.dumps(tw_data) + '\n'})
                    pass

                except Exception, e:
                    print"Failed Kinesis Put Record {}".format(str(e))

        except BaseException, e:
            print "failed on data ", str(e)
            time.sleep(5)

    def on_error(self, status):
        if status_code == 420:
            return False

def main():
    stream_name = 'project4_capstone_stream_3'
    client = boto3.client('firehose', region_name='us-east-1',
                          aws_access_key_id='xxx',
                          aws_secret_access_key='xxx'
                          ) # the region may not be needed
    stream_status = client.describe_delivery_stream(DeliveryStreamName=stream_name)
    if stream_status['DeliveryStreamDescription']['DeliveryStreamStatus'] == 'ACTIVE':
        print "\n ==== KINESES ONLINE ===="
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = tweepy.API(auth)

    searched_list = ['Trump']

    streamListener = StreamListener(client, searched_list)
    stream = tweepy.Stream(auth=api.auth, listener=streamListener)

    while True:
        try:
            stream.filter(track=searched_list)
        except:
            time.sleep(5)
            continue
    # try:
    #     print "START STREAMING"

    #     stream.filter(track=searched_list)
    # except:

    # finally:
    #     stream.disconnect()

if __name__ == '__main__':
    main()
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from flask.ext.sqlalchemy import SQLAlchemy
from werkzeug import generate_password_hash, check_password_hash

import geocoder
import urllib2
import json


db = SQLAlchemy()

class User(db.Model):
  __tablename__ = 'users'
  uid = db.Column(db.Integer, primary_key = True, autoincrement=True)
  firstname = db.Column(db.String(100))
  lastname = db.Column(db.String(100))
  email = db.Column(db.String(120), unique=True)
  pwdhash = db.Column(db.String(54))

  def __init__(self, firstname, lastname, email, password):
    self.firstname = firstname.title()
    self.lastname = lastname.title()
    self.email = email.lower()
    self.set_password(password)
     
  def set_password(self, password):
    self.pwdhash = generate_password_hash(password)

  def check_password(self, password):
    return check_password_hash(self.pwdhash, password)


class influencer(db.Model):
  __tablename__='influence_score'
  User_id = db.Column(db.Integer,primary_key=True)
  User_name = db.Column(db.String(100))
  Number_of_Followers=db.Column(db.Integer)
  Number_of_Retweets=db.Column(db.Integer)
  Number_of_Likes=db.Column(db.Integer)
  Influencer_Score = db.Column(db.Float)
  Sentiment_Score = db.Column(db.String(100))
  Img_URL = db.Column(db.String(100))
  Tweets = db.Column(db.String(100))


  def __init__(self,User_id,User_name ,Number_of_Followers,Number_of_Retweets,Number_of_Likes,Influencer_Score,Sentiment_Score,Img_URL):
    self.User_id = User_id
    self.User_name = User_name
    self.Number_of_Followers = Number_of_Followers
    self.Number_of_Retweets = Number_of_Retweets
    self.Number_of_Likes = Number_of_Likes
    self.Influencer_Score = Influencer_Score
    self.Sentiment_Score = Sentiment_Score
    self.Img_URL = Img_URL
    self.Tweets = Tweets



class neu_word_cloud(db.Model):
  __tablename__="neu_word_cloud"
  word = db.Column(db.String(100),primary_key=True)
  word_count = db.Column(db.String(100))

  def __init__(self,word,word_count):
    self.word = word
    self.word_count = word_count





# p = Place()
# places = p.query("1600 Amphitheater Parkway Mountain View CA")
class Place(object):
  def meters_to_walking_time(self, meters):
    # 80 meters is one minute walking time
    return int(meters / 80)  

  def wiki_path(self, slug):
    return urllib2.urlparse.urljoin("http://en.wikipedia.org/wiki/", slug.replace(' ', '_'))
  
  def address_to_latlng(self, address):
    g = geocoder.google(address)
    return (g.lat, g.lng)

  def query(self, address):
    lat, lng = self.address_to_latlng(address)
    
    query_url = 'https://en.wikipedia.org/w/api.php?action=query&list=geosearch&gsradius=5000&gscoord={0}%7C{1}&gslimit=20&format=json'.format(lat, lng)
    g = urllib2.urlopen(query_url)
    results = g.read()
    g.close()

    data = json.loads(results)
    
    places = []
    for place in data['query']['geosearch']:
      name = place['title']
      meters = place['dist']
      lat = place['lat']
      lng = place['lon']

      wiki_url = self.wiki_path(name)
      walking_time = self.meters_to_walking_time(meters)

      d = {
        'name': name,
        'url': wiki_url,
        'time': walking_time,
        'lat': lat,
        'lng': lng
      }

      places.append(d)

    return places


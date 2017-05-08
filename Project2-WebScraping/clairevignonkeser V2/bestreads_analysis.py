import csv
import os
import re
import pandas as pd
import numpy as np
import json

# from textblob import TextBlob
from itertools import *

import matplotlib.pyplot as plt
# %matplotlib inline  

from  matplotlib import style
from matplotlib import rcParams
rcParams.update({'figure.autolayout': True})

# import spacy 
# nlp = spacy.load('en')

# from ipywidgets import interact
# from bokeh.io import push_notebook, show, output_notebook
# from bokeh.plotting import figure
# output_notebook()


os.chdir('/Users/clairevignon/DataScience/NYC_DSA/project2_webscraping/bestreads')
os.getcwd()

bestreads = pd.read_csv('bestreads.csv')
# bestreads = nlp(bestreads)

# 1- DATA CLEANING
# get unique observations
bestreads.drop_duplicates(inplace = True)

# remove commas in total score and turn into numeric
bestreads['TotalScore'] = bestreads['TotalScore'].str.replace(',', '')
bestreads['TotalScore'] = bestreads['TotalScore'].apply(lambda x: int(x))

# remove word pages in NumberOfPages column
# bestreads['NumberOfPages'] = [int(re.search('(\d*)\s*pages', pages).group(1)) for pages in bestreads['NumberOfPages']]

# remove any punctuation in reviews except exclamation marks, and replace multiple white spaces with one
bestreads['Reviews'] = [re.sub( '[.:\',\-;"()?]', " ", reviews).strip() for reviews in bestreads['Reviews']]
bestreads['Reviews'] = [re.sub( '\s+', " ", reviews ).strip() for reviews in bestreads['Reviews']]
bestreads['Reviews'] = [reviews.lower() for reviews in bestreads['Reviews']]

# remove any word that doesn't matter in reviews (e.g. I, and, the etc)
from nltk.corpus import stopwords
stops = set(stopwords.words("english"))
bestreads['Reviews'] = bestreads['Reviews'].apply(lambda x: ' '.join([word for word in x.split() if word not in stops]))

# remove words with 1 or 2 letters
shortword = re.compile(r'\W*\b\w{1,2}\b')
bestreads['Reviews'] = [shortword.sub('', word) for word in bestreads['Reviews']]

# remove proper nouns
bestreads['Reviews'] = bestreads['Reviews'].apply(lambda x: [word for word,pos in pos_tag(x.split()) if pos != 'NNP'])

# add column to group books by ranking (top 100, top 200, etc.)
bestreads['Ranking'] = bestreads['Ranking'].apply(lambda x: int(x)) # convert to integer

def rankingcat(row):
	if (row['Ranking'] >= 1) and (row['Ranking'] <=100):
		return 'Top 100'
	elif (row['Ranking'] > 100) and (row['Ranking'] <=200):
		return 'Top 100 - 200'
	elif (row['Ranking'] > 200) and (row['Ranking'] <=300):
		return 'Top 200 - 300'
	elif (row['Ranking'] > 300) and (row['Ranking'] <=400):
		return 'Top 300 - 400'
	else:
		return 'Top 400 - 500'

bestreads['RankingCat'] = bestreads.apply(lambda x: rankingcat(x), axis = 1)



import numpy as np
from PIL import Image
from wordcloud import WordCloud, STOPWORDS
from nltk.corpus import stopwords
from nltk.stem.wordnet import WordNetLemmatizer
import string
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from sklearn.decomposition import NMF, LatentDirichletAllocation
from time import time
import os
from scipy.misc import imread
import matplotlib.pyplot as plt
import random
from sklearn.feature_extraction.stop_words import ENGLISH_STOP_WORDS
import re
import json
import numpy as np
import random
from os import listdir



json_filepath = r'C:\Users\Pradeep Krishnan\Desktop\NewsFlows\data_output'
json_files= listdir(json_filepath)
image_filepath = r'C:/Users/Pradeep Krishnan/Desktop/NewsFlows/image_files'

text=''
doc_complete = []
for file in json_files:
	f = open(json_filepath + '/'+ str(file), 'r')
	data = json.load(f)
	text = text + data['article']
	doc_complete.append(data['article'])

	
	
# clean files for LDA

n_features = 1000
n_topics = 5
lda_top_words = 50

stopword = set(stopwords.words('english')) 
punctuations = set(string.punctuation) 
get_lemmatized= WordNetLemmatizer()

def lemmatized_file(doc):
	removed_stopwords = " ".join([word for word in doc.lower().split() if word not in stopword])
	removed_punctuations = "".join(word for word in removed_stopwords if word not in punctuations)
	lemmatized_text = " ".join(get_lemmatized.lemmatize(word) for word in removed_punctuations.split())
	return lemmatized_text
    
	

lemmatized_doc = [lemmatized_file(doc) for doc in doc_complete]        


tf_vectorizer = TfidfVectorizer(max_df=0.90, min_df=2,
                                   max_features=n_features,
                                   stop_words='english')
								   

tf = tf_vectorizer.fit_transform(lemmatized_doc)

lda = LatentDirichletAllocation(n_topics=n_topics, max_iter=500,
                                learning_method='online',
                                learning_offset=50.,
                                random_state=0)

lda.fit(tf)


tf_feature_names = tf_vectorizer.get_feature_names()

def get_top_words(model, feature_names, n_top_words):
	t_top_words=[]
	for topic_idx, topic in enumerate(model.components_):
		aggregate_of_top_words = " ".join([feature_names[i] for i in topic.argsort()[:-n_top_words - 1:-1]])
		print "Topic id ::" + str(topic_idx)
		print aggregate_of_top_words
		topic_top_words = t_top_words.append([topic_idx, aggregate_of_top_words])

	return t_top_words
		  

#print_top_words(lda, tf_feature_names, lda_top_words)
topic_top_words = get_top_words(lda, tf_feature_names, lda_top_words)

#defining all the stop words


stopwords = STOPWORDS.copy()

addtnl_words = ["Mr", "President", "shot", "replied", "saying", "including", "bring", "bringing", "using", "said", "added", "like", "mr", "planned", "told",
"going", "say", "want", "ask", "used", "feel", "including"] 

allstop_words = list(ENGLISH_STOP_WORDS) + list(stopwords) + list(STOPWORDS) + addtnl_words

def encode_utf8(x):
	for i in x:
		i.encode('UTF8')
	return x	

allstop_words = encode_utf8(allstop_words)

for i in range(len(topic_top_words)):
	u = np.array(Image.open(image_filepath + '/' + 'us.jpg'))
	wc = WordCloud(background_color="white", mask=u, stopwords=allstop_words, random_state=1)
	wc.generate(topic_top_words[i][1])
	wc.to_file('wordclouds'+ str(i) +'.jpg')
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
			
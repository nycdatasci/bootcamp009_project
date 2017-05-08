from google.cloud import language
import re
import json
import numpy as np
import random
from os import listdir
import os


class GoogleData(object):
	def __init__(self, dir, folder_name, only_trump):
		self.dir = dir
		self.folder_name = folder_name
		self.only_trump = only_trump
	
	def get_df(self):
		source_folder_dir = self.dir+'/'+self.folder_name
		source_dir_files = listdir(source_folder_dir)
		print 'Files in source:', len(source_dir_files)
		output_dir_path = self.dir+'/' + self.folder_name + '_trumpoutput/'
		if not os.path.exists(output_dir_path):
			os.makedirs(output_dir_path)
			
		for file in source_dir_files:
			print 'For file' + str(file)
			input_file = open(source_folder_dir + '/' + str(file), 'r')
			data = json.load(input_file)
			input_file.close()
			
			get_article = True
			if self.only_trump == True:
				get_article = True if ('Trump' in data['article'] or 'trump' in data['article']) else False
			if(get_article):
				print 'artcle with name ' + str(file) + ' sending to GoogleAPI ...'
				data = self.google_API(data)
				with open( output_dir_path + str(file), 'w') as f:
					json.dump(data, f)
		
	def google_API(self, df):
		text_content = df['article']
		client = language.Client()
		document = client.document_from_text(text_content)
		annotations = document.annotate_text(include_sentiment=True, include_syntax=True,
                                         include_entities=True)
		sentenceList = []
		for sentence in annotations.sentences:
			sentenceList.append(sentence.content)
			df['googleAPIsentences'] = sentenceList
				
		tokenList = []
		for token in annotations.tokens:
			tokenList.append({token.text_content: token.part_of_speech})
		
		df['googleAPItokens'] = tokenList
		df['googleAPIsentiment'] = [annotations.sentiment.score, annotations.sentiment.magnitude]

		entityList = []
		for entity in annotations.entities:
			entityList.append({'name': entity.name,
                           'type': entity.entity_type,
                           #'wikipedia_url': entity.wikipedia_url,
                           'metadata': entity.metadata,
                           'salience': entity.salience})
		df['googleAPIentities'] = entityList

		return df			

dir_path = r'C:\Users\Pradeep Krishnan\Desktop\NewsFlows'
folder = 'data'
all_files = GoogleData(dir_path,folder,True)
all_files.get_df()
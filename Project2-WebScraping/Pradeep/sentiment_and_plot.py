import numpy as np
import matplotlib.pyplot as plt
from os import listdir
import pandas as pd
import json
from pandas.io.json import json_normalize
from bokeh.charts import BoxPlot, output_notebook, show
from pandas.tools.plotting import boxplot_frame_groupby

allowed_spider_list = ['cbs', 'cnn', 'abc', 'fox', 'nypost'] #list of spider names
json_filepath = r'C:\Users\Pradeep Krishnan\Desktop\NewsFlows\data_output'
json_files= listdir(json_filepath)

# >>>>>> id is not a good variable name in Python because it is a built-in function. <<<<<<<
id, spider, sentiment, magnitude, article_length = [],[],[],[],[]

for file in json_files:
	f = open(json_filepath + '/'+ str(file), 'r')
	data = json.load(f)
	f.close()
	spider.append(data['spider'])
	id.append(data['id'])
	sentiment.append(data['googleAPIsentiment'][0])
	magnitude.append(data['googleAPIsentiment'][1])
	article_length.append(len(data['article']))

data_items = {'spider': spider,
			  'id': id,
			  'sentiment':sentiment,
			  'magnitude' : magnitude,
			  'article_length': article_length}

#df = pd.DataFrame(dict('Spider': spider, 'sentiment':sentiment))
df_spider_sentiment = pd.DataFrame(dict(spider=spider, sentiment=sentiment))
df_spider_article_len = pd.DataFrame(dict(spider=spider, article_length=article_length))
#df_spider_sentiment.to_csv('out.csv')

# Box plot for sentiment
sentiment_box_plt = df_spider_sentiment.boxplot(column='sentiment', by='spider')
plt.show(sentiment_box_plt)

# Bar plot for mean of article length
#y = data_items['article_length'].mean()
#N = len(y)
#x = allowed_spider_list
#width = 1/1.5
#article_len_bar_plt = plt.bar(x, y, width, color="blue")

df_grouped_len = df_spider_article_len.groupby(['spider'])['article_length'].mean()
article_len_bar_plt=df_grouped_len.plot.bar()
plt.show(article_len_bar_plt)

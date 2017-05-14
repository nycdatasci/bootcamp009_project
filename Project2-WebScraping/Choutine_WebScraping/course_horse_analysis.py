# -*- coding: utf-8 -*-

import pandas as pd
import numpy as np
import csv
import re 
from matplotlib import pyplot as plt
import seaborn as sns
import plotly.plotly as py
import plotly.graph_objs as go
plotly.tools.set_credentials_file(username='qiuzhou', api_key='qQJOspxuLygq7XMkOfgo')
from wordcloud import WordCloud, STOPWORDS



# read csv files of cities into dataframe
data_new_york=pd.read_csv("new_york.csv")
data_los_angeles=pd.read_csv("los_angeles.csv")
data_chicago=pd.read_csv("chicago.csv")
data_boston=pd.read_csv("boston.csv")
data_nashville=pd.read_csv("nashville.csv")
data_houston=pd.read_csv("houston.csv")

# combine all the data by rows
data=pd.concat([data_new_york,data_los_angeles,data_chicago,data_boston,data_nashville,data_houston])

# filter out the data with missing values of class_name, school and location
course_data=data[(data["class_name"].notnull())&(data["school"].notnull())&(data["location"].notnull())]

course_data.shape
#  (15575, 17) 53 rows, aprrox. 0.2% of data filtered out 


# split location column to address and neighborhood by "/n" to a new data frame
new_location=course_data.location.apply(lambda x: pd.Series([i for i in reversed(x.split('\n',1))]))
new_location.columns=["address","neighborhood"]

# remove remaining '\n' characters in address column 
new_location.address=new_location.address.apply(lambda x: x.replace("\n"," "))

# combine the data of new_location with course_data
course_data=pd.concat([course_data, new_location], axis=1)

# drop the untidy location column
course_data = course_data.drop('location', 1)

# remove text from" num_saved" column
course_data['num_saved'] = course_data['num_saved'].map(lambda x: x.rstrip('people saved this class'))
course_data['num_saved'] = course_data['num_saved'].map(lambda x: x.rstrip('person saved this class'))

# change data type of "num_saved" to int
course_data['num_saved']=course_data['num_saved'].astype(int)
# change data type of  "class_name" and "description" to string
course_data['description']=course_data['description'].astype(str)                                                           
course_data['class_name']=course_data['class_name'].astype(str)

# remove dollar sign from" price" columnm
course_data['price'] = course_data['price'].map(lambda x: x.lstrip('$'))
course_data['price']=course_data['price'].str.replace(',','')

# check No of courses per city
course_data.groupby("city").count()


# Graph barchart to showOverall number of class listings 
# %matplotlib inline

overallG=sns.barplot(x=course_data.category.value_counts().index, y=data.category.value_counts())
overallG.figure.set_size_inches(18,10)
# sns.set_style("white")
overallG.set_ylabel("No. of Available Courses",fontsize=20)
overallG.tick_params(labelsize=18,labelcolor="black")

# Graph barchart to show No. of tech courses
tech=course_data.loc[course_data.category=="Tech"]
techG=sns.barplot(x=tech.sub_cat1.value_counts().index, y=tech.sub_cat1.value_counts())
techG.figure.set_size_inches(20,10)
techG.set_ylabel("No. of Available Courses",fontsize=20)
techG.tick_params(labelsize=18,labelcolor="black")

# Graph barchart to show No. of software courses
AllSoftware=tech.loc[tech.sub_cat1=="All Software"]
AllSoftware["sub_cat2"].value_counts()
softG=sns.barplot(x=AllSoftware.sub_cat2.value_counts().index, y=AllSoftware.sub_cat2.value_counts())
softG.figure.set_size_inches(20,10)
softG.set_ylabel("No. of Available Courses",fontsize=20)
softG.tick_params(labelsize=18,labelcolor="black")

# =============================================================================
# Compare % of No. of offerings and % of num saved regarding software courses
total_software=len(AllSoftware)
# get counts of each sub_cateogories2
count_software=AllSoftware.groupby("sub_cat2").size()
# % of each sub_cateogories2 in software
perc_software=(count_software/total_software).sort_values(ascending=False)

sum_software_saved=AllSoftware[["num_saved"]].sum()[0]
saved_software=AllSoftware.groupby("sub_cat2")["num_saved"].agg(sum)
#  percentage of times of saved by sub_cat2
perc_software_saved=saved_software/sum_software_saved

# graph group bar chart
trace1 = go.Bar(
    x=perc_software.index,
    y=perc_software,
    name='Supply',
    marker=dict(
        color='#1f78b4')
)
trace2 = go.Bar(
    x=perc_software_saved.index,
    #x=perc_software.index,
    y=perc_software_saved,
    name='Demand',
     marker=dict(
        color='#b2df8a')
)

data = [trace1, trace2]
layout = go.Layout(
    title="All Software",
    font=dict(family='Lucida Sans Unicode', size=22, color='#7f7f7f'),
    barmode='group',
    xaxis=dict(
        tickfont=dict(
        size=18)),
    
    yaxis=dict(
        tickfont=dict(
            size=18
        )
    )
)

fig = go.Figure(data=data, layout=layout)
py.iplot(fig, filename='grouped-bar')

# show wordcloud of Microsoft courses description 
Microsoft=AllSoftware[AllSoftware["sub_cat2"]=="Microsoft"]

# join description to a single string
words = ' '.join(Microsoft.description)
MicrosoftDescr= ' '.join([word for word in words.split() if '\n' not in word and 
                           word !='file' and word !='students' and word !='Using'
                         and word !='students will'and word !='course will'
                          and word !='will able'and word !='will learn'])
    
wordcloud = WordCloud(
                      stopwords=STOPWORDS,
                      background_color='black',
                      width=1800,
                      height=1400
                     ).generate(MicrosoftDescr)
plt.imshow(wordcloud)
plt.axis('off')
plt.show()

# show wordcloud of Adobe courses description 

adobe=AllSoftware[AllSoftware["sub_cat2"]=="Adobe"]
# join Adobe to a single string
words = ' '.join(adobe.description)
adobeDescr= ' '.join([word for word in words.split() if '\n' not in word and 
                           word !='file' and word !='Lesson' and word !='Using'and word !='using'])
    
wordcloud = WordCloud(
                      stopwords=STOPWORDS,
                      background_color='black',
                      width=1800,
                      height=1400
                     ).generate(adobeDescr)
plt.imshow(wordcloud)
plt.axis('off')
plt.show()


# =============================================================================
# Compare % of No. of offerings and % of num saved regarding programming courses
programming=tech.loc[tech.sub_cat1=="Programming"]

total_prog=len(programming)
count_prog=programming.groupby("sub_cat2").size()
perc_prpg=(count_prog/total_prog).sort_values(ascending=False)


sum_prog_saved=programming[["num_saved"]].sum()[0]
saved_prog=programming.groupby("sub_cat2")["num_saved"].agg(sum)
perc_prog_saved=saved_prog/sum_prog_saved


trace1 = go.Bar(
    x=perc_prpg.index,
    y=perc_prpg,
    name='Supply',
    marker=dict(
        color='#1f78b4')
)
trace2 = go.Bar(
    x=perc_prog_saved.index,
    #x=perc_software.index,
    y=perc_prog_saved,
    name='Demand',
     marker=dict(
        color='#b2df8a')
)

data = [trace1, trace2]
layout = go.Layout(
    title="Programming",
    font=dict(family='Lucida Sans Unicode', size=22, color='#7f7f7f'),
    barmode='group',
    xaxis=dict(
        tickfont=dict(
        size=11)),
    
    yaxis=dict(
        tickfont=dict(
            size=16
        )
    )
)

fig = go.Figure(data=data, layout=layout)
py.iplot(fig, filename='grouped-bar')


# show wordcloud of introProg
introProg=programming[programming["sub_cat2"]=="Intro to Programming"]

words = ' '.join(introProg.description)
introProgDescr= ' '.join([word for word in words.split() if '\n' not in word 
                          and word !='Lesson' and word !='Programming'
                          and word !='training'and word !='programming'
                          and word !='course'])    
wordcloud = WordCloud(
                      stopwords=STOPWORDS,
                      background_color='black',
                      width=1800,
                      height=1400
                     ).generate(introProgDescr)
plt.imshow(wordcloud)
plt.axis('off')
plt.show()


# show wordcloud of Programming Languages
progLang=programming[programming["sub_cat2"]=="Programming Languages"]

words = ' '.join(progLang.description)
progLangDescr= ' '.join([word for word in words.split() if '\n' not in word and 
                           word !='Introduction' and word !='Lesson' 
                           and word !='Programming'and word !='training'
                           and word !='file' and word !='students' 
                           and word !='Using'and word !='students will'
                           and word !='Students will'and word !='course will'
                           and word !='course provides'])
    
wordcloud = WordCloud(
                      stopwords=STOPWORDS,
                      background_color='black',
                      width=1800,
                      height=1400
                     ).generate(progLangDescr)
plt.imshow(wordcloud)
plt.axis('off')
plt.show()


# ===============================================================================
# analyzing categories of class by cities
# new york city
newyork=course_data[course_data["city"]=="New York"]
newyork_cat=newyork.category.value_counts()

newyork_cat.plot.pie(fontsize=18,autopct='%1.1f%%',colormap="Blues_r",
                     pctdistance=0.8,explode = (0.1, 0, 0, 0,0,0,0,0,0),
                     figsize=(6, 6))
plt.axis('equal')
plt.title("New York City", fontsize = 25)
plt.ylabel('')








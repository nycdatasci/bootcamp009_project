# histogram with density plot
with sns.color_palette("Set2", 5):
    sns.distplot(bestreads['Year'], 
                 bins = max(bestreads['Year']) - min(bestreads['Year']))
    plt.title('Number of books in top 500 list by year of publication', fontsize=16)


###################

top_5_per_cat_pivot = top_5_per_cat.pivot(index='AllGenres', columns='RankingCat', values ='Count')
top_5_per_cat_pivot
# utilize utility to make it easy to get json/dict data converted to a dataframe
df = df_from_json(data)

from collections import OrderedDict
from bokeh.charts import Bar, output_file, show
from bokeh.charts.attributes import cat, color
from bokeh.charts.operations import blend

top_5_per_cat_pivot_index = top_5_per_cat_pivot.reset_index()
top_5_per_cat_pivot_index = top_5_per_cat_pivot_index.fillna(0)

genres = top_5_per_cat_pivot_index['AllGenres'].values.tolist()
top100 = top_5_per_cat_pivot_index['Top 100'].astype(float).values
top200 = top_5_per_cat_pivot_index['Top 100 - 200'].astype(float).values
top300 = top_5_per_cat_pivot_index['Top 200 - 300'].astype(float).values
top400 = top_5_per_cat_pivot_index['Top 300 - 400'].astype(float).values

rank = OrderedDict(top100=top100, top200=top200, top300=top300, top400=top400)

bar = Bar(rank, genres, stacked=True)
show(bar)


#####################
from bokeh.charts import Bar, output_file, show, Scatter
from bokeh.charts.attributes import cat, color
from bokeh.charts.operations import blend
from bokeh.charts.utils import df_from_json
from bokeh.models import HoverTool, BoxSelectTool

hover = HoverTool(
        tooltips=[
            ("Category", "$x"),
            ('Count','$y')
        ]
    )

scatter = Scatter(top_5_per_cat, x='RankingCat', y='Count', color='AllGenres' ,
                  title="Top 5 Genres per Category", xlabel="",
                  ylabel=" ",tools = [hover], plot_width=950, plot_height=600)

scatter.xgrid.grid_line_color = None
scatter.ygrid.grid_line_color = None
scatter.title.text_font_size = '16pt'
# scatter.xaxis.axis_label_text_font_size = "20pt"
# scatter.yaxis.axis_label_text_font_size = "20pt"
scatter.legend.location = "top_right"

show(scatter)


###################
import plotly.plotly as py
import plotly.graph_objs as go

fig = {
    'data': [{'labels': ['Residential', 'Non-Residential', 'Utility'],
              'values': [19, 26, 55],
              'type': 'pie'}],
    'layout': {'title': 'Forcasted 2014 U.S. PV Installations by Market Segment'}
     }

py.iplot(fig)


df_pie = go.Pie(labels=counter_df['Genre'], values=counter_df['Count'])

py.iplot([df_pie])


###############
# removing other from plot
data = [
    go.Area(
    r=counter_df_no_other['Count'],
    t=counter_df_no_other['Genre'],
    marker=dict(
        color='rgb(102,166,30)'
    ))
        ] 

layout = go.Layout(
    title='Distribution of Top 500 books by genre',
    font=dict(
        size=14,
        color = '#000'
    ),
    showlegend = False,
    legend=dict(
        font=dict(
            size=10
        )
    ),
    angularaxis=dict(
        tickcolor='#CCC',
        showline=False,
        range = [0,0.025]
    ),
    radialaxis=dict(
        ticksuffix='%'
    ),
    xaxis = dict(
        showgrid= False,
        zeroline=False,
        nticks = 20,
        showline = False,
        showticklabels=False,
        autotick = False,
        visible = True
    ),
    yaxis = dict(
        autotick=False,
        showgrid= False,
        showticklabels=False,
        ticks='',
        tick0=0,
        dtick=0.25,
        ticklen=8,
        tickwidth=4,
        tickcolor='#000',
        showexponent='All'
    ),
    orientation= 90
)

fig = go.Figure(data=data, layout=layout)
py.iplot(fig)


##############
# plot the results
with sns.color_palette("Set2", 5), sns.plotting_context("notebook",font_scale=1.5):
    g= sns.barplot(counter_df_percent_no_other['Genre'], counter_df_percent_no_other['Count'], palette = 'Set2')
    plt.ylabel('')
    plt.xlabel('')
    plt.xticks(rotation=45)
    g.figure.set_size_inches(16,6)
    


###############
with sns.color_palette("Set2", 5), sns.plotting_context("notebook",font_scale=1.7):
    sns.lmplot("Score", "NumberOfPages", bestreads, palette="Set2", fit_reg=False, size=8, aspect = 1.7)
    plt.ylabel('Number of Pages')
    plt.xlabel('Score')


###############
df_histogram = bestreads[['Year','Title']].groupby('Year').size().rename('Count').reset_index
list(df_histogram.columns.values)



##############
from bokeh.models import Range1d

hover = HoverTool(
        tooltips=[
            ("Number of Books", "$y{int}"),
            ('Year','$x{int}')
        ]
    )

p = Histogram(bestreads['Year'], 
              title="# of Books in Top 500 by Year of Publication", 
              tools = [hover],
              plot_width=950, 
              plot_height=400,
              bins = max(bestreads['Year']) - min(bestreads['Year']),
              palette = ['#d3ffce'])
p.x_range = Range1d(min(bestreads['Year']), max(bestreads['Year']))

plot_aes(p)
show(p)


###########
rcParams.update({'font.size': 15})
plt.rcParams['figure.figsize']=(16,8)
plt.style.use('seaborn-white')
with sns.color_palette("Set2", 5):
    sns.distplot(bestreads['Year'], 
                 bins = max(bestreads['Year']) - min(bestreads['Year']))
    sns.despine()
    plt.title('Number of books in top 500 list by year of publication', fontsize=16)



############
rcParams.update({'font.size': 15})
plt.rcParams['figure.figsize']=(16,8)
plt.style.use('seaborn-white')
bestreads['Year'].plot.hist(bins = max(bestreads['Year']) - min(bestreads['Year']), color = ['#87c2db'])
sns.despine()
plt.xlabel('log of budget')
plt.ylabel('count')
plt.title('Histogram of budget', fontsize=20)

#######
import plotly.plotly as py
import plotly.graph_objs as go

data = [go.Histogram(x=bestreads['Year'])]

py.iplot(data, filename='')


############
rcParams.update({'font.size': 15})
plt.rcParams['figure.figsize']=(16,8)
plt.style.use('seaborn-white')
with sns.plotting_context("notebook",font_scale=1.3):
    g = bestreads['Year'].plot.hist(bins = max(bestreads['Year']) - min(bestreads['Year']), color = ['#87c2db'])
    sns.despine()
    sns.plt.xlim(min(bestreads['Year'])-2,max(bestreads['Year']))
    plt.ylabel('')
    plt.suptitle('Number of Books in Top 500 by Year of Publication', fontsize=20, y=0.82, weight = 'bold')
    g.figure.set_size_inches(16,6)

################

rcParams.update({'font.size': 15})
plt.rcParams['figure.figsize']=(16,8)
plt.style.use('seaborn-white')
with sns.color_palette("Set2", 5):
    sns.distplot(bestreads['Year'], 
                 bins = max(bestreads['Year']) - min(bestreads['Year']))
    sns.despine()
    plt.title('Number of books in top 500 list by year of publication', fontsize=16)


############
from bokeh.models import Range1d

hover = HoverTool(
        tooltips=[
            ("Number of Books", "$y{int}"),
            ('Year','$x{int}')
        ]
    )

p = Histogram(bestreads['Year'], 
              title="# of Books in Top 500 by Year of Publication", 
              tools = [hover],
              plot_width=950, 
              plot_height=400,
              bins = max(bestreads['Year']) - min(bestreads['Year']),
              palette = ['#87c2db'])
p.x_range = Range1d(min(bestreads['Year']), max(bestreads['Year']))

plot_aes(p)
show(p)

##############
import plotly.plotly as py
import plotly.graph_objs as go
import datetime
bestreads['Year'] = bestreads['Year'].apply(lambda x: str(x))
bestreads['Year'] = bestreads['Year'].apply(lambda x: datetime.datetime.strptime(x, "%Y").year)

data = [go.Histogram(
        x=bestreads['Year'], 
        autobinx=False,
        xbins=dict(
            start=min(bestreads['Year']),
            end=max(bestreads['Year']),
            size=1
        ),
        marker=dict(
            color='#87c2db'
        ),
        opacity=0.75)]

layout = go.Layout(
    title='Number of Books in Top 500 by Year of Publication',
    font=dict(size=16, color='#000'),
    xaxis = dict(
        title='',
        showgrid= False,
    ),
    yaxis = dict(
        autotick=False,
        showgrid= False,
        showticklabels=False,
        ticks=''),
    bargap=0.1,
    bargroupgap=0.1
)

fig = go.Figure(data = data, layout = layout)
py.iplot(fig)

###########
rcParams.update({'font.size': 15})
plt.rcParams['figure.figsize']=(16,8)
plt.style.use('seaborn-white')
with sns.plotting_context("notebook",font_scale=1.3):
    g = bestreads['Year'].plot.hist(bins = max(bestreads['Year']) - min(bestreads['Year']), color = ['#87c2db'])
    sns.despine()
    sns.plt.xlim(min(bestreads['Year'])-2,max(bestreads['Year']))
    plt.ylabel('')
    plt.suptitle('Number of Books in Top 500 by Year of Publication', fontsize=20, y=0.82, weight = 'bold')
    g.figure.set_size_inches(16,6)
    plt.annotate('2006', xy = (2006, 37), 
             xycoords = 'data', xytext = (2008, 35), textcoords = 'data', 
             arrowprops = dict(arrowstyle = 'simple', color = '#000000'))
    plt.annotate('2003', xy = (2003, 36), 
             xycoords = 'data', xytext = (2005, 34), textcoords = 'data', 
             arrowprops = dict(arrowstyle = 'simple', color = '#000000'))

############
import plotly.plotly as py
import plotly.graph_objs as go
import datetime
# bestreads['Year'] = bestreads['Year'].apply(lambda x: str(x))
# bestreads['Year'] = bestreads['Year'].apply(lambda x: datetime.datetime.strptime(x, "%Y").year)

data = [go.Histogram(
        x=bestreads['Year'], 
        autobinx=False,
        xbins=dict(
            start=min(bestreads['Year']),
            end=max(bestreads['Year']),
            size=1
        ),
        marker=dict(
            color='#87c2db'
        ),
        opacity=0.75)]

layout = go.Layout(
    title='Number of Books in Top 500 by Year of Publication',
    font=dict(size=16, color='#000'),
    xaxis = dict(
        title='',
        showgrid= False,
    ),
    yaxis = dict(
        autotick=False,
        showgrid= False,
        showticklabels=False,
        ticks=''),
    bargap=0.1,
    bargroupgap=0.1
)

fig = go.Figure(data = data, layout = layout)
py.iplot(fig)


##########
test = bestreads[['Year','MainGenre']].groupby('Year').size().rename('Count').reset_index()
test


#########
data = {'fruit': df_merged['RankingCat'],
        'fruit_count': df_merged['Percent'],
        'sample': df_merged['AllGenres']}

hm = HeatMap(data, x='fruit', y='sample', values='fruit_count',
             title='Fruits', stat=None)
show(hm)


###########
# # look at number of genres per cat to be able to manually select the top 5
# print df_genre_stacked.groupby('RankingCat').count() 

# select the top 5 in each ranking category (e.g top 100 category, etc.)
top_5_per_cat = df_genre_stacked.iloc[[0,1,2,3,4,136,137,138,139,140,261, 262, 263, 264, 265, 379, 380, 381, 382, 383]]
top_5_per_cat = top_5_per_cat.sort_values(by ='RankingCat')

# round the 'count' column
top_5_per_cat['Count'] = top_5_per_cat['Count'].round()

##### instead of a absolute numbers, let's calculate the relative numbers of books per genre and ranking category

# create a dataframe where we calculate the total number of books by category
df_genre_stacked_percent = df_genre_stacked.groupby('RankingCat').agg({'Count': sum}).reset_index()

# merge the dataframe with the top_5_per_cat dataframe
df_merged = pd.merge(top_5_per_cat, df_genre_stacked_percent , how='inner', on = 'RankingCat')

# create an additional column to calculate percentage
df_merged['Percent'] = (df_merged['Count_x']/df_merged['Count_y'])*100
df_merged['Percent'] = df_merged['Percent'].apply(lambda x: round(x,1)) # round the percentages

# plot the results
from bokeh.charts import Bar, show
from bokeh.models import HoverTool, BoxSelectTool

hover = HoverTool(
        tooltips=[
            ("Genre", "@AllGenres"),
            ('Percent','$y{1.1}%')
        ]
    )

p = Bar(df_merged, 'RankingCat', 
        values='Percent', 
        xlabel="",
        ylabel="% books per genre",
        group='AllGenres', 
        title="Top 5 Genres per Rank Category",
        tools = [hover],
        plot_width=950, plot_height=600,
        color=['#d3ffce', '#ffd1d1', '#c6e2ff', '#dba087', '#d8be7e', '#b1d0ca']
       )

plot_aes(p)
p.xaxis.major_label_orientation = 'horizontal' 
# p.xaxis.axis_label_text_font_size = "40pt"

show(p)

################

from bokeh.models import Range1d

hover = HoverTool(
        tooltips=[
            ("Number of Books", "$y{int}"),
            ('Year','$x{int}')
        ]
    )

p = Histogram(bestreads, 
              values = 'Year',
              color=['#cfaec6'],
              title="Number of Books in Top 500 by Year of Publication", 
              tools = [hover],
              plot_width=950, 
              plot_height=400,
              ylabel=" ",
              xlabel=" ",
              bins = max(bestreads['Year']) - min(bestreads['Year'])
             )
p.x_range = Range1d(min(bestreads['Year']), max(bestreads['Year']))
p.line(year_pages['Year'],year_pages['NumberOfPages'] , line_width=2)

plot_aes(p)
show(p)

##############
# plot the results to see if correlation between books sold and # of books in top 500
hover = HoverTool(
        tooltips=[
            ("Number of Books in Top 500", "$y{int}"),
            ('Number of Books Sold',"$x{int}")
        ]
    )


p = Scatter(reviewscount_df, 
            x="RankingCat", 
            y="NumberOfReviews", 
            title="Number of Books Sold vs. Number of Books in Top 500",
            xlabel='# of Books Sold in US ($Millions)', 
            ylabel='Number of Books in Top 500',
            tools = [hover],
            color = ['#7ea4b3'],
            plot_width=950, plot_height=400)
    
plot_aes(p)
show(p)


#################
# plot the results to see if correlation between books sold and # of books in top 500
hover = HoverTool(
        tooltips=[
            ("Number of Books in Top 500", "$y{int}"),
            ('Number of Books Sold',"$x{int}")
        ]
    )


p = Scatter(reviewscount_df, 
            x="NumberOfReviews", 
            y="Score", 
            title="Number of Books Sold vs. Number of Books in Top 500",
            xlabel='# of Books Sold in US ($Millions)', 
            ylabel='Number of Books in Top 500',
            tools = [hover],
            color = ['#7ea4b3'],
            plot_width=950, plot_height=400)
    
plot_aes(p)
show(p)

####
# The score is not necessarily truly respective of the rank. GoodReads users vote for the top books.
# The ranking is the most accurate reflection of the votes. 
# Looking at the relationship between Afinn Score and Ranking.

# The graph does not tell much either b

# hover = HoverTool(
#         tooltips=[
#             ("Value", "$y{int}")
#         ]
#     )

p = BoxPlot(filtered_df, 
            values='afinn', 
            label='RankingCat',
            title="Afinn Score vs GoodReads Score", 
            ylabel='Number of Reviews',
            xlabel='',
            tools = ['box_zoom', 'reset'],
            color = ['#cfaec6'],
            whisker_color='black',
            legend = None,
#             marker= 'x',
            outliers=False,
            plot_width=950, plot_height=400)

p.left[0].formatter.use_scientific = False
p.xaxis.major_label_orientation = 'horizontal'

plot_aes(p)
show(p)


##########
unigrams = []
afinn_value = []
ranking_category = []
for ind, review in islice(filtered_df.iterrows(),388):
    unigrams = ( [i.lower() for i in wordpunct_tokenize(review['Reviews']) if i.lower() not in stop_words])
    afinn_value.append(np.mean(list(map(lambda x: afinn.score(str(x.encode('utf-8'))), unigrams))))
    ranking_category.append(review['RankingCat'])
    
    score_boxplot = pd.DataFrame()
score_boxplot['ranking_category'] = ranking_category
score_boxplot['senti_value'] = afinn_value
score_boxplot['ranking_category'].min()

rcParams.update({'font.size': 15})
plt.style.use('seaborn-white')
ax = score_boxplot.boxplot(by=['ranking_category'], figsize=(10,6))
ax.get_figure().suptitle("")
ax.set_title('Average sentiment score and rating. - Using AFINN')
ax.set_xlabel('Score')
ax.set_ylabel('Average sentiment score')
ax.grid(False)


##############
# looking at Vader Score vs goodreads score and evaluating its reliability compared to Afinn score
# plot the results to see if correlation between books sold and # of books in top 500
hover = HoverTool(
        tooltips=[
            ("GoodReads Score", "$x{int}"),
            ('Vader Score',"$y{int}")
        ]
    )


p = Scatter(filtered_vader_df, 
            x="Score", 
            y="compound", 
            title="Vader Compound Score vs. GoodReads Score",
            xlabel='GoodReads Score)', 
            ylabel='Vader Compound Score',
            tools = [hover],
            color = 'RankingAfinn',
            plot_width=950, plot_height=400)
    
plot_aes(p)
show(p)

# The results show a positive Afinn Score for most of the top 500 books which is expected. 
# However we see that some books have a negative Afinn score. 
# We can question the accuracy of the Afinn score to predict the success of a book.

# 1- We will look at the positive and negative words that impact the ranking in the Afinn library to understand why
# 2- We will look at another library to help better predict the score


#######################
TOTAL AFINN SCORE PER REVIEW 

# looking at goodreads score vs Afinn score. The AFINN lexicon provides a positivity score for each word, 
# from -5 (most negative) to 5 (most positive).  We take the average of the AFINN score per review.
# plot the results to see if correlation between GoodReads score and Afinn Score
hover = HoverTool(
        tooltips=[
            ("GoodReads Score", "$x{int}"),
            ('Afinn Score',"$y{int}")
        ]
    )


p = Scatter(filtered_df, 
            x="Score", 
            y="afinn_avg", 
            title="GoodReads Score vs. Afinn Score",
            xlabel='GoodReads Score', 
            ylabel='Total Afinn Score',
            tools = [hover],
            color = ['#7ea4b3'],
            plot_width=950, plot_height=400)
    
plot_aes(p)
show(p)

# The results show a positive Afinn Score for most of the top 500 books which is expected. 
# However we see that some books have a negative Afinn score. 
# We can question the accuracy of the Afinn score to predict the sucess of a success.

# 1- We will look at the positive and negative words that impact the ranking in the Afinn library to understand why
# 2- We will look at another library to help better predict the score


# The score is not necessarily truly respective of the rank. GoodReads users vote for the top books.
# The ranking is the most accurate reflection of the votes. 
# Looking at the relationship between Afinn Score and Ranking.

# The graph does not tell much either b

# hover = HoverTool(
#         tooltips=[
#             ("Value", "$y{int}")
#         ]
#     )

p = BoxPlot(filtered_df, 
            values='afinn', 
            label='RankingCat',
            title="Total Afinn Score by Ranking Category", 
            ylabel='Total Sentiment Score',
            xlabel='',
            tools = ['box_zoom', 'reset'],
            color = ['#cfaec6'],
            whisker_color='black',
            legend = None,
#             marker= 'x',
            outliers=False,
            plot_width=950, plot_height=400)

p.left[0].formatter.use_scientific = False
p.xaxis.major_label_orientation = 'horizontal'

plot_aes(p)
show(p)


#######################
#GRAPHS WITH VADER SCORE

# looking at Vader Score vs goodreads score and evaluating its reliability compared to Afinn score
# plot the results to see if correlation between books sold and # of books in top 400
hover = HoverTool(
        tooltips=[
            ("GoodReads Score", "$x{int}"),
            ('Vader Score',"$y{int}")
        ]
    )


p = Scatter(filtered_vader_df, 
            x="Score", 
            y="compound", 
            title="Vader Compound Score vs. GoodReads Score",
            xlabel='GoodReads Score)', 
            ylabel='Vader Compound Score',
            tools = [hover],
            color = 'RankingAfinn',
            plot_width=950, plot_height=400)
    
plot_aes(p)
show(p)

# The results show a positive Afinn Score for most of the top 400 books which is expected. 
# However we see that some books have a negative Afinn score. 
# We can question the accuracy of the Afinn score to predict the success of a book.

# 1- We will look at the positive and negative words that impact the ranking in the Afinn library to understand why
# 2- We will look at another library to help better predict the score



#############
from bokeh.models import Span, ColumnDataSource, Range1d, LabelSet, Label

# adding vertical line
vline = Span(location=1500, dimension='height', line_color='#dba087', line_width=1.5)

# adding label next to vertical line
citation = Label(x=1600, y=3.87,
                 text='word count > 1500', render_mode='css', border_line_alpha=1.0, text_font_size = '8pt', text_color = 'grey')


tooltips=[
            ('Word', '@Reviews')
        ]

p = Scatter(afinn_scatter_df_1500, 
            x="Count", 
            y="Score", 
            title="Word Count vs. GoodReads Score",
            xlabel='Word Count', 
            ylabel='Average GoodReads Score',
            tooltips = tooltips,
            color = ['#7ea4b3'],
            plot_width=950, plot_height=400)


p.renderers.extend([vline])
p.add_layout(citation)

plot_aes(p, legend ='bottom_right')
show(p)


###########

# plotting a scatter to analyze possible trends between goodreads score and afinn score.
hover = HoverTool(
        tooltips=[
            ("GoodReads Score", "$x{int}"),
            ('Afinn Score',"$y")
        ]
    )


p = Scatter(afinn_plot, 
            x="score", 
            y="senti_value", 
            title="GoodReads Score vs. Sentiment Score (using AFINN)",
            xlabel='GoodReads score', 
            ylabel='Average sentiment score',
            tools = [hover],
            color = ['#7ea4b3'],
            plot_width=950, plot_height=400)

p.ray(x=[0], y=[0], length=0, angle=0, line_width=1.5,color = ['#dba087'])
    
plot_aes(p)
show(p)

###########
#PAIR GRID - 2ND BEST
sns.set(style="white")
sns.pairplot(filtered_vader_df)
sns.plt.show()


#########
#PAIR GRID
from pandas import scatter_matrix
scatter_matrix(filtered_vader_df, diagonal='kde', figsize=(14,14))
sns.plt.show()


########
#PAIR GRID

import matplotlib.pyplot as plt
plt.matshow(filtered_vader_df.corr())
plt.show()# 

#########
import seaborn as sns
import matplotlib.pyplot as plt

computing the correlation matrix
corr = filtered_vader_df.corr()

# # generating a mask for the upper triangle
mask = np.zeros_like(corr, dtype=np.bool)
mask[np.triu_indices_from(mask)] = True

# setting up the matplotlib figure
f, ax = plt.subplots(figsize=(12, 16))

# generating a custom diverging colormap
cmap = sns.diverging_palette(220, 10, as_cmap=True)


# drawing the heatmap with the mask and correct aspect ratio
with sns.axes_style("white"):
    ax = sns.heatmap(corr, 
            mask=mask, 
            cmap=cmap, 
            vmax=.3,
            square=True, 
            xticklabels=5, 
            yticklabels=5,
            linewidths=.5, 
            cbar_kws={"shrink": .5}, 
                     ax=ax
                    )

ax.set_xticks(np.arange(5)+0.5) # center x ticks
ax.set_yticks(np.arange(5)+0.5) # center y ticks
ax.set_xticklabels(filtered_vader_df.columns)
ax.set_yticklabels(filtered_vader_df.columns)

sns.plt.show()

#############
hover = HoverTool(
        tooltips=[
            ("GoodReads Score", "$x{int}"),
            ('Vader Score',"$y{int}")
        ]
    )


p = Scatter(filtered_vader_df, 
            x="Score", 
            y="compound", 
            title="Vader Compound Score vs. GoodReads Score",
            xlabel='GoodReads Score)', 
            ylabel='Vader Compound Score',
            tools = [hover],
#             color = 'RankingAfinn',
            plot_width=950, plot_height=400)
    
plot_aes(p)
show(p)


###########
import numpy as np; np.random.seed(0)
import seaborn as sns; sns.set()

filtered_vader_df_heatmap = filtered_vader_df[['goodreads_score','afinn_score','compound','pos','neu','neg']]

ax = sns.heatmap(filtered_vader_df_heatmap)
plt.show()

##############
# creating categories for Afinn score to help read the plot
def afinncat(row):
    if (row['afinn'] >= 500):
        return 'Score: over 500'
    elif (row['afinn'] < 500) and (row['afinn'] > 0):
        return 'Score: 0 - 500'
    else:
        return 'Score: negative'

filtered_vader_df['RankingAfinn'] = filtered_vader_df.apply(lambda x: afinncat(x), axis = 1)

##############
# plotting a heatmap to analyze correlation between ratio negative and positive Vader Score vs goodreads score

# hover = HoverTool(
#         tooltips=[
#             ("Genre", "$x"),
#             ('Count', "@Count")
#         ]
#     )

data = {'Vader Positive Score': filtered_vader_df_heatmap['pos'],
        'GoodReads Score': filtered_vader_df_heatmap['goodreads_score'],
        'Vader Negative Score': filtered_vader_df_heatmap['neg']}

p = HeatMap(data, y='Vader Negative Score', 
            x='Vader Positive Score', 
            values='GoodReads Score',
             title='Top 5 Genres per Rank Category', stat=None, xlabel="",
            ylabel="",
#             tools = [hover],
            plot_width=950, plot_height=600,
#             palette=['#7ea4b3', '#9ebbc6', '#cedde2', '#bed1d8','#dee8eb']
           ) 

plot_aes(p)
p.yaxis.major_label_orientation = 'horizontal'

show(p)

#############
# We are interested in analyzing the sentiment score for the Reviews column.
# The AFINN lexicon provides a positivity score for each word, from -5 (most negative) to 5 (most positive).  

# Filtering df with the relevant columns
filtered_df = bestreads[['RankingCat','Reviews', 'Score', 'Title']]

# # Sentiment analysis with AFINN for Reviews column
# afinn_scores = [afinn.score(text) for text in filtered_df.Reviews]
# filtered_df['afinn'] = afinn_scores
# filtered_df.head(10)


# # computing the average sentiment score for each review. 
# stop_words = set(stopwords.words('english'))
# stop_words.update(['.', ',', '"', "'", '?', '!', ':', ';', '(', ')', '[', ']', '{', '}' ,'<', '>','*','&','%','#',':',';'])

# unigrams = []
# afinn_value = []
# ranking_category = []
# score = []
# for ind, review in islice(filtered_df.iterrows(),388):
#     unigrams = ( [i.lower() for i in wordpunct_tokenize(review['Reviews']) if i.lower() not in stop_words])
#     afinn_value.append(np.mean(list(map(lambda x: afinn.score(str(x.encode('utf-8'))), unigrams))))
#     ranking_category.append(review['RankingCat'])
#     score.append(review['Score'])



# computing the average sentiment score for each review. We already cleaned the Reviews columns by removing 'stop words',
# punctuation and converting all lower cases to upper cases 

# stop_words = set(stopwords.words('english'))
# stop_words.update(['.', ',', '"', "'", '?', '!', ':', ';', '(', ')', '[', ']', '{', '}' ,'<', '>','*','&','%','#',':',';'])

unigrams = []
afinn_value = []
ranking_category = []
score = []
for ind, review in islice(filtered_df.iterrows(),388):
    unigrams = ( [i for i in wordpunct_tokenize(review['Reviews'])])
    afinn_value.append(np.mean(list(map(lambda x: afinn.score(str(x.encode('utf-8'))), unigrams))))
    ranking_category.append(review['RankingCat'])
    score.append(review['Score'])




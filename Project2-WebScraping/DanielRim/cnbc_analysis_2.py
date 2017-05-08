import pandas as pd
import pandas_datareader.data as web
import pylab
import datetime
import matplotlib.pylab as plt
import seaborn as sns
import statsmodels.formula.api as sm
from sklearn import datasets, linear_model
from sklearn.metrics import r2_score, mean_squared_error, make_scorer
import numpy as np

df_estimates = pd.read_csv('estimates_price.csv', index_col=False, header=0)

#df_estimates = df_estimates.loc[df_estimates["Report Date"]>datetime("2015-12-31")]
#print df_estimates.loc[df_estimates["Report Date"]<=datetime("2015-12-31")]

df_estimates = df_estimates.drop("Unnamed: 0",1)
df_estimates = df_estimates.drop("Unnamed: 0.1",1)
df_estimates = df_estimates.reset_index(drop=True)


############ Convert string to float ############################

print df_estimates["Estimate EPS"].replace(',','',inplace=True)
df_estimates["Estimate EPS"] = df_estimates["Estimate EPS"].apply(pd.to_numeric, errors='coerce')

df_estimates["Actual EPS"] = df_estimates["Actual EPS"].apply(pd.to_numeric, errors='coerce')


df_estimates = df_estimates.loc[df_estimates["Estimate EPS"].notnull()]
df_estimates = df_estimates.loc[df_estimates["Actual EPS"].notnull()]

######## Outlier ################################################

df_estimates = df_estimates.loc[df_estimates["Estimate EPS"]<400]



######## Compute return after reporting earnings ################
df_estimates["Perf"]=100*(df_estimates["Post Date Price"]/df_estimates["Prior Date Price"]-1)

######## Compute Surprise #######################################
df_estimates["Surprise"]=(df_estimates["Actual EPS"]-
df_estimates["Estimate EPS"])


print df_estimates
print len(df_estimates["Estimate EPS"])
print len(df_estimates["Actual EPS"])
print "*"*50
print type(df_estimates["Estimate EPS"][0])
print type(df_estimates["Actual EPS"][0])

df_estimates.to_csv('estimates_final.csv')

############# Group by Beat/Miss and compute average returns ####
print "Mean:" 
print df_estimates.groupby("Hurdle")["Perf"].mean()
print "Median:" 
print df_estimates.groupby("Hurdle")["Perf"].median()
print "Maximum:" 
print df_estimates.groupby("Hurdle")["Perf"].max()
print "Minimum:" 
print df_estimates.groupby("Hurdle")["Perf"].min()

############## Save Final Database file ###############

df_estimates.to_csv('estimates_final.csv')

############# Linear Regression #################################
print max(df_estimates['Estimate EPS'])
print min(df_estimates['Estimate EPS'])
print np.any(np.isnan(df_estimates['Estimate EPS']))
print df_estimates.loc[np.isnan(df_estimates['Estimate EPS'])]
print np.any(np.isfinite(df_estimates['Estimate EPS']))
# print np.isfinite(df_estimates['Estimate EPS'])

############# Sci-kit Learn 

reg = linear_model.LinearRegression()
x = df_estimates['Estimate EPS']
y = df_estimates['Actual EPS']

x = x.values.reshape(len(x),1)
y = y.values.reshape(len(y),1)

#print reg.residues_

reg.fit(x,y)
m = reg.coef_[0]
b = reg.intercept_


# import metrics from sklearn


print(' y = {0} * x + {1}'.format(m, b))
print("Mean squared error: %.2f" % np.mean((reg.predict(x) - y) ** 2))

r2 = r2_score(y, reg.predict(x))
print 'R2: %2.3f' % r2
     
     
print reg.get_params
print reg.score
print reg.rank_
print reg.fit
print reg.normalize

#print r2_score(y, reg)

# print len(df_estimates['Actual EPS'])
# print len(df_estimates['Estimate EPS'])


############# Analysis by Visualization #########################

# sns.kdeplot(df_estimates["Estimate EPS"], shade=True, label='Estimated PDF of Estimate EPS')

plt.scatter(df_estimates["Estimate EPS"],df_estimates["Actual EPS"])


# plt.scatter(x,y)
min_x = min(df_estimates["Estimate EPS"])
max_x = max(df_estimates["Estimate EPS"])

plt.plot([min_x, max_x], [m*min_x + b, m*max_x + b], 'r')
plt.title('Fitted linear regression', fontsize=16)

plt.xlabel("Estimate EPS")
plt.ylabel("Actual EPS")
plt.title("Quarterly Estimate EPS and Actual EPS")

plt.show()

fig_2 = plt.figure(2)
plt.scatter(df_estimates["Surprise"],df_estimates["Perf"])
plt.xlabel("Surprise")
plt.ylabel("Stock Performance")
plt.title("Quarterly EPS surprise and Stock Performance")

plt.show()

fig_3 = plt.figure(3)

plt.scatter(df_estimates["Num Analyst"],df_estimates["Surprise"])
plt.xlabel("Num Analysts")
plt.ylabel("Surprise")
plt.title("Number of Analysts and Earnings Surprise")

plt.show()


df_perf = df_estimates[["Hurdle", "Perf"]]
df_perf.boxplot(by="Hurdle", column="Perf",showfliers=False)
plt.ylabel('Stock Performance')

plt.show()


#plt.hist(df_estimates["Perf"])
#plt.show()

df_beat = df_estimates.loc[df_estimates["Hurdle"]=="beat"]["Perf"]
plt.hist(df_beat.dropna(),bins=40)
plt.show()

df_missed = df_estimates.loc[df_estimates["Hurdle"]=="missed"]["Perf"]
plt.hist(df_missed.dropna(),bins=40)
plt.show()

############ Seaborn ########################################
import seaborn as sns

sns.boxplot(x='Hurdle', y='Perf', data=df_estimates)
sns.plt.show()

sns.lmplot("Estimate EPS", "Actual EPS", df_estimates)
sns.plt.show()

sns.lmplot("Surprise","Perf",df_estimates)
sns.plt.show()

sns.lmplot("Num Analyst","Surprise",df_estimates)
sns.plt.show()

sns.distplot(df_beat.dropna())
sns.plt.show()

sns.distplot(df_missed.dropna())
sns.plt.show()
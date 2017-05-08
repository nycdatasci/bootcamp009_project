import pandas as pd
import pandas_datareader.data as web
import matplotlib.pyplot
import pylab
# import yahoo-finance
import datetime

df_estimates = pd.read_csv('estimates_cleanup.csv', index_col=False, header=0)

# print yahoo.get_historical('2014-04-25', '2014-04-29')
# matplotlib.pyplot.scatter(df_estimates['Estimate EPS'],df_estimates['Actual EPS'])
# matplotlib.pyplot.show()

df_estimates = df_estimates.drop_duplicates(subset=['Ticker'], keep="first")

print df_estimates["Ticker_confirm"].notnull()

print df_estimates.loc[df_estimates["Ticker_confirm"].notnull()]
df_estimates = df_estimates.loc[df_estimates["Ticker_confirm"].notnull()]

func = lambda x: x[1:-1]
print df_estimates["Report Date"].astype(str).map(func)
df_estimates["Report Date"] = pd.to_datetime(df_estimates["Report Date"].astype(str).map(func), format='%m/%d/%y')

print df_estimates["Report Date"]

df_estimates["Ticker_original"] = df_estimates["Ticker"]
df_estimates["Ticker"] = df_estimates["Ticker_confirm"]

ticker_list = df_estimates["Ticker"]
# ticker_list = ["ADK"]

df_estimates["Prior Date Price"]=""
df_estimates["Post Date Price"]=""

for ticker in ticker_list:
    try:
        print df_estimates.loc[df_estimates["Ticker"]==ticker]
        report_date = df_estimates.loc[df_estimates["Ticker"]==ticker]["Report Date"]
        print report_date+ pd.DateOffset(1)
        print report_date- pd.DateOffset(1)

        start = report_date- pd.DateOffset(1)
        end = report_date+ pd.DateOffset(1)

        print start.iloc[0]
        print end.iloc[0]


        price_df = web.DataReader(ticker, 'yahoo', start.iloc[0],end.iloc[0] )

        # dates =[]
        # for x in range(len(df)):
            # newdate = str(df.index[x])
            # newdate = newdate[0:10]
            # dates.append(newdate)

        # df['dates'] = dates

        print price_df.iloc[0]["Adj Close"]
        print price_df.iloc[1]["Adj Close"]
        
        prior_price = price_df.iloc[0]["Adj Close"]
        post_price = price_df.iloc[1]["Adj Close"]
        
        # df_estimates["Prior Date Price"].loc[df_estimates["Ticker"]==ticker] = prior_price
        
        df_estimates.set_value(df_estimates["Ticker"]==ticker, "Prior Date Price", prior_price)
        
        df_estimates.set_value(df_estimates["Ticker"]==ticker, "Post Date Price", post_price)
    except:
        continue
    
print df_estimates.head()

df_estimates.to_csv('estimates_price.csv')
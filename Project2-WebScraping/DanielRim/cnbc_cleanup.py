import pandas as pd
import re

df_estimates = pd.read_csv('estimates.csv', index_col=False, header=0)
# print df_estimates
df_estimates = df_estimates[df_estimates.Ticker != "Ticker"]
df_estimates = df_estimates[df_estimates.Ticker != ""]
df_estimates = df_estimates[df_estimates.Estimates != "Sorry, no data available."]
df_estimates = df_estimates.reset_index(drop=True)

print df_estimates.loc[df_estimates['Ticker']=="Ticker"]
print df_estimates.loc[df_estimates['Ticker']==""]
print df_estimates.loc[df_estimates['Estimates']=="Sorry, no data available."]

print df_estimates
print df_estimates[0:10]
print df_estimates.shape

"ADK reported 1st qtr 2016 earnings of $-0.16 per share on 5/16/16. This missed the $-0.06 consensus of the 1 analysts covering the company."
match_str = "(.*) reported (.*) earnings of (.*) per share on (.*). This (.*) the (.*) consensus of the (.*) covering the company."
# m = re.match("([\+-][a-zA-Z0-9]+)*", '-56+a')


ticker_list = []
quarter_list = []
actual_eps_list = []
report_date_list = []
estimate_eps_list = []
num_analyst_list = []

df_tenrows = df_estimates[0:10]
df_estimates["Ticker_confirm"]=""
df_estimates["Quarter"]=""
df_estimates["Actual EPS"]=""
df_estimates["Report Date"]=""
df_estimates["Hurdle"]=""
df_estimates["Estimate EPS"]=""
df_estimates["Num Analyst"]=""



for raw_estimate in df_estimates['Estimates']:
    try:
        m = re.match(match_str,raw_estimate)
        print m.groups()
        df_estimates['Ticker_confirm'].loc[df_estimates['Estimates']==raw_estimate]= m.groups()[0]
        df_estimates['Quarter'].loc[df_estimates['Estimates']==raw_estimate]= m.groups()[1]
        df_estimates['Actual EPS'].loc[df_estimates['Estimates']==raw_estimate]= m.groups()[2].replace("$","")
        df_estimates['Report Date'].loc[df_estimates['Estimates']==raw_estimate]= "'"+str(m.groups()[3])+"'"
        df_estimates['Hurdle'].loc[df_estimates['Estimates']==raw_estimate]= m.groups()[4]
        df_estimates['Estimate EPS'].loc[df_estimates['Estimates']==raw_estimate]= m.groups()[5].replace("$","")
        df_estimates['Num Analyst'].loc[df_estimates['Estimates']==raw_estimate]= m.groups()[6].replace("analysts","")
      
        
    except:
        continue

print df_estimates
del df_estimates['Estimates']
df_estimates.to_csv('estimates_cleanup.csv')

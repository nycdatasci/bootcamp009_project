coin = read.csv('../ran/coin.csv')
head(coin)
names(coin)
coin = coin[,-1]
head(coin)

library(RMySQL)
con = dbConnect(MySQL(),user='mes',host='127.0.0.1',dbname='bccs')
rs <- dbSendQuery(con, "select * from curr_exch_daily;")
data <- fetch(rs, n=-1)
head(data)

#Get the real current exchange rate from yahoo finance
library(quantmod)
curr<-new.env()
startDate = as.Date('2010-01-01')
endDate   = as.Date('2017-06-15')

#EUR
getSymbols('USDEUR=X',env=curr, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)

plot(curr$"USDEUR=X"[,6])
lines(USDEUR2, col = 'red')
USDEUR = curr$"USDEUR=X"[,6]

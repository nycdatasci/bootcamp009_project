library(RMySQL)
con = dbConnect(MySQL(),user='mes',host='127.0.0.1',dbname='bccs')
rs <- dbSendQuery(con, "select * from coinbaseUSDdaily;")
cbUSD <- fetch(rs, n=-1)
rs2 <- dbSendQuery(con, "select * from etherUSDdaily;")
etherUSD <- fetch(rs2, n=-1)
plot(as.Date(etherUSD$date),etherUSD$avg)

rs3 <- dbSendQuery(con, "select * from btceUSDdaily;")
btceUSD <- fetch(rs3, n=-1)


setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/mark/')
source('bitcoints.R')
 
# Change to xts
cbUSD$date = as.Date(cbUSD$date)
etherUSD$date = as.Date(etherUSD$date)
cbUSD = xts(cbUSD[,-1], cbUSD$date)
etherUSD = xts(etherUSD[,-1], etherUSD$date)
btceUSD$date = as.Date(btceUSD$date)
btceUSD = xts(btceUSD[,-1], btceUSD$date)

cbUSD.rr = return_rate(cbUSD[,1])
etherUSD.rr = return_rate(etherUSD[,1])
btceUSD.rr = return_rate(btceUSD[,1])
btceUSD.rr = btceUSD.rr[!apply(is.na(btceUSD.rr), 1,any), ]

hist(log(cbUSD.rr), breaks = 1000)
hist(etherUSD.rr, breaks = 100)

bind = merge.xts(cbUSD.rr, etherUSD.rr)
bind = bind[!apply(is.na(bind), 1,any), ]
cor(bind[,1],bind[,2])

## Correlation plots
par(mfrow=c(1,1))
plot(corr_gen(bind[,1], bind[,2], 100))
acf(bind[,1])
acf(bind[,2])
acf(btceUSD.rr)
acf(btceUSD$totalvol)
acf(btceUSD$trades)

# Find dates with very high negative return rate
par(mfrow=c(3,1))
plot(btceUSD$avg)
plot(btceUSD$totalvol)
plot(btceUSD.rr)
#big_days = btceUSD.rr[which(abs(btceUSD.rr) > 0.07)]
big_days = btceUSD.rr[which(btceUSD.rr < -0.07)]
points(big_days, col = 'red')
#plot(etherUSD.rr)
#points(etherUSD.rr[which(abs(etherUSD.rr) > 0.1)], col = 'blue')
library(dplyr)
# Start looking at august 13, 2014 which is big_days[114]
big_days= big_days[index(big_days) > '2014-08-01']

# Don't want xts anymore, want a data frame
prior_10 = function(big_day, xts_obj) {
  ind = which((index(xts_obj) == big_day))
  sub_df = xts_obj[(ind-10):ind,]
  #sub_df
  return(sub_df)
}

df_list = list()
for (i in 1:length(big_days)) {
  df_list[[i]] = prior_10(index(big_days)[i], btceUSD)
}



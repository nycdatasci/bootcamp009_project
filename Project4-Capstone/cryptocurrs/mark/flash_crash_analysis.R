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

par(mfrow=c(1,1))
plot(cbUSD.rr)
points(cbUSD.rr[which(abs(cbUSD.rr) > 0.07)], col = 'red')
#plot(etherUSD.rr)
points(etherUSD.rr[which(abs(etherUSD.rr) > 0.1)], col = 'blue')

hist(log(cbUSD.rr), breaks = 1000)
hist(etherUSD.rr, breaks = 100)

bind = merge.xts(cbUSD.rr, etherUSD.rr)
bind = bind[!apply(is.na(bind), 1,any), ]
cor(bind[,1],bind[,2])

par(mfrow=c(1,1))
plot(corr_gen(bind[,1], bind[,2], 100))
acf(bind[,1])
acf(bind[,2])
acf(btceUSD.rr)

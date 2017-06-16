setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/mark/')
source('ts_functions.R')

library(RMySQL)
con = dbConnect(MySQL(),user='mes',host='127.0.0.1',dbname='bccs')
rs <- dbSendQuery(con, "select date,avg,totalvol,trades from coinbaseUSDdaily;")
cbUSD <- fetch(rs, n=-1)
rs2 <- dbSendQuery(con, "select date,avg,totalvol,trades from btceUSDdaily;")
btceUSD <- fetch(rs2, n=-1)
rs3 <- dbSendQuery(con, "select * from curr_exch_daily;")
curr_ex <- fetch(rs3, n=-1)
par(mfrow=c(1,3))
plot(as.Date(btceUSD$date), btceUSD$avg)
points(as.Date(cbUSD$date), cbUSD$avg, col='red')
plot(as.Date(btceUSD$date), btceUSD$totalvol, col = 'green')
plot(as.Date(btceUSD$date), btceUSD$trades, col = 'purple')

## Convert data into an xts
library(xts)
btceUSD$date = as.Date(btceUSD$date)
mat = data.matrix(btceUSD[,2:4])
btceUSD = xts(mat, order.by = btceUSD[,1])

curr_ex$date = as.Date(curr_ex$date)
mat2 = data.matrix(curr_ex[,2])
euro_usd = xts(mat2, order.by = curr_ex[,1])

par(mfrow=c(1,1))
plot(return_rate(btceUSD[,1]))
plot(moving_vol(btceUSD[,1], 10))
plot(moving_avg(btceUSD[,1], 10))
new = merge.xts(btceUSD[,1],euro_usd)
new = new[!apply(is.na(new), 1,any), ]
plot(new[,2])
plot(corr_gen(new[,1], new[,2], 10))

# Do an auto.arima on whatever
library(forecast)
mod = auto.arima(new[,1])
fc = forecast(mod, h=500)
plot(fc)

mod.rr = auto.arima(return_rate(new[,1]))
fc.rr = forecast(mod.rr, h= 200)
plot(fc.rr)


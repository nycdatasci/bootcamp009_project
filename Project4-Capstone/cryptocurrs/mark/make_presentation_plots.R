library(RMySQL)
library(dygraphs)
# Create plots to be used for the presentation
setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/')
source('mark/data_clean_for_models.R')
source('ts_functions.R')
setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/')
#Get the different currency prices will add the most recent data manually
#USD
mp = read.csv('blockchain_info/market-price-1year.csv')
mp = xts(mp[,2], order.by=as.Date(mp$X2016.06.19.00.00.00))
## Now extend the xts object
usdxts = xts(coin$btc_usd, order.by = as.Date(coin$X))
mp = mp[(which(index(mp) == index(usdxts[nrow(usdxts),]))+1):nrow(mp),]
mp = rbind(usdxts, mp)

## Create the "since we last spoke" plots
dygraph(mp[537:nrow(mp),], main = 'Bitcoin Price History', ylab = 'Price (USD)')

con = dbConnect(MySQL(),user='mes',host='127.0.0.1',dbname='bccs')

#Get the different currency prices will add the most recent data manually
#USD
rs1 <- dbSendQuery(con, "select * from coinbaseUSDdaily;")
usd <- fetch(rs1, n= -1)
c1 <- usd[,c(1,4)]
colnames(c1)[2] <- "btc_usd"
c1$date <- as.Date(c1$date)
class(c1$btc_usd)
c1.xts<- as.xts(c1[,2], order.by = c1$date)

dygraph(c1.xts[1458:nrow(c1.xts),], main = 'Bitcoin Price Since 1/1/17', ylab = 'Price (USD)')

## Create the return rate plot with the points of interest that we want to predict
mp.rr.1 = return_rate(mp,1)
svg('drr.svg')
dygraph(mp.rr.1, ylab = '1 Day Return Rate', main = 'Days Greater than a 3% Return Rate')
dev.off()
svg('drr_w_bigs.svg')
plot(mp.rr.1, ylab = '1 Day Return Rate', main = 'Days Greater than a 3% Return Rate')
points(mp.rr.1[mp.rr.1 > 0.03], col = 'green')
dev.off()

## Create the return rate vs. the chinese volume plot to demonstrate motivation for SVM
svg('rr_vs_cnyvol.svg')
plot(coin$cny_vol, coin$btc_rr_1, col = coin$activity, pch = 16, cex = 0.9, 
     main = 'Previous day BTC RR vs. OK Coin Volume', ylab = '1 day Return Rate', 
     xlab = 'OK Coin(CNY) Daily BTC Volume')
legend('topright', legend = levels(coin$activity), fill = palette(), col = levels(coin$activity))
dev.off()

etv = read.csv('blockchain_info/estimated-transaction-volume.csv')
etv = xts(etv[,2], order.by=as.Date(etv$X2009.01.03.00.00.00))
n.trans = read.csv('blockchain_info/n-transactions.csv')
n.trans = xts(n.trans[,2], order.by=as.Date(n.trans$X2009.01.03.00.00.00))
mct = read.csv('blockchain_info/median-confirmation-time.csv')
mct = xts(mct[,2], order.by=as.Date(mct$X2009.01.03.00.00.00))
mct = mct[550:1543,]
tv = read.csv('blockchain_info/trade-volume.csv')
tv = xts(tv[,2], order.by=as.Date(tv$X2009.01.03.00.00.00))
mp = read.csv('blockchain_info/market-price.csv')
mp = xts(mp[,2], order.by=as.Date(mp$X2009.01.03.00.00.00))
mp[mp <=0,] = 0.01

bc_info = cbind(etv, n.trans, tps, mct, tv)

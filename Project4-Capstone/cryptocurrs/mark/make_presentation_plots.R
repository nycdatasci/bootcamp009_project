# Create plots to be used for the presentation

setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/mark/')
source('data_clean_for_models.R')

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
library(RMySQL)
library(xts)

# source time series functions
setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/')
source('mark/ts_functions.R')

con = dbConnect(MySQL(),user='ran',host='127.0.0.1',dbname='bccs')

#Get the different currency prices
#USD
rs1 <- dbSendQuery(con, "select * from btceUSDdaily;")
usd <- fetch(rs1, n= -1)
head(usd)
dim(usd)
c1 <- usd[,c(1,4,5)]
colnames(c1)[2] <- "btc_usd"
colnames(c1)[3] <- "usd_vol"
c1$date <- as.Date(c1$date)
class(c1$btc_usd)
c1.xts<- as.xts(c1[,c(2,3)], order.by = c1$date)

#EUR
rs2 <- dbSendQuery(con, "select * from krakenEURdaily;")
eur <- fetch(rs2,n= -1)
c2 <- eur[,c(1,4,5)]
colnames(c2)[2] <- "btc_eur"
colnames(c2)[3] <- "eur_vol"
c2$date <- as.Date(c2$date)
c2.xts<- as.xts(c2[,c(2,3)], order.by = c2$date)
c2.xts = c2.xts[seq(1,nrow(c2.xts),by=2)]

#CAD
rs3 <- dbSendQuery(con, "select * from anxhkCADdaily;")
cad <- fetch(rs3,n= -1)
c3 <- cad[,c(1,4,5)]
colnames(c3)[2] <- "btc_cad"
colnames(c3)[3] <- "cad_vol"
c3$date <- as.Date(c3$date)
c3.xts<- as.xts(c3[,c(2,3)], order.by = c3$date)
c3.xts = c3.xts[seq(1,nrow(c3.xts),by=2)]

#AUD
rs4 <- dbSendQuery(con, "select * from anxhkAUDdaily;")
aud <- fetch(rs4, n= -1)
c4 <- aud[,c(1,4,5)]
colnames(c4)[2] <- "btc_aud"
colnames(c4)[3] <- "aud_vol"
c4$date <- as.Date(c4$date)
c4.xts<- as.xts(c4[,c(2,3)], order.by = c4$date)
c4.xts = c4.xts[seq(1,nrow(c4.xts),by=2)]

#GBP
rs5 <- dbSendQuery(con, "select * from localbtcGBPdaily;") 
gbp <- fetch(rs5,n=-1)
c5 <- gbp[,c(1,4,5)]
colnames(c5)[2] <- "btc_gbp"
colnames(c5)[3] <- "gbp_vol"
c5$date <- as.Date(c5$date)
c5.xts<- as.xts(c5[,c(2,3)], order.by = c5$date)

#JPY
rs6 <- dbSendQuery(con, "select * from coincheckJPYdaily;") 
jpy <- fetch(rs6,n=-1)
c6 <- jpy[,c(1,4,5)]
colnames(c6)[2] <- "btc_jpy"
colnames(c6)[3] <- "jpy_vol"
c6$date <- as.Date(c6$date)
c6.xts<- as.xts(c6[,c(2,3)], order.by = c6$date)
c6.xts = c6.xts[seq(1,nrow(c6.xts),by=2)]

#CNY
rs7 <- dbSendQuery(con, "select * from okcoinCNYdaily;")
cny <- fetch(rs7, n= -1)
c7 <- cny[,c(1,4,5)]
colnames(c7)[2] <- "btc_cny"
colnames(c7)[3] <- "cny_vol"
c7$date <- as.Date(c7$date)
c7.xts<- as.xts(c7[,c(2,3)], order.by = c7$date)

#BRL
rs8 <- dbSendQuery(con, "select * from mrcdBRLdaily;") 
brl <- fetch(rs8, n=-1)
c8 <- brl[,c(1,4,5)]
colnames(c8)[2] <- "btc_brl"
colnames(c8)[3] <- "brl_vol"
c8$date <- as.Date(c8$date)
c8.xts<- as.xts(c8[,c(2,3)], order.by = c8$date)
## For some reason there are doubles
c8.xts = c8.xts[seq(1,nrow(c8.xts),by=2)]

#RUB
rs9 <- dbSendQuery(con, "select * from btceRURdaily;")
rur <- fetch(rs9,n=-1)
c9 <- rur[,c(1,4,5)]
colnames(c9)[2] <- "btc_rub"
colnames(c9)[3] <- "rub_vol"
c9$date <- as.Date(c9$date)
c9.xts<- as.xts(c9[,c(2,3)], order.by = c9$date)
## For some reason there are doubles
c9.xts = c9.xts[seq(1,nrow(c9.xts),by=2)]

#SLL
rs10 <- dbSendQuery(con, "select * from virwoxSLLdaily;")
sll <- fetch(rs10, n=-1)
c10 <- sll[,c(1,4,5)]
colnames(c10)[2] <- "btc_sll"
colnames(c10)[3] <- "sll_vol"
c10$date <- as.Date(c10$date)
c10.xts<- as.xts(c10[,c(2,3)], order.by = c10$date)

#Get the real current exchange rate from yahoo finance
library(quantmod)
sp500<-new.env()
startDate = as.Date('2010-01-01')
endDate   = as.Date('2017-06-15')

#EUR
getSymbols('USDEUR=X',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)

plot(sp500$"USDEUR=X"[,6])
USDEUR = sp500$"USDEUR=X"[,6]

#GBP
getSymbols('USDGBP=X',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
USDGBP = sp500$"USDGBP=X"[,6]

#CAD
getSymbols('USDCAD=X',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
USDCAD = sp500$"USDCAD=X"[,6]

#AUD
getSymbols('AUD=X',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
USDAUD = sp500$"AUD=X"[,6]

#JPY
getSymbols('USDJPY=X',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
USDJPY = sp500$"USDJPY=X"[,6]

#CNY
getSymbols('CNY=X',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
USDCNY = sp500$"CNY=X"[,6]

#BRL
getSymbols('CNY=X',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
USDBRL = sp500$"CNY=X"[,6]

#RUB
getSymbols('USDRUB=X',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
USDRUB = sp500$"USDRUB=X"[,6]

#SLL
getSymbols('USDSLL=X',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
USDSLL = sp500$"USDSLL=X"[,6]

#Oil   *limited data
getSymbols('CL=F',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
oil = sp500$"CL=F"[,6]

#Gold  *limited data
getSymbols('GC=F',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
gold = sp500$"GC=F"[,6]

#VTWSX: Vanguard Total World Stock Index Inv (VTWSX)
getSymbols('VTWSX',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
VTWSX = sp500$VTWSX[,6]

# EEM:iShares MSCI Emerging Markets ETF
getSymbols('EEM',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
EEM = sp500$EEM[,6]

# EFA: iShares MSCI EAFE ETF (EFA)
getSymbols('EFA',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
EFA = sp500$EFA[,6]

#NYSE ARCA COMPUTER TECH INDEX
getSymbols('^XCI',env=sp500, src='yahoo', from=startDate,
           to=endDate,auto.assign=T)
XCI = sp500$"XCI"[,6]

## Get bitcoin return rates
usd$date = as.Date(usd$date)
usdxts = xts(usd[,-1], order.by=usd$date)
rr = data.frame(return_rate(usdxts$avg, 1))
names(rr)[1] = 'btc_rr_1'
lags = c(1,2,3,4,5,10,15,30)

for (i in 2:length(lags)) {
    rr[,i] = return_rate(usdxts$avg,lags[i])
    names(rr)[i] = paste0('btc_rr_',lags[i])
}

rr = xts(rr, order.by = usd$date)
trade_info = cbind(usd$trades, usd$totalvol,intra_day_fluc(usd$high,usd$low))
colnames(trade_info) = c('btc_trades','btc_dailyvol','btc_in_day_fluc')
trade_info = xts(trade_info, order.by = usd$date)

#merge everything
coin=merge.xts(c1.xts,
               c2.xts,
               c3.xts,
               c4.xts,
               c5.xts,
               c6.xts,
               c7.xts,
               c8.xts,
               c9.xts,
               c10.xts,
               USDEUR,
               USDGBP,
               USDCAD,
               USDJPY,
               USDAUD,
               USDCNY,
               USDBRL,
               USDRUB,
               USDSLL,
               oil,
               gold,
               VTWSX,
               EEM,
               EFA,
               XCI,
               trade_info,
               rr)

#Cut the coin dataset to start at first day of btceUSD which is 08/14/2011, FYI the earliest bitcoin data
# is from SLL at 04/27/2011
coin = coin[which(index(coin)=='2011-08-14'):which(index(coin)=='2017-05-31'),]

coin$btc_USDEUR = coin$btc_eur/coin$btc_usd
coin$btc_USDGBP = coin$btc_gbp/coin$btc_usd
coin$btc_USDCAD = coin$btc_cad/coin$btc_usd
coin$btc_USDAUD = coin$btc_aud/coin$btc_usd
coin$btc_USDJPY = coin$btc_jpy/coin$btc_usd
coin$btc_USDCNY = coin$btc_cny/coin$btc_usd
coin$btc_USDRUB = coin$btc_rub/coin$btc_usd
coin$btc_USDBRL = coin$btc_brl/coin$btc_usd
coin$btc_USDSLL = coin$btc_sll/coin$btc_usd

coin$CNY.X.Adjusted.1 <- NULL
names(coin)[21:34]<-c("USDEUR","USDGBP","USDCAD","USDJPY","USDAUD","USDCNY","USDRUB","USDSLL","oil","gold","VTWSX","EEM","EFA","XCI")

#Don't impute yet


# Need to specify the row.names for the dates to be written
write.csv(coin, file = "mark/coin.csv", row.names = index(coin))



################################plot different exchanges######################### 
# #Real currency
# curr <- dbSendQuery(con, "select * from curr_exch_daily;")
# curr <- fetch(curr, n= -1)
# dim(curr)
# head(curr)
# 
# 
# coinbaseUSD <- read.csv("~/Desktop/bccp/top3USD/coinbaseUSD.csv", header=FALSE)
# bitstampUSD <- read.csv("~/Desktop/bccp/top3USD/bitstampUSD.csv", header=FALSE)
# #btceUSD <- read.csv("~/Desktop/bccp/top3USD/btceUSD.csv", header=FALSE)
# dim(coinbaseUSD)
# dim(bitstampUSD)
# dim(btceUSD)
# coinbaseUSD$V1 = format(as.POSIXct(coinbaseUSD$V1, origin="1970-01-01"),format="%Y-%m-%d")
# bitstampUSD$V1 = format(as.POSIXct(bitstampUSD$V1, origin="1970-01-01"),format="%Y-%m-%d")
# #btceUSD$V1 =format(as.POSIXct(btceUSD$V1, origin="1970-01-01"),format="%Y-%m-%d")
# library(ggplot2)
# ggplot(coinbaseUSD, aes(V1, V2)) + geom_line()
# 
# ggplot(bitstampUSD, aes(V1, V2)) + geom_line() +
#   xlab("") + ylab("Daily Views")
# 
# ggplot(coinbaseUSD,aes(V1, V2))+geom_line(aes(color="coinbaseUSD"))+
#   geom_line(data=bitstampUSD,aes(color="bitstampUSD"))+
#   labs(color="Platform")
# 
# 
# 
# plot.ts(coinbaseUSD$V1, coinbaseUSD$V2,col='red')
# points(bitstampUSD$V1,bitstampUSD$V2,col='blue')
# 

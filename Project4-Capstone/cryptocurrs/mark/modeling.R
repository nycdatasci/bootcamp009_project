coin = read.csv('coin.csv')
#coin = xts(coin[,-1], order.by = as.Date(coin$X))

## Make a categorical out of the return rates
coin = coin[!is.na(coin$btc_rr_1),]
coin[is.na(coin)] = -999
activity = ifelse(coin$btc_rr_1 < 0, 'neg', 'pos')
activity2 = activity[2:length(activity)]
activity = xts(activity, order.by = as.Date(coin$X))

#library(mlr)
#t=makeClassifTask(data = coin, target = 'activity')
#x = oversample(task = t, rate = 3)

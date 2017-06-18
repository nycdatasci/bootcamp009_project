library(xts)

setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/mark/')
coin = read.csv('coin.csv')
coin = coin[!is.na(coin$btc_rr_1),]
#coin[is.na(coin)] = -999
#coin = xts(coin[,-1], order.by = as.Date(coin$X))
## Make a categorical out of the return rates
## If the 1 day return rate is greater than 0.07 than label it as a big
## If the intra day volatility is greater than 0.07 than also label it as big
## Otherwise other
label_volatile_days = function(threshold) {
    activity = rep('stable',nrow(coin))
    activity[coin$btc_usd_in_day_fluc > threshold] = 'big_fluc'
    activity[coin$btc_rr_1 > threshold] = 'big_gain'
    activity[coin$btc_rr_1 < -threshold] = 'big_drop'
    activity[coin$btc_max_rr_1 > threshold] = 'big_gain'
    activity = activity[2:length(activity)]
    # Totally arbitrary labeling
    activity[length(activity)+1] = 'stable'
    activity = xts(activity, order.by = as.Date(coin$X))
    coin$activity = activity
    coin$activity = factor(coin$activity)
    summary(coin$activity)
    return(coin)
}

## Also make a function that just labels if it goes up or it goes down.
simple_label_days = function() {
    activity = rep('stable',nrow(coin))
    activity[coin$btc_rr_1 > 0] = 'up'
    activity[coin$btc_rr_1 < 0] = 'down'
    activity = activity[2:length(activity)]
    activity[length(activity)+1] = 'other'
    activity = xts(activity, order.by = as.Date(coin$X))
    coin$activity = activity
    coin$activity = factor(coin$activity)
    summary(coin$activity)
    return(coin)
}

## This is an attempt at oversampling, there's always just using the sample function
#library(mlr)
#t=makeClassifTask(data = coin, target = 'activity')
#x = oversample(task = t, rate = 3)

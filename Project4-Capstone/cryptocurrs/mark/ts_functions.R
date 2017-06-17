## Useful time series functions
## Calculate return rates of data
return_rate = function(vec, k=1) {
    return((vec - lag(vec,k))/lag(vec,k))
}

intra_day_fluc = function(high,low) {
    return((high-low)/low)
}

## Compute the x day moving average
moving_avg = function(vec, x) {
    return(rollmean(vec, x, align='center'))
}

## Compute the x day moving volatility
moving_vol = function(vec, x) {
    return(rollapply(vec, width=x, FUN=sd))
}

## Correlation between two time series
corr_gen = function(vec1, vec2, width) {
    return(rollapply(cbind(vec1, vec2), width, FUN = function(x) {cor(x[,1],x[,2])},
                     by.column = F))
}

# This function takes a date, a data frame, and a lag number and returns the lag number of days
# prior to the day passed in a xts object
prior_days = function(big_day, xts_obj,lag=10) {
    ind = which((index(xts_obj) == big_day))
    sub_df = xts_obj[(ind-lag):ind,]
    #sub_df
    return(sub_df)
}
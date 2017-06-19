# Create plots to be used for the presentation

setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/mark/')
source('data_clean_for_models.R')

svg('rr_vs_cnyvol.svg')
plot(coin$cny_vol, coin$btc_rr_1, col = coin$activity, pch = 16, cex = 0.9, 
     main = 'Previous day BTC RR vs. OK Coin Volume', ylab = '1 day Return Rate', 
     xlab = 'OK Coin(CNY) Daily BTC Volume')
legend('topright', legend = levels(coin$activity), fill = palette(), col = levels(coin$activity))
dev.off()


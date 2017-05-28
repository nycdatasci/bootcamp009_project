library(psych)
library(reshape2)
library(lubridate)
library(xts)
library(ggplot2)
library(ggthemes)
library(readr)
library(corrplot)
library(MTS)
library(stats)
library(xts)
library(zoo)
library(dlmodeler)
library(vars)
library(dplyr)
library(tseries)
library(prophet)
library(dse)
library(corrplot)
library(forecast)
library(TTR)
library(caTools)
library(quantmod)

############### Import Macro Data and Training Data To Construct Dependent Variable ####################

macro <- read_csv("./macro.csv", 
                  col_types = cols(apartment_fund_sqm = col_number(), 
                                   average_provision_of_build_contract = col_number(), 
                                   average_provision_of_build_contract_moscow = col_number(), 
                                   balance_trade_growth = col_number(), 
                                   bandwidth_sports = col_number(), 
                                   deposits_rate = col_number(), gdp_deflator = col_number(), 
                                   gdp_quart = col_number(), gdp_quart_growth = col_number(), 
                                   grp_growth = col_number(), hospital_bed_occupancy_per_year = col_number(), 
                                   hospital_beds_available_per_cap = col_number(), 
                                   incidence_population = col_number(), 
                                   modern_education_share = col_number(), 
                                   mortgage_growth = col_number(), net_capital_export = col_number(), 
                                   oil_urals = col_number(), old_education_build_share = col_number(), 
                                   population_reg_sports_share = col_number(), 
                                   provision_retail_space_sqm = col_number(), 
                                   rent_price_1room_bus = col_number(), 
                                   rent_price_1room_eco = col_number(), 
                                   rent_price_2room_bus = col_number(), 
                                   rent_price_2room_eco = col_number(), 
                                   rent_price_3room_bus = col_number(), 
                                   rent_price_3room_eco = col_number(), 
                                   `rent_price_4+room_bus` = col_number(), 
                                   salary_growth = col_number(), students_state_oneshift = col_number(), 
                                   timestamp = col_date(format = "%Y-%m-%d")))


problems(macro) #0 rows - No data corruption classes were assigned.

macro$rent_price_2room_eco <- ifelse(macro$rent_price_2room_eco == .1, 40.25, macro$rent_price_2room_eco)

macro$rent_price_1room_eco <- ifelse(macro$rent_price_1room_eco == 2.31, 32.61, macro$rent_price_1room_eco)


for (i in seq(ncol(macro),2)) {
  macro[,i] = as.numeric(unlist(macro[,i]))
}

train <- read_csv("./train_clean.csv", 
                  col_types = cols(build_year = col_number(), 
                                   max_floor = col_number(), timestamp = col_date(format = "%Y-%m-%d")))

## Join the data and mutate the dependent variable to be modeled (price / sq. foot).

price = data.frame(train$timestamp,train$price_doc,train$full_sq)
colnames(price) = c('timestamp','price_doc','full_sq')

# Log transform (Leaving it turned off right now while doing EDA).
#price$price_doc = log(price$price_doc)
#price$full_sq = log(price$full_sq)

#Re-frame data for better features to model at the Russian macro level.

price = price %>%
  mutate(p_sqf = price_doc / full_sq)
price$price_doc = NULL
price$full_sq = NULL

macro = macro %>%
  mutate(brent_rub = brent * usdrub)
macro_brent = NULL

## Aggregate duplicate observations for one date due to time series analysis limitation.
price = aggregate(x=price$p_sqf, by = list(unique.timestamp = price$timestamp), FUN=mean, na.rm=TRUE)
colnames(price) = c('timestamp','p_sqf')
price$timestamp = as.Date(price$timestamp)

## Take fifteen day moving average.
price$p_sqf = runmean(price$p_sqf,30)
macro$brent_rub = runmean(macro$brent_rub,30)

## Calculate the rates of change based on estimated lag factors.
price$p_sqf = Delt(price$p_sqf, k = 450)
macro$brent_rub = Delt(macro$brent_rub, k = 450)
macro$mortgage_rate = Delt(macro$mortgage_rate, k =550)

macro = macro %>%
  select(timestamp,brent_rub,mortgage_rate)

macro = macro[complete.cases(macro),]
price = price[complete.cases(price),]

rm(train)
macro = left_join(macro,price, by = 'timestamp')
rm(price)

ggplot(macro,aes(x=timestamp,y=p_sqf)) +
  geom_point(aes(color=brent_rub)) + geom_smooth(method='lm') +
  theme_excel() + scale_color_gradient2()

ggplot(macro,aes(x=timestamp,y=p_sqf)) +
  geom_point(aes(color=mortgage_rate)) + geom_smooth(method='lm') +
  theme_excel() + scale_color_gradient2()

a = lm(p_sqf ~ brent_rub + mortgage_rate, macro)
summary(a)
BIC(a)
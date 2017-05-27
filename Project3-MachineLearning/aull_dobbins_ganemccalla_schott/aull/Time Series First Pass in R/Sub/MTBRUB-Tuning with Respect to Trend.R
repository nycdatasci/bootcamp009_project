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
library(urca)

set.seed(0)

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



train <- read_csv("./train_clean.csv", 
                  col_types = cols(build_year = col_number(), 
                                   max_floor = col_number(), timestamp = col_date(format = "%Y-%m-%d")))

price = data.frame(train$timestamp,train$price_doc,train$full_sq,train$sub_area)
colnames(price) = c('timestamp','price_doc','full_sq','sub_area')

############################# Data Cleaning & Feature Extraction ################################

########### Clean-up of Clearly Mistaken Data

## Clearly incorrect values that are imputed from the prior month's value.
macro$rent_price_2room_eco <- ifelse(macro$rent_price_2room_eco == .1, 40.25, macro$rent_price_2room_eco)
macro$rent_price_1room_eco <- ifelse(macro$rent_price_1room_eco == '2.31', 32.61, macro$rent_price_1room_eco)

########### Feature Creation

## Calculate price / square foot as our dependent variable to model.
price = price %>%
  mutate(p_sqf = price_doc / full_sq)
price$price_doc = NULL
price$full_sq = NULL

## Calculate barrel oil in rubles.  Oil is a major source of exports (and highly correlated
## with its other mineral/energy exports).  Revenue at the local currency level represent
## Russia's true cash inflows for its exports that take into account both the international
## price for oil and Russia's exchange rate.
macro = macro %>%
  mutate(brent_rub = brent * usdrub)
macro_brent = NULL

## The metric represents the amount of profit that a bank makes on a loan.  The larger the
## the spread, the greater incentive the bank has to lend, which is the main source of credit
## for real estate when credit is used.
macro = macro %>%
  mutate(lending_spread = mortgage_rate - deposits_rate)

############## Feature Extraction through Aggregation, Smoothing, and Rate of Change

## Aggregate duplicate observations for one date due to time series analysis limitation.
price = aggregate(x=price$p_sqf, by = list(unique.timestamp = price$timestamp), FUN=mean, na.rm=TRUE)
colnames(price) = c('timestamp','price_square_meter')
price$timestamp = as.Date(price$timestamp)

## Take sixty day moving average.
price$price_square_meter = runmean(price$price_square_meter,60)
macro$brent_rub = runmean(macro$brent_rub,60)
macro$mortgage_rate = runmean(macro$mortgage_rate,60)
macro$lending_spread = runmean(macro$lending_spread,60)
macro$rent_price_2room_bus = runmean(macro$rent_price_2room_bus,60)

# Note the base lagged price / square meter for calculating rate of change.
# This is later used to test predictions in the multi-transaction training set.

for (i in seq(nrow(price),401)) {  
  price$p_sqm_lagged[i] = price$price_square_meter[(i-400)]
}

psqmlagged = data.frame(price$timestamp,price$p_sqm_lagged)
colnames(psqmlagged) = c('timestamp','p_sqm_lagged')

price$p_sqm_lagged = NULL

## Calculate the rates of change based on estimated/optimized lag in impact (in days).
price$price_square_meter = Delt(price$price_square_meter, k = 400)
macro$brent_rub = Delt(macro$brent_rub, k = 500)
macro$mortgage_rate = Delt(macro$mortgage_rate, k = 600)
macro$lending_spread = Delt(macro$lending_spread, k = 400)
macro$rent_price_2room_bus = Delt(macro$rent_price_2room_bus, k = 400)

#Delt function made this column into a matrix, odd.
price$price_square_meter = as.numeric(price$price_square_meter)

#Selecting the key variables used for our modelling.
macro = macro %>%
  select(timestamp,brent_rub,mortgage_rate,lending_spread, rent_price_1room_bus,
         rent_price_1room_eco,rent_price_2room_bus,rent_price_2room_eco)

#Reducing to complete observations before merger of training and macro data.
macro = macro[complete.cases(macro),]
price = price[complete.cases(price),]

#Standardizing and transforming data for normality.
PSQ_preProcessParameters = preProcess(price, method = c('center','scale','YeoJohnson'))
price = predict(PSQ_preProcessParameters,price)
qqnorm(price$price_square_meter); qqline(price$price_square_meter, col = 2)

macro = as.data.frame(macro)
macro_preProcessParameters = preProcess(macro, method = c('center','scale','YeoJohnson'))
macro = predict(macro_preProcessParameters,macro)
qqnorm(macro$brent_rub); qqline(macro$brent_rub, col = 2)

################################# Join Data & Model ######################################

####### Join data & clean environment.
rm(train)
macro = left_join(price,macro, by = 'timestamp')
rm(price)

######## Potential Cointegration Test To Ensure non-Spurious Regression?
#jotest = ca.jo(macro[2:3],type='trace',K=2)
#summary(jotest)

######## Linear Model of Relationship Between 60D-MA P/Sq. Meter &
######## Select Rate of % / 60D-MA Macro Variables
a = lm(price_square_meter ~ brent_rub + mortgage_rate + rent_price_2room_bus, macro)
summary(a)
BIC(a)

################################ Test Predictions ########################################

## Create a column containing the lagged price per square foot to bring into the training
## model and use the predictor with.  [Going to approximate for now]

macro$psq_delt_predict = a$fitted.values

macro_predictors = macro %>%
  select(timestamp,rent_price_2room_bus,mortgage_rate,brent_rub,psq_delt_predict) 

train <- read_csv("./train_clean.csv", 
                  col_types = cols(build_year = col_number(), 
                                   max_floor = col_number(), timestamp = col_date(format = "%Y-%m-%d")))
train$X1 = NULL
train$id = NULL

## Calculate price / square foot as our dependent variable to model.
train = train %>%
  mutate(p_sqm = price_doc / full_sq)

## Create 120 transaction moving average of price square foot.
train$p_sqm = runmean(train$p_sqm,120)

## Bring forward the moving average by 400 days for to apply prediction output.

train_original = left_join(train,macro_predictors, by = 'timestamp')

train = train_original %>%
  select(timestamp,rent_price_2room_bus,mortgage_rate,brent_rub,psq_delt_predict,full_sq,material,product_type,sub_area)

train = left_join(train,psqmlagged, by = 'timestamp')

train = train[complete.cases(train),]

train = train %>%
  mutate()

a = lm(price_square_meter ~ brent_rub + mortgage_rate + rent_price_2room_bus, macro)
summary(a)
BIC(a)

PSQ_preProcessParameters


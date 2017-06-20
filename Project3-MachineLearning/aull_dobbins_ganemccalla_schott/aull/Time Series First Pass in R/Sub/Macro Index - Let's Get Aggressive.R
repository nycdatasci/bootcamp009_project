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
library(tseries)
library(prophet)
library(dse)
library(corrplot)
library(forecast)
library(TTR)
library(caTools)
library(quantmod)
library(urca)
library(dplyr)

set.seed(0)

############### Import Macro Data and Training Data To Construct Dependent Variable ####################

macro_f <- read_csv("./macro.csv", 
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

macro_f$rent_price_1room_eco = NULL

train <- read_csv("~/GoogleDrive/NYCDSA/bootcamp009_project/Project3-MachineLearning/aull_dobbins_ganemccalla_schott/data/imputed/train_total.csv", 
                  col_types = cols(timestamp = col_date(format = "%Y-%m-%d")))
train$timestamp = as.Date(train$timestamp)

test <- read_csv("~/GoogleDrive/NYCDSA/bootcamp009_project/Project3-MachineLearning/aull_dobbins_ganemccalla_schott/data/imputed/test_total.csv", 
                 col_types = cols(timestamp = col_datetime(format = "%Y-%m-%d")))
test$timestamp = as.Date(test$timestamp)

price = data.frame(train$timestamp,train$price_doc,train$full_sq,train$sub_area,train$kremlin_km)
colnames(price) = c('timestamp','price_doc','full_sq','sub_area','kremlin_km')

############################# Data Cleaning & Feature Extraction ################################

########### Clean-up of Clearly Mistaken Data

## Clearly incorrect values that are imputed from the prior month's value.
macro_f$rent_price_2room_eco <- ifelse(macro_f$rent_price_2room_eco == .1, 40.25, macro_f$rent_price_2room_eco)
#macro_f$rent_price_1room_eco <- ifelse(macro_f$rent_price_1room_eco == '2.31', 32.61, macro_f$rent_price_1room_eco)

########### Feature Creation

## Calculate price / square meter.
price = price %>%
  mutate(p_sqm = price_doc / full_sq)

## Calculate barrel oil in rubles.  Oil is a major source of exports (and highly correlated
## with its other mineral/energy exports).  Revenue at the local currency level represent
## Russia's true cash inflows for its exports that take into account both the international
## price for oil and Russia's exchange rate.
macro_f = macro_f %>%
  mutate(brent_rub = brent * usdrub)
macro_f$macro_brent = NULL

## The metric represents the amount of profit that a bank makes on a loan.  The larger the
## the spread, the greater incentive the bank has to lend, which is the main source of credit
## for real estate when credit is used.
macro_f = macro_f %>%
  mutate(lending_spread = mortgage_rate - deposits_rate)

############## Feature Extraction through Aggregation, Smoothing, and Rate of Change

## Aggregate duplicate observations for one date due to time series analysis limitation.
price = aggregate(x=price$p_sqm, by = list(unique.timestamp = price$timestamp), FUN=mean, na.rm=TRUE)
colnames(price) = c('timestamp','price_square_meter')
price$timestamp = as.Date(price$timestamp)

## Take sixty day moving average.
price$price_square_meter = runmean(price$price_square_meter,90)
macro_f$brent_rub = runmean(macro_f$brent_rub,200)
macro_f$mortgage_rate = runmean(macro_f$mortgage_rate,200)
macro_f$lending_spread = runmean(macro_f$lending_spread,200)
macro_f$rent_price_1room_bus = runmean(macro_f$rent_price_1room_bus,90)
macro_f$rent_price_2room_bus = runmean(macro_f$rent_price_2room_bus,90)
macro_f$rent_price_2room_eco = runmean(macro_f$rent_price_2room_eco,90)

# Note the base lagged price / square meter for calculating rate of change.
# This is later used to test predictions in the multi-transaction training set.

#for (i in seq(nrow(price),401)) {  
#  price$p_sqm_lagged[i] = price$price_square_meter[(i-400)]
#}

#psqmlagged = data.frame(price$timestamp,price$p_sqm_lagged)
#colnames(psqmlagged) = c('timestamp','p_sqm_lagged')

#price$p_sqm_lagged = NULL

## Calculate the rates of change based on estimated/optimized lag in impact (in days).
price$price_square_meter = Delt(price$price_square_meter, k = 400)
macro_f$brent_rub = Delt(macro_f$brent_rub, k = 400)
macro_f$mortgage_rate = Delt(macro_f$mortgage_rate, k = 400)
macro_f$lending_spread = Delt(macro_f$lending_spread, k = 200)
macro_f$rent_price_1room_bus = Delt(macro_f$rent_price_1room_bus, k = 400)
macro_f$rent_price_2room_bus = Delt(macro_f$rent_price_2room_bus, k = 400)
macro_f$rent_price_2room_eco = Delt(macro_f$rent_price_2room_eco, k = 400)

#Delt function made this column into a matrix, odd.
price$price_square_meter = as.numeric(price$price_square_meter)

#Selecting the key variables used for our modelling.
macro_f = macro_f %>%
  select(timestamp,brent_rub,mortgage_rate,lending_spread, rent_price_1room_bus,
         rent_price_2room_bus,rent_price_2room_eco)

#Reducing to complete observations before merger of training and macro data.
macro_f = macro_f[complete.cases(macro_f),]
price = price[complete.cases(price),]

#Standardizing and transforming data for normality.
macro_f = as.data.frame(macro_f)
macro_preProcessParameters = preProcess(macro_f, method = c('center','scale','YeoJohnson'))
macro = predict(macro_preProcessParameters,macro_f)
qqnorm(macro$brent_rub); qqline(macro$brent_rub, col = 2)

# Creating a copy prior to join to training set.
macro = macro_f

################################# Join Data & Model ######################################

####### Join data & clean environment.
rm(train)
macro = left_join(price,macro, by = 'timestamp')
rm(price)

######## Cointegration Test To Ensure non-Spurious Regression With Brent
#jotest = ca.jo(macro[2:3],type='trace',K=2)
#summary(jotest)

######## Ridge and Linear Regression Model of Relationship Between Price / Square Meter Pricing Environment &
######## Select Rate of YOY % / 60D-MA Macro Variables

#Creating the data matrices for the glmnet() function.
x = model.matrix(price_square_meter ~ mortgage_rate + lending_spread + brent_rub + rent_price_2room_eco + rent_price_2room_bus + rent_price_1room_bus, macro[2:ncol(macro)])[, -1]
y = macro$price_square_meter

#Creating training and test sets with an 80-20 split, respectively.
set.seed(0)
train = sample(1:nrow(x), 8*nrow(x)/10)
test = (-train)
y.test = y[test]
length(train)/nrow(x)
length(y.test)/nrow(x)

#Values of Lambda over which to check.
grid = 10^seq(5, -2, length = 100)

#Fitting the ridge regression. Alpha = 0 for ridge regression.
library(glmnet)
ridge.models = glmnet(x[train, ], y[train], alpha = 0, lambda = grid)
coef(ridge.models)

# Coefficients across Lambda Parameter space.
plot(ridge.models, xvar = "lambda", label = TRUE, main = "Ridge Regression")

# Cross Validation To Optimize Lambda.
set.seed(0)
cv.ridge.out = cv.glmnet(x[train, ], y[train], alpha = 0, nfolds = 10, lambda = grid)

# Plot of Mean-Squared Error across lambda parameter space / optimal value.
plot(cv.ridge.out, main = "Ridge Regression\n")
bestlambda.ridge = cv.ridge.out$lambda.min
bestlambda.ridge
log(bestlambda.ridge)
# The train MSE at optimized lambda is .0039.

ridge.bestlambdatrain = predict(ridge.models, s = bestlambda.ridge, newx = x[test, ])
mean((ridge.bestlambdatrain - y.test)^2)

#The test MSE is about 0.00465.

#8
ridge.out = glmnet(x, y, alpha = 0)
predict(ridge.out, type = "coefficients", s = bestlambda.ridge)

# Model as Linear Regression (simply for inspection)
a = lm(price_square_meter ~ mortgage_rate + lending_spread + brent_rub + rent_price_2room_bus + rent_price_2room_eco + rent_price_1room_bus, macro)
summary(a)
BIC(a)
plot(a$fitted.values)
mean(a$residuals^2)
# The linear regression MSE is about .0036.

# Output of Ridge Model To Be Used as RE Macro Index for Training & Test Set
x_full = as.matrix(macro_f[,2:7])
ridge.bestlambda = predict(ridge.out, s = bestlambda.ridge, newx = x_full)

RE_Macro = data.frame(macro_f$timestamp,ridge.bestlambda)
colnames(RE_Macro) = c('timestamp','RE_Macro_Index')

Train_Dates = data.frame(train$timestamp)
colnames(Train_Dates) = c('timestamp')
Train_Dates$RE_Macro_Index[1] = 'NA'
Train_Dates = Train_Dates[1:721,]
Train_Dates = aggregate(x=Train_Dates$RE_Macro_Index, by = list(unique.timestamp = Train_Dates$timestamp), FUN=mean, na.rm=TRUE)
Train_Dates$RE_Macro_Index[1:96] = .31 
Train_Dates$x = NULL
colnames(Train_Dates) = c('timestamp','RE_Macro_Index')
Train_Dates = Train_Dates[1:45,]

RE_Macro_Imputed = rbind(Train_Dates,RE_Macro)

write.csv(RE_Macro_Imputed, file = 'RE_Macro_Index',row.names = FALSE)
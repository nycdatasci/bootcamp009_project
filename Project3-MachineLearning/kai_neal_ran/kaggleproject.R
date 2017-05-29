setwd("~/Desktop/data_science/projects")
library(plyr)
library(dplyr)
library(ggplot2)
library(VIM)
library(mice)
library(MASS)
macro <- read.csv("macro.csv")
test <- read.csv("test.csv")
train <- read.csv("train.csv")

############# Check the structure of each data###############
# macro
dim(macro)
# 2484 100
head(macro)
str(macro)
#check macro variable's type
class_macro <- data.frame(sapply(macro,class))
View(class_macro)

# Do the same for train and test
dim(test)  # 7662  291
head(test)
str(test)
dim(train) # 30471   292
head(train)
str(train)

# Check the null
sum(is.na(macro)) #46658
sum(is.na(train)) #261026
sum(is.na(test)) #47138

# See the missing value pattens. More virtulization in python
a = aggr(macro) 
a

b = aggr(train)
b

c = aggr(test)
c

###########################MACRO##############################
miss_macro = is.na.data.frame(macro)
miss_macro

# Check some variables time series 
plot.ts (macro$gdp_quart)
plot.ts (macro$cpi)
plot.ts (macro$ppi)
plot.ts (macro$oil_urals)
plot.ts (macro$micex)
plot.ts (macro$micex_rgbi_tr)
plot.ts(macro$gdp_quart_growth)

# Filter out the variables that have more than 20% missingness in python. 56 columns left
##############################Fill in missing value###################################
library(RANN)
library(VIM)
library(caret)
macro_final <- read.csv("macro_final.csv")
head(macro_final)
macro_final=macro_final[,-1] #delete index
dim(macro_final)

summary(macro_final)
sapply(macro_final, sd)
missing_macrofinal=aggr(macro_final)
summary(missing_macrofinal) #72% of the columns has no missingness

## puts a 1 where missing and a 0 where not
miss_mat=is.na.data.frame(macro_final)
# which rows have at least one missing value
miss=which(rowSums(miss_mat)>0)

## only the observations that are fully complete
pre.5nn = preProcess(macro_final[-miss,], method = 'knnImpute', k=5)

## the rows we have full data on, don't want to change these, dont do anything here
macro.train <- predict(pre.5nn, macro_final[-miss,])
dim(macro.train)  


## the rows we have missing data with, we want to replace where they were missing
macro.test     <- predict(pre.5nn, macro_final[miss,])
dim(macro.test)  ## 261 observations 


## must adjust the output of z-scores using std. dev. and mean of imputation model
means=pre.5nn$mean
std=pre.5nn$std

## do it for training, but skip the first 1 variable (timestamp)
for (j in 2:53){
  macro.train[,j]=macro.train[,j]*std[j-1]+means[j-1]}

## should match original data (check if same)
summary(macro.train)
summary(macro_final[-miss,])

## now do it for real on the test
for (j in 2:53){
  macro.test[,j]=macro.test[,j]*std[j-1]+means[j-1]}


## now create
imputed_mat=macro_final   ## just create a shell matrix with the original values
imputed_mat[miss,]=macro.test    # replace those rows with missing values with the imputed ones

## done here...save it
write.csv(imputed_mat,"imputed_macro_final.csv")


## do some checks on some of the missing values
macro_final[miss[1:5],]  ## original 
macro.test[1:5,]   ## replaced missing rows

head(imputed_mat)

###############################Merge with price with timestamp####################
price <- select(train, price_doc, timestamp)
price_macro_final<- left_join(price, imputed_mat, by='timestamp')
price_macro_final$price_log = log(price_macro_final$price_doc) 
price_macro_final$price_doc = NULL
price_macro_final_notime = price_macro_final[,-1]
head(price_macro_final_notime)
sum(is.na(price_macro_final_notime)) # no missingness left
dim(price_macro_final_notime) #30471 53
which(sapply(price_macro_final, is.numeric)==FALSE)

##############################Check variable importance by randomforest##################
library(MASS)
library(randomForest)
set.seed(0)
rf_price_macro = randomForest(price_log ~., data = price_macro_final_notime, importance = TRUE)
macro_rank = data.frame(importance(rf.default.final))
macro_rank = macro_rank[order(macro_rank$X.IncMSE,decreasing = TRUE),] 
varImpPlot(rf.default.final)
head(macro_rank,20)
#                         X.IncMSE IncNodePurity
# micex                 29.397977     93.390317
# micex_cbi_tr          21.956191    107.417999
# micex_rgbi_tr         21.164628     86.752334
# eurrub                20.170340    126.281399
# brent                 19.753208     97.919046
# usdrub                17.435559    101.518821
# rts                   15.921828     82.460388
# rent_price_4.room_bus  9.717574      5.481220
# balance_trade          9.617758      4.332617
# rent_price_3room_bus   9.122844      4.801460
# cpi                    8.453745     51.472241
# net_capital_export     8.265241      5.103609
# deposits_growth        8.182679      3.681086
# rent_price_3room_eco   8.173950      4.544496
# rent_price_1room_bus   7.801346      4.224082
# income_per_cap         7.766445      4.074513
# mortgage_value         7.231206      3.703031
# rent_price_1room_eco   6.733238      3.429841
# mortgage_rate          6.276747      5.296093
# oil_urals              5.974155      6.086634

################Lasso###############
library(ISLR)
library(glmnet)
x = model.matrix(price_log ~ ., price_macro_final_notime)[, -1] #Dropping the intercept column.
y = price_macro_final_notime$price_log
grid = 10^seq(5, -2, length = 100)
lasso.models = glmnet(x, y, alpha = 1, lambda = grid)
dim(coef(lasso.models))
coef(lasso.models)
plot(lasso.models, xvar = "lambda", label = TRUE, main = "Lasso Regression")

set.seed(0)
cv.lasso.out = cv.glmnet(x, y,
                         lambda = grid, alpha = 1, nfolds = 10)
plot(cv.lasso.out, main = "Lasso Regression\n")
bestlambda.lasso = cv.lasso.out$lambda.min
bestlambda.lasso #0.01176812
log(bestlambda.lasso)
lasso.out = glmnet(x, y, alpha = 1)
predict(lasso.out, type = "coefficients", s = bestlambda.lasso)
# micex_rgbi_tr & gdp_deflator have raletively higher absolute value

# 53 x 1 sparse Matrix of class "dgCMatrix"
# 1
# (Intercept)                                 1.502054e+01
# oil_urals                                   .           
# gdp_quart                                   .           
# gdp_quart_growth                            .           
# cpi                                         .           
# ppi                                         .           
# gdp_deflator                                2.720614e-03
# balance_trade                               .           
# balance_trade_growth                        .           
# usdrub                                      .           
# eurrub                                      .           
# brent                                       .           
# net_capital_export                          .           
# gdp_annual                                  2.140844e-07
# gdp_annual_growth                           .           
# average_provision_of_build_contract         .           
# average_provision_of_build_contract_moscow  .           
# rts                                         .           
# micex                                       .           
# micex_rgbi_tr                              -1.649685e-03
# micex_cbi_tr                                .           
# deposits_value                              7.366719e-09
# deposits_growth                             .           
# mortgage_value                              .           
# mortgage_growth                             .           
# mortgage_rate                               .           
# income_per_cap                              .           
# salary                                      4.458266e-07
# fixed_basket                                3.108581e-06
# retail_trade_turnover                       .           
# retail_trade_turnover_per_cap               .           
# retail_trade_turnover_growth                .           
# labor_force                                 .           
# unemployment                                .           
# employment                                  .           
# invest_fixed_capital_per_cap                8.976404e-10
# invest_fixed_assets                         1.547620e-06
# pop_natural_increase                        .           
# childbirth                                  .           
# mortality                                   .           
# average_life_exp                            .           
# rent_price_4.room_bus                       .           
# rent_price_3room_bus                        .           
# rent_price_2room_bus                        .           
# rent_price_1room_bus                        .           
# rent_price_3room_eco                        .           
# rent_price_2room_eco                        .           
# rent_price_1room_eco                        .           
# load_of_teachers_school_per_teacher         .           
# provision_nurse                             .           
# load_on_doctors                             .           
# turnover_catering_per_cap                   2.965412e-05
# seats_theather_rfmin_per_100000_cap         .           

lasso.bestlambda = predict(lasso.out, s = bestlambda.lasso, newx = x)
mean((lasso.bestlambda - y)^2)
# MSE = 0.35741

#save the final picks
price_micro_1st= price_macro_final[,c('timestamp','price_log','micex_rgbi_tr', 'gdp_deflator', 'micex', 'micex_cbi_tr', 
                                      'eurrub', 'brent', 'usdrub', 'rts', 'rent_price_4.room_bus', 'balance_trade', 'cpi')]



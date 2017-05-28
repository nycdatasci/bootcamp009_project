library(data.table)
library(tidyverse)
library(lubridate)
library(scales)
library(corrplot)
library(DT)
library(car)
library(ggplot2)


setwd('/Users/clairevignon/DataScience/NYC_DSA/project3_ML_kaggle')
train = read.csv("train_cleaned.csv", stringsAsFactors = FALSE)
# macro = read.csv("macro.csv", stringsAsFactors = FALSE)
test = read.csv("test_cleaned.csv", stringsAsFactors = FALSE)

# using log
train$price_doc = log(train$price_doc+1)

##### Top Variables from Jack's lasso #####
top_35 = c("full_sq", "num_room", "kitch_sq", "state", "sub_area", "indust_part",
           "build_count_frame", "green_zone_km", "sadovoe_km", "railroad_km", "office_km", "theater_km",
           "catering_km", "trc_sqm_500", "church_count_500", "leisure_count_500", "trc_sqm_1000",
           "cafe_count_1000_price_high",  "mosque_count_1500", "prom_part_2000", "cafe_sum_2000_min_price_avg",
           "prom_part_3000", "office_sqm_5000", "cafe_sum_5000_min_price_avg", "cafe_count_5000_price_high",
           "mosque_count_5000", "sport_count_5000", 'price_doc')

# splitting top 35 to make it easier to look at corplot
top_35_1 = c("full_sq", "num_room", "kitch_sq", "build_count_frame", 'price_doc') # only numeric
top_35_2 = c("green_zone_km", "sadovoe_km", "railroad_km", "office_km", "theater_km",
             "catering_km", "trc_sqm_500", 'price_doc')
top_35_3 = c("trc_sqm_500", "church_count_500", "leisure_count_500", "trc_sqm_1000",
             "cafe_count_1000_price_high",  "mosque_count_1500", "prom_part_2000", "cafe_sum_2000_min_price_avg",
             "prom_part_3000", "office_sqm_5000", "cafe_sum_5000_min_price_avg", "cafe_count_5000_price_high",
             "mosque_count_5000", "sport_count_5000", 'price_doc')

# look at multi-collinearity between the variables
corrplot(cor(train[, top_35_1], use="complete.obs"))
# full_sq & num_room are correlated. We will drop num_room and keep full_sq (which is
# highly correlated with price)

corrplot(cor(train[, top_35_2], use="complete.obs"))
# office_km, theater_km seem somewhat correlated but there is no real good reason
# to think so so will keep both

# catering_km and office km are correlated which can make sense so will keep
# office_km only. None seem highly correlated with price

corrplot(cor(train[, top_35_3], use="complete.obs"))
# variables of the same family (e.g. trc_sqm_500 and trc_sqm_1000) are correlated 
# which make sense. We won't consider them in our linear model for now

top_35_reduced = c("id", "full_sq", "kitch_sq", "state", "sub_area", 'price_doc', "green_zone_km", 
                   "sadovoe_km", "railroad_km", "office_km", "theater_km")
top_35_reduced_noprice = c("id", "full_sq", "kitch_sq", "state", "sub_area", "green_zone_km", 
                           "sadovoe_km", "railroad_km", "office_km", "theater_km")

train_top35_reduced = subset(train, select= top_35_reduced)
test_top35_reduced = subset(test, select= top_35_reduced_noprice)

str(train_top35_reduced)
str(test_top35_reduced)

# convert state and sub_area variables to factor
train_top35_reduced$state = factor(train_top35_reduced$state)
train_top35_reduced$sub_area = factor(train_top35_reduced$sub_area)

test_top35_reduced$state = factor(test_top35_reduced$state)
test_top35_reduced$sub_area = factor(test_top35_reduced$sub_area)


# Impute NA with random for factor variables
sum(is.na(train_top35_reduced$state)) #13559 NAs which is more than 30% of the
# dataset so we will impute with random method

library(Hmisc)
train_top35_reduced$state = impute(train_top35_reduced$state, "random")
test_top35_reduced$state = impute(test_top35_reduced$state, "random")

sum(is.na(train_top35_reduced)) # no more NAs
sum(is.na(test_top35_reduced))

# # check relationship between variables (matrix scatter plot)
# plot(train_top35_reduced, pch=16, col="blue", main="Matrix Scatterplot")

# 1- Is there a relationship between price and house characterictics?
# fitting a multiple regression model of price onto top variables 
model = lm(price_doc ~ . - id, data = train_top35_reduced)

# # 2- Is the relationship linear
# # checking if we violate any assumptions
# plot(model) # none of the assumptions are violated

# 3- How strong is the relationship?
summary(model)
vif(model) # sadovoe_km  VIF is higher than 10 so removing it from model

model_1 = update(model, ~.-sadovoe_km)
summary(model_1)
vif(model_1)

# 4- How accurately can we predict the relationship?
prediction = predict(model_1,test_top35_reduced) 
prediction = exp(prediction)-1
prediction = data.frame(id=test$id, price_doc=prediction)
# prediction = apply(prediction,2,function(x){x[x<0] = min(x[x>0]);x})
write.csv(prediction, "prediction.csv", row.names=F)


##### METHOD 2 - Linear Regression, different features, median imputation grouped by sub_area #####
train_reduced = read.csv("train_reduced.csv", stringsAsFactors = FALSE)
test_reduced = read.csv("test_reduced.csv", stringsAsFactors = FALSE)

train_reduced = subset(train_reduced, select = -c(X))
test_reduced = subset(test_reduced, select = -c(X))

train_reduced$price_doc = log(train_reduced$price_doc+1)

model_2 = lm(price_doc ~ . - id - usdrub - cpi - mortgage_rate - micex - timestamp, data = train_reduced)

summary(model_2)
vif(model_2)

# VIF is higher than 5 for preschool_km, public_healthcare_km, swim_pool_km, 
# public_transport_station_km, kindergarten_km, hospice_morgue_km so removing them
model_2a = update(model_2, ~ . -preschool_km - public_healthcare_km - swim_pool_km - public_transport_station_km - kindergarten_km - hospice_morgue_km)
summary(model_2a)
vif(model_2a)

prediction_2 = predict(model_2a,test_reduced) 
prediction_2 = exp(prediction_2)-1
prediction_2 = data.frame(id=test$id, price_doc=prediction_2)
write.csv(prediction_2, "prediction_2.csv", row.names=F)

##Improved score by 78 from method 2##

##### METHOD 3 - Linear Regression, same as METHOD 2 + take macro into account in model #####













##### Improve upon the model #####
### use variables from random forest ###
# use variables for which feature importance is >= 80
top_80 = c("full_sq", "life_sq", "floor", "build_year", "max_floor", "kitch_sq",
           "state", "additional_education_km", "public_transport_station_km", 
           "num_room", "ID_metro", "big_church_km", "sub_area",
           "preschool_km", "cafe_avg_price_500", "big_road2_km", "green_zone_km",
           "kindergarten_km", "catering_km", "big_road1_km", 
           "public_healthcare_km", "hospice_morgue_km", "swim_pool_km", "material", 
           "green_part_1000", "railroad_km", "industrial_km", "cemetery_km",
           "fitness_km", "theater_km", "radiation_km", "price_doc", "id")

top_80_noprice = c("full_sq", "life_sq", "floor", "build_year", "max_floor", "kitch_sq",
                   "state", "additional_education_km", "public_transport_station_km", 
                   "num_room", "ID_metro", "big_church_km", "sub_area",
                   "preschool_km", "cafe_avg_price_500", "big_road2_km", "green_zone_km",
                   "kindergarten_km", "catering_km", "big_road1_km", 
                   "public_healthcare_km", "hospice_morgue_km", "swim_pool_km", "material", 
                   "green_part_1000", "railroad_km", "industrial_km", "cemetery_km",
                   "fitness_km", "theater_km", "radiation_km", "id")


train_top80 = subset(train, select= top_80)
test_top80 = subset(test, select= top_80_noprice)

str(train_top80)
str(test_top80)

# convert variables to factor type
# convert state and sub_area variables to factor
train_top80$floor = factor(train_top80$floor)
test_top80$floor = factor(test_top80$floor)

test_top35_reduced$state = factor(test_top35_reduced$state)
test_top35_reduced$sub_area = factor(test_top35_reduced$sub_area)

# impute missing values

# scale dataframe


# look at importance of state in price_doc



summary(model_1)

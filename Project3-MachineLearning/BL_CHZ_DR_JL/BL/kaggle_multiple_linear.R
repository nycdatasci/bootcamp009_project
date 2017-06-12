library(data.table)
library(dplyr)
library(ggplot2)
rm(list=ls())

getwd()
setwd("~/NYC Data Science Academy/Kaggle Project/kaggle_jumpstart_sberbank")
train_data <- fread("train.csv")
macro_data <- fread("macro.csv")
test_data <- fread("test.csv")
names(test_data)
head(test_data)
train_data <- fread("train_cleaned.csv")

train_data <- fread("bo_train.csv")
macro_data <- fread("macro.csv")
test_data <- fread("bo_test.csv")

train_data <- fread("trainnew.csv")
test_data <- fread("testnew.csv")

train_data <- fread("cleaned_full_train.csv")

########################################################
######### Trying Multiple Linear Regression ############
######### with few select features          ############
########################################################

library(MASS)
library(ggplot2)
library(ggthemes)

names(train_data)
lm_model = lm(log(price_doc)~full_sq+
                build_year+
                public_transport_station_min_walk,
              data=train_data)

##### Simple Model with low RMSE ###############
lm_model = lm(log(price_doc)~full_sq+
                kremlin_km+
                public_transport_station_min_walk,
              data=train_data)


lm_model = lm(log(price_doc)~
                full_sq + ttk_km +
                year+
                month+
                full_all+
                metro_min_walk+
                workplaces_km,data=train_data)
               public_transport_station_min_walk+
names(train_data) 

lm_model = lm(log(price_doc)~
                full_sq + ttk_km +
                public_transport_station_min_walk,
                # year+full_all+office_km,
                data=train_data)

# lm_model = lm(log(price_doc)~metro_min_walk
#               ,data=train_data)

##### Final Model with lowest RMSE ###############
lm_model = lm(log(price_doc)~full_sq+
                material+
                kremlin_km+
                year+
                month+
                full_all+
                floor+
                school_education_centers_raion+
                church_count_500+
                office_count_500+
                shopping_centers_raion+
                green_zone_km+
                industrial_km+
                indust_part+
                school_education_centers_top_20_raion
              ,data=train_data)


?predict
# metro_min_walk+ttk_km+


library(usdm)
train_lm<-
  train_data%>%
  dplyr::select(full_sq,
                # state,
                material,
                # ttk_km,
                kremlin_km,
                # museum_km,
                # workplaces_km,
                # university_top_20_raion,
                year,
                month,
                full_all,
                floor,
                # big_church_km,
                school_education_centers_raion,
                # big_market_raion,
                # cafe_count_500,
                # big_road1_km,
                church_count_500,
                office_count_500,
                # preschool_km,
                # museum_km,
                shopping_centers_raion,
                # office_raion,
                # sport_count_500,
                # green_part_500,
                # park_km,
                green_zone_km,
                industrial_km,
                # state,
                # oil_chemistry_km,
                # nuclear_reactor_km,
                indust_part,
                # school_quota,
                school_education_centers_top_20_raion,
                # healthcare_centers_raion,
                # culture_objects_top_25,
                # radiation_raion,
                # sadovoe_km,
                price_doc)


train_lm<-
  train_data%>%
  dplyr::select(ttk_km,
                `0_17_female`,
                year,                           
                trc_sqm_5000,                   
                material,
                month,
                full_all,
                floor,
                school_education_centers_raion,
                church_count_500,
                office_count_500,
                shopping_centers_raion,
                green_zone_km,
                industrial_km,
                indust_part,
                school_education_centers_top_20_raion,
                
                # kitch_sq,                       
                # num_room,                       
                full_sq,                        
                price_doc)


train_lm<-
  train_data%>%
  dplyr::select(full_sq,
                kremlin_km,
                public_transport_station_min_walk,
                price_doc)

aggr(train_lm)
names(train_lm)
summary(train_lm$material)
head(train_lm)

cor(train_lm$kremlin_km,train_lm$nuclear_reactor_km)
cor(train_lm$kremlin_km,train_lm$oil_chemistry_km)
cor(train_data$kremlin_km,train_data$university_km)
cor(train_data$kremlin_km,train_data$office_km)
cor(train_data$kremlin_km,train_data$mosque_km)
cor(train_data$kremlin_km,train_data$theater_km)

full_sq                                
kremlin_km                            
year                                  
month                                  
full_all                              
floor                                  
school_education_centers_raion         
church_count_500                      
office_count_500                      
shopping_centers_raion                
green_zone_km                         
industrial_km                         
indust_part                           
school_education_centers_top_20_raion 


head(train_lm)

############### Imputing missing values ################
library(VIM)
library(mice)
train_lm$full_sq = impute(train_lm$full_sq, mean) 
train_lm$floor = impute(train_lm$floor, mean) 
train_lm$material = impute(train_lm$material, mean) 
train_lm$material = impute(train_lm$material, median) 
train_lm$material = impute(train_lm$material, mode) 
summary(train_lm$material)
head(train_lm)

train_lm%>%
  group_by(material)%>%
  summarise(n())

library(deldir) #Load the Delaunay triangulation and Dirichelet tesselation library.
#Conducting a 12NN classification imputation based on the square root of n.
sqrt(nrow(train_sub_predictors))
train_lm.imputed175NN = kNN(train_lm, k = 175)
aggr(train_lm.imputed175NN)

library(caret)
library(zoo)
pre.175nn = preProcess(train_lm, method = 'knnImpute', k=175)
imputed.175nn = predict(pre.175nn, train_lm)
hist(imputed.175nn$price_doc)
?preProcess
lm_model = lm(log(price_doc)~.,data=train_lm.imputed175NN)
lm_model = lm(log(price_doc)~.,data=imputed.175nn)

#####Using Minkowski Distance Measures in KNN#####
library(kknn) #Load the weighted knn library.
#Separating the complete and missing observations for use in the kknn() function.
aggr(train_lm)
complete = 
  train_lm%>%
  dplyr::filter(is.na(material))%>%
  dplyr::filter(is.na(full_sq))#%>%
# dplyr::filter(is.na(floor))


train_lm%>%
  filter(is.na(material))
is.na(train_lm$material)
+is.na(train_lm$floor)

aggr(complete)

missing = iris.example[missing.vector, -3]

#Distance corresponds to the Minkowski power.
train_lm.imputed175NN.euclidean = kknn(price_doc ~ ., complete, missing, k = 175, distance = 2)
summary(iris.euclidean)

train_lm.imputed175NN..manhattan = kknn(price_doc ~ ., complete, missing, k = 175, distance = 1)
summary(iris.manhattan)

#######################################################
################ Model Evaluation #####################
#######################################################

lm_model = lm(log(price_doc)~.,data=train_lm)


summary(lm_model)
vif(train_lm)
#RMSE Calculation
sqrt(mean(lm_model$residuals^2))
head(train_lm)
plot(lm_model)

# 0.4909611
# 0.4905725
# 0.4826886
# 0.4823861
# 0.482261
# 0.4656072
# 15 model: 0.4658388

# 0.4897784
# 0.4651837

names(train_lm)
plot(train_lm)

dim(train_lm)
boxplot(price_doc~big_market_raion,data=train_lm)
train_lm$museum_km
plot(train_data$museum_km~train_lm)

plot(lm_model)
hist(lm_model$residuals)

influencePlot(lm_model)
train_lm_plot<-train_lm
summary(train_lm_plot)
train_lm_plot$price_doc<-log(train_lm$price_doc)
train_lm_plot$ttk_km<-log(train_lm$ttk_km)
train_lm_plot$workplaces_km<-log(train_lm$workplaces_km)
names(train_lm)
plot(train_lm)
plot(train_lm_plot)
aggr(train_lm)
summary(train_lm)
boxplot(train_lm$floor)

##### Inspecting Outliers
train_lm[20244,]
train_lm[20388,]
train_lm[1030,]

train_lm[1380,]
train_lm[18525,]
train_lm[1030,]

summary(train_lm$price_doc)
hist(log(train_lm$price_doc))
hist(lm_model$residuals)
hist(log(train_lm$full_all))
names(test_data)
test_lm<-
  test_data%>%
  dplyr::select(full_sq,
                # material,
                kremlin_km,
                year,
                month,
                full_all,
                floor,
                school_education_centers_raion,
                church_count_500,
                office_count_500,
                shopping_centers_raion,
                green_zone_km,
                industrial_km,
                indust_part,
                school_education_centers_top_20_raion,
                healthcare_centers_raion,
                radiation_raion,
                sadovoe_km)

names(test_data)
test_lm<-
  test_data%>%
  dplyr::select(full_sq,
                ttk_km,
                public_transport_station_min_walk)


aggr(test_lm)
head(test_data)
head(test_lm)

######## Imputing test data with mean ##################
library(Hmisc) #Load the Harrell miscellaneous library.
names(test_lm)
train_lm$full_sq = impute(train_lm$full_sq, mean) 
train_lm$material = impute(train_lm$material, mean) 
test_lm$full_sq = impute(test_lm$full_sq, mean) 


######## Prediction ###################################
lm_test_predict = predict.lm(lm_model, test_lm)
lm_test_predict = lm_model$coefficients*x_test
dim(test_lm)
dim(x_test)
lm_model$coefficients
dim(lm_model$coefficients)
length(lm_test_predict)
result = exp(lm_test_predict)
result
sum(is.na(result))
result = impute(result, mean) 

write.csv(file="Multiple_Linear_Simple.csv",x=result)
?skew

skew(log(result))
skew(log(train_lm$price_doc))
skew(result)
skew(train_lm$price_doc)

hist(log(result))
hist(log(train_lm$price_doc))
####### Delete Missing Rows ###############################
train_lm<-
  train_lm[complete.cases(train_lm), ]

########################################################
############ Trying LASSO on Multiple Linear Reg #######
############ Variables                           #######
########################################################
x = model.matrix(price_doc ~ ., train_lm)[, -1]
y = log(train_lm$price_doc)#y is log transformed
dim(train_lm)
dim(x)
length(y)

#Values of lambda over which to check.
grid = 10^seq(2, -10, length = 100)
library(glmnet)
#Fitting the lasso regression. Alpha = 1 for lasso regression.
lasso.models = glmnet(x, y, alpha = 1, lambda = grid)
# ?glmnet
plot(lasso.models, xvar = "lambda", label = TRUE, main = "Lasso Regression")
lasso.models

set.seed(0)
cv.lasso.out = cv.glmnet(x, y, alpha = 1, nfolds = 10, lambda = grid,standardize=TRUE)
plot(cv.lasso.out, main = "Lasso Regression\n")
bestlambda.lasso = cv.lasso.out$lambda.min
bestlambda.lasso
log(bestlambda.lasso)

#### Min MSE
min(cv.lasso.out$cvm)
#### Min RMSE
sqrt(min(cv.lasso.out$cvm))

###########################################################

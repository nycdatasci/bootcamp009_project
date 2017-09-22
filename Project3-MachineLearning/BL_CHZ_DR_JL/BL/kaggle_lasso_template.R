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


# Significant Macro data ############################################
# cpi','ppi','gdp_deflator','gdp_annual_growth','salary','deposits_value'

View(macro_data)
column_names <- fread("key_features.csv")
column_names
sample(5)
head(train_data)
aggr(train_data)

##### Fixing max_floor ###########################
train_data$max_floor<-ifelse(train_data$floor>train_data$max_floor,
                             train_data$floor,
                             train_data$max_floor)
train_data$floor
plot(train_data$floor,train_data$max_floor)

write.csv(file="train_max_floor_fixed.csv", x=train_data)
###################################

head(train_data[,1:15])
aggr(train_data[,2:15])
names(train_data)[1:15]
unique(train_data$sub_area)
match(column_names$Predictor,names(train_data))
column_names$Predictor[21]
column_names$Predictor[35]
head(train_data)
column_names$Predictor[78]
colnames(train_data)[11] <- "product_type"
colnames(train_data)[12] <- "sub_area"
colnames(train_data)[25] <- "incineration_raion"
colnames(train_data)[26] <- "oil_chemistry_raion"
colnames(train_data)[29] <- "culture_objects_top_25"
colnames(train_data)[37] <- "railroad_1line"

colNums <- match(c(column_names$Predictor,"price_doc"),names(train_data))

train_sub_predictors<-
train_data%>%
  dplyr::select(colNums)
# ,-basketball_km

train_sub_predictors<-
  train_data%>%
  dplyr::select(c(full_sq,price_doc))
library(VIM)
aggr(train_sub_predictors)

# Exclude some factors ############################
train_sub_predictors<-
  train_sub_predictors%>%
  select(-swim_pool_km,
         -shopping_centers_km,
         -big_church_km,
         -life_sq,
         -`0_17_female`,
         -`16_29_female`)

train_sub_predictors<-
  train_sub_predictors%>%
  dplyr::select(-full_all,
                -male_f,
                -ttk_km,
                -basketball_km,
                -sport_objects_raion,
                -year,
                -cpi)

vif(train_sub_predictors)

# View(train_sub_predictors)

colnames(test_data)[11] <- "product_type"
colnames(test_data)[12] <- "sub_area"
colnames(test_data)[25] <- "incineration_raion"
colnames(test_data)[26] <- "oil_chemistry_raion"
colnames(test_data)[29] <- "culture_objects_top_25"
colnames(test_data)[37] <- "railroad_1line"


colNums_test <- match(column_names$Predictor,names(test_data))
column_names$Predictor[1]



library(corrplot)
test_sub_predictors<-
  test_data%>%
  select(colNums_test)

test_sub_predictors<-
  test_sub_predictors%>%
  dplyr::select(-swim_pool_km,
         -shopping_centers_km,
         -big_church_km,
         -life_sq,
         -`0_17_female`,
         -`16_29_female`)

test_sub_predictors<-
  test_sub_predictors%>%
  dplyr::select(-full_all,
         -male_f,
         -ttk_km,
         -basketball_km,
         -sport_objects_raion,
         -year,
         -cpi)

names(train_sub_predictors)
names(test_sub_predictors)

head(test_sub_predictors)
dim(test_sub_predictors)
cor(test_sub_predictors)
corrplot(test_sub_predictors)
?corrplot

head(train_sub_predictors)
summary(train_sub_predictors)
names(train_sub_predictors)

######## Inspecting Missing Values ##########
# ?complete.cases
library(VIM)
aggr(train_sub_predictors[,1:10])

head(train_sub_predictors)
train_sub_predictors$max_floor<-NULL
train_sub_predictors$material<-NULL
train_sub_predictors$build_year<-NULL
train_sub_predictors$num_room<-NULL
train_sub_predictors$kitch_sq<-NULL
train_sub_predictors$state<-NULL
train_sub_predictors$sub_area<-NULL

sum(is.na(train_sub_predictors$life_sq))

dim(train_sub_predictors)
#Rows with missing values
train_sub_predictors_missing<-
  train_sub_predictors[!complete.cases(train_sub_predictors), ]
head(train_sub_predictors)
nrow(train_sub_predictors)
head(train_sub_predictors_missing)


# of Rows missing
nrow(train_sub_predictors_missing)/
  nrow(train_sub_predictors)


#Excluding rows with missing values
train_sub_predictors<-
  train_sub_predictors[complete.cases(train_sub_predictors), ]

# Test data missing
aggr(test_sub_predictors)
test_data_missing<-
  test_data[!complete.cases(test_data), ]

nrow(test_data_missing)/
  nrow(test_data)

test_data<-
  test_data[complete.cases(test_data), ]

# Deleting missing values in original train_data
train_data<-
  train_data[!complete.cases(train_data), ]

dim(train_data)
head(train_data)

summary(train_sub_predictors)
head(train_sub_predictors)
names(train_sub_predictors)

vif(train_lm)
head(train_lm)
avPlots(model)
aggr(train_lm)
lm_model.empty = lm(log(price_doc) ~ 1, data = train_lm) #The model with an intercept ONLY.
lm_model.full = lm(log(price_doc) ~ ., data = train_lm) #The model with ALL variables.
scope = list(lower = formula(lm_model.empty), upper = formula(lm_model.full))

forwardAIC = step(lm_model.empty, scope, direction = "forward", k = 2)
backwardAIC = step(lm_model.full, scope, direction = "backward", k = 2)
bothAIC.empty = step(lm_model.empty, scope, direction = "both", k = 2)
bothAIC.full = step(lm_model.full, scope, direction = "both", k = 2)

#Stepwise regression using BIC as the criteria (the penalty k = log(n)).
forwardBIC = step(lm_model.empty, scope, direction = "forward", k = log(50))
backwardBIC = step(lm_model.full, scope, direction = "backward", k = log(50))
bothBIC.empty = step(lm_model.empty, scope, direction = "both", k = log(50))
bothBIC.full = step(lm_model.full, scope, direction = "both", k = log(50))

AIC(lm_model)
AIC(model,  
    model2, 
    model3) 

## 5
BIC(model,
    model2,
    model3)


########################################################

#Creating the data matrices for the glmnet() function.
x = model.matrix(price_doc ~ ., train_sub_predictors)[, -1]
y = log(train_sub_predictors$price_doc)#y is log transformed

dim(x)
length(y)

# Material LASSO
x = model.matrix(material ~ ., train_data)[, c(-1,-291)]
y = log(train_data$material)#y is log transformed
train_sub_predictors

x = model.matrix(material ~ ., train_sub_predictors)[, -1]
y = log(train_sub_predictors$material)#y is log transformed

x = model.matrix(kitch_sq ~ ., train_sub_predictors)[, -1]
y = log(train_sub_predictors$kitch_sq)#y is log transformed

unique(train_sub_predictors$kitch_sq)
dim(train_sub_predictors)
dim(x)
length(y)
head(x)
y

#### 5NN Imputed LASSO ################
library(caret)

library(zoo)
rus_train$prom_part_5000_x1 <- 
  na.aggregate(rus_train$prom_part_5000, 
               by = rus_train$sub_area, FUN = median)

#Imputing using 5NN.
train_sub_predictors$price_doc=log(train_sub_predictors$price_doc)
pre.5nn = preProcess(train_sub_predictors, method = 'knnImpute', k=5)
pre.9nn = preProcess(train_sub_predictors, method = 'knnImpute', k=9)
pre.9nn = preProcess(train_sub_predictors, method = 'knnImpute', k=9)
pre.175nn = preProcess(train_sub_predictors, method = 'knnImpute', k=175)
sqrt(nrow(train_sub_predictors))

imputed.5nn = predict(pre.5nn, train_sub_predictors)
imputed.175nn = predict(pre.175nn, train_sub_predictors)

head(imputed.5nn)
head(imputed.175nn)

x = model.matrix(price_doc ~ ., imputed.175nn)[, -1]
y = imputed.175nn$price_doc#y is not log transformed

#Inspecting the Voronoi tesselation for the complete observations in the iris
#dataset.
library(deldir) #Load the Delaunay triangulation and Dirichelet tesselation library.
#Conducting a 12NN classification imputation based on the square root of n.
sqrt(nrow(train_sub_predictors))
sberbank.imputed175NN = kNN(train_sub_predictors, k = 175)

x = model.matrix(price_doc ~ ., sberbank.imputed175NN)[, -1]
y = sberbank.imputed175NN$price_doc#y is not log transformed

#####Using Minkowski Distance Measures in KNN#####
library(kknn) #Load the weighted knn library.

#Distance corresponds to the Minkowski power.
sberbank.euclidean = kknn(price_doc ~ ., train_sub_predictors, missing, k = 175, distance = 2)
summary(iris.euclidean)

sberbank.manhattan = kknn(price_doc ~ ., train_sub_predictors, missing, k = 175, distance = 1)
summary(iris.manhattan)


##############################################

# plot(train_sub_predictors$price_doc)
# plot(y)

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

library(usdm)
vif(train_sub_predictors)


names(train_sub_predictors)[c(1,2,5,4)]
dim(train_sub_predictors)
#### Min MSE
min(cv.lasso.out$cvm)
#### Min RMSE
sqrt(min(cv.lasso.out$cvm))

names(train_sub_predictors)
cv.lasso.out$glmnet.fit


#Test Data Imputation ###############################
head(test_sub_predictors)
test_sub_predictors$max_floor<-NULL
test_sub_predictors$material<-NULL
test_sub_predictors$build_year<-NULL
test_sub_predictors$num_room<-NULL
test_sub_predictors$kitch_sq<-NULL
test_sub_predictors$state<-NULL
test_sub_predictors$sub_area<-NULL

aggr(test_sub_predictors[,1:10])
aggr(test_sub_predictors)
names(test_sub_predictors[,1:10])
library(Hmisc) #Load the Harrell miscellaneous library.
names(test_sub_predictors)

train_sub_predictors$full_sq

test_sub_predictors$full_sq = impute(test_sub_predictors$full_sq, mean) 
test_sub_predictors$life_sq = impute(test_sub_predictors$life_sq, mean) 
test_sub_predictors$floor = impute(test_sub_predictors$floor, mean) 
test_sub_predictors$build_count_monolith = impute(test_sub_predictors$build_count_monolith, mean) 
aggr(test_sub_predictors)

names(train_sub_predictors)
names(test_sub_predictors)
#The error seems to be reduced with a log lambda value of around -3.3027; this
#corresponts to a lambda value of about 0.038. This is the value of lambda
#we should move forward with in our future analyses.


lasso.bestlambdatrain = predict(lasso.models, s = bestlambda.lasso, newx = x)
lasso.coefficient = predict(lasso.models, s = bestlambda.lasso, 
                                type="coefficient")
lasso.coefficient = predict(lasso.models, s = exp(-3), 
                            type="coefficient")

class(lasso.coefficient)
lasso.coefficient[,1]

#Convert it back from log-transform
mean((exp(lasso.bestlambdatrain) - exp(y))^2)
length(names(test_sub_predictors))
length(names(train_sub_predictors))

x_test = model.matrix(~., test_sub_predictors)[, -1]
dim(x_test)
dim(train_sub_predictors)
dim(test_sub_predictors)
###### Prediction ####################
names(test_data)
lasso.bestlambdatest = predict(lasso.models, s = bestlambda.lasso, newx = x_test)
lasso.bestlambdatrain = predict(lasso.models, s = bestlambda.lasso, newx = x)

x[1:7634,]-x_test
sum((x[1,]-x_test[1,])^2)
length(lasso.coefficient)
length(x[1,])
sum(lasso.coefficient*c(1,x[300,]))
sum(lasso.coefficient*c(1,x_test[300,]))

class(x[1:7634,])
class(x_test)
dim(x)
dim(x_test)

summary(lasso.models)
lasso.models$beta

nrow(lasso.bestlambdatest)
summary(lasso.bestlambdatest)
exp(lasso.bestlambdatest)
result = exp(lasso.bestlambdatest)
result_train = exp(lasso.bestlambdatrain)

hist(train_sub_predictors$price_doc-result_train)

nrow(lasso.bestlambdatrain)
summary(lasso.bestlambdatrain)


write.csv(file="LASSO_prediction_4.csv",x=result)
names(train_sub_predictors_forest)
train_sub_predictors_forest<-train_sub_predictors
colnames(train_sub_predictors_forest)[13]<-"X0_17_female"
colnames(train_sub_predictors_forest)[14]<-"X16_29_female"
head(train_sub_predictors_forest)
aggr(train_sub_predictors_forest)
library(randomForest)
rf.sberbank = randomForest(price_doc ~ ., data = train_sub_predictors_forest, ntree = 300, 
                           importance = TRUE, na.action = na.omit)
rf.sberbank

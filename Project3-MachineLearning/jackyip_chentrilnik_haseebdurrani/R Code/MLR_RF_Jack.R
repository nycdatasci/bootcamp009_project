######################
# Scatterplot Matrix #
######################

library(car)
pairs(price_doc~., data=temp,
                   main="Scatterplot Matrix")


######################
# Correlation Matrix #
######################

#create temp2 with additional 5 features that contain missing values
temp2 <- merge(x = temp, y = orig_train[ , c("life_sq", 
                                             "material", 
                                             "num_room",
                                             "kitch_sq",
                                             "state",
                                             "id")], by = "id")

temp2_numeric <- temp2[, sapply(temp2, is.numeric)]
cor_matrix <- round(cor(temp2_numeric, use = "complete.obs"), 2)
write.csv(cor_matrix, 'cor_matrix.csv')

#########################################
# Correlation Matrix  - 5 features only #
#########################################
temp3_numeric <- temp3[, sapply(temp3, is.numeric)]
cor_matrix_temp3 <- round(cor(temp3_numeric, use = "complete.obs"), 2)
cor_matrix_temp3

#############################################################################
# Multiple Linear Regression - life_sq, material, num_room, kitch_sq, state #
#############################################################################
temp3 = orig_train[c('life_sq','price_doc','material','num_room','kitch_sq','state')]
temp3 = temp3[complete.cases(temp3),]
temp3$material <- as.factor(temp3$material)
temp3$state <- as.factor(temp3$state)
temp3_mlr = lm(price_doc ~ life_sq + material + num_room + kitch_sq + state , data = temp3)
summary(temp3_mlr)

library(car)
vif(temp3_mlr)

#just kitch_sq
kitch = orig_train[c('price_doc','kitch_sq')]
kitch = kitch[complete.cases(kitch),]
kitch_mlr = lm(price_doc ~ ., data = kitch)
summary(kitch_mlr)

#############################################################################
# Multiple Linear Regression - 33 features (excluding life_sq and state) v3 #
#############################################################################
# create new test_df_temp5 
test_df_temp5 <- merge(test, orig_test[c("area_m", 
                                         "raion_popul", 
                                         "metro_min_avto",
                                         "park_km",
                                         "green_zone_km",
                                         "industrial_km",
                                         "public_transport_station_km",
                                         "water_km",
                                         "big_road1_km",
                                         "railroad_km",
                                         "radiation_km",
                                         "fitness_km",
                                         "shopping_centers_km",
                                         "preschool_km",
                                         "id")], by = 'id')

# fit model
temp5_mlr = lm(price_doc ~ . - id, data = temp)
summary(temp5_mlr)
# Multiple R-squared:  0.469,	Adjusted R-squared:  0.468 

# cross validation
cv <- cv.lm(temp, temp5_mlr, m=3)
attr(cv, "ms")
# attr(cv, "ms") [1] 1.22e+13

# run predictions
test_prediction <- as.data.frame(predict(temp5_mlr, test_df_temp5))
test_prediction <- cbind(test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v3.csv', row.names = FALSE)


#############################################################################
# Multiple Linear Regression - including only significant features v4 #
#############################################################################

# including only significant features
temp5_mlr_sig = lm(price_doc ~ . -id 
                   -school_km
                   -area_m
                   -park_km
                   -public_transport_station_km,
                   data = temp)
summary(temp5_mlr_sig)
# Multiple R-squared:  0.469,	Adjusted R-squared:  0.468 

# cross validation
cv <- cv.lm(temp, temp5_mlr_sig, m=3)
attr(cv, "ms")
# [1] 1.22e+13

# run predictions
test_prediction <- as.data.frame(predict(temp5_mlr_sig, test_df_temp5))
test_prediction <- cbind(orig_test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v4.csv', row.names = FALSE)

# check for VIF
car::vif(temp5_mlr_sig)

# removing features with high VIF

# create train set with only significant features
temp5 <- temp[c("id",
                "school_km",
                "month",
                "year",     
                "sub_area",
                "full_sq",
                "build_year",
                "floor",        
                "max_floor",
                "product_type",
                "green_zone_km",
                "industrial_km",
                "water_km",
                "big_road1_km",
                'price_doc')]

# fit model
temp6_mlr = lm(price_doc ~ . - id,
               data = temp5)
summary(temp6_mlr)
# Multiple R-squared:  0.455,	Adjusted R-squared:  0.454 

# cross validation
cv <- cv.lm(temp, temp6_mlr, m=3)
attr(cv, "ms")
# 1.25e+13

# check for VIF
car::vif(temp6_mlr)

# create new test_df_temp6
test_df_temp6 <- test_df_temp4[c('id',
                                 'school_km',
                                 'month',
                                 'year',
                                 'sub_area',
                                 'full_sq',
                                 'build_year',
                                 'floor',
                                 'max_floor',
                                 'product_type',
                                 'green_zone_km',
                                 'industrial_km',
                                 'water_km',
                                 'big_road1_km')]

# run predictions
test_prediction <- as.data.frame(predict(temp6_mlr, test_df_temp6))
test_prediction <- cbind(orig_test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v6.csv', row.names = FALSE)




#############################################################################
# Multiple Linear Regression - 33 features (excluding life_sq and state)    #
#############################################################################
# create new test_df (note that this contains only 15k rows)
test_df_temp4 <- merge(test, orig_test[c('life_sq',
                                         'material',
                                         'num_room',
                                         'kitch_sq',
                                         'state',
                                         "area_m", 
                                         "raion_popul", 
                                         "metro_min_avto",
                                         "park_km",
                                         "green_zone_km",
                                         "industrial_km",
                                         "public_transport_station_km",
                                         "water_km",
                                         "big_road1_km",
                                         "railroad_km",
                                         "radiation_km",
                                         "fitness_km",
                                         "shopping_centers_km",
                                         "preschool_km",
                                         "id")], by = 'id')
test_df_temp4$state <- as.factor(test_df_temp4$state)
test_df_temp4$material <- as.factor(test_df_temp4$material)

# create training
temp4 = temp2[complete.cases(temp2),]
temp4$material <- as.factor(temp4$material)
temp4$state <- as.factor(temp4$state)
levels(temp4$material) <- c('1', '2', '3', '4', '5', '6')

# manually change one observation to material '6'
temp4[1,30] <- 6

# fit model without life_sq and state (these have missing values in train/test)
temp4_mlr = lm(price_doc ~ . - id - life_sq - state, data = temp4)
summary(temp4_mlr)

# With all features
# Multiple R-squared:  0.526,	Adjusted R-squared:  0.523

# run predictions
test_prediction <- as.data.frame(predict(temp4_mlr, test_df_temp4))
test_prediction <- cbind(test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v2.csv', row.names = FALSE)


library(DAAG)
cv <- cv.lm(temp4, temp4_mlr, m=3)
attr(cv, "ms")

# with all features
# attr(cv, "ms") 1.27e+13

temp4_mlr_sig = lm(price_doc ~ . -id 
               -school_km
               -raion_popul
               -public_transport_station_km
               -public_transport_station_km
               -radiation_km
               -preschool_km
               -num_room
               -kitch_sq, data = temp4)
summary(temp4_mlr_sig)

# Multiple R-squared:  0.537,	Adjusted R-squared:  0.534 

cv <- cv.lm(temp4, temp4_mlr_sig, m=3)
attr(cv, "ms")

# Check BIC
model.empty = lm(price_doc ~ 1, data = temp4) #The model with an intercept ONLY.
model.full = lm(price_doc ~ . - id - life_sq - state, data = temp4) #The model with ALL variables.
scope = list(lower = formula(model.empty), upper = formula(model.full))
forwardBIC = step(model.empty, scope, direction = "forward", k = log(50))
backwardBIC = step(model.full, scope, direction = "backward", k = log(50))

# with all features 
# attr(cv, "ms") [1] 1.27e+13

# next steps
# 
# try to remove features (and look at R^2, Mean Squared Errors, BIC)
# consider imputing state/life_sq
# understand how xgboost handles missing values (i.e. does it
# ignore the whole observation or handles it at the feature-level?)
# observation (5/20): when we created a model with less rows (15k instead of 30k),
# we observed a higher R^2, but the prediction were less accurate 




##################################################
# Multiple Linear Regression - First Model (v1) #
##################################################
train <- read.csv('train_df.csv')
test <- read.csv('test_df.csv')

# fit the MLR model
model.saturated = lm(price_doc ~ . - id, data = train)

# examine model summary
summary(model.saturated)
# Multiple R-squared:  0.4602,	Adjusted R-squared:  0.4592 

# examine plot
plot(model.saturated)

# Assessing the variance inflation factors for the variables in our model.
library(car)
car::vif(model.saturated)

# predict and write to csv
test_prediction <- as.data.frame(predict(model.saturated, test))
test_prediction <- cbind(test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v1.csv', row.names = FALSE)

############################################################
# Multiple Linear Regression - Even more Simple Model (v7) #
############################################################

# fit the MLR model
temp7_mlr = lm(price_doc ~ . - id
                     -school_km, data = train)

# examine model summary
summary(temp7_mlr)
# Multiple R-squared:  0.46,	Adjusted R-squared:  0.459 

# examine VIF
car::vif(temp7_mlr)

# CV
cv <- cv.lm(train, temp7_mlr, m=3)
attr(cv, "ms")
# 1.24e+13

# predict and write to csv
test_prediction <- as.data.frame(predict(temp7_mlr, test))
test_prediction <- cbind(test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v7.csv', row.names = FALSE)

############################################################
# Multiple Linear Regression - Even more Simple Model (v8) #
############################################################

# fit the MLR model
temp8_mlr = lm(price_doc ~ . - id
               -school_km
               -metro_km_avto
               -public_healthcare_km
               -build_year
               -product_type
               -max_floor, data = train)

# examine model summary
summary(temp8_mlr)
# Multiple R-squared:  0.442,	Adjusted R-squared:  0.441

# examine VIF
car::vif(temp8_mlr)

# CV
cv <- cv.lm(train, temp8_mlr, m=3)
attr(cv, "ms")
# 1.29e+13 

# predict and write to csv
test_prediction <- as.data.frame(predict(temp8_mlr, test))
test_prediction <- cbind(test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v8.csv', row.names = FALSE)

############################################################
# Multiple Linear Regression - v1 without year + 1.05x (v9)#
############################################################

# fit the MLR model
temp9_mlr = lm(price_doc ~ . - id - year, data = train)

# examine model summary
summary(temp9_mlr)

# examine VIF
car::vif(temp9_mlr)

# CV
cv <- cv.lm(train, temp9_mlr, m=3)
attr(cv, "ms")

# predict and write to csv
test_prediction <- as.data.frame(predict(temp9_mlr, test))
test_prediction <- cbind(test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v9.csv', row.names = FALSE)

#############################################################
# Multiple Linear Regression - v1 without year + 1.15x (v10)#
#############################################################
test_prediction <- as.data.frame(predict(temp9_mlr, test))
test_prediction <- cbind(test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v10.csv', row.names = FALSE)

#############################################################
# Multiple Linear Regression - v1 without year + 1.1x (v11) #
#############################################################
test_prediction <- as.data.frame(predict(temp9_mlr, test))
test_prediction <- cbind(test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v11.csv', row.names = FALSE)

#############################################################
# Multiple Linear Regression - v1 without year + 1.075x (v12) #
#############################################################
test_prediction <- as.data.frame(predict(temp9_mlr, test))
test_prediction <- cbind(test$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v12.csv', row.names = FALSE)

#######################################################################
# Multiple Linear Regression - v1 with Regularization - Ridge (v12.1) #
#######################################################################
library(glmnet)
#Need matrices for glmnet() function. Automatically conducts conversions as well
#for factor variables into dummy variables.
x = model.matrix(price_doc ~ . - id, train)[, -1] #Dropping the intercept column.
y = train$price_doc

#Values of lambda over which to check.
grid = 10^seq(15, -20, length = 50)

#Fitting the ridge regression. Alpha = 0 for ridge regression.
ridge.models = glmnet(x, y, alpha = 0, lambda = grid, standardize = TRUE)

#Visualizing the ridge regression shrinkage.
plot(ridge.models, xvar = "lambda", label = TRUE, main = "Ridge Regression")

#Can use the predict() function to obtain ridge regression coefficients for a
#new value of lambda, not necessarily one that was within our grid:
predict(ridge.models, s = 80, type = "coefficients")

#Creating training and testing sets. Here we decide to use a 70-30 split with
#approximately 70% of our data in the training set and 30% of our data in the
#test set.
set.seed(0)
train.ridge = sample(1:nrow(train), 7*nrow(train)/10)
test.ridge = (-train.ridge)
y.test = y[test.ridge]

length(train.ridge)/nrow(train)
length(y.test)/nrow(train)

#Running 10-fold cross validation.
set.seed(0)
cv.ridge.out = cv.glmnet(x[train.ridge, ], y[train.ridge],
                         lambda = grid, alpha = 0, nfolds = 10)
plot(cv.ridge.out, main = "Ridge Regression\n")
bestlambda.ridge = cv.ridge.out$lambda.min
bestlambda.ridge

cv.ridge.out$lambda.min
cv.ridge.out$lambda.1se
coef(cv.ridge.out, s=cv.ridge.out$lambda.min)

#What is the test MSE associated with this best value of lambda?
ridge.bestlambdatrain = predict(ridge.models.train, s = bestlambda.ridge, newx = x[test.ridge, ])
ridge.bestlambdatrain[ridge.bestlambdatrain < 0] = ridge.bestlambdatrain[ridge.bestlambdatrain < 0]*-1
mean((ridge.bestlambdatrain - y.test)^2)
# [1] 3323865688

#Making prediction on the test set
x.test = model.matrix(~ . - id, test)[, -1] #Dropping the intercept column.
ridge.bestlambdatest = predict(ridge.models.train, s = bestlambda.ridge, newx = x.test)

# write to csv
ridge.bestlambdatest <- cbind(test$id, ridge.bestlambdatest)
colnames(ridge.bestlambdatest) <- c('id', 'price_doc')
write.csv(ridge.bestlambdatest, 'prediction_v12.1.csv', row.names = FALSE)

###########
## Lasso ##
###########

#Fitting the lasso regression. Alpha = 1 for lasso regression.
lasso.models = glmnet(x, y, alpha = 1, lambda = grid, standardize = TRUE)

#Visualizing the lasso regression shrinkage.
plot(lasso.models, xvar = "lambda", label = TRUE, main = "Lasso Regression")

#Can use the predict() function to obtain lasso regression coefficients for a
#new value of lambda, not necessarily one that was within our grid:
predict(lasso.models, s = 80, type = "coefficients")

#Creating training and testing sets. Here we decide to use a 70-30 split with
#approximately 70% of our data in the training set and 30% of our data in the
#test set.
set.seed(0)
train.lasso = sample(1:nrow(train), 7*nrow(train)/10)
test.lasso = (-train.lasso)
y.test = y[test.lasso]

length(train.lasso)/nrow(train)
length(y.test)/nrow(train)

#Running 10-fold cross validation.
set.seed(0)
cv.lasso.out = cv.glmnet(x[train.lasso, ], y[train.lasso],
                         lambda = grid, alpha = 1, nfolds = 10)
plot(cv.lasso.out, main = "lasso Regression\n")
bestlambda.lasso = cv.lasso.out$lambda.min
bestlambda.lasso
log(bestlambda.lasso)

#What is the test MSE associated with this best value of lambda?
lasso.bestlambdatrain = predict(cv.lasso.out, s = bestlambda.lasso, newx = x[test.lasso, ])
mean((lasso.bestlambdatrain - y.test)^2)
# [1] 1.263734e+13

#Making prediction on the test set
x.test = model.matrix(~ . - id, test)[, -1] #Dropping the intercept column.
lasso.bestlambdatest = predict(cv.lasso.out, s = bestlambda.lasso, newx = x.test)

###################################################
# Multiple Linear Regression - Variable Selection #
###################################################
library(MASS) 

#We can use stepwise regression to help automate the variable selection process.
#Here we define the minimal model, the full model, and the scope of the models
#through which to search:

model.empty = lm(price_doc ~ 1, data = train) #The model with an intercept ONLY.
model.full = lm(price_doc ~ . - id, data = train) #The model with ALL variables.
scope = list(lower = formula(model.empty), upper = formula(model.full))
#Stepwise regression using AIC as the criteria (the penalty k = 2).
forwardAIC = step(model.empty, scope, direction = "forward", k = 2)
backwardAIC = step(model.full, scope, direction = "backward", k = 2)
bothAIC.empty = step(model.empty, scope, direction = "both", k = 2)
bothAIC.full = step(model.full, scope, direction = "both", k = 2)

#Stepwise regression using BIC as the criteria (the penalty k = log(n)).
forwardBIC = step(model.empty, scope, direction = "forward", k = log(50))
backwardBIC = step(model.full, scope, direction = "backward", k = log(50))
bothBIC.empty = step(model.empty, scope, direction = "both", k = log(50))
bothBIC.full = step(model.full, scope, direction = "both", k = log(50))

#############################
# Random Forest - Fit Model # 
#############################
library(randomForest)
train <- read.csv('train_df.csv')
test <- read.csv('test_df.csv')

rf.train = sample(1:nrow(train), 7*nrow(train)/10)
rf.sberbank = randomForest(price_doc ~ . -id, data = train, subset = rf.train, importance = TRUE)



#################
# Random Forest #
#################
library(randomForest)

# impute NAs as outliers
rf.train_imputed <- train
rf.train_imputed[is.na(rf.train_imputed)] <- -9999999999999

# split data 70%/30% training/test
rf.train = sample(1:nrow(rf.train_imputed), 7*nrow(rf.train_imputed)/10)

# reduce number of sub_areas
sub_area_all <- table(rf.train_imputed$sub_area)
sub_area_30 <- names(sort(sub_area_all, decreasing=TRUE)[1:30])
rf.train_imputed$sub_area <- as.character(rf.train_imputed$sub_area)
rf.train_imputed$sub_area[!rf.train_imputed$sub_area %in% sub_area_30] <- 'Others'
rf.train_imputed$sub_area <- as.factor(rf.train_imputed$sub_area)

# fit Random Forest 
rf.sberbank = randomForest(price_doc ~ full_sq +
                             life_sq +
                             floor +
                             max_floor +
                             build_year +
                             kitch_sq +
                             state +
                             num_room +
                             material +
                             metro_min_avto +
                             kindergarten_km +
                             school_km +
                             industrial_km +
                             sub_area +
                             green_zone_km +
                             railroad_km +
                             metro_km_avto +
                             park_km +
                             radiation_km +
                             area_m,
                           data = rf.train_imputed, subset = rf.train, importance = TRUE)

importance(rf.sberbank)
varImpPlot(rf.sberbank)



# get column classes
# col = sapply(train, class)
# col[col=='factor']
# str(train, list.len=ncol(train))

#################
# Data Cleaning #
#################

cleaning <- read.csv('full_data_kaggle.csv')
cleaning <- cleaning[,-1]

#########################################
# Feature Engineering - floor/max_floor #
#########################################
train$floorratio <- train$floor/train$max_floor
train$topfloor <- ifelse(train$floorratio == 1, '1', '0')

model.saturated = lm(price_doc ~ . - id - build_year, data = train)
summary(model.saturated)

model.saturated = lm(price_doc ~ . - id, data = train)
summary(model.saturated)

car::vif(model.saturated)

library(DAAG)
cv <- cv.lm(train, model.saturated, m=3)
attr(cv, "ms")

# attr(cv, "ms") [1] 1.24e+13

####################
# Create train_df2 #
####################
orig_train <- read.csv('train.csv')
temp <- merge(x = train, y = orig_train[ , c("area_m", 
                                          "raion_popul", 
                                          "metro_min_avto",
                                          "park_km",
                                          "green_zone_km",
                                          "industrial_km",
                                          "public_transport_station_km",
                                          "water_km",
                                          "big_road1_km",
                                          "railroad_km",
                                          "radiation_km",
                                          "fitness_km",
                                          "shopping_centers_km",
                                          "preschool_km",
                                     "id")], by = "id")

write.csv(temp, 'train_df2.csv', row.names = FALSE)


# impute NAs for product type in test set
sample(c('Investment', 'OwnerOccupier'), 33, replace =TRUE)
sample(c('Investment', 'OwnerOccupier'), 33, replace =TRUE)
test$product_type[is.na(test$product_type)] <- sample(c('Investment', 'OwnerOccupier'), 33, replace =TRUE)
test$product_type[is.na(test$product_type)] 

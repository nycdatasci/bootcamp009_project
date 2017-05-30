library(car)

setwd('/Users/clairevignon/DataScience/NYC_DSA/project3_ML_kaggle')

train = read.csv("input/train_cleaned.csv", stringsAsFactors = FALSE)
test = read.csv("input/test_cleaned.csv", stringsAsFactors = FALSE)

##### THIS IS A **SUMMARY** OF ALL THE MODELS I TRIED #####
# The goal is to compare the predictions from Linear model vs Random Forest 
# and make a case for linear regression. This is why in this R document
# I am doing prediction for the training set and looking at error rate
# I added the Kaggle score for the test set as an indicator too.

##### USING LINEAR REGRESSION #####
### ONLY LOOKING AT BEST MODEL FOR LINEAR REGRESSION
# Below is a list of all the different strategy used with linear regression that did not perform as well:
# 1- Linear Regression with feature engineering - SCORE ON KAGGLE:0.39105
# 2- Linear Regression after doing PCA (PCA is described at the very bottom for the curious) - SCORE ON KAGGLE: 0.38651
# 3- Linear Regression with more variables - SCORE ON KAGGLE: 0.40140

# using log price
train$price_doc = log(train$price_doc+1)

# selecting variables (based on Jack's lasso and xgboost Variable Importance)
top_35_reduced = c('price_doc', "full_sq", "kitch_sq", "state", "sub_area", "green_zone_km",
                   "sadovoe_km", "railroad_km", "office_km", "theater_km", "preschool_km", 
                   "public_healthcare_km", "swim_pool_km", "big_church_km",
                   "public_transport_station_km", "kindergarten_km", "hospice_morgue_km")
top_35_reduced_noprice = c("full_sq", "kitch_sq", "state", "sub_area", "green_zone_km",
                           "sadovoe_km", "railroad_km", "office_km", "theater_km", "preschool_km", 
                           "public_healthcare_km", "swim_pool_km", "big_church_km",
                           "public_transport_station_km", "kindergarten_km", "hospice_morgue_km")

train_top35_reduced = subset(train, select= top_35_reduced)
test_top35_reduced = subset(test, select= top_35_reduced_noprice)

# # convert state and sub_area variables to factor
# train_top35_reduced$state = factor(train_top35_reduced$state)
# train_top35_reduced$sub_area = factor(train_top35_reduced$sub_area)
# 
# test_top35_reduced$state = factor(test_top35_reduced$state)
# test_top35_reduced$sub_area = factor(test_top35_reduced$sub_area)

# Impute NA with random for factor variables
sum(is.na(train_top35_reduced$state)) #13559 NAs which is more than 30% of the
# dataset so we will impute with random method
library(Hmisc)
train_top35_reduced$state = impute(train_top35_reduced$state, "random")
test_top35_reduced$state = impute(test_top35_reduced$state, "random")

# we still have a lot of NA for kitchen square. We remove it because 
# it is not an important variable. We have 4 NAs for the full_sq variable. We'll
# remove the 4 observations
library(dplyr)
train_top35_reduced = select(train_top35_reduced,-kitch_sq)
train_top35_reduced = train_top35_reduced[!is.na(train_top35_reduced$full_sq),]

model_2 = lm(price_doc ~ ., data = train_top35_reduced)

summary(model_2)
vif(model_2)

# VIF is higher than 5 for preschool_km, public_healthcare_km, swim_pool_km, big_church_km ,
# public_transport_station_km, kindergarten_km, hospice_morgue_km, sadovoe_km so removing them
model_2a = update(model_2, ~ . - preschool_km - theater_km -
                    public_healthcare_km - sadovoe_km - swim_pool_km - 
                    public_transport_station_km - kindergarten_km - 
                    hospice_morgue_km - big_church_km )
summary(model_2a)
vif(model_2a)

# look at prediction on training (for presentation purposes)
mean(model_2a$residuals^2) # looking at mse

prediction_1 = predict(model_2a, train_top35_reduced) 
prediction_1 = exp(prediction_1)-1
prediction_1 = data.frame(linearprediction=prediction_1)
write.csv(prediction_1, "prediction_train_lnr.csv", row.names=F)

## Predicting for test dataset
prediction = data.frame(id=test$id, price_doc=prediction)

#### SCORE ON KAGGLE: 0.35198 (BEST SCORE)

###### RANDOM FOREST #####
# using the same features as the best performing model in linear regression 
# with a random forest model
library(randomForest)

train_top35_reduced$sub_area = factor(train_top35_reduced$sub_area)
train_top35_reduced$state = factor(train_top35_reduced$state)

# Some sub_areas are in the train but not the test datasets and vice versa.
# When we dummify, the levels will be different between the test and train. 
# To make sure the levels are the same, we will combine test and training sets as 
# one set (before dummifying).

# before combining the 2 sets, we need to use a label that will differentiate them
# adding a column in each dataset with the label "train" or "test"
train_top35_reduced$label =rep("train", dim(train_top35_reduced)[1])
train_top35_reduced = select(train_top35_reduced, - price_doc) # removing price_doc variable
# (as it is not in the test dataset)

test_top35_reduced$label =rep("test", dim(test_top35_reduced)[1])
test_top35_reduced = select(test_top35_reduced, - kitch_sq) # removing the kitch_sq variable
# (as it is not in the train dataset)

totalData = rbind(train_top35_reduced, test_top35_reduced)

library(psych)
x = dummy.code(totalData$sub_area)
totalData = select(totalData, -sub_area)
totalData = cbind(totalData,x)

# resplitting into 2 datasets
split = split(totalData , f = totalData$label)
test_top35_reduced_2 = split[[1]]
train_top35_reduced_2 = split[[2]]

# remove label column
test_top35_reduced_2 = select(test_top35_reduced_2, -label)
train_top35_reduced_2 = select(train_top35_reduced_2, -label)

# add price back to train dataset
train_top35_reduced = as.data.frame(train_top35_reduced_2, train_top35_reduced$price_doc)
test_top35_reduced = test_top35_reduced_2 # rename dataset for consistency

# library(psych)
# x = dummy.code(train_top35_reduced$sub_area)
# train_top35_reduced = select(train_top35_reduced, -sub_area)
# train_top35_reduced = cbind(train_top35_reduced,x)

# we need to replace white space and other special characters in column name for our RF to work
names(train_top35_reduced) = gsub(x = names(train_top35_reduced), pattern = "'", replacement = "_") 
names(train_top35_reduced) = gsub(x = names(train_top35_reduced), pattern = " ", replacement = "_") 
names(train_top35_reduced) = gsub(x = names(train_top35_reduced), pattern = "-", replacement = "_") 

rf.house = randomForest(price_doc ~ .  - preschool_km - theater_km -
                          public_healthcare_km - sadovoe_km - swim_pool_km - 
                          public_transport_station_km - kindergarten_km - 
                          hospice_morgue_km - big_church_km, 
                        data = train_top35_reduced, importance = TRUE)

treepredictions = predict(rf.house,train_top35_reduced)
D = as.data.frame(treepredictions)

mean((D$treepredictions-train_top35_reduced$price_doc)^2) # looking at MSE: 0.07
plot(sort(exp(D$treepredictions)))

median(D$treepredictions)

D$treepredictions= exp(D$treepredictions)-1 # transforming price back
write.csv(D, "prediction_train_rf.csv", row.names=F)

# Repeated process for test 
test_top35_reduced$sub_area = factor(test_top35_reduced$sub_area)
test_top35_reduced$state = factor(test_top35_reduced$state)

# update the column names for test dataset too
names(test_top35_reduced) = gsub(x = names(test_top35_reduced), pattern = "'", replacement = "_") 
names(test_top35_reduced) = gsub(x = names(test_top35_reduced), pattern = " ", replacement = "_") 
names(test_top35_reduced) = gsub(x = names(test_top35_reduced), pattern = "-", replacement = "_") 

treepredictions = predict(rf.house,test_top35_reduced)
D = as.data.frame(treepredictions)

D$treepredictions= exp(D$treepredictions)-1 # transforming price back
write.csv(D, "prediction_2.csv", row.names=F)
#### SCORE ON KAGGLE: 0.35346

##### TUNING RANDOM FOREST #####
### METHOD 1 - Change mtry to square root of p
metric = "RMSE"
mtry = sqrt(ncol(train_top35_reduced))

rf.house_tuned = randomForest(price_doc ~ .  - preschool_km - theater_km -
                          public_healthcare_km - sadovoe_km - swim_pool_km - 
                          public_transport_station_km - kindergarten_km - 
                          hospice_morgue_km - big_church_km, 
                        data = train_top35_reduced, importance = TRUE, mtry=mtry, metric = metric)

treepredictions_2 = predict(rf.house_tuned,train_top35_reduced)
D_2 = as.data.frame(treepredictions_2)

mean((D_2$treepredictions_2 - train_top35_reduced$price_doc)^2) # looking at MSE: 0.15

D_2$treepredictions= exp(D_2$treepredictions_2)-1 # transforming price back
D_2 = as.data.frame(D_2$treepredictions, id=test$id)
colnames(D_2) = c("price_rf_2")
write.csv(D_2, "prediction_train_rf_2.csv", row.names=F)

# predicting for test
treepredictions_test_2 = predict(rf.house_tuned,test_top35_reduced)
D_test_2 = as.data.frame(treepredictions_test_2)
D_test_2$treepredictions= exp(D_2$treepredictions_test_2)-1 # transforming price back
D_test_2 = as.data.frame(D_test_2$treepredictions, id=test$id)
colnames(D_2) = c("price_doc")
write.csv(D_2, "prediction_rf_2.csv", row.names=F)

### METHOD 2 - Create categories out for continuous variables
# Skipping this one for time purposes.

##### VISUALIZATION #####
library(dplyr)
library(ggplot2)

setwd('/Users/clairevignon/DataScience/NYC_DSA/project3_ML_kaggle')

linear = read.csv("prediction_train_lnr.csv", stringsAsFactors = FALSE)
rf = read.csv("prediction_train_rf.csv", stringsAsFactors = FALSE)
rf_2 = read.csv("prediction_train_rf_2.csv", stringsAsFactors = FALSE)
train = read.csv("input/train_cleaned.csv", stringsAsFactors = FALSE)

# remove the rows where full_sq was Nan as we removed them from other datasets
train = train[!is.na(train$full_sq),]

# combine all the datasets into 1
df = cbind(linear, rf, rf_2, train)

# for the graph, we would like to distinguish points by color
# we will need to do a rbind and distinguish price from linear model vs price
# from rf
# adding an extra column as a label
linear$label = rep("lnr",dim(linear)[1])
rf$label = rep("rf",dim(rf)[1])
rf_2$label = rep("rf_2",dim(rf_2)[1])
train_2 = train$price_doc

# making copies before combining dataset and changing column names
linear_1 = linear
rf_1 = rf
rf_2a = rf_2

colnames(linear_1) <- c("price", "label")
colnames(rf_1) <- c("price", "label")
colnames(rf_2a) <- c("price", "label")

df_bind = rbind(linear_1, rf_1, rf_2a)
df_bind = cbind(df_bind, train_2) # add column wih actual price

colnames(df_bind) <- c("price", "label", "price_doc")

# plotting each prediction vs. actual on a separate chart
ggplot(df, aes(price_doc, price_linear)) +
  geom_point() +
  theme(panel.background = element_blank()) +
  labs(x = "Actual Price", y = "Predicted Price") +
  geom_abline(slope=1, intercept=0, color = "red")

ggplot(df, aes(price_doc, price_rf)) +
  geom_point() +
  theme(panel.background = element_blank()) +
  labs(x = "Actual Price", y = "Predicted Price") +
  geom_abline(slope=1, intercept=0, color = "red")

ggplot(df, aes(price_doc, price_rf_2)) +
  geom_point() +
  theme(panel.background = element_blank()) +
  labs(x = "Actual Price", y = "Predicted Price") +
  geom_abline(slope=1, intercept=0, color = "red")

# plotting prediction and actual for 1st rf & linear model on same plot
rf_lnr_plot = filter(df_bind, label %in% c("rf", "lnr"))

ggplot(rf_lnr_plot, aes(price_doc, price, color = label, alpha = 0.1)) +
  geom_point() +
  theme(panel.background = element_blank()) +
  labs(x = "Actual Price", y = "Predicted Price") +
  scale_color_manual(labels = c("Linear", "RF mtry: 53"), values=c("#999999", "#E69F00")) +
  geom_abline(slope=1, intercept=0, color = "grey") +
  scale_alpha(guide = 'none')

# plotting prediction and actual for the 2 RFs on same plot
rf_x2_plot = filter(df_bind, label %in% c("rf", "rf_2"))

ggplot(rf_x2_plot, aes(price_doc, price, color = label, alpha = 0.1)) +
  geom_point() +
  theme(panel.background = element_blank()) +
  labs(x = "Actual Price", y = "Predicted Price") +
  geom_abline(slope=1, intercept=0, color = "grey") +
  scale_color_manual(labels = c("RF mtry: 53", "RF mtry: 12"), values=c("#E69F00", "#56B4E9")) +
  scale_alpha(guide = 'none')

# plotting prediction and actual for the 3 models on same plot
ggplot(df_bind, aes(price_doc, price, color = label, alpha = 0.05)) +
  geom_point() +
  theme(panel.background = element_blank()) +
  labs(x = "Actual Price", y = "Predicted Price") +
  scale_color_manual(labels = c("Linear", "RF mtry: 53", "RF mtry: 12"), values=c("#999999", "#E69F00", "#56B4E9")) +
  geom_abline(slope=1, intercept=0, color = "grey") +
  scale_alpha(guide = 'none')

# checking if all the factor variables were both in training and testing sets
# RF does not predict beyond the range of the training data so this would be a way to check
# for the graph, we would like to distinguish data for train and test set
# we will need to do a rbind and distinguish data between test & train by adding a column
train_top35 = train_top35_reduced
test_top35 = test_top35_reduced

train_top35$label = rep("train", 30428)
test_top35$label = rep("test",7662)


train_test = rbind(select(train_top35,-price_doc), select(test_top35,-kitch_sq))
ggplot(train_test, aes(state, fill = label)) + geom_bar() +
  theme(panel.background = element_blank())

train_test = rbind(select(train_top35,-price_doc), select(test_top35,-kitch_sq))
ggplot(train_test, aes(sub_area, fill = label)) + geom_bar() +
  theme(panel.background = element_blank())

# only 2 sub_areas were not in test set. They included 1 observation each so they would
# be the main cause of the underperformance of RF



##### PCA #####
# Here is the code I ran for the PCA. I applied results from PCA to a linear regression model
setwd('/Users/clairevignon/DataScience/NYC_DSA/project3_ML_kaggle')
train = read.csv("input/train_cleaned.csv", stringsAsFactors = FALSE)
test = read.csv("test_cleaned.csv", stringsAsFactors = FALSE)

# using log
train$price_doc = log(train$price_doc+1)

# grab only a few numeric variables from train dataset to test PCA
sapply(train, class)
pca_features = c("full_sq", "life_sq", "kitch_sq",
                 "num_room", "big_church_km", "preschool_km", 
                 "cafe_avg_price_500", "big_road2_km", "green_zone_km",
                 "kindergarten_km", "catering_km", "big_road1_km", 
                 "public_healthcare_km", "hospice_morgue_km", "swim_pool_km", 
                 "green_part_1000", "railroad_km", "industrial_km", 
                 "cemetery_km", "fitness_km", "theater_km", "radiation_km",
                 'area_m', 'children_preschool', 'preschool_quota', 
                 'preschool_education_centers_raion', 'children_school', 
                 'school_quota', 'school_education_centers_raion', 
                 'school_education_centers_top_20_raion', 
                 'university_top_20_raion', 'additional_education_raion', 
                 'additional_education_km', 'university_km',
                 'nuclear_reactor_km', 'thermal_power_plant_km', 
                 'power_transmission_line_km', 'incineration_km',
                 'water_treatment_km', 
                 'railroad_station_walk_km', 'railroad_station_walk_min',
                 'railroad_station_avto_km', 'railroad_station_avto_min', 
                 'public_transport_station_km', 'public_transport_station_min_walk', 
                 'water_km', 'mkad_km', 'ttk_km', 'sadovoe_km','bulvar_ring_km',
                 "price_doc", "id")
# Starting small; not all the numeric data is here, e.g. cafes, etc. 

train_pca = subset(train, select = pca_features) # not working because there are 
                                                # items that are highly correlated. 

# checking the highly correlated items with correlation matrix
cm = cor(train_pca, method = "pearson")
dim(cm) # 52 x 52 matrix

for(i in which(cm==1)){ # looking for highly correlated items (could change from 1 to 0.99 if needed)
  if(i%%52 != (i%/%52+1)){
    print(i)
  }
}

# look for rows and columns of highly correlated items 
# i.e. 2281, 2332, 2704
2281 %/% 52 # find row
2281 %% 52 # find column
cm[43:44, 45:46] # correlation between public_transport_station_min_walk and public_transport_station_km 

2332 %/% 52 # find row
2332 %% 52 # find column
cm[44:45, 44:45] # correlation between public_transport_station_min_walk and public_transport_station_km 

## update the features by removing one of the highly correlated features
# remove 'public_transport_station_min_walk' and 'railroad_station_walk_min'
pca_features = pca_features[pca_features != c('public_transport_station_min_walk', 'railroad_station_walk_min')]
# removing price for the test subset
pca_features_test = pca_features[pca_features!= 'price_doc']

# applying features to dataset
train_pca = subset(train, select = pca_features)
test_pca = subset(test, select = pca_features_test)


library(psych)
# Impute NAs
sum(is.na(train_pca)) # 52734 missing values

# impute NAs by median 
f=function(x){
  x = as.numeric(as.character(x)) #first convert each column into numeric if it is from factor
  x[is.na(x)] =median(x, na.rm=TRUE) #convert the item with NA to median value from the column
  x #display the column
}
train_pca=data.frame(apply(train_pca,2,f))
test_pca=data.frame(apply(test_pca,2,f))

# remove price and ID from dataframe
# train_pca_noprice = train_pca[ , names(train_pca) != "price_doc"]
train_pca_noprice = train_pca[ , !names(train_pca) %in% c("price_doc", "id")]

fa.parallel(train_pca_noprice, 
            fa = "pc", 
            n.iter = 100)
abline(h = 1)
# graph shows that 10 PCs is about the right number

pc_train_pca_noprice = principal(train_pca_noprice, 
                                   nfactors = 10,
                                   rotate = "none")
pc_train_pca_noprice

# visualizing PCs   
factor.plot(pc_train_pca_noprice)

library(ggbiplot)
train_pca_biplot = prcomp(train_pca_noprice, scale. = TRUE)

ggbiplot(train_pca_biplot, obs.scale = 1, var.scale = 1,
      ellipse = TRUE, circle = TRUE) +
  scale_color_discrete(name = '') +
  theme(legend.direction = 'horizontal', legend.position = 'top')

# predicting on test data using the PCs we uncovered 
# a few points to remember:
# 1- We can not combine the train and test set to obtain PCA components of whole data at once. 
# Because, this would violate the entire assumption of generalization since test data would get ‘leaked’ into the training set. 
# 2- We can not perform PCA on test and train data sets separately. Because, the resultant vectors 
# from train and test PCAs will have different directions ( due to unequal variance). 
# Due to this, we’ll end up comparing data registered on different axes. 
# Therefore, the resulting vectors from train and test data should have same axes.

# So we need to do exactly the same transformation to the test set as we did to training set:

## apply to linear model
library(caret)
ctrl_1 = trainControl(preProcOptions = list(pcaComp = 10))

md_1 = train(price_doc ~ . - id , data = train_pca,
             method = 'lm', # change if plug in another model
             preProc = 'pca',
             trControl = ctrl_1)

# # Other way to do it:
# md = train(price_doc ~ ., data = train_pca_2,
#            method = 'lm',
#            preProc = c('medianImpute', 'pca'), # can do computation automatically here
#            trControl = ctrl) # specify the kind of CV we want to use

# see how it performs on train first
prediction_pca_train = predict.train(md_1, newdata=train_pca)
D = as.data.frame(prediction_pca_train)
mean((D$prediction_pca_train - train_pca$price_doc)^2) # looking at MSE (0.25)

# now on to the test data
prediction_pca_1 = predict.train(md_1, newdata=test_pca)
prediction_pca_1 = exp(prediction_pca_1)-1
prediction_pca_1 = data.frame(id=test$id, price_doc=prediction_pca_1)
write.csv(prediction_pca_1, "prediction_pca_2.csv", row.names=F)

#### SCORE ON KAGGLE: 0.38651
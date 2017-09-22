#Loading data

train_full = read.csv('train_df2.csv')
test_full = read.csv('test_df2.csv')


# creating a sub set with selected features for the model
test_full = test_full[c('id',"kindergarten_km","school_km",
                        "metro_km_avto","public_healthcare_km",
                        "month","year","sub_area","full_sq","build_year",
                        "floor","max_floor","product_type","area_m",
                        "raion_popul","metro_min_avto","park_km",
                        "green_zone_km","industrial_km",
                        "public_transport_station_km","water_km"
                        ,"big_road1_km","railroad_km","radiation_km",
                        "fitness_km","shopping_centers_km","preschool_km")]

#Loading the tree library for fitting classification and regression trees.
library(tree)

#Splitting the data into training and test sets by an 70% - 30% split.
set.seed(0)
train = sample(1:nrow(train_full), 7*nrow(train_full)/10) #Training indices.
Carseats.test = train_full[-train, ] #Test dataset.
price.test = train_full$price_doc[-train] #Test response.

##########################
#####Regression Trees#####
##########################

#Training the tree to predict the median value of prices of housing in Russia.
tree.russia = tree(price_doc ~ . -id , train_full, subset = train)
summary(tree.russia)

# got this error. neet do subset more sub area. will keep 15 unique values
#Error in tree(price_doc ~ . - id, train_full, subset = train) : 
#  factor predictors must have at most 32 levels

#creating a list of the top 15 sub_area, all the others will be subset to other
top_sub = (train_full %>% 
  group_by(sub_area) %>% 
  summarise(count = n()) %>% 
  arrange(-count))[1:15,1]

#changing the class of sub area to character in order to change its values
train_full$sub_area = as.character(train_full$sub_area)

#changing the values of the sub areas that are not the top 15
train_full$sub_area = ifelse(train_full$sub_area %in% top_area, 
                             train_full$sub_area,
                             'other')

top_area = c("other","Poselenie Sosenskoe",
             "Nekrasovka","Poselenie Vnukovskoe",
             "Poselenie Moskovskij","Poselenie Voskresenskoe",
             "Mitino","Tverskoe","Krjukovo","Mar'ino",
             "Poselenie Filimonkovskoe","Juzhnoe Butovo",
             "oselenie Shherbinka","Solncevo","Zapadnoe Degunino")

# changing the class of sub area to factor
train_full$sub_area = as.factor(train_full$sub_area)
  
# Trying to train the tree to predict the median value of prices of housing in Russia.
tree.russia = tree(price_doc ~ . -id , train_full, subset = train)
summary(tree.russia)  


#Visually inspecting the regression tree.
plot(tree.russia)
text(tree.russia, pretty = 0)


#Performing cross-validation.
set.seed(0)
cv.russia = cv.tree(tree.russia)
par(mfrow = c(1, 2))
plot(cv.russia$size, cv.russia$dev, type = "b",
     xlab = "Terminal Nodes", ylab = "RSS")
plot(cv.russia$k, cv.russia$dev, type  = "b",
     xlab = "Alpha", ylab = "RSS")

cv.russia


#Pruning the tree to have 9 terminal nodes.
prune.russia = prune.tree(tree.russia, best = 9)
par(mfrow = c(1, 1))
plot(prune.russia)
text(prune.russia, pretty = 0)


#Calculating and assessing the MSE of the test data on the overall tree.
yhat = predict(tree.russia, newdata = train_full[-train, ])
yhat
russia.test = train_full[-train, "price_doc"]
russia.test
# 6.13e+13
plot(yhat, russia.test)
abline(0, 1)
mean((yhat - russia.test)^2)
#1.17e+13


#Pruning the tree to have 4 terminal nodes.
prune.russia = prune.tree(tree.russia, best = 4)
par(mfrow = c(1, 1))
plot(prune.russia)
text(prune.russia, pretty = 0)


#Calculating and assessing the MSE of the test data on the overall tree.
yhat = predict(tree.russia, newdata = train_full[-train, ])
yhat
russia.test = train_full[-train, "price_doc"]
russia.test
plot(yhat, russia.test)
abline(0, 1)
mean((yhat - russia.test)^2)
#1.17e+13


##################################
#####Bagging & Random Forests#####
##################################
library(randomForest)

set.seed(0)
rf.russia = randomForest(price_doc ~ . -id, data = train_full, subset = train, importance = TRUE)
# 20 minutes of processing

rf.russia
#Type of random forest: regression
#Number of trees: 500
#No. of variables tried at each split: 9

#Mean of squared residuals: 7.92e+12
#% Var explained: 65.7

#Can visualize a variable importance plot.
importance(rf.russia)
varImpPlot(rf.russia)


#%IncMSE IncNodePurity
#id                            22.37      1.53e+16
#kindergarten_km               21.52      1.02e+16
#school_km                     19.11      8.46e+15
#metro_km_avto                 19.64      1.42e+16
#public_healthcare_km          17.70      1.33e+16
#month                          4.62      4.02e+15
#year                          12.02      4.15e+15
#sub_area                      28.61      8.59e+15
#full_sq                      159.23      2.06e+17
#build_year                    31.19      1.54e+16
#floor                          9.03      8.03e+15
#max_floor                     19.07      1.30e+16
#product_type                  11.60      1.59e+15
#area_m                        13.25      6.63e+15
#raion_popul                   19.93      1.66e+16
#metro_min_avto                16.35      1.51e+16
#park_km                       17.17      1.43e+16
#green_zone_km                 20.89      8.81e+15
#industrial_km                 16.43      1.17e+16
#public_transport_station_km   18.08      8.45e+15
#water_km                      16.66      7.58e+15
#big_road1_km                  21.02      1.11e+16
#railroad_km                   18.48      8.98e+15
#radiation_km                  14.22      1.76e+16
#fitness_km                    11.56      1.05e+16
#shopping_centers_km           27.39      9.93e+15
#preschool_km                  16.83      8.65e+15


##################
#####Boosting#####
##################
library(gbm)

#Fitting 10,000 trees with a depth of 4. process takes 10 minutes
set.seed(0)
boost.russia = gbm(price_doc ~ . -id, data = train_full[train, ],
                   distribution = "gaussian",
                   n.trees = 10000,
                   interaction.depth = 4)


#Inspecting the relative influence.
par(mfrow = c(1, 1))
summary(boost.russia)

#var rel.inf
#full_sq                                         full_sq 61.8930
#radiation_km                               radiation_km  5.5744
#raion_popul                                 raion_popul  4.2744
#park_km                                         park_km  3.2407
#sub_area                                       sub_area  2.9031
#public_healthcare_km               public_healthcare_km  2.8645
#metro_km_avto                             metro_km_avto  2.2818
#build_year                                   build_year  2.0321
#fitness_km                                   fitness_km  2.0317
#year                                               year  1.8118
#metro_min_avto                           metro_min_avto  1.4656
#industrial_km                             industrial_km  1.3381
#shopping_centers_km                 shopping_centers_km  1.3051
#green_zone_km                             green_zone_km  1.2934
#kindergarten_km                         kindergarten_km  1.0635
#max_floor                                     max_floor  0.9342
#public_transport_station_km public_transport_station_km  0.7781
#railroad_km                                 railroad_km  0.7049
#floor                                             floor  0.5532
#big_road1_km                               big_road1_km  0.5317
#preschool_km                               preschool_km  0.3817
#area_m                                           area_m  0.2186
#school_km                                     school_km  0.2106
#product_type                               product_type  0.1609
#water_km                                       water_km  0.0910
#month                                             month  0.0617



#Let’s make a prediction on the test set. With boosting, the number of trees is
#a tuning parameter; having too many can cause overfitting. In general, we should
#use cross validation to select the number of trees. Instead, we will compute the
#test error as a function of the number of trees and make a plot for illustrative
#purposes.
n.trees = seq(from = 100, to = 10000, by = 100)
predmat = predict(boost.russia, newdata = train_full[-train, ], n.trees = n.trees)

#Produces 100 different predictions for each of the 9142 observations in our
#test set.
dim(predmat)


#Calculating the boosted errors.
par(mfrow = c(1, 1))
berr = with(train_full[-train, ], apply((predmat - train_full$price_doc)^2, 2, mean))
plot(n.trees, berr, pch = 16,
     ylab = "Mean Squared Error",
     xlab = "# Trees",
     main = "Boosting Test Error")

#Increasing the shrinkage parameter; a higher proportion of the errors are
#carried over.
set.seed(0)
boost.russia2 = gbm(price_doc ~ . -id, data = train_full[train,],
                    # distribution = "gaussian",
                    n.trees = 1000,
                    interaction.depth = 4,
                    shrinkage = 0.1) # larger lambda - trying to loss the error faster
predmat2 = predict(boost.russia2, newdata = train_full[train,], n.trees = n.trees)


berr2 = with(train_full[train, ], apply((predmat2 - train_full$price_doc)^2, 2, mean))
plot(n.trees, berr2, pch = 16,
     ylab = "Mean Squared Error",
     xlab = "# Trees",
     main = "Boosting Test Error")

predmat2 =as.data.frame(predmat2)
# predict and write to csv 1000 0.36796
test_prediction <- as.data.frame(predmat2$`1000`)
test_prediction <- cbind(test_full$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v13.csv', row.names = FALSE)


test_prediction <- as.data.frame(predmat2$`700`) #0.36846
test_prediction <- cbind(test_full$id, test_prediction)
colnames(test_prediction) <- c('id', 'price_doc')
write.csv(test_prediction, 'prediction_v16.csv', row.names = FALSE)
  
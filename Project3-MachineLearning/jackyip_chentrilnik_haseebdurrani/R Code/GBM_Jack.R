######################################
## Kaggle - Gradient Boosting Trees ##
######################################

#load train_df3 and test_df3
train <- read.csv('train_df3.csv')
test  <- read.csv('test_df3.csv')

#load caret
library(caret)
library(mboost)

#drop timestamp as they are causing trouble for boosting
train <- train[ , !(names(train) %in% c('timestamp'))]
test  <- test[ , !(names(test) %in% c('timestamp'))]

# set up fitControl
fitControl <- trainControl(method = "repeatedcv", number = 2, repeats = 1)

# fit Boosting with 47 features, 150 trees and depth 3
gbmFit <- train(price_doc ~ . - id, 
                 data = train, 
                 method = "gbm",
                 tuneGrid=expand.grid(
                   n.trees=150,
                   interaction.depth=3,
                   shrinkage=.1,
                   n.minobsinnode = 10
                 ),
                 trControl = fitControl,
                 verbose = FALSE)

gbm_pred <- cbind(test$id, as.data.frame(predict(gbmFit, test)))
colnames(gbm_pred) <- c('id', 'price_doc')
write.csv(gbm_pred, 'prediction_v17.csv', row.names = FALSE)

# Variable Importance
gbmImp <- varImp(gbmFit, scale = TRUE)
gbmImp
plot(gbmImp, top = 20)

# Reduce features to top 20 importance
train_2 <- train[ , (names(train) %in% c('id', 'price_doc', 'full_sq', 'radiation_km', 'park_km', 'raion_popul', 'build_year', 'metro_km_avto', 'public_healthcare_km', 'fitness_km', 'big_road1_km', 'shopping_centers_km', 'industrial_km', 'eurrub', 'metro_min_avto', 'max_floor', 'kindergarten_km', 'railroad_km'))]
test_2  <- test[ , (names(test) %in% c('id', 'full_sq', 'radiation_km', 'park_km', 'raion_popul', 'build_year', 'metro_km_avto', 'public_healthcare_km', 'fitness_km', 'big_road1_km', 'shopping_centers_km', 'industrial_km', 'eurrub', 'metro_min_avto', 'max_floor', 'kindergarten_km', 'railroad_km'))]

# set up fitControl
fitControl <- trainControl(method = "repeatedcv", number = 2, repeats = 1)

# fit Boosting with trees=1000 and depth =3 
gbmFit2 <- train(price_doc ~ . - id, 
                data = train_2, 
                method = "gbm",
                tuneGrid=expand.grid(
                  n.trees=1000,
                  interaction.depth=3,
                  shrinkage=.1,
                  n.minobsinnode = 10
                ),
                trControl = fitControl,
                verbose = FALSE)

gbm_pred <- cbind(test$id, as.data.frame(predict(gbmFit2, test)))
colnames(gbm_pred) <- c('id', 'price_doc')
write.csv(gbm_pred, 'prediction_v18.csv', row.names = FALSE)

# fit Boosting with trees=3000 and depth =4
gbmFit3 <- train(price_doc ~ . - id, 
                 data = train_2, 
                 method = "gbm",
                 tuneGrid=expand.grid(
                   n.trees=3000,
                   interaction.depth=4,
                   shrinkage=.1,
                   n.minobsinnode = 10
                 ),
                 trControl = fitControl,
                 verbose = FALSE)

gbm_pred <- cbind(test$id, as.data.frame(predict(gbmFit3, test)))
colnames(gbm_pred) <- c('id', 'price_doc')
write.csv(gbm_pred, 'prediction_v19.csv', row.names = FALSE)


# For Reference (Tuning Model)
# tuneGrid=expand.grid(
#   n.trees=seq(100, 10000, length=10),
#   interaction.depth=seq(1, 3, length=3),
#   shrinkage=.1,
#   n.minobsinnode = 10
# ),
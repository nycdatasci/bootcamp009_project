#### Let's take a look at the high level sberbank dataset

train <- read.csv("sberbank_train_unclean.csv", header = T, stringsAsFactors = T)
test <- read.csv("sberbank_test_unclean.csv", header = T, stringsAsFactors = T) 

## First look at train. I want to run a regression tree to predict log(price_doc)
colSums(is.na(train))

library(dplyr)

# drop industrial_zone_km cuz they're all missing (I loaded it wrong)
train <- train %>% dplyr::select(-industrial_km, -state)
# do same for test
test <- test %>% dplyr::select(-industrial_km, -state)

# how many complete caes do we have in train
sum(complete.cases(train)) #16088 out of 30471

# convert timesetamp to date
train$timestamp <- as.Date(train$timestamp)
test$timestamp <- as.Date(test$timestamp)

# Include log price_doc and then drop original price_doc because science
train$log_price <- log(train$price_doc)
train <- train %>% select(-price_doc)

# Take care of any factor var with more than 32 factors
#subarea
train <- train %>% dplyr::select(-sub_area)
test <- test %>% dplyr::select(-sub_area)


##########################
#####Regression Tree#####
##########################
library(MASS)
library(tree)

#Creating a training set on 70% of the data.
set.seed(0)
cvtrain = sample(1:nrow(train), 7*nrow(train)/10)

#Training the tree to predict the median value of owner-occupied homes (in $1k).
tree.train = tree(log_price ~ ., train, subset = cvtrain)

summary(tree.train)

#Visually inspecting the regression tree.
plot(tree.train)
text(tree.train, pretty = 0)

#Performing cross-validation.
set.seed(0)
cv.sberbank = cv.tree(tree.train)
par(mfrow = c(1, 2))
plot(cv.sberbank$size, cv.sberbank$dev, type = "b",
     xlab = "Terminal Nodes", ylab = "RSS")
plot(cv.sberbank$k, cv.sberbank$dev, type  = "b",
     xlab = "Alpha", ylab = "RSS")

#Pruning the tree to have 7 terminal nodes.
prune.sberbank = prune.tree(tree.train, best = 7)
par(mfrow = c(1, 1))
plot(prune.sberbank)
text(prune.sberbank, pretty = 0)

#Calculating and assessing the MSE of the test data on the overall tree.
yhat = predict(tree.train, newdata = train[-cvtrain, ])
yhat
tree.test = train[-cvtrain, "log_price"]
tree.test
plot(yhat, tree.test)
abline(0, 1)
mean((yhat - tree.test)^2)

#Calculating and assessing the MSE of the test data on the pruned tree.
yhat = predict(prune.tree, newdata = test)
yhat
plot(yhat, boston.test)
abline(0, 1)
mean((yhat - boston.test)^2)



##################################
#####Bagging & Random Forests#####
##################################
library(randomForest)

#Fitting an initial random forest to the training subset.
# Random Forests don't handle missing values, so just take complete.cases for now
complete_train = train[complete.cases(train),]
cv.complete.train = sample(1:nrow(complete_train), 7*nrow(complete_train)/10)

set.seed(0)
rf.sberbank = randomForest(log_price ~ ., data = complete_train, subset = cv.complete.train,
                           importance = TRUE)
rf.sberbank

#The MSE and percent variance explained are based on out-of-bag estimates,
#yielding unbiased error estimates. The model reports that mtry = 4, which is
#the number of variables randomly chosen at each split. Since we have 13 overall
#variables, we could try all 13 possible values of mtry. We will do so, record
#the results, and make a plot.

#Varying the number of variables used at each step of the random forest procedure.
set.seed(0)
oob.err = numeric(48)
for (mtry in 1:48) {
  fit = randomForest(log_price ~ ., data = complete_train[cv.complete.train, ], mtry = mtry)
  oob.err[mtry] = fit$mse[500]
  cat("We're performing iteration", mtry, "\n")
}

#Visualizing the OOB error.
plot(1:13, oob.err, pch = 16, type = "b",
     xlab = "Variables Considered at Each Split",
     ylab = "OOB Mean Squared Error",
     main = "Random Forest OOB Error Rates\nby # of Variables")

#Can visualize a variable importance plot.
importance(rf.boston) # we only want to look at 2nd column!!!
varImpPlot(rf.boston) # number of rooms in most import one

library(tree)


setwd("~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser")
macro <- read.csv("~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser/macro_merged.csv", stringsAsFactors=FALSE)
macro <- macro[-1]

summary(macro)
#clean up dates
macro$date = as.Date(macro$date)

dateconversion <- function(x){
  return(as.numeric(julian(x,origin = macro$date[1])))
}

macro$date <-  sapply(macro$date,dateconversion)

#simple tree model
tree.macro <- tree(price_doc ~ . -date, data = macro, mindev=0.01)
summary(tree.macro)

names(tree.macro)

plot(tree.macro)
text(tree.macro,  cex=.7)

#new model with test/training set
set.seed(0)
train = sample(1:nrow(macro), 7*nrow(macro)/10) #Training indices.
macro.test = macro[-train, ] #Test dataset.
macro.train = macro[train,] #Test response.

tree.macrotrain <- tree(price_doc ~ . -date, data = macro, subset = train, mindev=0.01)
summary(tree.macrotrain)


plot(tree.macrotrain)
text(tree.macrotrain,  cex=.7)


boston.test = Boston[-train, "medv"]
boston.test
plot(yhat, boston.test)
abline(0, 1)
mean((yhat - boston.test)^2)

tree.pred = predict(tree.macrotrain, macro.test)
plot(macro.test$price_doc, tree.pred)
abline(0, 1)
mean((macro.test$price_doc - tree.pred)^2)

sqrt((1/340)*sum((log(tree.pred+1) - log(1+macro.test$price_doc))**2))

length(tree.pred)

cv.macro = cv.tree(tree.macro)
names(cv.macro)
par(mfrow = c(1, 2))
plot(cv.macro$size, cv.macro$dev, type = "b",
     xlab = "Terminal Nodes", ylab = "RSS")
plot(cv.macro$k, cv.macro$dev, type  = "b",
     xlab = "Alpha", ylab = "RSS")


par(mfrow = c(1, 1))
prune.macro = prune.tree(tree.macro, best = 5)
plot(prune.macro)
text(prune.macro, pretty = 0)

#Random Forest
library(randomForest)
set.seed(0)

rf.macro = randomForest(price_doc ~ .-date, data = macro, subset = train, importance = TRUE)
rf.macro
importance(rf.macro)
varImpPlot(rf.macro)
?importance

rf.macroall = randomForest(price_doc ~ .-date, data = macro, importance = TRUE)
rf.macroall
importance(rf.macroall)

#Apply this to the macro test data
macro_test <- read.csv("~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser/macro_test.csv", stringsAsFactors=FALSE)

macro_test$X <- NULL
macro_test$month <- NULL
macro_test$day <- NULL
macro_test$timestamp <- NULL

macro_test.pred <- predict(rf.macroall, macro_test)
summary(macro_test.pred)



write.csv(cbind(macro_test, macro_test.pred), 'macro_test_pred.csv')

library(dplyr)
importance(rf.macroall)
as.data.frame(importance(rf.macroall)) %>% arrange(IncNodePurity)

library(tree)


setwd("~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser")

sberCC = read.csv('~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser/trainCC.csv', stringsAsFactors = FALSE)

sberCC = select(sberCC, -incineration_raion, -id)



summary(sberCC)
#Convert timestamp colummn to the appropriate format:
sberCC$timestamp = as.Date(sberCC$timestamp)

#add log price
sberCC$logprice <- log(1+sberCC$price_doc)

#Define a function that we can sapply
dateconversion <- function(x){
  return(as.numeric(julian(x,origin = sberCC$timestamp[1])))
}

#Apply to the timestamp column, and refine column
sberCC$timestamp = sapply(sberCC$timestamp,dateconversion)

#simple tree model
library(tree)
tree.train <- tree(logprice ~ .-price_doc, data = sberCC, mindev=0.005)
summary(tree.train)

names(tree.train)

plot(tree.train)
text(tree.train,  cex=.7)

#new model with test/training set
set.seed(0)
train = sample(1:nrow(sberCC), 7*nrow(sberCC)/10) #Training indices.
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

sberCC_nochar = sberCC[,sapply(sberCC, class)!='character']

rf.train = randomForest(logprice ~ .-price_doc-timestamp, data = sberCC_nochar, subset = train, importance = TRUE)
rf.train
importance(rf.train)
class(varImpPlot(rf.train))
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

sapply(train_cleaned, sd, na.rm=TRUE)

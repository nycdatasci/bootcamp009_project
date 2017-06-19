setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/mark/')
source('data_clean_for_models.R')
source('custom_ml_functions.R')
coin = label_volatile_days(0.03)
# Cut the time frame
#coin = coin[coin$X > '2012-01-08',]

# Percentage of missing
sum(is.na(coin))/(nrow(coin)*ncol(coin))

# Find the missingness of each column
sapply(coin, function(x) sum(is.na(x))/length(x))

# Make a general cut on the columns to include
general_cols = c(seq(3,21,by=2), 32:50, 60)
coin = coin[,general_cols]
drop_vols = c(2,3,4,5,6,10)
coin = coin[,-drop_vols]

# Interpolate a few columns
coin$est_trans_vol = na.interp(coin$est_trans_vol)
coin$num_trans = na.interp(coin$num_trans)
coin$median.conf.time = na.interp(coin$median.conf.time)
coin$trade_vol = na.interp(coin$trade_vol)

# Run KNN on this data frame
library(VIM)
coin.imputed = kNN(coin, k=ceil(sqrt(ncol(coin))))
coin = coin.imputed[,1:ncol(coin)]

# Relabel the predicted columns into an either/or scenario
activity_base = coin$activity
coin$activity = ifelse(coin$activity == 'big_gain', 'buy', 'consider')
coin$activity = factor(coin$activity)
coin$activity = relevel(coin$activity, ref = 'consider')

# Split into test and training
slice = floor(0.8*nrow(coin))
coin.train = coin[1:slice,]
coin.test = coin[(slice+1):nrow(coin),]

## Logistic Regression
logit.overall = glm(activity ~ ., family = "binomial", data = coin.train)
library(car)
influencePlot(logit.overall)
plot(logit.overall)

## Do Predictions
ypred.log = predict(logit.overall, coin.test[,-ncol(coin)])
table("Predicted Values" = ypred.log, "True Values" = coin.test$activity)

## SVM
library(e1071)

# scale the features
activity = coin$activity
coin.scale = as.data.frame(scale(coin[, -ncol(coin)]))
coin = cbind(coin.scale, activity)
slice = floor(0.8 * nrow(coin))
coin.train.svm = coin[1:slice, ]
coin.test.svm = coin[(slice+1):nrow(coin), ]

# Tune and pick out the best model
cv.coin.svc.linear = tune(svm,
                          activity ~ .,
                          data = coin.train.svm,
                          kernel = "linear",
                          ranges = list(cost = 10^(seq(-5, 1, length = 50))))

cv.coin.svc.linear

plot(cv.coin.svc.linear$performances$cost,
     cv.coin.svc.linear$performances$error,
     xlab = "Cost",
     ylab = "Error Rate",
     type = "l")

best.linear.model = cv.coin.svc.linear$best.model

# Look at the confidence matrix
summary(best.linear.model)
ypred = predict(best.linear.model, coin.test.svm)
table("Predicted Values" = ypred, "True Values" = coin.test.svm$activity)

##########################################################################################################
## Random Forest
library(randomForest)
 
rf.default = randomForest(activity ~., data = coin.train, importance = TRUE)
rf.default

table(predict(rf.default, coin.test[,-ncol(coin.test)], type = "class"), coin.test$activity)
importance(rf.default)
varImpPlot(rf.default)

# Use my custom made cross validation script and then run it multiple times to create a few plots
result = rfcv_custom(coin.train[,-ncol(coin.train)], coin.train$activity)
svg('rfcv_FS.svg')
plot(result[[1]], type = 'l', main = 'Random Forest OOB Error for Importance Sorted Variables',
     ylab = 'OOB Error', xlab = 'Number of Variables')
for (i in 2:5) {
    result = rfcv_custom(coin.train[,-ncol(coin.train)], coin.train$activity)
    lines(result[[1]])
}
dev.off()

### Retrieve best variable set
result[[1]][is.na(result[[1]])] = 0
nvars = which(result[[1]] == min(result[[1]]))

# Needs to cross validate on the training set 
result <- rfcv(coin[,-ncol(coin)], coin$activity, recursive = T, scale = 'step', step = -1)
#with(result, plot(n.var, error.cv, log="x", type="o", lwd=2))
with(result, plot(n.var, error.cv, type="o", lwd=2))

# Repeat the cross validation 5 times to be sure, recursive means the importance is not recalculated
result2 <- replicate(5, rfcv(coin[,-ncol(coin)], coin$activity, recursive = F, step = -1), simplify=FALSE)
error.cv <- sapply(result2, "[[", "error.cv")
matplot(result2[[1]]$n.var, cbind(rowMeans(error.cv), error.cv), type="l",
        lwd=c(2, rep(1, ncol(error.cv))), col=1, lty=1, xlab="Number of variables", ylab="CV Error")

max_mtry = ncol(coin)-1
num_trees = 500
oob.err = numeric(max_mtry)
for (mtry in 1:max_mtry) {
    fit = randomForest(activity ~ ., data = coin.train, mtry = mtry, ntree = num_trees)
    oob.err[mtry] = fit$err.rate[num_trees, 1]
    cat("We're performing iteration", mtry, "\n")
}

plot(1:max_mtry, oob.err, pch = 16, type = "b",
     xlab = "Variables Considered at Each Split",
     ylab = "OOB Misclassification Rate",
     main = "Random Forest OOB Error Rates\nby # of Variables")

optimal_mtry = which(oob.err == min(oob.err))

rf.default = randomForest(activity ~., data = coin.train, importance = TRUE, mtry = optimal_mtry, 
                          ntree = num_trees)

rf.default
table(predict(rf.default, coin.test[,-ncol(coin.test)], type = "class"), coin.test$activity)

importance(rf.default)
varImpPlot(rf.default)

## Boosting
# library(gbm)
# coin.train$activity = factor(ifelse(coin.train$activity=='consider',0,1))
# coin.test$activity = factor(ifelse(coin.test$activity=='consider',0,1))
# boost.initial = gbm(activity ~ ., data = coin.train,
#                     distribution = "bernoulli",
#                     n.trees = 10000,
#                     interaction.depth = 4,
#                     shrinkage = 0.001)
# 
# #3
# n.trees = seq(from = 100, to = 10000, by = 100)
# boost.predictions = predict(boost.initial,
#                             newdata = coin.test,
#                             n.trees = n.trees,
#                             type = "response")
# boost.predictions = round(boost.predictions)
# # Why did we use round() here?
# 
# #4
# accuracy.boost = numeric(100)
# for (i in 1:100) {
#     accuracy.boost[i] = sum(diag(table(coin.test$activity, boost.predictions[, i])))
# }
# min(which(accuracy.boost == max(accuracy.boost)) * 100)
# 
# #In this setting, we would ultimately choose a boosted model that has 2,100 trees.
# 
# #-----------------------------------------Another way to do it-------------------------------------------#
# acc=rep(0,100)
# for (i in 1:100){
#     acc[i]<-length(which(boost.predictions [,i]==coin.test$activity))/length(coin.test$activity)
# }
# max(acc)
# #[1] 0.8364485981
# which.max(acc)
# # [1] 21 -- so num. of tree = 2,100
# 
# #--------------------------------------------------------------------------------------------------------#
# 
# #5abc
# plot(n.trees, acc, pch = 16, type = "b",
#      xlab = "Number of Trees",
#      ylab = "Accuracy",
#      main = "Accuracy of Boosted Trees")
# abline(h = max(accuracy.boost), lty = 2) #Boosting.
# abline(h = (1 - min(oob.err)), col = "red3", lty = 2) #Random forests.
# abline(h = (113 + 57)/nrow(OJ.test), col = "blue", lty = 2) #Pruned tree.
# legend("bottomright",
#        c("Boosting", "Random Forests", "Pruned Tree"),
#        lwd = 2,
#        lty = 2,
#        col = c("black", "red3", "blue"))

## Clustering AKA Kmeans

wssplot = function(data, nc = 15, seed = 0) {
    wss = (nrow(data) - 1) * sum(apply(data, 2, var))
    for (i in 2:nc) {
        set.seed(seed)
        wss[i] = sum(kmeans(data, centers = i, iter.max = 100, nstart = 100)$withinss)
    }
    plot(1:nc, wss, type = "b",
         xlab = "Number of Clusters",
         ylab = "Within-Cluster Variance",
         main = "Scree Plot for the K-Means Procedure")
}

wssplot(coin.scale)

# Just checking the screeplot but still there is no apparent minimum although I would expect there to be 3
km.coin = kmeans(coin.scale, centers = 4, nstart = 100)



setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/mark/')
source('data_clean_for_models.R')
coin = label_volatile_days(0.03)
# Make a general cut on the columns to include
general_cols = c(seq(3,21,by=2), 32:46, 56)
coin = coin[,general_cols]

# Run KNN on this data frame
library(VIM)
coin.imputed = kNN(coin, k=4)
coin = coin.imputed[,1:26]

# Relabel the predicted columns into an either/or scenario
coin$activity = ifelse(coin$activity == 'big_gain', 'buy', 'consider')
coin$activity = factor(coin$activity)
coin$activity = relevel(coin$activity, ref = 'consider')

## Logistic Regression
logit.overall = glm(activity ~ ., family = "binomial", data = coin)
library(car)
influencePlot(logit.overall)
# what if we want to plot the function?
plot(logit.overall)

## SVM

# scale the features
coin.scale = as.data.frame(scale(coin[, -ncol(coin)]))
coin = cbind(coin.scale, activity)
slice = floor(0.8 * nrow(coin))
coin.train = coin[1:slice, ]
coin.test = coin[(slice+1):nrow(coin), ]

# Tune and pick out the best model
cv.coin.svc.linear = tune(svm,
                          activity ~ .,
                          data = coin.train,
                          kernel = "linear",
                          ranges = list(cost = 10^(seq(-5, 1, length = 100))))

cv.coin.svc.linear

plot(cv.coin.svc.linear$performances$cost,
     cv.coin.svc.linear$performances$error,
     xlab = "Cost",
     ylab = "Error Rate",
     type = "l")

best.linear.model = cv.wine.svc.linear$best.model

# Look at the confidence matrix
summary(best.linear.model)
ypred = predict(best.linear.model, coin.test)
table("Predicted Values" = ypred, "True Values" = coin.test$activity)

# ROC curve?

## Random Forest


### Lasso regression model for the sberbank housing kaggle competition
### Read in proper data set, read in specific columns to draw from data set,
### slice data frame by those columns, scale data, do cross-validation, retrieve model,
### predict pricing data

library(caret)
library(glmnet) 

# Split setwd into two because the path is so long
setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project3-MachineLearning')
setwd('aull_dobbins_ganemccalla_schott/schott/models')

FP = '../../data/train_barebones_price_complete.csv'
train = read.csv(FP, row.names = 'id')

# Also read in test data set
test = read.csv('../../data/test_total_complete.csv', row.names = 'id')

# Handle date columns
train$timestamp = as.numeric(train$timestamp)
test$timestamp = as.numeric(test$timestamp)

# Read in the choice variables to slice by
choice_vars = scan("choice_vars.txt", what=",", sep="\n")
train = train[choice_vars]
# price_doc is not in the test set
test = test[choice_vars[-11]]

# Set up scaling for the lasso regression
preProcessParameters = preProcess(train, method = c('center','scale'))
train = predict(preProcessParameters,train)

preProcessParameters = preProcess(test, method = c('center','scale'))
test = predict(preProcessParameters,test)

# Set the predicted and predictors
y = train$price_doc
x = model.matrix(price_doc ~ ., train)[,-1]

# Must create a new dummy predictor column to use as the formula in the model.matrix
test$dummy = rep(-999,nrow(test))
x.test = model.matrix(dummy ~ ., test)[,-1]

grid = 10^seq(5,-5,length=100)

### Perform lasso regression with caret, using method 'lasso' instead of glmnet
set.seed(0)
train_control = trainControl(method = 'cv', number=10)
tune.grid = expand.grid(lambda = grid, alpha=c(0))
ridge.caret = train(x, y,
                    method = 'glmnet',
                    trControl = train_control, tuneGrid = tune.grid)

### Plot the tuning object:
plot(ridge.caret, xTrans=log)
plot(ridge.caret$

### We see caret::train returns a different result from the
### one by cv.glmnet. By comparing the ridge.caret$results
### and cv.ridge.out$cvm, it's most likely to be rounding and 
### averaging.

### Predicting with the final model
pred = predict.train(ridge.caret, newdata = test)
hist(pred, breaks = 100)
#ean((pred - y[test])^2)



# Alternative method but still needs caret for preprocessing at this point
# Cross validation for lasso regression
#v.lasso.out = cv.glmnet(x, y, lambda = grid, alpha = 1, nfolds = 10)

# Inspect the errors/coefficients
#lot(cv.lasso.out, main = "Lasso Regression\n")
#oef(cv.lasso.out)

# Retrieve the best value of lambda and train the model with it
#estlambda.lasso = cv.lasso.out$lambda.min
#asso.models.train = glmnet(x[train, ], y[train], alpha = 1, lambda = bestlambda.lasso)





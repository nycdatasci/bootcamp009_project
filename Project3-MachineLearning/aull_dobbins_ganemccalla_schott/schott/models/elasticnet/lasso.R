
### Lasso regression model for the sberbank housing kaggle competition
### Read in proper data set, read in specific columns to draw from data set,
### slice data frame by those columns, scale data, do cross-validation, retrieve model,
### predict pricing data

library(caret)
library(glmnet) 

# Handle date columns, change price to numeric, change material and state to factors
# These conversions are after the model.matrix has been turned into a data frame
convert_columns_dummies = function(df) {
    
    #train_raw$timestamp = as.Date(as.character(train$timestamp))
    #test_raw$timestamp = as.Date(test$timestamp)
    #train_raw$price_doc = as.numeric(train$price_doc)
    df$material2 = as.factor(df$material2)
    df$material4 = as.factor(df$material4)
    df$material5 = as.factor(df$material5)
    df$material6 = as.factor(df$material6)
    df$state2 = as.factor(df$state2)
    df$state3 = as.factor(df$state3)
    df$state4 = as.factor(df$state4)
    return(df)
}

# Handle date columns, change price to numeric, change material and state to factors
# These conversions are for the base raw data to insure that the right columns are discounted
# in the standardization
convert_columns_raw = function(df) {
    
    #train_raw$timestamp = as.Date(as.character(train$timestamp))
    #test_raw$timestamp = as.Date(test$timestamp)
    #train_raw$price_doc = as.numeric(train$price_doc)
    df$material = as.factor(df$material)
    df$state = as.factor(df$state)
    return(df)
}

# Split setwd into two because the path is so long
setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project3-MachineLearning')
setwd('aull_dobbins_ganemccalla_schott/schott/models')

FP = '../../data/train_barebones_price_complete.csv'
train_raw = read.csv(FP, row.names = 'id')

# Also read in test data set
test_raw = read.csv('../../data/test_total_complete.csv', row.names = 'id')

# Read in the choice variables to slice by
choice_vars = scan("choice_vars.txt", what=",", sep="\n")
train_raw = train_raw[choice_vars]

# price_doc is not in the test set
test_raw = test_raw[choice_vars[-which(choice_vars == 'price_doc')]]

# convert the state and material columns to factors
train_raw = convert_columns_raw(train_raw)
test_raw = convert_columns_raw(test_raw)

# Must create a new dummy predictor column to use as the formula in the model.matrix
test_raw$dummy = rep(-999,nrow(test_raw))

# Set up scaling for the lasso regression
#preProcessParameters = preProcess(train_raw, method = c('center','scale'))
#train = predict(preProcessParameters,train_raw)

#preProcessParameters = preProcess(test_raw, method = c('center','scale'))
#test = predict(preProcessParameters,test_raw)

# Set the predicted and predictors
y = train_raw$price_doc
x = model.matrix(price_doc ~ ., train)[,-1]
x.test = model.matrix(dummy ~ ., test)[,-1]

grid = 10^seq(10,-2,length=500)

### Perform lasso regression with caret, using method 'lasso' instead of glmnet
set.seed(0)
train_control = trainControl(method = 'cv', number=10)
tune.grid = expand.grid(lambda = grid, alpha=c(1))
ridge.caret = train(x, y,
                    method = 'glmnet',
                    trControl = train_control, tuneGrid = tune.grid)

plot(ridge.caret, xTrans = log)

# It seems that the prices are not what I would expect due to the standardization.
# I've got to "un"standardize the prices 

# Retrieve the coefficients from the best model
bestlambda = as.numeric(ridge.caret$bestTune[2])
coefs = predict(ridge.caret$finalModel, s = bestlambda, type='coefficients')

# Calculate means and standard deviations of test frame for the "un" standardization
#stds = sapply(convert_columns_dummies(data.frame(model.matrix(dummy ~ ., test_raw)[,-1])), 
#              function(x) ifelse(class(x)=='numeric',sd(x),1))

#means = sapply(convert_columns_dummies(data.frame(model.matrix(dummy ~ ., test_raw)[,-1])), 
#              function(x) ifelse(class(x)=='numeric',mean(x),0)) 


# Manually calculate prediction prices, by inverting the standardization 
#predict_prices = function(data, intercept, coefs, stds, means) {
#    pred = numeric(nrow(x.test))
#    for (i in 1:length(pred)) {
#        pred[i] = intercept + sum(x.test[i,] * coefs * stds + means)
#        if (i %% 100 ==0) {
#            print(pred[i])
#        }
#    }
#    return(pred)
#}

#pred = predict_prices(x.test, coefs[1], coefs[-1], stds, means)
lasso.models.train = glmnet(x, y, alpha = 1, lambda = grid)
plot(lasso.models.train, xvar = 'lambda')
set.seed(0)
cv.lasso.out = cv.glmnet(x, y,
                         lambda = grid, alpha = 1, nfolds = 10)
plot(cv.lasso.out, main = "Lasso Regression\n")
bestlambda.lasso = cv.lasso.out$lambda.min
bestlambda.lasso
log(bestlambda.lasso)

#What is the test MSE associated with this best value of lambda?
lasso.bestlambdatrain = predict(lasso.models.train, s = bestlambda.lasso, newx = x.test)
### Predicting with the final model
pred = predict.train(ridge.caret, newdata = x.test)
hist(pred, breaks = 100)

# Write out id numbers and prices to a csv, not working quite right trying to switch to numeric
predictions = as.data.frame(cbind(row.names(test_raw), pred))
names(predictions) = c('id','price_doc')
sapply(predictions, as.numeric)

write.csv(predictions, 'submission_lasso.csv', row.names = F)

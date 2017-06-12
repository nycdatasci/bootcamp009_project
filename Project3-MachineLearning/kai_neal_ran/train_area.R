
library(data.table)
library(tidyverse)
library(dplyr)
library(ggplot2)

dtrain = fread("~/train.csv")
train_area = fread("~/train_area.csv")
test_area = fread("~/test.csv")


price = select(dtrain, price_doc)

rtrain= bind_cols(price, train_area)
dim(rtrain)
View(rtrain)

#A look at the price distribution:
hist(rtrain$price_doc)

#Data cleaning & a Look at missingness:
### 1) A Look at Missingness:
#How many cells in the data are missing values?

sum(is.na(rtrain))
mean(is.na(rtrain)) * 100

sum(is.na(test_area$))

# There are 81,229 missing cells in the entire dataset
# about 1.87% of all cells in the dataset.

#Visualizing missingness:
miss_pct = map_dbl(rtrain, function(x) { round((sum(is.na(x)) / length(x)) * 100, 1) })
miss_pct = miss_pct[miss_pct > 0]
miss.df = data.frame(miss=miss_pct, var=names(miss_pct), row.names=NULL)

miss.df %>% 
  ggplot(aes(x=reorder(var, -miss), y=miss)) + 
  geom_bar(stat='identity', fill='red') +
  labs(x='', y='% missing', title='Percent missing data by feature') +
  theme(axis.text.x=element_text(angle=90, hjust=1))

# 3 variables have over 30% missingness:

#1  43.6  cafe_sum_500_min_price_avg
#2  43.6  cafe_sum_500_max_price_avg
#3  43.6          cafe_avg_price_500

#Removing variables with over 30% missingness:
rtrain$cafe_sum_500_min_price_avg= NULL
rtrain$cafe_sum_500_max_price_avg= NULL
rtrain$cafe_avg_price_500= NULL
dim(rtrain)

test_area$cafe_sum_500_min_price_avg= NULL
test_area$cafe_sum_500_max_price_avg= NULL
test_area$cafe_avg_price_500= NULL
dim(test_area)

#Imputation by the median:
library(caret)
pre = preProcess(rtrain, method = "medianImpute") 
rtrain = predict(pre, rtrain)

pre_test = preProcess(test_area, method= 'medianImpute')
test_area = predict(pre_test, test_area)

#checking imputation:
sum(!complete.cases(rtrain))


#write csv file:
write.csv(rtrain, "clean_train_area.csv")
write.csv(test_area, 'clean_test_area.csv')

#----------------------
#RANDOM FOREST

library(caret)
library(randomForest)


complete_obs = complete.cases(rtrain)
trControl <- trainControl(method='none')


rf_area = train(price_doc ~.,
                method='rf',
                data=rtrain[complete_obs, ],
                trControl= trControl,
                tuneLength=1,
                importance=TRUE)

varImp(rf_area)

#RandomForest Imputation test:
rf_area.imput= train(price_doc ~.,
                     method='rf',
                     data= rtrain,
                     trControl = trControl,
                     tuneLength=1,
                     importance=TRUE)



#> varImp(rf_area)
#rf variable importance

#only 20 most important variables shown (out of 17301)

#Overall
#prom_part_2000               100.00
#prom_part_3000                94.10
#prom_part_1500                93.63
#cafe_sum_2000_max_price_avg   90.27
#green_part_1000               88.70
#office_sqm_5000               86.07
#prom_part_1000                85.77
#office_sqm_1500               84.66
#cafe_count_1500               84.34
#trc_sqm_5000                  84.03
#sport_count_3000              83.77
#cafe_avg_price_2000           82.97
#green_part_5000               82.07
#cafe_count_5000               81.04
#prom_part_5000                80.94
#cafe_count_5000_price_2500    80.54
#cafe_count_1500_price_1000    80.17
#cafe_count_3000_price_1500    80.03
#trc_sqm_2000                  79.89
#sport_count_5000              79.72




#LASSO:

#Need matrices for glmnet() function. Automatically conducts conversions as well
#for factor variables into dummy variables.
library(caret)
library(glmnet) # Make sure imputation is processed before running:
rtrain$price_doc = log(rtrain$price_doc)


x = model.matrix(price_doc ~., data=rtrain)[, -1] #Dropping the intercept column
y = rtrain$price_doc

set.seed(0)
train = sample(1:nrow(x), 8*nrow(x)/10)
test = (-train)
y.test = y[test]
length(train)/nrow(x)
length(y.test)/nrow(x)



lasso.models = glmnet(x[train, ], y[train], alpha = 1, lambda = grid)

plot(lasso.models, xvar = "lambda", label = TRUE, main = "Lasso Regression")

#The coefficients all seem to shrink towards 0 as lambda gets quite large. All
#coefficients seem to go to 0 once the log lambda value gets to about 0. We
#note that in the lasso regression scenario, coefficients are necessarily set
#to exactly 0.

set.seed(0)
cv.lasso.out = cv.glmnet(x[train, ], y[train], alpha = 1, nfolds = 10, lambda = grid)
plot(cv.lasso.out, main = "Lasso Regression\n")
bestlambda.lasso = cv.lasso.out$lambda.min
bestlambda.lasso
log(bestlambda.lasso)

#The error seems to be reduced with a log lambda value of around -4.60517; this
#corresponts to a lambda value of about 0.01. This is the value of lambda
#we should move forward with in our future analyses.

lasso.bestlambdatrain = predict(lasso.models, s = bestlambda.lasso, newx = x[test, ])
mean((lasso.bestlambdatrain - y.test)^2)

#The test MSE is about 0.3181086

lasso.out = glmnet(x, y, alpha = 1)
predict(lasso.out, type = "coefficients", s = bestlambda.lasso)

#The coefficients have been shrunken towards 0. The largest coefficient estimates:
#mosque_count_1000            8.163335e-02
#mosque_count_1500            6.169446e-03
#green_part_1000              7.116660e-06
#ecologygood                  5.438056e-02
#ecologysatisfactory          5.388344e-02
#cafe_count_1000_price_high   5.123018e-03
#cafe_sum_1500_max_price_avg  4.211964e-05
#prom_part_500                3.752917e-04
#cafe_sum_2000_max_price_avg  3.557896e-05
#office_sqm_5000              2.907289e-08
#leisure_count_500            2.567178e-02
#cafe_sum_1000_max_price_avg  2.437866e-05
#sport_count_5000             2.326478e-06
#trc_count_5000               2.098864e-03
#trc_count_1500               2.037594e-03
#sport_count_2000             1.943918e-03
#sport_count_3000             1.879921e-03
#cafe_sum_3000_max_price_avg  1.544276e-05
#trc_count_3000               1.472152e-04
#cafe_count_500_price_1000    1.159128e-03
#mosque_count_5000            1.021517e-02

lasso.bestlambda = predict(lasso.out, s = bestlambda.lasso, newx = x)
mean((lasso.bestlambda - y)^2)

#The overall MSE is: 0.3087766. 
#marginally smaller than the intial MSE


predict(lasso.out, type = "coefficients", s = bestlambda.lasso)
mean((lasso.bestlambda - y)^2)

#Predict lasso.out results:
#mosque_count_1000            8.163335e-02
#green_part_1000              7.116660e-06
#mosque_count_1500            6.169446e-03
#ecologygood                  5.438056e-02
#ecologysatisfactory          5.388344e-02
#cafe_count_1000_price_high   5.123018e-03
#cafe_sum_1500_max_price_avg  4.211964e-05
#prom_part_500                3.752917e-04
#cafe_sum_2000_max_price_avg  3.557896e-05
#office_sqm_5000              2.907289e-08
#leisure_count_500            2.567178e-02
#cafe_sum_1000_max_price_avg  2.437866e-05
#sport_count_5000             2.326478e-06
#trc_count_5000               2.098864e-03
#trc_count_1500               2.037594e-03
#sport_count_2000             1.943918e-03
#sport_count_3000             1.879921e-03
#cafe_sum_3000_max_price_avg  1.544276e-05
#trc_count_3000               1.472152e-04
#cafe_count_500_price_1000    1.159128e-03
#mosque_count_5000            1.021517e-02
#cafe_count_1000_price_4000  -1.278741e-02
#prom_part_1000              -1.064041e-03
#big_church_count_2000       -1.962113e-03
#green_part_5000             -1.286591e-03
#prom_part_2000              -3.522660e-03
#church_count_500            -2.049449e-02
#trc_sqm_500                 -2.821862e-08
#ecologyno data              -6.925263e-02

train_area.vars = rtrain[,c('price_doc', 'mosque_count_1000', 'green_part_1000',
                            'ecology', 'cafe_count_1000_price_high', 'cafe_sum_1500_max_price_avg',
                            'prom_part_500', 'cafe_sum_2000_max_price_avg', 'office_sqm_5000', 
                            'leisure_count_500', 'cafe_sum_1000_max_price_avg', 'sport_count_5000',
                            'trc_count_5000', 'trc_count_1500', 'sport_count_2000', 
                            'sport_count_3000', 'cafe_sum_3000_max_price_avg', 'trc_count_3000',
                            'cafe_count_500_price_1000', 'mosque_count_5000', 'cafe_count_1000_price_4000',
                            'prom_part_1000', 'big_church_count_2000','green_part_5000',
                            'prom_part_2000', 'church_count_500', 'trc_sqm_500')]



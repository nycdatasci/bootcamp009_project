
library(data.table)
library(tidyr)
library(dplyr)
library(ggplot2)
library(tidyverse)

dtrain = fread("~/train.csv")
train_edudemo = fread("~/data/train_edudemo_etc.csv")
test_edudemo = fread("~/test.csv")


price = select(dtrain, price_doc)

edudo_train= bind_cols(price, train_edudemo)
dim(edudo_train)


miss_pct = map_dbl(edudo_train, function(x) { round((sum(is.na(x)) / length(x)) * 100, 1) })
miss_pct = miss_pct[miss_pct > 0]
miss.df = data.frame(miss=miss_pct, var=names(miss_pct), row.names=NULL)

miss.df %>% 
  ggplot(aes(x=reorder(var, -miss), y=miss)) + 
  geom_bar(stat='identity', fill='red') +
  labs(x='', y='% missing', title='Percent missing data by feature') +
  theme(axis.text.x=element_text(angle=90, hjust=1))

#Only one column has over 30% missingness- delete it:
edudo_train$hospital_beds_raion = NULL
edudo_train$V1=NULL
#Data cleaning & a Look at missingness:
### 1) A Look at Missingness:
#How many cells in the data are missing values?

sum(is.na(edudo_train))
#93229

#Imputation by the median:
library(caret)
pre_edudo = preProcess(edudo_train, method = "medianImpute")
edudo_train = predict(pre_edudo, edudo_train)


#checking imputation:
sum(!complete.cases(edudo_train))

#write csv file:
write.csv(edudo_train, "clean_edudo_train.csv")




#Need matrices for glmnet() function. Automatically conducts conversions as well
#for factor variables into dummy variables.
library(caret)
library(glmnet) # Make sure imputation is processed before running:
edudo_train$price_doc = log(edudo_train$price_doc)

x1 = model.matrix(price_doc ~., data=edudo_train)[, -1] #Dropping the intercept column
y1 = edudo_train$price_doc

set.seed(0)
train1 = sample(1:nrow(x1), 8*nrow(x1)/10)
test1 = (-train)
y.test1 = y[test]


grid = 10^seq(5, -2, length = 100)

edudo_lasso.models = glmnet(x1[train1, ], y1[train1], alpha = 1, lambda = grid)

plot(lasso.models, xvar = "lambda", label = TRUE, main = "Lasso Regression")

#The coefficients all seem to shrink towards 0 as lambda gets quite large. All
#coefficients seem to go to 0 once the log lambda value gets to about 0. We
#note that in the lasso regression scenario, coefficients are necessarily set
#to exactly 0.

set.seed(0)
edudo_cv.lasso.out = cv.glmnet(x1[train1, ], y1[train1], alpha = 1, nfolds = 10, lambda = grid)
plot(edudo_cv.lasso.out, main = "Lasso Regression\n")
bestlambda.lasso1 = edudo_cv.lasso.out$lambda.min
bestlambda.lasso1
log(bestlambda.lasso1)

#The error seems to be reduced with a log lambda value of around -4.60517; this
#corresponts to a lambda value of about 0.01. This is the value of lambda
#we should move forward with in our future analyses.

edudo_lasso.bestlambdatrain = predict(edudo_lasso.models, s = bestlambda.lasso1, newx = x1[test1, ])
mean((edudo_lasso.bestlambdatrain - y.test1)^2)

#The test MSE is 0.3319273

lasso.out1 = glmnet(x1, y1, alpha = 1)
predict(lasso.out1, type = "coefficients", s = bestlambda.lasso1)

#The coefficients have been shrunken towards 0. The largest coefficient estimates:
#(Intercept)                            1.565951e+01
#area_m                                -1.713768e-09
#green_zone_part                       -4.316878e-02
#indust_part                           -3.856309e-01
#preschool_quota                       -4.566851e-05
#school_education_centers_raion         1.566260e-02
#school_education_centers_top_20_raion  9.017775e-03
#healthcare_centers_raion               2.871859e-03
#university_top_20_raion                2.871015e-02
#sport_objects_raion                    9.376183e-03
#culture_objects_top_25yes              7.134893e-02
#culture_objects_top_25_raion          -4.963078e-02
#shopping_centers_raion                 2.685688e-03
#oil_chemistry_raionyes                -8.659146e-02
#radiation_raionyes                    -1.356920e-02
#big_market_raionyes                    1.046507e-03
#ekder_male                             6.933864e-06
#X16_29_female                         -6.826903e-08
#build_count_block                     -6.015066e-04
#build_count_frame                     -1.353178e-05
#build_count_monolith                   2.989097e-03
#build_count_mix                       -5.545127e-03


lasso.bestlambda1 = predict(lasso.out1, s = bestlambda.lasso1, newx = x1)
mean((lasso.bestlambda1 - y1)^2)

#The overall MSE is: 0.3321528


predict(lasso.out1, type = "coefficients", s = bestlambda.lasso1)
mean((lasso.bestlambda1 - y1)^2)

#(Intercept)                            1.565951e+01
#area_m                                -1.713768e-09
#green_zone_part                       -4.316878e-02
#indust_part                           -3.856309e-01
#preschool_quota                       -4.566851e-05
#school_education_centers_raion         1.566260e-02
#school_education_centers_top_20_raion  9.017775e-03
#healthcare_centers_raion               2.871859e-03
#university_top_20_raion                2.871015e-02
#sport_objects_raion                    9.376183e-03
#culture_objects_top_25yes              7.134893e-02
#culture_objects_top_25_raion          -4.963078e-02
#shopping_centers_raion                 2.685688e-03
#oil_chemistry_raionyes                -8.659146e-02
#radiation_raionyes                    -1.356920e-02
#big_market_raionyes                    1.046507e-03
#ekder_male                             6.933864e-06
#X16_29_female                         -6.826903e-08
#build_count_block                     -6.015066e-04
#build_count_frame                     -1.353178e-05
#build_count_monolith                   2.989097e-03
#build_count_mix                       -5.545127e-03

edudo_train.vars = edudo_train[,c('area_m', 'green_zone_part', 'indust_part',
                                  'preschool_quota', 'school_education_centers_raion', 'school_education_centers_top_20_raion',
                                  'healthcare_centers_raion', 'university_top_20_raion', "sport_objects_raion",
                                  "culture_objects_top_25", "culture_objects_top_25_raion","shopping_centers_raion", "oil_chemistry_raion",
                                  "radiation_raion", "big_market_raion", "ekder_male", "X16_29_female",
                                  "build_count_block", "build_count_frame", "build_count_monolith", "build_count_mix")]

write.csv(edudo_train.vars, 'edudemo_train.vars.csv')


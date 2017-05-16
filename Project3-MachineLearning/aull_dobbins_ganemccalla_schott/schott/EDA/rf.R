path = ('/data/data/kaggle/sberbank_housing/')

base_data = read.csv(paste0(path,'train.csv'))

# Do a random forest with this data set. Must get rid of missing values. 
set.seed(0)
library(randomForest)
rf.base = randomForest(price_doc ~ ., data = base_data)
rf.base

#2.
#a. training
#Confusion matrix:
#CH  MM class.error
#CH 442  70   0.1367188
#MM  78 266   0.2267442
(442+266)/(442+70+78+266) #82.7%

table(predict(rf.OJ, OJ.test),OJ.test$Purchase)
#b. test
# Confustion matrix:
#CH  MM
#CH 113  23   
#MM  18  60   
(113+60)/(113+23+18+60)#72.5%

#3
importance(rf.OJ)
varImpPlot(rf.OJ)
plot(rf.OJ$importance)
#LoyalCH is the supremo classifying assister

#4
set.seed(0)
oob.err = numeric(17)
for (i in 1:17) {
  fit = randomForest(Purchase ~ ., data=OJ.train, mtry = i)
  oob.err[i] = fit$err.rate[500,1]
}

#5
plot(1:17, oob.err, type = 'b')

#6
oob.err[2]
# Close to 18.9% with 2 variables

#7
### Not sure what the bagged model is in this case. The one with all the variables used?
### I thought the bagged was where you take a bunch of trees with the same variable and 
### take the average of them all when making a prediction.
table(predict(fit, OJ.train),OJ.train$Purchase)
#CH  MM
#CH 519   8
#MM   3 326
(519+326)/848 #99.6%

#8
set.seed(0)
bestfit = randomForest(Purchase ~ ., data=OJ.test, mtry = 2)
bestfit

#9
set.seed(0)
table(predict(fit, OJ.test),OJ.test$Purchase)
#CH  MM
#CH 109  22
#MM  22  61
170/212 # 80%
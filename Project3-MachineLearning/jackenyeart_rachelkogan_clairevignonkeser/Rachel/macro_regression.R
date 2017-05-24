library(dplyr)
library(car)

macro_merged <- read.csv("~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser/macro_merged.csv", stringsAsFactors=FALSE)
View(macro_merged)
X <- macro_merged %>% dplyr::select(cpi, mortgage_rate, usdrub, micex, price_doc)


model = lm(price_doc ~ mortgage_rate + micex, data = X)
summary(model)

plot(model)
influencePlot(model)

vif(model)
avPlots(model)

#apply this model to test set!!

macro_test <- read.csv("~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser/macro_test.csv", stringsAsFactors=FALSE)
View(macro_test)
X_test <- macro_test %>% dplyr::select(cpi, mortgage_rate, usdrub, micex)

macro_test.pred = predict(model, X_test)
macro_test.pred

write.csv(cbind(macro_test, macro_test.pred), 'macro_test_reg_pred.csv')

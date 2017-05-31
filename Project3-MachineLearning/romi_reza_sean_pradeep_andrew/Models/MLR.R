library(data.table)
library(caret)
library(MASS)
library(dplyr)
library(car)
library(VIM)
library(mice)



df = fread('df_important.csv')
View(df)
df$V1 = NULL
summary(df)

dfTrain = df[which(df$dataset == 'train')]
dfTest = df[which(df$dataset == 'test')]
nrow(dfTrain) + nrow(dfTest) == nrow(df) # checks out


cor(Filter(is.numeric, dfTrain), use="pairwise.complete.obs")

aggr(df, col=c('navyblue','red'), numbers=TRUE, sortVars=TRUE, 
     labels=names(data), cex.axis=.7, gap=3,
     ylab=c("Histogram of missing data","Pattern"))
md.pattern(df)

plot(dfTrain)

dfTrain = Filter(is.numeric, dfTrain)
dfTrain$price_doc = NULL
dfTrain$price_doc_log10 = NULL
##########################
model = lm(price_doc_log ~ ., dfTrain)
summary(model)
plot(model)

influencePlot(model)
vif(model)
alias(model)

########################
# drop aliases?
model = lm(price_doc_log ~ .-labor_force - unemployment - employment, dfTrain)
summary(model)
plot(model)

influencePlot(model)
vif(model)
###########################
# drop id
model = lm(price_doc_log ~ .-labor_force - unemployment - employment -
             id, dfTrain)
summary(model)
plot(model)

influencePlot(model)
vif(model)
avPlots(model)
##########################
# forward aic
# first make dfTrain only with complete cases
dfTrain = dfTrain[complete.cases(dfTrain),]
dfTrain$full_sq_squared = dfTrain$full_sq^2

# then define empyt and full models
model.empty = lm(price_doc_log ~ 1, data = dfTrain) #The model with an intercept ONLY.
model.full = lm(price_doc_log ~ . - id-labor_force - unemployment - employment, data = dfTrain) #The model with ALL variables.
scope = list(lower = formula(model.empty), upper = formula(model.full)) # list of models you want to test --> its a range for the models

# now run step
forwardAIC = step(model.empty, scope, direction = "forward", k = 2) 
# result:
# price_doc_log ~ full_sq + kremlin_km + full_sq_squared + state + 
#   floor + usdrub + indust_part + fitness_km + culture_objects_top_25_raion + 
#   cafe_count_5000_price_high + cafe_count_1500_price_500 + 
#   school_education_centers_raion + trc_sqm_5000 + salary + 
#   additional_education_km + radiation_km + industrial_km + 
#   metro_min_avto + income_per_cap + cafe_count_1500_price_high + 
#   oil_chemistry_raion + green_zone_km + ts_km + material + 
#   stadium_km + cafe_count_2000_price_2500 + build_year
summary(forwardAIC)

backwardAIC = step(model.full, scope, direction = "backward", k = 2)
#result:
# price_doc_log ~ full_sq + floor + max_floor + material + num_room + 
#   state + indust_part + school_education_centers_raion + culture_objects_top_25_raion + 
#   oil_chemistry_raion + metro_min_avto + green_zone_km + industrial_km + 
#   kremlin_km + radiation_km + ts_km + fitness_km + stadium_km + 
#   additional_education_km + cafe_count_1500_price_500 + cafe_count_1500_price_high + 
#   cafe_count_2000_price_2500 + trc_sqm_5000 + cafe_count_5000_price_high + 
#   usdrub + income_per_cap + salary

bothAIC.empty = step(model.empty, scope, direction = "both", k = 2)
bothAIC.full = step(model.full, scope, direction = "both", k = 2)

#Stepwise regression using BIC as the criteria (the penalty k = log(n)).
forwardBIC = step(model.empty, scope, direction = "forward", k = log(nrow(dfTrain)))
backwardBIC = step(model.full, scope, direction = "backward", k = log(nrow(dfTrain)))
bothBIC.empty = step(model.empty, scope, direction = "both", k = log(nrow(dfTrain)))
bothBIC.full = step(model.full, scope, direction = "both", k = log(nrow(dfTrain)))

##################################
#checking VIFs

vif(forwardAIC)
vif(backwardAIC)
vif(bothAIC.empty)
vif(bothAIC.full)

vif(forwardBIC)
vif(backwardBIC)
vif(bothBIC.empty)+ full_sq_squared
vif(bothBIC.full)

model = lm(formula = price_doc_log ~ full_sq + kremlin_km  + 
     state + floor + usdrub + indust_part + fitness_km + culture_objects_top_25_raion + 
     cafe_count_5000_price_high + school_education_centers_raion + trc_sqm_5000 + salary + 
     additional_education_km + radiation_km + industrial_km + 
     metro_min_avto + income_per_cap + oil_chemistry_raion + green_zone_km + ts_km + build_year, data = dfTrain)
backwardAIC = step(model, scope, direction = "backward", k = 2)
summary(backwardAIC)
vif(backwardAIC)

predictions = cbind(dfTest, pred = predict(backwardAIC, newdata = dfTest))
predictions$pred[is.na(predictions$pred)] = median(predictions$pred, na.rm = TRUE)
predictions = subset(predictions, select=c("id", "pred"))
predictions$price_doc = exp(predictions$pred)
predictions$pred = NULL
write.csv(predictions, 'sample1.csv', row.names = F)


k = predict(backwardAIC, dfTest)
k$fittedvalues
#################################
# comparing AICs and BICs
AIC(forwardAIC,
    backwardAIC,
    bothAIC.empty,
    bothAIC.full) #Model with all variables EXCEPT Illiteracy, Area, and Income.
# all same????


BIC(forwardBIC,
    backwardBIC,
    bothBIC.empty,
    bothBIC.full) #Both the minimum AIC and BIC values appear alongside the
#reduced model that we tested above.
# backwardBIC best


summary(backwardBIC)
summary(backwardAIC)
summary(forwardAIC)



anova(forwardAIC, backwardBIC)
# really small p-value which shows forward AIC significantly different from backwardBIC



##################################################################

# introduce complexity by increasing degree of polynomial
# compute the rmse of reg. models with different order in polynomials
rmse_train = function(n) {
  model = lm(price_doc_log ~ poly(full_sq,n), data=dfTrain)
  pred = predict(model)
  rmse = sqrt(mean((dfTrain$price_doc_log-pred)^2))
  return(rmse)
}
rmse1 = sapply(1:10, rmse_train)
plot(1:10, rmse1, type='b')
# 
# rmse_train = function(n) {
#   model = lm(price_doc_log ~ poly(radiation_km,n), data=dfTrain)
#   pred = predict(model)
#   rmse = sqrt(mean((dfTrain$price_doc_log-pred)^2))
#   return(rmse)
# }
# rmse1 = sapply(1:10, rmse_train)
# plot(1:10, rmse1, type='b')
# # from 0.620 to 0.6175

rmse_train = function(n) {
  model = lm(price_doc_log ~ poly(cafe_count_1500_price_500,n), data=dfTrain)
  pred = predict(model)
  rmse = sqrt(mean((dfTrain$price_doc_log-pred)^2))
  return(rmse)
}
rmse1 = sapply(1:10, rmse_train)
plot(1:10, rmse1, type='b')
# maybe????

# rmse_train = function(n) {
#   model = lm(price_doc_log ~ poly(indust_part,n), data=dfTrain)
#   pred = predict(model)
#   rmse = sqrt(mean((dfTrain$price_doc_log-pred)^2))
#   return(rmse)
# }
# rmse1 = sapply(1:10, rmse_train)
# plot(1:10, rmse1, type='b')
# # maybe????

# rmse_train = function(n) {
#   model = lm(price_doc_log ~ poly(stadium_km,n), data=dfTrain)
#   pred = predict(model)
#   rmse = sqrt(mean((dfTrain$price_doc_log-pred)^2))
#   return(rmse)
# }
# rmse1 = sapply(1:10, rmse_train)
# plot(1:10, rmse1, type='b')
# # maybe????

# rmse_train = function(n) {
#   model = lm(price_doc_log ~ poly(kremlin_km,n), data=dfTrain)
#   pred = predict(model)
#   rmse = sqrt(mean((dfTrain$price_doc_log-pred)^2))
#   return(rmse)
# }
# rmse1 = sapply(1:10, rmse_train)
# plot(1:10, rmse1, type='b')
# maybe????

rmse_train = function(n) {
  model = lm(price_doc_log ~ poly(fitness_km,n), data=dfTrain)
  pred = predict(model)
  rmse = sqrt(mean((dfTrain$price_doc_log-pred)^2))
  return(rmse)
}
rmse1 = sapply(1:10, rmse_train)
plot(1:10, rmse1, type='b')
# maybe????

rmse_train = function(n) {
  model = lm(price_doc_log ~ poly(cafe_count_1500_price_500,n), data=dfTrain)
  pred = predict(model)
  rmse = sqrt(mean((dfTrain$price_doc_log-pred)^2))
  return(rmse)
}
rmse1 = sapply(1:10, rmse_train)
plot(1:10, rmse1, type='b')
# maybe????

rmse_train = function(n) {
  model = lm(price_doc_log ~ poly(cafe_count_1500_price_500,n), data=dfTrain)
  pred = predict(model)
  rmse = sqrt(mean((dfTrain$price_doc_log-pred)^2))
  return(rmse)
}
rmse1 = sapply(1:10, rmse_train)
plot(1:10, rmse1, type='b')
# maybe????

rmse_train = function(n) {
  model = lm(price_doc_log ~ poly(cafe_count_1500_price_500,n), data=dfTrain)
  pred = predict(model)
  rmse = sqrt(mean((dfTrain$price_doc_log-pred)^2))
  return(rmse)
}
rmse1 = sapply(1:10, rmse_train)
plot(1:10, rmse1, type='b')
# maybe????






#####################
# huh?

# Evaluating Models
#underfitting
plot(x, y)
model1 = lm(y ~ x)
abline(model1)
# overfitting
model2 = lm(y ~ poly(x,20))
plot(x, y)
lines(x, model2$fitted.values)

# learning curve... performance vs. complexity
#... split the data into two portions
dat = data.frame(x,y)
set.seed(1)
index = sample(1:100, 50)
train = dat[index,]
test = dat[-index,]


# full_sq squared significant


# plot performance versus complexity (i.e. the learning curve)
plot(1:10, rmse1, type='b')

# do to test
rmse_test = function(n) {
  model = lm(y ~ poly(x, n), data=train)
  pred = predict(model, newdata=test)
  rmse = sqrt(mean((test$y-pred)^2))
  return(rmse)
}
rmse2 = sapply(1:10, rmse_test)

plot(1:10, rmse2, type='b')

plotdata = data.frame(rmse=c(rmse1,rmse2), 
                      type=rep(c('train','test'), each=10),
                      x=rep(1:10,times=2))
p = ggplot(plotdata, aes(x=x,y=rmse,group=type,color=type))
p = p + geom_point() + geom_line()
#overfitting detected as the curves deviate
print(p)
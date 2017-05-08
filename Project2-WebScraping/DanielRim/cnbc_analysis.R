library(data.table)
library(dplyr)
library(ggplot2)
library(ggthemes)

getwd()
setwd("~/NYC Data Science Academy/Scraping Project/")
estimates<-''
estimates <- fread("estimates_final.csv")
summary(estimates)
head(estimates)
nrow(estimates)
which(estimates$`Estimate EPS`>600)
summary(estimates$`Estimate EPS`)
summary(estimates$`Actual EPS`)
estimates$`Estimate EPS`<-as.numeric(estimates$`Estimate EPS`)
estimates$`Actual EPS`<-as.numeric(estimates$`Actual EPS`)

####### Excluding Outliers #######################
# estimates<-filter(estimates,
#                   `Estimate EPS`<20)
# 
# estimates<-filter(estimates,
#                   `Estimate EPS`>-20)
# 
# estimates<-filter(estimates,
#                   `Estimate EPS`>-20)
# estimates<-filter(estimates,
#                   `Actual EPS`>-50)

estimates<-filter(estimates,
                  `Quarter`=='4th qtr 2016'|`Quarter`=='1st qtr 2017'|
                    `Quarter`=='2nd qtr 2017')
head(estimates)
nrow(estimates)
plot(estimates$`Estimate EPS`,
     estimates$`Actual EPS`,
     xlab = "Estimate EPS", 
     ylab = "Actual EPS")

model_original =
  lm(`Actual EPS`~`Estimate EPS`,
     data =estimates)

summary(model_original)
abline(model_original,lty=1,col="red")
model_original$coefficients
model_original$residuals
sum(model_original$residuals)

plot(density(model_original$residuals,
             na.rm=T), xlab = "Residuals",
     main = "Sample Distribution of Residuals", col = "red")

# seq(from = -5, to = 40, by = 1)
#Visualizing the confidence and prediction bands.
newdata = data.frame(`Estimate EPS` = -5:40)
head(newdata)
newdata$`Estimate EPS` = c(-5:40)
names(model_original)
model_original$fitted.values
names(model_original$coefficients[2])
model_original$coefficients[2]*newdata$`Estimate EPS`+
model_original$coefficients[1]
predict(model_original, newdata)

conf.band = predict(model_original, newdata, interval = "confidence")
pred.band = predict(model_original, newdata, interval = "prediction")
?predict

head(conf.band)
head(pred.band)
nrow(conf.band)
nrow(pred.band)
nrow(newdata)


plot(estimates$`Estimate EPS`,estimates$`Actual EPS`,
     xlab = "Estimate EPS", ylab = "Actual EPS",
     main = "Scatterplot of Wall Street EPS Dataset")
abline(model_original, lty = 2) #Plotting the regression line.
lines(newdata$`Estimate EPS`, conf.band[, 2], col = "blue") #Plotting the lower confidence band.
lines(newdata$`Estimate EPS`, conf.band[, 3], col = "blue") #Plotting the upper confidence band.
lines(newdata$`Estimate EPS`, pred.band[, 2], col = "red") #Plotting the lower prediction band.
lines(newdata$`Estimate EPS`, pred.band[, 3], col = "red") #Plotting the upper prediction band.
legend("topleft", c("Regression Line", "Conf. Band", "Pred. Band"),
       lty = c(2, 1, 1), col = c("black", "blue", "red"))



######### Normality of Residuals ################

qqnorm(model_original$residuals)
qqline(model_original$residuals)
library(car)
influencePlot(model_original)

##### Attempt to identify outliers ##############
estimates[823,]
estimates[615,]
estimates[1418,]
estimates[2389,]
estimates[3711,]
estimates[792,]
estimates[883,]
estimates[1512,]

plot(model_original)

####### Constant Variance of Residuals ##########
names(model_original)
cor(model_original$residuals,
  model_original$fitted.values)
residuals<-model_original$residuals
fitted_values<-model_original$fitted.values
const_var<- lm(residuals~fitted_values)
summary(const_var)

### T-test of beat/missed group #################

estimates_beat<-estimates%>%
  filter(Hurdle=="beat")%>%
  select(Perf)

estimates_missed<-estimates%>%
  filter(Hurdle=="missed")%>%
  select(Perf)

summary(estimates_beat)
summary(estimates_missed)
class(estimates_beat)
class(estimates_missed)

estimates_beat<-as.numeric(estimates_beat$Perf)
estimates_missed<-as.numeric(estimates_missed$Perf)

plot(density(estimates_beat,
             na.rm=T), xlab = "Stock Performance",
              main = "Sample Distribution of Stock Performance", col = "red")
lines(density(estimates_missed,
              na.rm=T), col = "blue",na.rm=T)
legend("topright", c("Beat", "Missed"), lwd = 1, col = c("red", "blue"))

qqnorm(estimates_beat)
qqline(estimates_beat)

qqnorm(estimates_missed)
qqline(estimates_missed)


# x<-
# y<-
  
boxplot(estimates_beat,estimates_missed, main = "Sample Distribution of Stock Performance",
        col = c("red", "blue"), names = c("Beat", "Missed"))


t.test(estimates_beat, estimates_missed, alternative = "two.sided")

plot(estimates$`Num Analyst`,
     estimates$`Surprise`,
     xlab = "Num Analyst", 
     ylab = "Surprise")

hist(estimates$`Surprise`)

####### Surprise Outlier
estimates<-filter(estimates,
                  Surprise<20&Surprise>-20)

# estimates<-filter(estimates,
#                   Surprise<5&Surprise>-5)

plot(estimates$`Surprise`,
     estimates$Perf,
     xlab = "Surprise", 
     ylab = "Stock Performance")
nrow(estimates)
surprise<-
  estimates%>%
  filter(!is.na(Perf) & !is.na(Perf))%>%
  select(Surprise)

perf<-
  estimates%>%
  filter(!is.na(Perf) & !is.na(Perf))%>%
  select(Perf)

test<-
  estimates%>%
  filter(!is.na(Perf) & !is.na(Perf))

surprise<-test$Surprise  
perf <- test$Perf
class(test$Surprise)
class(test$Perf)


sum(is.na(surprise))
sum(is.na(perf))

length(test$Surprise)
length(test$Perf)
cor(test$Surprise,test$Perf)

model_stock_perf =
  lm(estimates$Perf~estimates$`Surprise`,
     data =estimates, na.action = na.omit)

summary(estimates$`Surprise`)
summary(model_stock_perf)
abline(model_stock_perf,lty=1,col="red")


g<-ggplot(data=estimates,aes(x=`Estimate EPS`,
                             y=`Actual EPS`))

g+geom_point()+#stat_summary(fun.data=mean_cl_normal) + 
  geom_smooth(method='lm',formula=y~x)
  # theme_wsj()
library(devtools)
g+geom_point(color='red4')+
  theme_economist()+ 
  geom_smooth(method='lm',formula=y~x,color="black")

g<-ggplot(data=estimates,aes(x=`Num Analyst`,
                             y=`Surprise`))
g+geom_point(color='red4')+
  theme_economist()

names(estimates)
g<-ggplot(data=estimates,aes(x=`Surprise`,
                             y=`Perf`))

g+geom_point(aes(color=Hurdle))+
  theme_economist()

g+geom_point(aes(color=Quarter))+
  theme_economist()

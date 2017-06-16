#########################################################
#########################################################
#####[10] Support Vector Machines Homework Solutions#####
#########################################################
#########################################################



#####################
#####Question #1#####
#####################
#1ab
wine = read.csv("[10] Wine Quality.csv")
quality = ifelse(wine$quality <= 5, "Low", "High")
wine.scale = as.data.frame(scale(wine[, -12]))
wine = cbind(wine.scale, quality)
# When using SVMs, why do I need to scale the features? 
#http://stats.stackexchange.com/questions/154224/when-using-svms-why-do-i-need-to-scale-the-features
#2
set.seed(0)
train = sample(1:nrow(wine), 8*nrow(wine)/10)
wine.train = wine[train, ]
wine.test = wine[-train, ]

#3ab
plot(wine[, -12], col = wine$quality)

#It seems as though the two categories are overlapping in each of the two-dimensional
#cross-sections of the data. Thus, it is implausible that a maximal margin classifier
#would work in this scenario. Also, the maximal margin classifier is very sensitive;
#even if it were possible to construct, we should implement a soft margin instead
#in order to build a more robust model.

#4abc
library(e1071)

set.seed(0)
cv.wine.svc.linear = tune(svm,
                          quality ~ .,
                          data = wine.train,
                          kernel = "linear",
                          ranges = list(cost = 10^(seq(-5, -.5, length = 50))))

cv.wine.svc.linear

plot(cv.wine.svc.linear$performances$cost,
     cv.wine.svc.linear$performances$error,
     xlab = "Cost",
     ylab = "Error Rate",
     type = "l")

#The best cost appears to be a value of about 0.136. This corresponds to an error
#rate of about 0.261. We see that the error rate seems to have stabilized so it
#is plausible we have checked enough parameter values.

#5
best.linear.model = cv.wine.svc.linear$best.model
summary(best.linear.model)

#There are 767 support vectors.

#6
ypred = predict(best.linear.model, wine.test)
table("Predicted Values" = ypred, "True Values" = wine.test$quality)
(38 + 44)/320

#The test error is approximately 0.256.

#7ab
best.linear.model.overall = svm(quality ~ .,
                                data = wine,
                                kernel = "linear",
                                cost = best.linear.model$cost)

summary(best.linear.model.overall)
555 %in% best.linear.model.overall$index

#There are 956 support vectors; observation 555 is a support vector.

#8
ypred = predict(best.linear.model.overall, wine)
table("Predicted Values" = ypred, "True Values" = wine$quality)
(173 + 235)/1599

#The overall error is about 0.255.

#9
plot(best.linear.model.overall, wine,
     free.sulfur.dioxide ~ total.sulfur.dioxide)

#10abcd
set.seed(0)
cv.svm.radial = tune(svm,
                     quality ~ .,
                     data = wine.train,
                     kernel = "radial",
                     ranges = list(cost = seq(.75, 1.25, length = 5),
                                   gamma = seq(.55, .95, length = 5)))

cv.svm.radial

# Choice of kernels
# http://www.louisaslett.com/Courses/Data_Mining/ST4003-Lab7-Introduction_to_Support_Vector_Machines.pdf


library(rgl)
plot3d(cv.svm.radial$performances$cost,
       cv.svm.radial$performances$gamma,
       cv.svm.radial$performances$error,
       xlab = "Cost",
       ylab = "Gamma",
       zlab = "Error",
       type = "s",
       size = 1)

#The best cost appears to be a value of about 0.875, and the best gamma appears to
#be a value of about 0.65. This corresponds to an error rate of about 0.209. We see
#that the error rate seems to have stabilized so it is plausible we have checked
#enough parameter values.

#11
best.radial.model = cv.svm.radial$best.model
summary(best.radial.model)

#There are 1,054 support vectors.

#12
ypred = predict(best.radial.model, wine.test)
table("Predicted Values" = ypred, "True Values" = wine.test$quality)
(40 + 33)/320

#The test error is approximately 0.228.

#13ab
best.radial.model.overall = svm(quality ~ .,
                                data = wine,
                                kernel = "radial",
                                cost = best.radial.model$cost,
                                gamma = best.radial.model$gamma)

summary(best.radial.model.overall)
798 %in% best.radial.model.overall$index

#There are 1,276 support vectors; observation 798 is not a support vector.

#14
ypred = predict(best.radial.model.overall, wine)
table("Predicted Values" = ypred, "True Values" = wine$quality)
(67 + 63)/1599

#The overall error is about 0.081.

#15
plot(best.radial.model.overall, wine,
     free.sulfur.dioxide ~ total.sulfur.dioxide)

#16
#The support vector classifier is a simpler model and it is easier to train, but
#its error rate is relatively high. In contrast, the support vector machine is a
#more complicated model and is more difficult to train, but its error rate is
#relatively low. Both models do not offer much interpretive value.

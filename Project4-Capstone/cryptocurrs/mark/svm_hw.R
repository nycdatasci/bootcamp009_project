library(e1071)

wine = read.csv('[10] Wine Quality.csv')

wine$quality = as.factor(ifelse(wine$quality > 5, 'High', 'Low'))

#1b
#Scale and center the numeric vectors if this dataset

#2
#Creating training and test sets.
set.seed(0)
train.index = sample(1:200, 200*.8)
test.index = -train.index

#3
# Too many variables from a marginal maximum classifier. The data overlaps in its feature space. 

# For the complementary reason to above, a support vector machine is more flexible and will better adapt to
# an overlapped feature space. 

cost = 10^(seq(-5, 0.5, length = 50))

#4
svm.svc.linear2 = svm(quality ~ .,
                      data = wine,
                      kernel = "linear",
                      cost = cost)

#Visualizing the results of the support vector classifier.
#plot(svm.svc.linear2, data = wine)
summary(svm.svc.linear2)
svm.svc.linear2$index
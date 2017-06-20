library(kernlab)
library(caret)
library(tree)
library(dplyr)
library(rpart)
library(lubridate)

kchousingraw <- read.csv("~/Desktop/kc_house_data.csv",stringsAsFactors=T)
dim(kchousingraw)
colnames(kchousingraw)
class(kchousingraw$date)
head(kchousingraw$date)
kchousingraw$date <- (as.Date(kchousingraw$date, format = "%y"))
table(kchousingraw$date)
sum(is.na(kchousingraw))
kchousing <- mutate(kchousingraw, price = price /sqft_above)
head(kchousingraw)
head(kchousing)
hist(kchousingraw$price)
summary(kchousing$price)
unique(kchousing$zipcode)
hist(kchousing$price)
kchousing$zipcode <- as.character(kchousing$zipcode)

set.seed(0)
train = sample(1:nrow(kchousing), 7*nrow(kchousing)/10) #Training indices.
kchousing.train = kchousing[train, ]
kchousing.test = kchousing[-train, ] #Test dataset.


temp <- kchousing.train %>% group_by(zipcode) %>% summarise(avgprice = mean(price)) %>% arrange(avgprice)
temp$avgprice <-  round(temp$avgprice,0)
kchousing <- merge(kchousing, temp, by = "zipcode")

names(kchousing)


tree.kchousing = tree(price ~ avgprice +  bedrooms + bathrooms  + sqft_living + sqft_lot + floors + waterfront + view + condition + grade + yr_built + yr_renovated+sqft_living15 + sqft_lot15+sqft_above,  data = kchousing.train)
summary(tree.kchousing)
plot(tree.kchousing)
text(tree.kchousing, pretty = 0) #Yields category names instead of dummy variables.





library(randomForest)



rf.kchousing = randomForest(price ~ bedrooms + bathrooms + avgprice + sqft_living + sqft_lot + floors + waterfront + view + condition + grade + yr_built + yr_renovated +sqft_above + sqft_basement+sqft_living15 + sqft_lot15,  data = kchousing, subset = train)


importance(rf.kchousing)
varImpPlot(rf.kchousing)
tree.pred = predict(rf.kchousing, kchousing.test)
testdata = kchousing[-train, ]
testdata = mutate(testdata, pred = tree.pred)
diff = kchousing[-train, ]$price -tree.pred
berr = mean(diff*diff)
berr
library(ggplot2)
x=(tree.pred)
y=(kchousing[-train, ]$price)
gg=ggplot(data=testdata,aes(x=pred, y = testdata$price))
gg+ geom_point()

ggplot(kchousing.train, aes(avgprice,price,fill=zipcode)) + geom_boxplot() + theme(legend.position="none")


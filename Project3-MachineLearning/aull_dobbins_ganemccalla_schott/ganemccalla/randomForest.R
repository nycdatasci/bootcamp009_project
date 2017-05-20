#these filenames will change

train_raw = read.csv('train_clean.csv', header=TRUE)
test_raw = read.csv('test_clean.csv')


reducedTrainData = dplyr::select(train_raw,price_doc,timestamp,full_sq,life_sq,
                                 floor,max_floor,material,build_year,num_room,
                                 kitch_sq,state,product_type,sub_area,kremlin_km)
reducedTrainData$build_year = as.factor(reducedTrainData$build_year)

#this will take a while to execute, 10-30 minutes
inputedTrain = kNN(reducedTrainData, k = 9)
#we wanted this to be a factor but Random Forest can't handle that many factors
inputedTrain$build_year = as.numeric(inputedTrain$build_year)
inputedTrain$timestamp = as.numeric(inputedTrain$timestamp)
set.seed(0)
library(randomForest)
#this will take a while to execute, at least 30 minutes
rf.base = randomForest(price_doc ~ ., data = inputedTrain)
rf.base
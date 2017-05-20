#these filenames will change

train_raw = read.csv('train_clean.csv', header=TRUE)
test_raw = read.csv('test_clean.csv')


reducedTrainData = dplyr::select(train_raw,price_doc,timestamp,full_sq,life_sq,
                                 floor,max_floor,material,build_year,num_room,
                                 kitch_sq,state,product_type,sub_area,kremlin_km)
reducedTrainData$sub_area = as.factor(reducedTrainData$sub_area)
reducedTrainData$timestamp = as.Date(reducedTrainData$timestamp)

#this will take a while to execute, 10-30 minutes
library(VIM)
inputedTrain = kNN(reducedTrainData, k = 9)
#this gets rid of all the columns telling us which values are inputed
inputedTrain = inputedTrain[1:14]

set.seed(0)
library(randomForest)
#this will take a while to execute, at least 30 minutes
rf.base = randomForest(price_doc ~ ., data = inputedTrain)
rf.base
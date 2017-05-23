#these filenames will change

train_raw = read.csv('train_clean.csv', header=TRUE)
test_raw = read.csv('test_clean.csv', header=TRUE)
raions = read.csv("raion_clusters.csv")

reducedTrainData = dplyr::select(train_raw,price_doc,timestamp,full_sq,life_sq,
                                 floor,max_floor,material,build_year,num_room,
                                 kitch_sq,state,product_type,sub_area,kremlin_km,
                                 metro_km_walk,radiation_km,basketball_km)

reducedTrainData$sub_area = as.factor(reducedTrainData$sub_area)
reducedTrainData$state = as.factor(reducedTrainData$state)
reducedTrainData$material = as.factor(reducedTrainData$material)
reducedTrainData$timestamp = as.numeric(as.POSIXct(reducedTrainData$timestamp,origin="1970-01-01"))
#this matches the sub_area to the corresponding cluster
reducedTrainData$raion_cluster = as.factor(raions[match(reducedTrainData$sub_area,raions$sub_area),2])

reducedTestData = dplyr::select(train_raw,price_doc,timestamp,full_sq,life_sq,
                                floor,max_floor,material,build_year,num_room,
                                kitch_sq,state,product_type,sub_area,kremlin_km,
                                metro_km_walk,radiation_km,basketball_km)

reducedTestData$sub_area = as.factor(reducedTestData$sub_area)
reducedTestData$state = as.factor(reducedTestData$state)
reducedTestData$material = as.factor(reducedTestData$material)
reducedTestData$timestamp = as.numeric(as.POSIXct(reducedTestData$timestamp,origin="1970-01-01"))
reducedTestData$raion_cluster = as.factor(raions[match(reducedTestData$sub_area,raions$sub_area),2])

#this will take a while to execute, 10-30 minutes
library(VIM)
inputedTrain = kNN(reducedTrainData, k = 9)
inputedTest = kNN(reducedTestData, k = 9)

#this gets rid of all the columns telling us which values are inputed
inputedTrainModified = inputedTrain[1:18]
inputedTestModified = inputedTest[1:17]
#shouldn't be necesssary if the data is adequately cleaned
inputedTestModified[inputedTestModified==""] = "OwnerOccupier"

set.seed(0)
library(randomForest)
#we need to remove sub_area because there are too many categories

#this will take a while to execute, at least 30 minutes
rf.base = randomForest(price_doc ~ ., data = inputedTrainModified)

rf.base
#somehow the product_type has three values in the test data, we need to deal with this
#inputedTestModified$product_type <- droplevels(inputedTestModified$product_type)
#prediction = predict(rf.base,newdata = inputedTestModified)
#gives info about the trees branches
#plot(rf.base, log="y")
#library("party") 
#RandomTree <- cforest(price_doc ~ ., data = inputedTrainModified) 


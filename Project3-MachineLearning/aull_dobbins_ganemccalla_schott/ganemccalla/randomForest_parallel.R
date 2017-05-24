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
reducedTrainData = dplyr::select(reducedTrainData,-sub_area)
reducedTestData = dplyr::select(train_raw,price_doc,timestamp,full_sq,life_sq,
                                floor,max_floor,material,build_year,num_room,
                                kitch_sq,state,product_type,sub_area,kremlin_km,
                                metro_km_walk,radiation_km,basketball_km)

reducedTestData$sub_area = as.factor(reducedTestData$sub_area)
reducedTestData$state = as.factor(reducedTestData$state)
reducedTestData$material = as.factor(reducedTestData$material)
reducedTestData$timestamp = as.numeric(as.POSIXct(reducedTestData$timestamp,origin="1970-01-01"))
reducedTestData$raion_cluster = as.factor(raions[match(reducedTestData$sub_area,raions$sub_area),2])
reducedTestData = dplyr::select(reducedTestData,-sub_area)

#this will take a while to execute, 10-30 minutes
library(VIM)
inputedTrain = kNN(reducedTrainData, k = 9)
inputedTest = kNN(reducedTestData, k = 9)

#this gets rid of all the columns telling us which values are inputed
inputedTrainModified = inputedTrain[1:17]
inputedTestModified = inputedTest[1:16]
#shouldn't be necesssary if the data is adequately cleaned
inputedTestModified[inputedTestModified==""] = "OwnerOccupier"

# Library to run random forest in parallel
library(doMC)
# register 3 cores to be used
registerDoMC(3)
library(randomForest)
#we need to remove sub_area because there are too many categories

# Parellel version which uses foreach function
rf.base = foreach(ntree=rep(166, 3), .combine=combine, .multicombine = TRUE,
                  .packages='randomForest') %dopar% {
                      randomForest(price_doc ~ ., data = inputedTrainModified)
                  }

#this will take a while to execute, at least 30 minutes
#rf.base = randomForest(price_doc ~ ., data = inputedTrainModified)

rf.base
#somehow the product_type has three values in the test data, we need to deal with this
#inputedTestModified$product_type <- droplevels(inputedTestModified$product_type)
#prediction = predict(rf.base,newdata = inputedTestModified)
#gives info about the trees branches
#plot(rf.base, log="y")
#library("party") 
#RandomTree <- cforest(price_doc ~ ., data = inputedTrainModified) 




oob.err = numeric(16)
for (mtry in 1:16) {
  fit = randomForest(price_doc ~ ., data = inputedTrainModified, mtry = mtry)
  oob.err[mtry] = fit$mse[500]
  cat("We're performing iteration", mtry, "\n")
}

svg('rf_oob_error.svg')
plot(1:16, oob.err, pch = 16, type = "b",
     xlab = "Variables Considered at Each Split",
     ylab = "OOB Mean Squared Error",
     main = "Random Forest OOB Error Rates\nby # of Variables")
dev.off()

#Can visualize a variable importance plot.
svg('importance.svg')
importance(rf.base)
dev.off()
svg('varImpPlot.svg')
varImpPlot(rf.base)
dev.off()

boost.base = gbm(price_doc ~ ., data = inputedTrainModified,
                   distribution = "gaussian",
                   n.trees = 1000000,
                   interaction.depth = 4)
n.trees = seq(from = 100000, to = 1000000, by = 100000)
predmat = predict(boost.base, newdata = inputedTrainModified, n.trees = n.trees)
berr = with(inputedTrainModified, apply((predmat - price_doc)^2, 2, mean))

svg('boosting_test_err.svg')
plot(n.trees, berr, pch = 16,
     ylab = "Mean Squared Error",
     xlab = "# Trees",
     main = "Boosting Test Error")
dev.off()

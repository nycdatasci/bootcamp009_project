#change this!
fileLoc = "C:/Users/Robin/Desktop/Kaggle Competition/train.csv"
library(dplyr)

trainData = read.csv(fileLoc)
#these 13 columns are most relevant
#the rest contain information about the raion(region), this could be put into
#a smaller table, and there's also lots information about nearby facilities
#which will probably be reduced 
reducedTrainData = dplyr::select(trainData,price_doc,timestamp,full_sq,life_sq,floor,max_floor,material,build_year,num_room,kitch_sq,state,product_type,sub_area)
#we see there are lots of NA values
#we should probably impute some values as deleting all of the NAs
#would reduce the dataset largely
which(is.na(reducedTrainData))

hist(reducedTrainData$price_doc)
#we do not have a normal distribution of prices
#we remove the categorical variables for now
model = lm(price_doc ~.-timestamp -sub_area, data=reducedTrainData)
summary(model)
#the R-Squared value is .4322, life_sq, max_floor and kitch_sq
#are outside the p-value threshold
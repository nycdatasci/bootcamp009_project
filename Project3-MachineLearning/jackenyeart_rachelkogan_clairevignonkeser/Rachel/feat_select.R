train_cleaned <- read.csv("~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser/train_cleaned.csv", stringsAsFactors=FALSE)

train_cleaned$logprice <- log(1+train_cleaned$price_doc)

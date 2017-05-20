library(VIM)
library(mice)

#your paths will be different :)
#setwd("~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser")
#macro <- read.csv("~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser/macro.csv", stringsAsFactors=FALSE)

#investigate missingness

dim(macro)
sum(is.na(macro)==T)/(248400)
#18% of the data is missing

rowSums(is.na(macro))
dim(macro[,!is.na(macro[2471,])])

#throw away columns that disappear towards the end of the time range!
macro_small = macro[,!is.na(macro[2471,])]
macro_small = macro_small[rowSums(is.na(macro_small))==0,]
aggr(macro_small, numbers=T)
md.pattern(macro_small)



sum(is.na(macro_small))
dim(macro_small)
sum(is.na(macro_small))/(2484*34)
#now only 4% data is missing!

summary(macro_small)
str(macro_small)
cor(macro_small)
sapply(X = macro_small, FUN = class)


write.csv(x = macro_small, file = 'macro_small.csv', row.names=FALSE)


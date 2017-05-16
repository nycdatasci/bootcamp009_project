path = ('/data/data/kaggle/sberbank_housing/')

base_data = read.csv(paste0(path,'train.csv'))
dim(base_data) # 30471 x 292
macro = read.csv(paste0(path,'macro.csv')) # 2484 x 100

table(sapply(base_data,class))
#factor integer numeric 
#16     185      91 

table(sapply(macro,class))
#factor integer numeric 
#4      13      83

plot(sapply(base_data, function(x) sum(is.na(x))))

plot(sapply(macro, function(x) sum(is.na(x))))

plot(base_data[,2],base_data[,292])
library(plot3D)
base_data[,2] = as.Date(base_data[,2])
points3D(base_data[,4],base_data[,292],base_data$children_preschool)


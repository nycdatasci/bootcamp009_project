#path = ('/data/data/kaggle/sberbank_housing/')
path = '/home/mes/data/kaggle/sberbank_housing/'

train = read.csv(paste0(path,'train.csv'))
dim(train) # 30471 x 292
macro = read.csv(paste0(path,'macro.csv')) # 2484 x 100

table(sapply(train,class))
#factor integer numeric 
#16     185      91 

table(sapply(macro,class))
#factor integer numeric 
#4      13      83

missing_ratio = sapply(train, function(x) sum(is.na(x))/nrow(train))
missing_ratio[missing_ratio!=0]
plot(sapply(train, function(x) sum(is.na(x))/nrow(train)), xlab = 'index of variable', ylab = 'percentage missing')
plot(sapply(macro, function(x) sum(is.na(x))/nrow(macro)), xlab = 'index of variable', ylab = 'percentage missing')


plot(train[,2],train[,292])
#library(plot3D)
train[,2] = as.Date(train[,2])
#points3D(base_data[,4],base_data[,292],base_data$children_preschool)


setwd('/home/mes/data/kaggle/sberbank_housing')
train_raw = read.csv('train_mod.csv', header=TRUE)
test_raw = read.csv('test_mod.csv', header=TRUE)

train = train_raw
#property_features = c('timestamp', 'full_sq', 'life_sq', 'floor', 
#                     'max_floor', 'material', 'build_year', 'num_room',
#                     'kitch_sq', 'state', 'product_type', 'sub_area', 
#                     'price_doc')
#train = train_raw[property_features]

# Must get rid of missing values in order to do a random forest
missing_ratio = sapply(train, function(x) sum(is.na(x))/nrow(train))
complete_vars = missing_ratio[missing_ratio==0]

train_complete = train[!sapply(train, function(x) any(is.na(x)))]

# drop some columns manually
drop_em = which(names(train) == c('id','log_price_doc'))
train_complete = train_complete[,-drop_em]

# Do the bare minimum random forest
set.seed(0)
library(randomForest)
rf.base = randomForest(price_doc ~ ., data = base_data)
rf.base
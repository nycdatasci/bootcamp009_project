train_cleaned <- read.csv("~/Documents/NYCDSA/Projects/bootcamp009_project/Project3-MachineLearning/jackenyeart_rachelkogan_clairevignonkeser/train_cleaned.csv", stringsAsFactors=FALSE)

FinalCoefs = c('timestamp',
               'full_sq',
               'state',
               'sub_area',
               'sadovoe_km',
               'oil_chemistry_km',
               'church_count_500',
               'leisure_count_500',
               'prom_part_3000',
               'office_sqm_5000',
               'mosque_count_5000', 
               'price_doc')

#investigate the missingness of state
train = train_cleaned[which(colnames(train_cleaned) %in% FinalCoefs)]
sum(is.na(train$state)[1:10000])
sum(is.na(train$state)[10001:20000])
sum(is.na(train$state)[20001:nrow(train)])

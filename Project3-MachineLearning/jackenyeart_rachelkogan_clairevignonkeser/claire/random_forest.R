library(randomForest)

setwd('/Users/clairevignon/DataScience/NYC_DSA/project3_ML_kaggle')

train_2 = read.csv("train_cleaned_2.csv", stringsAsFactors = FALSE)
test_2 = read.csv("test_cleaned_2.csv", stringsAsFactors = FALSE)

train_2$price_doc = log(train_2$price_doc+1)

top_feat = c("price_doc", "full_sq", "life_sq", "build_year", "year_month", "floor", "additional_education_km", "catering_km", 
             "big_church_km", "public_healthcare_km", "railroad_km", "preschool_km", "industrial_km", 
             "radiation_km", "big_road1_km", "public_transport_station_km", "cemetery_km",
             "swim_pool_km", "green_zone_km", "big_road2_km", "hospice_morgue_km", "fitness_km")


top_feat_test = c("full_sq", "life_sq", "build_year", "year_month", "floor", "additional_education_km", "catering_km", 
                  "big_church_km", "public_healthcare_km", "railroad_km", "preschool_km", "industrial_km", 
                  "radiation_km", "big_road1_km", "public_transport_station_km", "cemetery_km",
                  "swim_pool_km", "green_zone_km", "big_road2_km", "hospice_morgue_km", "fitness_km")


train = subset(train_2, select= top_feat)
test = subset(test_2, select = top_feat_test)

rf.house = randomForest(price_doc ~ ., data = train, importance = TRUE)

treepredictions  = predict(rf.house,train)
D = as.data.frame(treepredictions)
names(treepredictions)
mean((D$treepredictions-train_2$price_doc)^2)
plot(sort(exp(D$treepredictions)))

median(D$treepredictions)
E = predict(rf.house,test)
E = as.data.frame(E)


E$E= exp(E$E)-1
E$id = test_2$id
E = E[,c(2,1)]
names(E) = c('id','price_doc')
write.csv(E, "rf_1.csv", row.names=F)


##############
train_2 = read.csv("train_cleaned_2.csv", stringsAsFactors = FALSE)
test_2 = read.csv("test_cleaned_2.csv", stringsAsFactors = FALSE)

train_2$price_doc = log(train_2$price_doc+1)

top_feat = c('price_doc', "full_sq", "life_sq", "build_year", "year_month", "floor", "additional_education_km", "catering_km", 
             "big_church_km", "public_healthcare_km", "railroad_km", "preschool_km", "industrial_km", 
             "radiation_km", "big_road1_km", "public_transport_station_km", "cemetery_km",
             "swim_pool_km", "green_zone_km", "big_road2_km", "hospice_morgue_km", "fitness_km",
             "kindergarten_km", "max_floor", "extra_sq", "green_part_1000", "ratio_life_sq_full_sq",
             "age_house", "ratio_kitch_sq_full_sq", "ratio_preschool", "ratio_floor_max_floor",
             "retire_proportion", "raion_popul","year", "preschool_quota", "month", "sub_area", "area_m", "state", "pop_density_raion",
             "full_all", "ratio_school", "ekder_all", "num_room", "school_quota", 
             "sales_per_month", "ratio_kitch_sq_life_sq", "kitch_sq", "floor_from_top")


top_feat_test = c("full_sq", "life_sq", "build_year", "year_month", "floor", "additional_education_km", "catering_km", 
                  "big_church_km", "public_healthcare_km", "railroad_km", "preschool_km", "industrial_km", 
                  "radiation_km", "big_road1_km", "public_transport_station_km", "cemetery_km",
                  "swim_pool_km", "green_zone_km", "big_road2_km", "hospice_morgue_km", "fitness_km",
                  "kindergarten_km", "max_floor", "extra_sq", "green_part_1000", "ratio_life_sq_full_sq",
                  "age_house", "ratio_kitch_sq_full_sq", "ratio_preschool", "ratio_floor_max_floor",
                  "retire_proportion", "raion_popul","year", "preschool_quota", "month", "sub_area", "area_m", "state", "pop_density_raion",
                  "full_all", "ratio_school", "ekder_all", "num_room", "school_quota", 
                  "sales_per_month", "ratio_kitch_sq_life_sq", "kitch_sq", "floor_from_top")

class(train)
train = subset(train_2, select= top_feat)
test = subset(test_2, select = top_feat_test)

# 216 values that are infinite
sum(apply( train, 2, function(.) sum(is.infinite(.)) ))
sum(apply( test, 2, function(.) sum(is.infinite(.)) ))

# get rid of infinite values and nas:
impute.mean = function(x) replace(x, is.na(x) | is.nan(x) | is.infinite(x), mean(x[!is.na(x) & !is.nan(x) & !is.infinite(x)], na.rm=TRUE))
train = apply(train, 2, impute.mean)
sum(apply( train, 2, function(.) sum(is.infinite(.)) ))

test = apply(test, 2, impute.mean)
sum(is.na(test))

names(test)
class(train)

rf.house_2 = randomForest(price_doc ~ ., data = train, importance = TRUE, na.action=na.omit)

treepredictions = predict(rf.house_2,train)
D = as.data.frame(treepredictions)
names(treepredictions)
mean((D$treepredictions-train_2$price_doc)^2)
plot(sort(exp(D$treepredictions)))

median(D$treepredictions)
E = predict(rf.house_2,test)
E = as.data.frame(E)


E$E= exp(E$E)-1
E$id = test_2$id
E = E[,c(2,1)]
names(E) = c('id','price_doc')
write.csv(E, "rf_2.csv", row.names=F)


##############
library(randomForest)

train_2 = read.csv("train_final.csv", stringsAsFactors = TRUE)
test_2 = read.csv("test_final.csv", stringsAsFactors = TRUE)

train_2$price_doc = log(train_2$price_doc+1)

top_feat = c('price_doc', "full_sq", "life_sq", "kitch_sq", "num_room", "floor", 
             "max_floor",  "build_year", "state", "product_type",
             "month_of_year","week_of_year", "day_of_month", "day_of_week", 
             "floor_from_top", "floor_by_maxfloor", "roomsize", "life_proportion", 
             "kitchen_proportion", "extra_area", "age_at_sale", "n_sales_permonth", 
             "distance_from_kremlin", "young_proportion", "work_proportion", 
             "retire_proportion", "mean_building_height", "ratio_preschool",
             "ratio_school", "count_na_perrow")


top_feat_test = c("full_sq", "life_sq", "kitch_sq", "num_room", "floor", 
                  "max_floor", "build_year", "state", "product_type",
                  "month_of_year","week_of_year", "day_of_month", "day_of_week", 
                  "floor_from_top", "floor_by_maxfloor", "roomsize", "life_proportion", 
                  "kitchen_proportion", "extra_area", "age_at_sale", "n_sales_permonth", 
                  "distance_from_kremlin", "young_proportion", "work_proportion", 
                  "retire_proportion", "mean_building_height", "ratio_preschool",
                  "ratio_school", "count_na_perrow")


train = subset(train_2, select= top_feat)
test = subset(test_2, select = top_feat_test)

# sapply(train, class)
# sapply(test, class)


# checking for infinite and Nas
sum(apply( train, 2, function(.) sum(is.infinite(.)) ))
sum(apply( test, 2, function(.) sum(is.infinite(.)) ))

sum(apply( train, 2, function(.) sum(is.na(.)) ))
sum(apply( test, 2, function(.) sum(is.na(.)) ))

# impute nas:
f=function(x){
  x<-as.numeric(as.character(x)) #first convert each column into numeric if it is from factor
  x[is.na(x)] =median(x) #convert the item with NA to median value from the column
  x #display the column
}

train = data.frame(apply(train,2,f))
test = data.frame(apply(test,2,f))

sum(apply( train, 2, function(.) sum(is.na(.)) ))
sum(apply( test, 2, function(.) sum(is.na(.)) ))


rf.house_2 = randomForest(price_doc ~ ., data = train, importance = TRUE, na.action=na.omit)

treepredictions = predict(rf.house_2,train)
D = as.data.frame(treepredictions)
names(treepredictions)
mean((D$treepredictions-train_2$price_doc)^2)
plot(sort(exp(D$treepredictions)))

median(D$treepredictions)
E = predict(rf.house_2,test)
E = as.data.frame(E)


E$E= exp(E$E)-1
E$id = test_2$id
E = E[,c(2,1)]
names(E) = c('id','price_doc')
write.csv(E, "rf_2.csv", row.names=F)




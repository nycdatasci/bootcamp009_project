library(car) 
library(data.table)
library(tidyverse)
library(lubridate)
library(scales)
library(corrplot)
library(DT)
library(VIM)
library(mice)
library(missForest)
library(mlr)
library(stats)
library(DAAG)
library(randomForest)
library(reshape2)
library(e1071)
library(tidyverse)
library(caret)
library(zoo)
library(DMwR)
library(fastmatch)


train_raw <- fread('train.csv', stringsAsFactors=TRUE)
test_raw <- fread('test.csv', stringsAsFactors=TRUE)

dtrain <- train_raw

# state should be between 1-4
dtrain[which(dtrain$state == 33),]$state <- 3

#full_sq cleaning
dtrain <- dtrain %>% mutate(full_sq = replace(full_sq, full_sq == 0, NA))
dtrain <- dtrain %>% mutate(full_sq = replace(full_sq, full_sq == 1, NA))
dtrain <- dtrain %>% mutate(full_sq = replace(full_sq, full_sq == 2, NA))
dtrain <- dtrain %>% mutate(full_sq = replace(full_sq, full_sq == 5326, NA))
sum(is.na(dtrain$full_sq))

# full_sq imputation with mean
full.sub_area.mean <- dtrain %>% select_('full_sq','sub_area') %>% group_by(sub_area) %>% 
  summarise(full_mean = mean(full_sq ,na.rm = TRUE))
dtrain <- left_join(dtrain, full.sub_area.mean, by = 'sub_area')
na.index <- which(is.na(dtrain$full_sq))
dtrain[na.index,"full_sq"] <- dtrain[na.index,"full_mean"]
sum(is.na(dtrain$full_sq))
dtrain <- dtrain[,-293]

# life sq
sum(dtrain$life_sq > dtrain$full_sq, na.rm=TRUE)
dtrain <- dtrain %>% mutate(life_sq = replace(life_sq, life_sq == 7478, NA))
dtrain$life_sq <- as.numeric(dtrain$life_sq)
dtrain[which(dtrain$life_sq > dtrain$full_sq),]$life_sq 
dtrain[which(dtrain$life_sq > dtrain$full_sq),]$full_sq
dtrain[which(dtrain$life_sq > dtrain$full_sq),]$life_sq  <-  NA
dtrain[which(dtrain$life_sq == 0),]$life_sq <- NA
dtrain[which(dtrain$life_sq == 1),]$life_sq <- NA

sum(is.na(dtrain$life_sq))
dtrain[which(dtrain$life_sq > dtrain$full_sq),]$life_sq
dtrain[which(dtrain$life_sq > dtrain$full_sq),]$full_sq


# life in test set
sum(test_raw$life_sq > test_raw$full_sq, na.rm = TRUE)
test_raw[which(test_raw$life_sq > test_raw$full_sq),]$life_sq  <- NA

table(dtrain$mosque_count_1000)
# build year
dtrain[which(dtrain$build_year == 20052009),]$build_year <- 2007
dtrain[which(dtrain$build_year == 4965),]$build_year <- 1965
dtrain[which(dtrain$build_year < 1800),]$build_year <- NA

# num of rooms 
dtrain[which(dtrain$num_room > 10),]$num_room <- NA
dtrain[which(dtrain$num_room == 0),]$num_room <- NA

table(dtrain$mosque_count_1000)

#kitch_Sq
dtrain$kitch_sq <- as.numeric(dtrain$kitch_sq)
dtrain[which(dtrain$kitch_sq==1970),]$build_year = 1970
dtrain[which(dtrain$kitch_sq==1970),]$kitch_sq = NA
dtrain[which(dtrain$kitch_sq==1974),]$build_year = 1974
dtrain[which(dtrain$kitch_sq==1974),]$kitch_sq = NA
dtrain[which(dtrain$kitch_sq==2013),]$build_year = 2013
dtrain[which(dtrain$kitch_sq==2013),]$kitch_sq = NA
dtrain[which(dtrain$kitch_sq==2014),]$build_year = 2014
dtrain[which(dtrain$kitch_sq==2014),]$kitch_sq = NA
dtrain[which(dtrain$kitch_sq==620),]$kitch_sq = NA
table(dtrain$mosque_count_1000)
dtrain[which(dtrain$kitch_sq > dtrain$full_sq),]$kitch_sq # same as above
dtrain[which(dtrain$kitch_sq > dtrain$full_sq),]  <-  NA
dtrain[which(dtrain$kitch_sq > dtrain$full_sq),]$kitch_sq # same as above
table(dtrain$mosque_count_1000)

# floor
dtrain[which(dtrain$floor==77),]$floor = NA
dtrain$max_floor <- 
  ifelse(dtrain$floor > dtrain$max_floor, 
         dtrain$floor,
         dtrain$max_floor)

dtrain$timestamp <- ymd(dtrain$timestamp)
test_raw$timestamp <- as.Date(test_raw$timestamp)

dtrain_cleanish <- dtrain

table(dtrain$mosque_count_1000)

# dropping variables
test.merge <- test_raw %>% mutate(price_doc = NA) %>% mutate(train_or_test = 'test')
train.merge <- dtrain_cleanish %>% mutate(train_or_test = 'train')
data.full <- rbind2(train.merge,test.merge, use.names = T, fill = T) 

miss_pct <- map_dbl(data.full, function(x) { round((sum(is.na(x)) / length(x)) * 100, 1) })

miss_pct <- miss_pct[miss_pct > 0]

miss_pct


library(data.table)
library(DT)
library(dplyr)
library(randomForest)
library(tidyverse)
library(caret)
library(zoo)
library(pracma)

total <- data.full

# imputing num_room with median group_by sub_area
#total$num_room <- na.aggregate(total$num_room, by = total$sub_area, FUN = median)


impute_room <- mice(total[,c(3,9)])
total$num_room <- complete(impute_room)$num_room


total[which(total$kitch_sq>total$full_sq),10 ] <- NA
total[which(total$kitch_sq>100),10 ] <- NA

#total$kitch_sq<-
#  na.aggregate(total$kitch_sq, by = total$sub_area, FUN = median)

# imputing life_sq with median group_by sub_area

# total$life_sq <- na.aggregate(total$life_sq, by = total$sub_area, FUN = median)


# build_year information missing all listings in a single raion
convert <- fread("./name_list.csv", stringsAsFactors = TRUE)
total_region <- left_join(total,convert, by="sub_area")

total_region[is.na(total_region$raion_build_count_with_builddate_info),] %>%
  group_by(sub_area) %>% summarise(count=n())

total_sub_area_bild_count <- total_region %>% 
  dplyr::select(sub_area, OKRUG,
                raion_build_count_with_builddate_info, 
                build_count_before_1920,
                `build_count_1921-1945`,
                `build_count_1946-1970`,
                `build_count_1971-1995`,
                build_count_after_1995) %>%
  dplyr::group_by(sub_area) %>% 
  dplyr::filter(row_number()==1) %>%
  dplyr::group_by(OKRUG) %>%
  dplyr::summarise(total_build = 
                     sum(raion_build_count_with_builddate_info),
                   total_before_1920 = 
                     sum(build_count_before_1920),
                   total_1921_1945 = 
                     sum(`build_count_1921-1945`),
                   total_1946_1970 = 
                     sum(`build_count_1946-1970`),
                   total_1971_1995 = 
                     sum(`build_count_1971-1995`),
                   total_after_1995 = 
                     sum(build_count_after_1995)) %>%
  dplyr::mutate(ratio_before_1920 = 
                  total_before_1920/total_build,
                ratio_1921_1945 = 
                  total_1921_1945/total_build,
                ratio_1946_1970 = 
                  total_1946_1970/total_build,
                ratio_1971_1995 = 
                  total_1971_1995/total_build,
                ratio_after_1995 = 
                  total_after_1995/total_build)
View(total_sub_area_bild_count)

total_sub_area_bild_count <- total_sub_area_bild_count[-13,]

# all of them are missing in the entire region...so cannot input based on that
# impute based on a combination of western and south-western regions closes 
# to the missing areas
#before 1920
total_sub_area_bild_count[6,]$ratio_before_1920 = (6052*0.014 + 4408*0.0082)/(6052+4408)
total_sub_area_bild_count[10,]$ratio_before_1920 = (6052*0.014 + 4408*0.0082)/(6052+4408)

#1921 - 1945
total_sub_area_bild_count[6,]$ratio_1921_1945 = (6052*0.122 + 4408*0.069)/(6052+4408)
total_sub_area_bild_count[10,]$ratio_1921_1945 = (6052*0.122 + 4408*0.069)/(6052+4408)

#1946 - 1970
total_sub_area_bild_count[6,]$ratio_1946_1970 = (6052*0.498 + 4408*0.45)/(6052+4408)
total_sub_area_bild_count[10,]$ratio_1946_1970 = (6052*0.498 + 4408*0.45)/(6052+4408)

#1971 - 1995
total_sub_area_bild_count[6,]$ratio_1971_1995 = (6052*0.191 + 4408*0.21)/(6052+4408)
total_sub_area_bild_count[10,]$ratio_1971_1995 = (6052*0.191 + 4408*0.21)/(6052+4408)

#after 1995
total_sub_area_bild_count[6,]$ratio_after_1995 = (6052*0.176 + 4408*0.26)/(6052+4408)
total_sub_area_bild_count[10,]$ratio_after_1995 = (6052*0.176 + 4408*0.26)/(6052+4408)

final_build_count <- total_sub_area_bild_count %>% dplyr::select(OKRUG,
                                                                 ratio_before_1920,
                                                                 ratio_1921_1945,
                                                                 ratio_1946_1970,
                                                                 ratio_1971_1995,
                                                                 ratio_after_1995)

final_build_count <- final_build_count %>% dplyr::select(OKRUG,
                                                         ratio_1920_ok = ratio_before_1920,
                                                         ratio_1921_ok = ratio_1921_1945,
                                                         ratio_1946_ok = ratio_1946_1970,
                                                         ratio_1971_ok = ratio_1971_1995,
                                                         ratio_1995_ok = ratio_after_1995)

# adding in ratio of building age

total <- left_join(total, convert, by = "sub_area")
total <- left_join(total, final_build_count, by = "OKRUG")
total <- total %>% dplyr::mutate(ratio_1920 = build_count_before_1920/raion_build_count_with_builddate_info,
                                 ratio_1921 = `build_count_1921-1945`/raion_build_count_with_builddate_info,
                                 ratio_1946 = `build_count_1946-1970`/raion_build_count_with_builddate_info,
                                 ratio_1971 = `build_count_1971-1995`/raion_build_count_with_builddate_info,
                                 ratio_1995 = build_count_after_1995/raion_build_count_with_builddate_info)

total[which(is.na(total$raion_build_count_with_builddate_info)),]$ratio_1920 <- total[which(is.na(total$raion_build_count_with_builddate_info)),]$ratio_1920_ok
total[which(is.na(total$raion_build_count_with_builddate_info)),]$ratio_1921 <- total[which(is.na(total$raion_build_count_with_builddate_info)),]$ratio_1921_ok
total[which(is.na(total$raion_build_count_with_builddate_info)),]$ratio_1946 <- total[which(is.na(total$raion_build_count_with_builddate_info)),]$ratio_1946_ok
total[which(is.na(total$raion_build_count_with_builddate_info)),]$ratio_1971 <- total[which(is.na(total$raion_build_count_with_builddate_info)),]$ratio_1971_ok
total[which(is.na(total$raion_build_count_with_builddate_info)),]$ratio_1995 <- total[which(is.na(total$raion_build_count_with_builddate_info)),]$ratio_1995_ok

total.full <- total

total <- total %>% dplyr::select(-ratio_1920_ok,
                                 -ratio_1921_ok,
                                 -ratio_1946_ok,
                                 -ratio_1971_ok,
                                 -ratio_1995_ok)


miss_pct <- map_dbl(total, function(x) { round((sum(is.na(x)) / length(x)) * 100, 1) })

miss_pct <- miss_pct[miss_pct > 0]

miss_pct






#buliding 
material_index <- total %>% dplyr::select(sub_area,OKRUG,
                                          raion_build_count_with_material_info,
                                          build_count_block,
                                          build_count_wood,
                                          build_count_frame,
                                          build_count_brick,
                                          build_count_monolith,
                                          build_count_panel,
                                          build_count_foam,
                                          build_count_slag,
                                          build_count_mix) %>%
  dplyr::group_by(OKRUG) %>%
  dplyr::summarise(total_build = sum(raion_build_count_with_material_info),
                   total_block = sum(build_count_block),
                   total_wood = sum(build_count_wood),
                   total_frame = sum(build_count_frame),
                   total_brick = sum(build_count_brick),
                   total_monolith = sum(build_count_monolith),
                   total_panel = sum(build_count_panel),
                   total_foam = sum(build_count_foam),
                   total_slag = sum(build_count_slag),
                   total_mix = sum(build_count_mix)) %>%
  dplyr::mutate(ratio_block = total_block/total_build,
                ratio_wood = total_wood/total_build,
                ratio_frame = total_frame/total_build,
                ratio_brick = total_brick/total_build,
                ratio_monolith = total_monolith/total_build,
                ratio_panel = total_panel/total_build,
                ratio_foam = total_foam/total_build,
                ratio_slag = total_slag/total_build,
                ratio_mix = total_mix/total_build) %>%
  dplyr::select(OKRUG,
                total_build,
                ratio_block,
                ratio_wood,
                ratio_frame,
                ratio_brick,
                ratio_monolith,
                ratio_panel,
                ratio_foam,
                ratio_slag,
                ratio_mix)
View(material_index)
#ratio_block
material_index[6,]$ratio_block = (1489829*0.0949+1591137*0.176)/(1489829+1591137)
material_index[10,]$ratio_block = (1489829*0.0949+1591137*0.176)/(1489829+1591137)

#ratio_wood
material_index[6,]$ratio_wood = (1489829*0.283+1591137*0.218)/(1489829+1591137)
material_index[10,]$ratio_wood = (1489829*0.283+1591137*0.218)/(1489829+1591137)

#ratio_frame
material_index[6,]$ratio_frame = (1489829*0.0567+1591137*0.00679)/(1489829+1591137)
material_index[10,]$ratio_frame = (1489829*0.0567+1591137*0.00679)/(1489829+1591137)

#ratio_brick
material_index[6,]$ratio_brick = (1489829*0.259+1591137*0.171)/(1489829+1591137)
material_index[10,]$ratio_brick = (1489829*0.259+1591137*0.171)/(1489829+1591137)

#ratio_monolith
material_index[6,]$ratio_monolith = (1489829*0.038+1591137*0.0516)/(1489829+1591137)
material_index[10,]$ratio_monolith = (1489829*0.038+1591137*0.0516)/(1489829+1591137)

#ratio_panel
material_index[6,]$ratio_panel = (1489829*0.246+1591137*0.344)/(1489829+1591137)
material_index[10,]$ratio_panel = (1489829*0.246+1591137*0.344)/(1489829+1591137)

#ratio_foam
material_index[6,]$ratio_foam = (1489829*0.00033+1591137*0.00036)/(1489829+1591137)
material_index[10,]$ratio_foam = (1489829*0.00033+1591137*0.00036)/(1489829+1591137)

mat.tot_join <- left_join(total,material_index)

miss_pct <- map_dbl(mat.tot_join, function(x) { round((sum(is.na(x)) / length(x)) * 100, 1) })

miss_pct <- miss_pct[miss_pct > 0]

miss_pct

total <- mat.tot_join




# life imputation
data.full.life.knn <- select_(total, 'full_sq', 'life_sq', 'num_room','cafe_count_1500')
#life.knn.imp = knnImputation(data.full.life.knn,k=173,meth = 'weighAvg')
#total$life_sq <- life.knn.imp$life_sq

impute_life <- mice(data.full.life.knn)
total$life_sq <- complete(impute_life)$life_sq


total$kitch_sq <- na.aggregate(total$kitch_sq, by = total$sub_area, FUN = median)
total$build_year <- na.aggregate(total$build_year, by = total$sub_area, FUN = median)




# full_sq and floor imp

total$full_sq <- na.aggregate(total$full_sq, by = total$sub_area, FUN = mean)
total$floor <- na.aggregate(total$floor, by = total$sub_area, FUN = median)
total$metro_min_walk <- na.aggregate(total$metro_min_walk, by = total$sub_area, FUN = mean)
total$metro_km_walk <- na.aggregate(total$metro_km_walk, by = total$sub_area, FUN = median)
total$ID_railroad_station_walk <- na.aggregate(total$ID_railroad_station_walk, by = total$sub_area, FUN = median)
total$cafe_sum_5000_min_price_avg <- na.aggregate(total$cafe_sum_5000_min_price_avg, by = total$sub_area, FUN = median)
total$cafe_sum_3000_max_price_avg <- na.aggregate(total$cafe_sum_3000_max_price_avg, by = total$sub_area, FUN = median)
total$cafe_sum_2000_max_price_avg <- na.aggregate(total$cafe_sum_2000_max_price_avg, by = total$sub_area, FUN = median)
total$cafe_sum_5000_max_price_avg <- na.aggregate(total$cafe_sum_5000_max_price_avg, by = total$sub_area, FUN = median)
total$cafe_avg_price_5000 <- na.aggregate(total$cafe_avg_price_5000, by = total$sub_area, FUN = median)
total$cafe_avg_price_2000 <- na.aggregate(total$cafe_avg_price_2000, by = total$sub_area, FUN = median)
total$prom_part_5000 <- na.aggregate(total$prom_part_5000, by = total$sub_area, FUN = median)
total$cafe_sum_5000_min_price_avg <- na.aggregate(total$cafe_sum_5000_min_price_avg, by = total$sub_area, FUN = median)
total$cafe_sum_3000_min_price_avg <- na.aggregate(total$cafe_sum_3000_min_price_avg, by = total$sub_area, FUN = median)
total$cafe_sum_2000_min_price_avg <- na.aggregate(total$cafe_sum_2000_min_price_avg, by = total$sub_area, FUN = median)
total$cafe_sum_5000_min_price_avg <- na.aggregate(total$cafe_sum_5000_min_price_avg, by = total$sub_area, FUN = median)
total$cafe_sum_5000_max_price_avg <- na.aggregate(total$cafe_sum_5000_max_price_avg, by = total$sub_area, FUN = median)
total$cafe_avg_price_5000 <- na.aggregate(total$cafe_avg_price_5000, by = total$sub_area, FUN = median)
total$cafe_avg_price_2000 <- na.aggregate(total$cafe_avg_price_2000, by = total$sub_area, FUN = median)
total$cafe_sum_2000_min_price_avg <- na.aggregate(total$cafe_sum_2000_min_price_avg, by = total$sub_area, FUN = median)
total$railroad_station_walk_min <- na.aggregate(total$railroad_station_walk_min, by = total$sub_area, FUN = median)
total$railroad_station_walk_km <- na.aggregate(total$railroad_station_walk_km, by = total$sub_area, FUN = median)



miss_pct <- map_dbl(total, function(x) { round((sum(is.na(x)) / length(x)) * 100, 1) })

miss_pct <- miss_pct[miss_pct > 0]

miss_pct





droppers <-  c('hospital_beds_raion','cafe_sum_500_max_price_avg','cafe_sum_500_min_price_avg','cafe_avg_price_500',
               'cafe_avg_price_1000','cafe_sum_1000_max_price_avg','cafe_sum_1000_min_price_avg',
               'raion_build_count_with_builddate_info','build_count_mix','build_count_slag','build_count_foam',
               'build_count_panel','build_count_monolith','build_count_brick','build_count_after_1995',
               'build_count_1946-1970','build_count_1971-1995','build_count_before_1920','build_count_frame',
               'build_count_wood','build_count_block','build_count_1921-1945','raion_build_count_with_material_info')

droppers2 <- c('cafe_avg_price_1500', 'cafe_sum_1500_max_price_avg', 'cafe_avg_price_1500', 'cafe_sum_2000_min_price_avg',
               'cafe_sum_5000_min_price_avg', 'cafe_sum_5000_max_price_avg', 'cafe_sum_3000_max_price_avg', 
               'cafe_sum_2000_max_price_avg', 'cafe_avg_price_2000', 'cafe_sum_5000_min_price_avg', 'cafe_avg_price_5000')

droppers3 <- c('cafe_sum_5000_max_price_avg', 'cafe_avg_price_5000', 'cafe_sum_5000_min_price_avg','cafe_avg_price_2000',
               'cafe_sum_2000_min_price_avg')

# missing removal
miss_pct <- map_dbl(total, function(x) { round((sum(is.na(x)) / length(x)) * 100, 1) })

miss_pct <- miss_pct[miss_pct > 0]

miss_pct


fmatch(droppers3,names(total))





train_final <- total[total$train_or_test=="train",]
test_final <- total[total$train_or_test=='test',]

write.csv(train_final, "train_final.csv")
write.csv(test_final, "test_final.csv")
write.csv(total, "total_final.csv")

miss_pct <- map_dbl(total, function(x) { round((sum(is.na(x)) / length(x)) * 100, 1) })

miss_pct <- miss_pct[miss_pct > 0]

miss_pct

macro <- fread('macro.csv', stringsAsFactors = TRUE)
macro$timestamp <- as.Date(macro$timestamp)

macro_trim <- macro[,c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)]

miss_pct <- map_dbl(total_final_macro, function(x) { round((sum(is.na(x)) / length(x)) * 100, 1) })

miss_pct <- miss_pct[miss_pct > 0]

miss_pct


train_final <- train_final[complete.cases(train_final[,2]),]
summary(train_final$timestamp)
date1_train <- min(train_final$timestamp)
date2_train <- max(train_final$timestamp)
date1_test <- min(test_final$timestamp)
date2_test <- max(test_final$timestamp)


macro_train <- macro_trim %>% filter(date1_train <= timestamp & timestamp <= date2_train)
macro_test <- macro_trim %>% filter(date1_test <= timestamp & timestamp <= date2_test)


train_final_macro <- left_join(train_final,macro_train, by = "timestamp")
test_final_macro <- left_join(test_final,macro_test, by = "timestamp")
total_final_macro <- left_join(total,macro_trim)

write.csv(train_final_macro, "train_final_macro.csv")
write.csv(test_final_macro, "test_final_macro.csv")
write.csv(total_final_macro, "total_final_macro.csv")



table(total$market_count_1000)
table(total$market_count_5000)


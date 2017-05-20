# @author Scott Dobbins
# @date 2017-05-19 05:30
# @version 0.5

### import packages ###
library(data.table)
library(dplyr)
library(tidyr)


### set global constants ###
test_classes <- c(rep("integer", 1), 
                  rep("character", 1), 
                  rep("double", 2), 
                  rep("integer", 2),
                  rep("factor", 1), 
                  rep("integer", 2), 
                  rep("double", 1), 
                  rep("factor", 3), 
                  rep("double", 1), 
                  rep("integer", 1), 
                  rep("double", 2), 
                  rep("integer", 12), 
                  rep("factor", 1), 
                  rep("integer", 3), 
                  rep("factor", 8), 
                  rep("integer", 44), 
                  rep("double", 14), 
                  rep("integer", 1), 
                  rep("double", 2), 
                  rep("integer", 1), 
                  rep("double", 3), 
                  rep("factor", 1), 
                  rep("double", 6), 
                  rep("integer", 1), 
                  rep("factor", 1), 
                  rep("double", 1), 
                  rep("integer", 1), 
                  rep("double", 1), 
                  rep("factor", 1), 
                  rep("double", 1), 
                  rep("integer", 1), 
                  rep("double", 1), 
                  rep("integer", 1), 
                  rep("double", 29), 
                  rep("factor", 1), 
                  rep("double", 2), 
                  rep("integer", 5), 
                  rep("double", 3),
                  rep("integer", 13), 
                  rep("double", 2), 
                  rep("integer", 5), 
                  rep("double", 3),
                  rep("integer", 13), 
                  rep("double", 2), 
                  rep("integer", 5), 
                  rep("double", 3),
                  rep("integer", 13), 
                  rep("double", 2), 
                  rep("integer", 5), 
                  rep("double", 3),
                  rep("integer", 13), 
                  rep("double", 2), 
                  rep("integer", 5), 
                  rep("double", 3),
                  rep("integer", 13), 
                  rep("double", 2), 
                  rep("integer", 5), 
                  rep("double", 3), 
                  rep("integer", 13))

train_classes <- c(test_classes, "integer")


### read csv files ###
train <- fread('data/train.csv', 
               header = TRUE, 
               stringsAsFactors = FALSE,
               colClasses = train_classes)
test <- fread('data/test.csv', 
              header = TRUE, 
              stringsAsFactors = FALSE,
              colClasses = test_classes)


### move raion data to separate file ###
raion_train <- train[,13:84]
raion_test <- test[,13:84]
raion_train[, sub_area := as.factor(sub_area)]
raion_test[, sub_area := as.factor(sub_area)]
setkey(raion_train, sub_area)
setkey(raion_test, sub_area)
raion_train <- unique(raion_train)
raion_test <- unique(raion_test)
raion <- rbind(raion_train, raion_test)
setkey(raion, sub_area)
raion <- unique(raion)
fwrite(raion, file = 'data/raion.csv', append = FALSE)
train[,14:84 := NULL]
test[,14:84 := NULL]


### set keys ###
setkey(train, id)
setkey(test, id)


### initial cleaning ###
train[life_sq <= 1, c("life_sq")] <- NA
test[life_sq <= 1, c("life_sq")] <- NA

train[full_sq <= 1, c("full_sq")] <- NA
test[full_sq <= 1, c("full_sq")] <- NA

train[life_sq > full_sq, life_sq := life_sq / 10]
train[life_sq > full_sq, life_sq := life_sq / 10]
test[life_sq > full_sq, life_sq := life_sq / 10]
test[life_sq > full_sq, life_sq := life_sq / 10]

train[full_sq >= 10*life_sq, full_sq := full_sq / 10]
train[full_sq >= 10*life_sq, full_sq := full_sq / 10]
test[full_sq >= 10*life_sq, full_sq := full_sq / 10]
test[full_sq >= 10*life_sq, full_sq := full_sq / 10]

train[floor < 1 | floor > 76, c("floor")] <- NA
test[floor < 1 | floor > 76, c("floor")] <- NA

train[max_floor < 1 | max_floor > 76, c("max_floor")] <- NA
test[max_floor < 1 | max_floor > 76, c("max_floor")] <- NA

train[floor > max_floor, c("max_floor")] <- NA
test[floor > max_floor, c("max_floor")] <- NA

train[!(material %in% c(1,2,4,5,6)), c("material")] <- NA
test[!(material %in% c(1,2,4,5,6)), c("material")] <- NA

train[build_year <= 1, c("build_year")] <- NA
test[build_year <= 1, c("build_year")] <- NA

train[build_year < 100, build_year := build_year + 1900L]
test[build_year < 100, build_year := build_year + 1900L]

train[build_year < 150, c("build_year")] <- NA
test[build_year < 150, c("build_year")] <- NA

train[build_year < 217, build_year := (build_year - (build_year %% 100)) + 1800L + (build_year %% 100)]
test[build_year < 217, build_year := (build_year - (build_year %% 100)) + 1800L + (build_year %% 100)]

train[build_year < 1850 | build_year > 2017, c("build_year")] <- NA
test[build_year < 1850 | build_year > 2017, c("build_year")] <- NA

train[num_room == 0, c("num_room")] <- 1
test[num_room == 0, c("num_room")] <- 1

train[num_room >= 10, c("num_room")] <- NA
test[num_room >= 10, c("num_room")] <- NA

train[kitch_sq <= 1 | kitch_sq > 25, c("kitch_sq")] <- NA
test[kitch_sq <= 1 | kitch_sq > 25, c("kitch_sq")] <- NA

train[!(state %in% c(1,2,3,4)), c("state")] <- NA
test[!(state %in% c(1,2,3,4)), c("state")] <- NA


### create new columns ###
train[, log_price := log(price_doc)]
train[, log_fullsq := log(full_sq)]
train[, log_lifesq := log(life_sq)]
train[, log_10p_floor := log(10+floor)]
train[, log_10p_maxfloor := log(10+max_floor)]
train[, log_1p_numroom := log(1+num_room)]
train[, log_kitchsq := log(kitch_sq)]
train[, price_per_room := price_doc / num_room]
train[, price_per_fullsq := price_doc / full_sq]
train[, log_price_per_10p_log_room := log(price_doc) / (10+log(num_room))]
train[, log_price_per_log_fullsq := log(price_doc) / log(full_sq)]


### further cleaning ###
train[full_sq > 250 & log_price < 16.5, full_sq := full_sq / 10]
train[life_sq > full_sq, life_sq := life_sq / 10]
train[price_per_fullsq > 5e5 & full_sq < 25, c("full_sq", "life_sq", "log_fullsq", "log_lifesq", "price_per_fullsq", "log_price_per_log_fullsq") := list(full_sq * 10, life_sq * 10, log_fullsq + log(10), log_lifesq + log(10), price_per_fullsq / 10, log_price_per_log_fullsq - log(10))]
train[price_per_fullsq > 5e5, c("price_doc", "log_price", "price_per_fullsq", "log_price_per_log_fullsq") := list(as.integer(price_doc / 10), log(price_doc / 10), price_per_fullsq / 10, log_price_per_log_fullsq - log(10))]


### write clean data to files ###
fwrite(train, file = 'data/train_clean.csv', append = FALSE)
fwrite(test, file = 'data/test_clean.csv', append = FALSE)


### exploratory model time ###
train_simple <- train[complete.cases(train),c(1,3:11,14,222:229)]
library(MASS)
mlr_model_empty <- lm(log_price ~ 1, data = train_simple)
mlr_model_full <- lm(log_price ~ ., data = train_simple)
scope <- list(lower = formula(mlr_model_empty), upper = formula(mlr_model_full))

BIC_empty_both <- step(mlr_model_empty, scope, direction = "both", k = log(30471))
BIC_full_both <- step(mlr_model_full, scope, direction = "both", k = log(30471))

summary(BIC_empty_both)
summary(BIC_full_both)


### exploratory categorization time ###
raions <- train %>% group_by(sub_area) %>% summarize(log_price = mean(log_price), log_price_per_log_fullsq = mean(log_price_per_log_fullsq, na.rm = TRUE))
states <- train %>% group_by(state) %>% summarize(log_price = mean(log_price), log_price_per_log_fullsq = mean(log_price_per_log_fullsq, na.rm = TRUE))
floors <- train %>% group_by(floor) %>% summarize(log_price = mean(log_price), log_price_per_log_fullsq = mean(log_price_per_log_fullsq, na.rm = TRUE))
max_floors <- train %>% group_by(max_floor) %>% summarize(log_price = mean(log_price), log_price_per_log_fullsq = mean(log_price_per_log_fullsq, na.rm = TRUE))
materials <- train %>% group_by(material) %>% summarize(log_price = mean(log_price), log_price_per_log_fullsq = mean(log_price_per_log_fullsq, na.rm = TRUE))
products <- train %>% group_by(product_type) %>% summarize(log_price = mean(log_price), log_price_per_log_fullsq = mean(log_price_per_log_fullsq, na.rm = TRUE))
rooms <- train %>% group_by(num_room) %>% summarize(log_price = mean(log_price), log_price_per_log_fullsq = mean(log_price_per_log_fullsq, na.rm = TRUE))


### mega model ###
models <- rep(list(rep(list(list()), nrow(states))), nrow(raions))

r_sq_sum <- 0
r_sq_adj_sum <- 0
model_count <- 0

for(raion in 1:nrow(raions)) {
  for(state in 1:nrow(states)) {
    subset <- train[train$sub_area == raions$sub_area[raion] & train$state == states$state[state],]
    if(nrow(subset) > 1) {
      if(!is.na(sum(complete.cases(subset)))) {
        model <- lm(formula = log_price ~ log_fullsq + log_kitchsq + log_lifesq + num_room + floor + max_floor, data = subset)
        model_summary <- summary(model)
        coefficients <- model$coefficients
        r_sq_sum <- r_sq_sum + model_summary$r.squared
        r_sq_adj_sum <- r_sq_adj_sum + model_summary$adj.r.squared
        model_count <- model_count + 1
      } else {
        coefficients <- list('(Intercept)' = 0, log_fullsq = 0, log_kitchsq = 0, log_lifesq = 0, num_room = 0, floor = 0, max_floor = 0)
        model <- list(r.squared = NA, adj.r.squared = NA)
      }
    } else {
      coefficients <- list('(Intercept)' = 0, log_fullsq = 0, log_kitchsq = 0, log_lifesq = 0, num_room = 0, floor = 0, max_floor = 0)
      model <- list(r.squared = NA, adj.r.squared = NA)
    }
    models[[raion]][[state]] <- list(c(unlist(coefficients), model$r.squared, model$adj.r.squared))
  }
}

avg_r_sq <- r_sq_sum / model_count
avg_r_sq_adj <- r_sq_adj_sum / model_count

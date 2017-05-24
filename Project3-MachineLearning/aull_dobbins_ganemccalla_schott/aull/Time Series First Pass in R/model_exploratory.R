# @author Scott Dobbins
# @date 2017-05-22 21:00
# @version 0.6.2

### import packages (in ascending order of importance) ###

# standard libraries
library(MASS)
library(tidyr)
library(data.table)
library(lubridate)
library(dplyr)

# helper files
source_directory <- 'Kaggle/'
data_processor_filename <- 'data_processor.R'
source(file = paste0(source_directory, data_processor_filename))


### get data ###
data_list <- refresh_data()
train <- data_list[['train']]
test <- data_list[['test']]
raion <- data_list[['raion']]
yearly <- data_list[['yearly']]
quarterly <- data_list[['quarterly']]
monthly <- data_list[['monthly']]
daily <- data_list[['daily']]


### exploratory model time ###
train_simple <- train[complete.cases(train), c(1,3:13,225:231)]
mlr_model_empty <- lm(log_price ~ 1, data = train_simple)
mlr_model_full <- lm(log_price ~ ., data = train_simple)
scope <- list(lower = formula(mlr_model_empty), upper = formula(mlr_model_full))

train_k <- log(nrow(train))
train_BIC_empty_both <- step(mlr_model_empty, scope, direction = "both", k = train_k)
#train_BIC_full_both <- step(mlr_model_full, scope, direction = "both", k = train_k)

#summary(train_BIC_empty_both)
#summary(train_BIC_full_both)


### exploratory categorization time ###
raions <- train[, .(log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE)), by = sub_area]
states <- train[, .(log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE)), by = state]
floors <- train[, .(log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE)), by = floor]
max_floors <- train[, .(log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE)), by = max_floor]
materials <- train[, .(log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE)), by = material]
products <- train[, .(log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE)), by = product_type]
rooms <- train[, .(log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE)), by = num_room]
yearlies <- train[, .(log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE)), by = year]
quarterlies <- train[, .(log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE)), by = quarter]
monthlies <- train[, .(log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE)), by = month]


### mega model ###

# raion
init_data <- rep(0, nrow(raions))

models_num <- array(data = init_data, dim = c(nrow(raions)))
models_intercept <- array(data = init_data, dim = c(nrow(raions)))
models_log_fullsq <- array(data = init_data, dim = c(nrow(raions)))
models_log_kitchsq <- array(data = init_data, dim = c(nrow(raions)))
models_log_lifesq <- array(data = init_data, dim = c(nrow(raions)))
models_numroom <- array(data = init_data, dim = c(nrow(raions)))
models_floor <- array(data = init_data, dim = c(nrow(raions)))
models_maxfloor <- array(data = init_data, dim = c(nrow(raions)))
models_r_squared <- array(data = init_data, dim = c(nrow(raions)))
models_adj_r_squared <- array(data = init_data, dim = c(nrow(raions)))

r_sq_sum <- 0
r_sq_adj_sum <- 0
model_count <- 0

for(raion in 1:nrow(raions)) {
  subset <- train[sub_area == raions$sub_area[raion],]
  subset <- subset[complete.cases(subset), .(log_price, log_fullsq, log_kitchsq, log_lifesq, num_room, floor, max_floor)]
  models_num[raion] <- models_num[raion] + nrow(subset)
  if(nrow(subset) > 7) {
    model <- lm(formula = log_price ~ log_fullsq + log_kitchsq + log_lifesq + num_room + floor + max_floor, data = subset)
    model_summary <- summary(model)
    coefficients <- model$coefficients
    if(is.na(model_summary$adj.r.squared)) print(paste0("raion: ", toString(raion)))
    r_sq_sum <- r_sq_sum + model_summary$r.squared
    r_sq_adj_sum <- r_sq_adj_sum + model_summary$adj.r.squared
    model_count <- model_count + 1
  } else {
    coefficients <- list('(Intercept)' = 0, log_fullsq = 0, log_kitchsq = 0, log_lifesq = 0, num_room = 0, floor = 0, max_floor = 0)
    model_summary <- list(r.squared = NA, adj.r.squared = NA)
  }
  models_intercept[raion] <- coefficients[['(Intercept)']]
  models_log_fullsq[raion] <- coefficients[['log_fullsq']]
  models_log_kitchsq[raion] <- coefficients[['log_kitchsq']]
  models_log_lifesq[raion] <- coefficients[['log_lifesq']]
  models_numroom[raion] <- coefficients[['num_room']]
  models_floor[raion] <- coefficients[['floor']]
  models_maxfloor[raion] <- coefficients[['max_floor']]
  models_r_squared[raion] <- model_summary[['r.squared']]
  models_adj_r_squared[raion] <- model_summary[['adj.r.squared']]
}

avg_r_sq <- r_sq_sum / model_count
avg_r_sq_adj <- r_sq_adj_sum / model_count



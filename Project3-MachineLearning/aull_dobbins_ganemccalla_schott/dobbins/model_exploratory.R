# @author Scott Dobbins
# @date 2017-05-20 21:00
# @version 0.5

### import packages (in ascending order of importance) ###

# standard libraries
library(MASS)
library(tidyr)
library(data.table)
library(dplyr)

# helper files
source_directory <- 'Kaggle/'
data_processor_filename <- 'data_processor.R'
source(file = paste0(source_directory, data_processor_filename))


### get data ###
refresh_data()


### exploratory model time ###
train_simple <- train[complete.cases(train),c(1,3:11,14,222:228)]
mlr_model_empty <- lm(log_price ~ 1, data = train_simple)
mlr_model_full <- lm(log_price ~ ., data = train_simple)
scope <- list(lower = formula(mlr_model_empty), upper = formula(mlr_model_full))

train_k <- log(nrow(train))
BIC_empty_both <- step(mlr_model_empty, scope, direction = "both", k = train_k)
BIC_full_both <- step(mlr_model_full, scope, direction = "both", k = train_k)

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

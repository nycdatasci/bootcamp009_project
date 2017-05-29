# @author Scott Dobbins
# @date 2017-05-28 19:00
# @version 0.9

### import packages (in ascending order of importance) ###

# standard libraries
library(MASS)
library(psych)
library(tidyr)
library(data.table)
library(lubridate)
library(dplyr)

# helper files
source_directory <- 'Kaggle/'
data_processor_filename <- 'data_processor.R'
source(file = paste0(source_directory, data_processor_filename))

# global variables
write_directory <- 'Kaggle/submissions/'
submissions_filename <- 'submission_Scott.csv'
pca_cols <- c(14:220)
price_cols <- c(15, 57:60)
all_price_cols <- c(221, 262:266)
transformed_cols <- c(4:11)
time_cols <- c(1, 3, 16:18)


### get data from raw sources ###
data_list <- refresh_data(impute = TRUE)
train <- data_list[['train']]
test <- data_list[['test']]
raion <- data_list[['raion']]
yearly <- data_list[['yearly']]
quarterly <- data_list[['quarterly']]
monthly <- data_list[['monthly']]
daily <- data_list[['daily']]


### get data from other sources ###
raion_wikipedia <- fread('data/raion_Wikipedia.csv')
macro_index <- fread('data/RE_Macro_Index.csv')
clusters_12 <- fread('data/raions_clusters12.csv')
clusters_24 <- fread('data/raions_clusters24.csv')


### create big dataset for PCA ###
dataset_list <- list(train[, -(all_price_cols), with = FALSE], test)
big <- rbindlist(dataset_list)
big_pca <- big[, (pca_cols), with = FALSE]
train[, (pca_cols) := NULL]
test[, (pca_cols) := NULL]


### PCA on km features ###
km_features <- select(big, contains("_km"))
pc_km_features <- principal(km_features, nfactors = 4, rotate = 'none')
km_features_scores <- data.table(PC_km_civilization = pc_km_features$scores[,'PC1'], 
                                 PC_km_residential_urban = pc_km_features$scores[,'PC2'], 
                                 PC_km_residential_suburban = pc_km_features$scores[,'PC3'], 
                                 PC_km_residential_rural = pc_km_features$scores[,'PC4'])


### PCA on cafe-count-like features ###
cafe_features <- select(big, contains("00"))
pc_cafe_features <- principal(cafe_features, nfactors = 10, rotate = 'none')
cafe_features_scores <- data.table(PC_num_cafe = pc_cafe_features$scores[,'PC1'], 
                                   PC_coffee_price_rural = pc_cafe_features$scores[,'PC2'], 
                                   PC_coffee_price_urban = pc_cafe_features$scores[,'PC3'], 
                                   PC_coffee_price_near_vs_far = pc_cafe_features$scores[,'PC4'], 
                                   PC_non_industrial = pc_cafe_features$scores[,'PC5'], 
                                   PC_markets_and_malls = pc_cafe_features$scores[,'PC6'], 
                                   PC_mosques = pc_cafe_features$scores[,'PC7'], 
                                   PC_markets_vs_malls = pc_cafe_features$scores[,'PC8'], 
                                   PC_parks_and_industry = pc_cafe_features$scores[,'PC9'], 
                                   PC_coffee_price_very_close_vs_elsewhere = pc_cafe_features$scores[,'PC10'])


### merge other data into train and test datasets ###

# PCs
train <- cbind(train, km_features_scores[1:nrow(train),], cafe_features_scores[1:nrow(train),])
test <- cbind(test, km_features_scores[(nrow(train)+1):nrow(big)], cafe_features_scores[(nrow(train)+1):nrow(big)])

# # raion clusters
# cluster12 <- data.table(sub_area = clusters_12$sub_area, cluster12 = factor(clusters_12$cluster), mean_price = clusters_12$log_price.mean, sd_price = clusters_12$log_price.sd, mean_ppsq = clusters_12$log_price_per_log_fullsq.mean, sd_ppsq = clusters_12$log_price_per_log_fullsq.sd, mean_dist = clusters_12$kremlin_km.mean, sd_dist = clusters_12$kremlin_km.sd, invest_prop = clusters_12$invest_prop, okrug = factor(clusters_12$Okrug), raion_area = clusters_12$Area.Total, raion_pop = clusters_12$Population, raion_density = clusters_12$Density, sqrt_mean_dist = clusters_12$sqrt_kremlin_km.mean)
# cluster24 <- data.table(sub_area = clusters_24$sub_area, cluster24 = factor(clusters_24$cluster))
# setkey(cluster12, sub_area)
# setkey(cluster24, sub_area)
# setkey(big, sub_area)
# big <- big[cluster12]
# big <- big[cluster24]
# setkey(big, id)
# train <- cbind(train, big[1:nrow(train), .(cluster12, cluster24)])
# test <- cbind(test, big[(nrow(train)+1):nrow(big), .(cluster12, cluster24)])

# macro index
setkey(train, timestamp)
setkey(test, timestamp)
setkey(macro_index, timestamp)
train <- macro_index[train]
test <- macro_index[test]
setkey(train, id)
setkey(test, id)


### exploratory model time ###
train_complete <- train[complete.cases(train), -c(price_cols, time_cols, transformed_cols), with = FALSE]
mlr_model_empty <- lm(log_price ~ 1, data = train_complete)
mlr_model_full <- lm(log_price ~ ., data = train_complete)
scope <- list(lower = formula(mlr_model_empty), upper = formula(mlr_model_full))

train_k <- log(nrow(train_complete))
train_BIC_empty_both <- step(mlr_model_empty, scope, direction = 'both', k = train_k)
#train_AIC_empty_both <- step(mlr_model_empty, scope, direction = 'both', k = 2)
#train_BIC_full_both <- step(mlr_model_full, scope, direction = 'both', k = train_k)
#train_AIC_full_both <- step(mlr_model_full, scope, direction = 'both', k = 2)

#summary(train_BIC_empty_both)
#summary(train_BIC_full_both)


# ### exploratory categorization time ###
# raions <- train_weird[, .(count = .N, log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE), kremlin_km.mean = mean(kremlin_km, na.rm = TRUE), kremlin_km.sd = sd(kremlin_km, na.rm = TRUE), invest_prop = (sum(product_type == "Investment", na.rm = TRUE) / .N), weird_prop = (sum(product_type == "Investment" & weird == 1, na.rm = TRUE) / sum(product_type == "Investment", na.rm = TRUE))), by = sub_area]
# states <- train_weird[, .(count = .N, log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE), kremlin_km.mean = mean(kremlin_km, na.rm = TRUE), kremlin_km.sd = sd(kremlin_km, na.rm = TRUE), invest_prop = (sum(product_type == "Investment", na.rm = TRUE) / .N), weird_prop = (sum(product_type == "Investment" & weird == 1, na.rm = TRUE) / sum(product_type == "Investment", na.rm = TRUE))), by = state]
# floors <- train_weird[, .(count = .N, log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE), kremlin_km.mean = mean(kremlin_km, na.rm = TRUE), kremlin_km.sd = sd(kremlin_km, na.rm = TRUE), invest_prop = (sum(product_type == "Investment", na.rm = TRUE) / .N), weird_prop = (sum(product_type == "Investment" & weird == 1, na.rm = TRUE) / sum(product_type == "Investment", na.rm = TRUE))), by = floor]
# max_floors <- train_weird[, .(count = .N, log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE), kremlin_km.mean = mean(kremlin_km, na.rm = TRUE), kremlin_km.sd = sd(kremlin_km, na.rm = TRUE), invest_prop = (sum(product_type == "Investment", na.rm = TRUE) / .N), weird_prop = (sum(product_type == "Investment" & weird == 1, na.rm = TRUE) / sum(product_type == "Investment", na.rm = TRUE))), by = max_floor]
# materials <- train_weird[, .(count = .N, log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE), kremlin_km.mean = mean(kremlin_km, na.rm = TRUE), kremlin_km.sd = sd(kremlin_km, na.rm = TRUE), invest_prop = (sum(product_type == "Investment", na.rm = TRUE) / .N), weird_prop = (sum(product_type == "Investment" & weird == 1, na.rm = TRUE) / sum(product_type == "Investment", na.rm = TRUE))), by = material]
# products <- train_weird[, .(count = .N, log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE), kremlin_km.mean = mean(kremlin_km, na.rm = TRUE), kremlin_km.sd = sd(kremlin_km, na.rm = TRUE)), by = product_type]
# rooms <- train_weird[, .(count = .N, log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE), kremlin_km.mean = mean(kremlin_km, na.rm = TRUE), kremlin_km.sd = sd(kremlin_km, na.rm = TRUE), invest_prop = (sum(product_type == "Investment", na.rm = TRUE) / .N), weird_prop = (sum(product_type == "Investment" & weird == 1, na.rm = TRUE) / sum(product_type == "Investment", na.rm = TRUE))), by = num_room]
# yearlies <- train_weird[, .(count = .N, log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE), kremlin_km.mean = mean(kremlin_km, na.rm = TRUE), kremlin_km.sd = sd(kremlin_km, na.rm = TRUE), invest_prop = (sum(product_type == "Investment", na.rm = TRUE) / .N), weird_prop = (sum(product_type == "Investment" & weird == 1, na.rm = TRUE) / sum(product_type == "Investment", na.rm = TRUE))), by = year]
# quarterlies <- train_weird[, .(count = .N, log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE), kremlin_km.mean = mean(kremlin_km, na.rm = TRUE), kremlin_km.sd = sd(kremlin_km, na.rm = TRUE), invest_prop = (sum(product_type == "Investment", na.rm = TRUE) / .N), weird_prop = (sum(product_type == "Investment" & weird == 1, na.rm = TRUE) / sum(product_type == "Investment", na.rm = TRUE))), by = quarter]
# monthlies <- train_weird[, .(count = .N, log_price.mean = mean(log_price), log_price.sd = sd(log_price), log_price_per_log_fullsq.mean = mean(log_price_per_log_fullsq, na.rm = TRUE), log_price_per_log_fullsq.sd = sd(log_price_per_log_fullsq, na.rm = TRUE), kremlin_km.mean = mean(kremlin_km, na.rm = TRUE), kremlin_km.sd = sd(kremlin_km, na.rm = TRUE), invest_prop = (sum(product_type == "Investment", na.rm = TRUE) / .N), weird_prop = (sum(product_type == "Investment" & weird == 1, na.rm = TRUE) / sum(product_type == "Investment", na.rm = TRUE))), by = month]
# 
# 
# ### mega model ###
# 
# # raion
# init_data <- rep(0, nrow(raions))
# 
# models_num <- array(data = init_data, dim = c(nrow(raions)))
# models_intercept <- array(data = init_data, dim = c(nrow(raions)))
# models_log_fullsq <- array(data = init_data, dim = c(nrow(raions)))
# models_log_kitchsq <- array(data = init_data, dim = c(nrow(raions)))
# models_floor <- array(data = init_data, dim = c(nrow(raions)))
# models_maxfloor <- array(data = init_data, dim = c(nrow(raions)))
# models_kremlin_km <- array(data = init_data, dim = c(nrow(raions)))
# models_water_km <- array(data = init_data, dim = c(nrow(raions)))
# models_industrial_km <- array(data = init_data, dim = c(nrow(raions)))
# models_oil_chemistry_km <- array(data = init_data, dim = c(nrow(raions)))
# models_r_squared <- array(data = init_data, dim = c(nrow(raions)))
# models_adj_r_squared <- array(data = init_data, dim = c(nrow(raions)))
# 
# r_sq_sum <- 0
# r_sq_adj_sum <- 0
# model_count <- 0
# 
# for(raion in 1:nrow(raions)) {
#   subset <- train_normal[sub_area == raions$sub_area[raion],]
#   subset <- subset[complete.cases(subset), .(log_price, log_fullsq, log_kitchsq, floor, max_floor, material, state, quarter, kremlin_km, water_km, industrial_km, oil_chemistry_km)]
#   models_num[raion] <- models_num[raion] + nrow(subset)
#   if(nrow(subset) > 12) {
#     model <- lm(formula = log_price ~ log_fullsq + log_kitchsq + floor + max_floor + kremlin_km + water_km + industrial_km + oil_chemistry_km, data = subset)
#     model_summary <- summary(model)
#     coefficients <- model$coefficients
#     if(is.na(model_summary$adj.r.squared)) print(paste0("raion: ", toString(raion)))
#     r_sq_sum <- r_sq_sum + model_summary$r.squared
#     r_sq_adj_sum <- r_sq_adj_sum + model_summary$adj.r.squared
#     model_count <- model_count + 1
#   } else {
#     coefficients <- list('(Intercept)' = 0, log_fullsq = 0, log_kitchsq = 0, floor = 0, max_floor = 0, kremlin_km = 0, water_km = 0, industrial_km = 0, oil_chemistry_km = 0)
#     model_summary <- list(r.squared = NA, adj.r.squared = NA)
#   }
#   models_intercept[raion] <- coefficients[['(Intercept)']]
#   models_log_fullsq[raion] <- coefficients[['log_fullsq']]
#   models_log_kitchsq[raion] <- coefficients[['log_kitchsq']]
#   models_floor[raion] <- coefficients[['floor']]
#   models_maxfloor[raion] <- coefficients[['max_floor']]
#   models_kremlin_km[raion] <- coefficients[['kremlin_km']]
#   models_water_km[raion] <- coefficients[['water_km']]
#   models_industrial_km[raion] <- coefficients[['industrial_km']]
#   models_oil_chemistry_km[raion] <- coefficients[['oil_chemistry_km']]
#   models_r_squared[raion] <- model_summary[['r.squared']]
#   models_adj_r_squared[raion] <- model_summary[['adj.r.squared']]
# }
# 
# avg_r_sq <- r_sq_sum / model_count
# avg_r_sq_adj <- r_sq_adj_sum / model_count
# 
# 
# ### cross-validation ###
# models = list()
# r_sq <- c()
# for(s in 1:5) {
#   subsample_test_selector <- round((s-1)*nrow(train)*0.2):round(s*nrow(train)*0.2)
#   subsample_train <- train[-subsample_test_selector,]
#   subsample_test <- train[subsample_test_selector,]
#   model <- lm(log_price ~ log_fullsq + log_kitchsq + floor + max_floor + product_type + state + material_factor, data = subsample_train)
#   models[[s]] <- model
#   predictions <- predict(model, subsample_test, interval = 'none')
#   predicted_prices <- exp(predictions)
#   residuals <- predicted_prices - subsample_test$price_doc
#   RSS <- sum(residuals**2, na.rm = TRUE)
#   TSS <- sum((mean(subsample_train$price_doc, na.rm = TRUE) - subsample_test$price_doc)**2)
#   r_sq <- c(r_sq, 1-RSS/TSS)
# }
# 
# 
### write predictions to submission.csv ###
model <- train_BIC_empty_both
predictions <- predict(model, test, interval = 'none')
predicted_prices <- round(exp(predictions))
fwrite(cbind(data.table(id = test$id), data.table(price_doc = predicted_prices)), paste0(write_directory, submissions_filename), append = FALSE)

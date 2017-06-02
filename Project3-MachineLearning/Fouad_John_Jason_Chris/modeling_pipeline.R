#loading in final total dataset
rm(list=ls())
setwd("/Users/jasonchiu0803/Desktop/data_bootcamp/sberbank_project")

library(data.table)
total_full <- fread("./old_data_file/final_total_2_27.csv",stringsAsFactors = TRUE)
names(total_full)
total_full$state <- factor(total_full$state, levels = c(1,2,3,4))
total_full$material <- factor(total_full$material)
total_full$V1<-NULL

library(pracma)
summary(total_full$material)
library(dplyr)
summary(total_full$product_type)
total_full$sub_area <- factor(total_full$sub_area)
total_full$product_type  <- factor(total_full$product_type)

# to moscow ring distances
city_dist <- total_full %>% 
  dplyr::select(metro_km_avto,
                railroad_station_avto_km,
                zd_vokzaly_avto_km,
                bus_terminal_avto_km
                )

#View(city_dist)
#View(cor(city_dist))
#feature engineering railroad and metro
library(psych)
fa.parallel(city_dist, #The data in question.
            fa = "pc", #Display the eigenvalues for PCA.
            n.iter = 100) #Number of simulated analyses to perform.
abline(h = 1) #Adding a horizontal line at 1.

distance_pointer = principal(city_dist, #The data in question.
                       nfactors = 2,
                       rotate = "none") #The number of PCs to extract.
distance_pointer

factor.plot(distance_pointer) #Add variable names to the plot.

#-PC1 ends up being a weighted average.
#-PC2 mostly for railroad.
distance_pointer$scores
plot(distance_pointer)
PC1 <- distance_pointer$scores[,1]
PC2 <- distance_pointer$scores[,2]
total_full <- total_full %>% mutate(dis_metro_rail = PC1, dis_rail = PC2)

# distance to city center
# distance score
# kremlin_km*5 + bulvar_ring_km*4 + sadovoe_km*3 + ttk_km*2 + mkmd_km*1
# did not significantly improve the model - retire feature
total_distance <- total_full %>% 
  dplyr::select(kremlin_km,
                bulvar_ring_km,
                sadovoe_km,
                ttk_km,
                mkad_km)
cor(total_distance)
# only distance to kremlin will be added due to low impact on mkad distance

# clustering based on the location
total_cluster <- total_full %>% 
  dplyr::select(cafe_count_1000,
                church_count_1000,
                mosque_count_1000,
                leisure_count_1000,
                sport_count_1000,
                market_count_1000,
                green_part_1000,
                prom_part_1000,
                office_count_1000,
                trc_count_1000)

M <- cor(total_cluster)
library(corrplot)
corrplot(M)

library(flexclust)
total.scaled_city = as.data.frame(scale(total_cluster))
d_1 = dist(total.scaled_city)
fit.avg_city = hclust(d_1, method = "average")
plot(fit.avg_city, hang = -1, main = "Dendrogram of Complete Linkage")
clusters.average_city = cutree(fit.avg_city, k = 3)
table(clusters.average_city)

#Aggregating the original data by the cluster assignments.
aggregate(total_cluster, by = list(cluster = clusters.average_city), median)

# 1 residentail/industrial/green
# 2 shopping/office
# 3 shopping/office/ethinic neighborhood

total_full$cluster_no <- factor(clusters.average_city)
summary(total_full$cluster_no)
#View(total_full)
#macro<-fread("macro.csv", stringsAsFactors = TRUE)
#total<-merge(x = total_full, y = macro[,c(1,5)], by = "timestamp", all.x = TRUE)
#View(total)
#total$inflation_rate <-total$cpi/total$cpi[1]
#total$inf_price <-total$price_doc/total$inflation_rate

library(zoo)
total_full$kitch_sq <- na.aggregate(total_full$kitch_sq, by = total_full$sub_area, FUN = median)

negative <- total_full %>% dplyr::select(oil_chemistry_raion, 
                                    radiation_raion,
                                    nuclear_reactor_raion,
                                    thermal_power_plant_raion,
                                    incineration_raion) %>%
  dplyr::mutate(oil_chem = ifelse(oil_chemistry_raion=="yes",1,0),
                radiation = ifelse(radiation_raion == "yes",1,0),
                nuclear = ifelse(nuclear_reactor_raion=="yes",1,0),
                thermal = ifelse(thermal_power_plant_raion=="yes",1,0),
                incineration = ifelse(incineration_raion=="yes",1,0)) %>%
  dplyr::select(-oil_chemistry_raion, 
                -radiation_raion,
                -nuclear_reactor_raion,
                -thermal_power_plant_raion,
                -incineration_raion)

summary(negative)

M <- cor(negative)
library(corrplot)
corrplot(M)

library(flexclust)
negative.scaled = as.data.frame(scale(negative))
d_neg = dist(negative.scaled)
fit.avg_neg = hclust(d_neg, method = "average")
plot(fit.avg_neg, hang = -1, main = "Dendrogram of Complete Linkage")
clusters.average_neg = cutree(fit.avg_neg, k = 3)
#Viewing the groups of data.
table(clusters.average_neg)

#Aggregating the original data by the cluster assignments.
aggregate(negative, by = list(cluster = clusters.average_neg), median)

total_full$neg_cluster <- factor(clusters.average_neg)

#education factors
summary(total_full$school_education_centers_raion)
summary(total_full$school_education_centers_top_20_raion)
total_full$school_percent <- total_full$school_education_centers_top_20_raion/total_full$school_education_centers_raion
total_full[which(is.na(total_full$school_percent)),]$school_percent <- 0
summary(total_full$school_percent)
hist(total_full$school_percent)

school_measures <- total_full %>% dplyr::filter(train_or_test=="train") %>% dplyr::select(school_percent,school_education_centers_raion, price_doc)
M <- cor(school_measures)
M


# negative presence (radiation, nuclear, oil chem, radiation, thermal
summary(total_full$kitch_sq)
library(dplyr)
train_1 <- total_full %>% dplyr::filter(train_or_test=="train") %>%
  dplyr::select(price_doc,
                full_sq,
                floor,
                num_room,
                kitch_sq,
                state,
                material,
                floor,
                sub_area,
                product_type,
                dis_metro_rail,
                cluster_no,
                neg_cluster)

train_1$log_price <- log(train_1$price_doc)

train_1 <- train_1 %>% dplyr::select(-price_doc)

test_1 <- total_full %>% dplyr::filter(train_or_test=="test") %>%
  dplyr::select(full_sq,
                floor,
                num_room,
                kitch_sq,
                state,
                material,
                floor,
                sub_area,
                product_type,
                dis_metro_rail,
                cluster_no,
                neg_cluster)

correlation_check <- train_1 %>% dplyr::select(-state,
                                               -sub_area,
                                               -material,
                                               -product_type,
                                               -cluster_no,
                                               -neg_cluster)
names(correlation_check)
corre <- cor(correlation_check)
library(corrplot)
corrplot(corre)
corre

library(ggplot2)
ggplot(data = train_1, aes(x = full_sq, y = log_price)) + geom_point() +
  geom_smooth(method="lm")
# somewhat of a linear relationship

# no linear relationship
plot(train_1$floor,train_1$log_price)

ggplot(data = train_1, aes(x = num_room, y = log_price)) + geom_point() +
  geom_smooth(method="lm")
#somewhat of a linear relationship

ggplot(data = train_1, aes(x = dis_metro_rail, y = log_price)) + geom_point() +
  geom_smooth(method="lm")
# somewhat of a linear relationship

# Forward Regression
model.empty = lm(log_price ~ 1, data = train_1)
model.full = lm(log_price ~ ., data = train_1)
scope = list(lower = formula(model.empty), upper = formula(model.full))
library(MASS) #The Modern Applied Statistics library.

#with neg
forwardAIC_n = step(model.empty, scope, direction = "forward", k = 2)
summary(forwardAIC_n)
# variable included: life_sq, kitch_sq, material, cluster, num_room, floor, 
# dis_mtreo_rail, product_type, state, sub_area, full_sq
# R2 = 0.3567
# AIC 42515.5
AIC(forwardAIC_n)
predict_train <- predict(forwardAIC_n, train_1)
sum((train_1$log_price - predict_train)^2)/nrow(train_1)
# 0.234

#compare with lasso
x = model.matrix(log_price ~ ., train_1)[, -1]
y = train_1$log_price
x_test = model.matrix(~.,test_1)[,-1]

grid = 10^seq(5, -20, length = 100)

#80 and 20 % train and test
set.seed(0)
train_index = sample(1:nrow(x), 8*nrow(x)/10)
test_index = (-train_index)
y.test = y[test_index]

length(train_index)/nrow(x)
length(y.test)/nrow(x)

set.seed(0)
library(glmnet)
cv.lasso.out = cv.glmnet(x = x[train_index, ], y = y[train_index],lambda = grid,
                         alpha = 1, nfolds = 10)
plot(cv.lasso.out, main = "Lasso Regression\n")
bestlambda.lasso = cv.lasso.out$lambda.min
a = cv.lasso.out$lambda.1se
bestlambda.lasso
a
log(bestlambda.lasso)
log(a)

lasso.models.train = glmnet(x[train_index, ], y[train_index], alpha = 1, lambda = bestlambda.lasso)
lasso.models.train$beta
# neg_cluster, cluster, dis_metro_rail, product_type, sub_area, material, 
# state, build_year, kitch_sq, num_room, floor, life_sq, full_sq
summary(lasso.models.train)
laso_predict_train <- predict(lasso.models.train, x)
sum((train_1$log_price - laso_predict_train)^2)/nrow(train_1)
# 0.234

lasso.models.train2 = glmnet(x[train_index, ], y[train_index], alpha = 1, lambda = a)
coef(lasso.models.train2)
laso_predict_train2 <- predict(lasso.models.train2, x)
laso_predict_train_origin <- exp(laso_predict_train2)

sum((train_1$log_price - laso_predict_train2)^2)/nrow(train_1)
# 0.237
laso_predict_residual2 <- (train_1$log_price - laso_predict_train2)
laso <- data.frame(fitted = laso_predict_train2, residual = laso_predict_residual2)
View(laso)

# creating a submission file
laso_predict_cv <- predict(lasso.models.train2, x_test)
laso_predict_origin <- exp(laso_predict_cv)
test_2 <- total_full %>% dplyr::filter(train_or_test== "test") %>% dplyr::select(id)

submission <- data.frame(id=test_2$id, price_doc = laso_predict_origin)
names(submission) = c("id","price_doc")
dim(submission)
write.csv(x = submission,"./submission_lasso_5.29_test.csv",row.names = FALSE)

#creating a full prediction file
full_predict <- rbind(laso_predict_train_origin, laso_predict_origin)
total_full$linear_predict <- full_predict
sum(is.na(total_full$linear_predict))
dim(total_full)
sum(is.na(total_full))
which(is.na(total_full))
write.csv(total_full, "./data_with_prediction.csv",row.names= FALSE)

# investigating residuals and assumptions
plot(laso$s0, laso$s0.1)

plot(forwardAIC_n$fitted.values, forwardAIC_n$residuals)
id <- total_full %>% dplyr::filter(train_or_test == "train") %>%
  dplyr::select(id)

summary(forwardAIC_n)

invest <- data.frame(residuals = forwardAIC_n$residuals, 
                     fitted = forwardAIC_n$fitted.values,
                     ID = id) 

a_res <- ggplot(data = invest, aes(x = fitted, y = residuals, label = id))
a_res + geom_text(angle = 45) + coord_cartesian(ylim = c(0, -2), xlim = c(14.9,15))
names(invest)

train_view <- total_full %>% dplyr::filter(train_or_test=="train") %>%
  dplyr::select(id,
                price_doc,
                full_sq,
                floor,
                num_room,
                kitch_sq,
                state,
                material,
                floor,
                sub_area,
                product_type,
                dis_metro_rail,
                cluster_no,
                neg_cluster)

train_view$log_price <- log(train_view$price_doc)

i_data <- left_join(train_view, invest, by= "id")
i_data %>% group_by(price_doc) %>% summarise(count=n()) %>%
  arrange(desc(count)) %>% filter(count>30) %>% summarise(total = sum(count))

i_data <- i_data %>% 
  dplyr::mutate(price_indicator = ifelse(price_doc==2000000, 1,ifelse(price_doc==1000000,2,ifelse(price_doc==6000000,3,ifelse(price_doc==3000000,4,ifelse(price_doc==6500000,5,ifelse(price_doc==7000000,6,ifelse(price_doc==5500000,7,ifelse(price_doc==6300000,8,ifelse(price_doc==5000000,9,ifelse(price_doc==6200000,10,NA)))))))))))

i_data <- i_data %>% dplyr::mutate(price_indicator = factor(price_indicator, levels= c(0,1,2,3,4,5,6,7,8,9,10)))
summary(i_data$price_indicator)
levels(i_data$price_indicator)
install.packages("ggthemes")
library(ggthemes)

ggplot(data = i_data, aes(x = fitted, y = residuals)) + geom_point() +
  geom_point(data = subset(i_data, price_indicator == 1), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 2), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 3), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 4), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 5), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 6), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 7), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 8), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 9), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 10), aes(color = price_indicator)) +
  ggtitle("Residual Plot") + labs(x = "Fitted Values", y = "Residuals") +
  scale_color_manual(labels = c("2M: 756", "1M: 747","6M: 372","3M: 332","6.5M: 329", "7M: 319", "5.5M: 309","6.3M: 295","5M: 294","6.2M: 277"),values = c("red", "orange","yellow","green","blue","royalblue","purple","salmon","seagreen","khaki")) +
  theme_bw() + theme(legend.position="bottom")

ggplot(data = i_data, aes(x = log_price, y = fitted)) + geom_point() +
  geom_point(data = subset(i_data, price_indicator == 1), aes(color=price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 2), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 3), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 4), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 5), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 6), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 7), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 8), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 9), aes(color = price_indicator)) +
  geom_point(data = subset(i_data, price_indicator == 10), aes(color = price_indicator)) +
  ggtitle("True VS. Fitted Value") + labs(x = "True Values", y = "Fitted Values") +
  scale_color_manual(labels = c("2M: 756", "1M: 747","6M: 372","3M: 332","6.5M: 329", "7M: 319", "5.5M: 309","6.3M: 295","5M: 294","6.2M: 277"),values = c("red", "orange","yellow","green","blue","royalblue","purple","salmon","seagreen","khaki")) +
  theme_bw() 

i_data %>% dplyr(filter<)
?cut

summary(cut(i_data$log_price, breaks = 30))

plot(forwardAIC_n)

no_1 <- c(4850, 11456,14377,23101,16597, 18392,23333,7768)
i_data %>% dplyr::filter(id %in% no_1)

i_data_2M <- i_data %>% dplyr::filter(price_doc == 2000000 | price_doc == 1000000)
ggplot(data = i_data_2M, aes(x = fitted, y = residuals, size = num_room, color = num_room)) +
  geom_point()
ggplot(data = i_data_2M, aes(x = fitted, y = residuals, size = c(full_sq), color = price_indicator)) + 
  geom_point() + ggtitle("Property at 2M and 1M") + labs(x = "Fitted Values", y = "Residuals") +
  theme_bw() + scale_color_manual(labels = c("2M: 756", "1M: 747"),values = c("red","royalblue")) +
  scale_size(range = c(0.5, 10))
ggplot(data = i_data_2M, aes(x = full_sq, y = price_doc)) + geom_point()

# comparing with a rf residual
rf_predict = fread("./old_data_file/rf_final.csv")
names(rf_predict)
rf_data <- rf_predict %>% dplyr::select(id,
                             price_doc,
                             full_sq,
                             floor,
                             num_room,
                             kitch_sq,
                             state,
                             material,
                             floor,
                             sub_area,
                             product_type,
                             dis_metro_rail,
                             cluster_no,
                             neg_cluster,
                             linear_predict,
                             Stack,
                             train_or_test) %>%
  dplyr::filter(train_or_test == "train") %>%
  dplyr::mutate(linear_log = log(linear_predict),
                log_price = log(price_doc)) %>%
  dplyr::mutate(res_linear = log_price - linear_log,
                res_rf = log_price - Stack) %>%
  dplyr::mutate(price_indicator = ifelse(price_doc==2000000, 1,ifelse(price_doc==1000000,2,ifelse(price_doc==6000000,3,ifelse(price_doc==3000000,4,ifelse(price_doc==6500000,5,ifelse(price_doc==7000000,6,ifelse(price_doc==5500000,7,ifelse(price_doc==6300000,8,ifelse(price_doc==5000000,9,ifelse(price_doc==6200000,10,NA))))))))))) %>%
  dplyr::mutate(price_indicator = factor(price_indicator, levels = c(1,2,3,4,5,6,7,8,9,10)))
str(rf_data$price_indicator)
summary(rf_data)

ggplot(data = rf_data, aes(x = Stack, y = res_rf)) + geom_point() + ggtitle("Residual VS. Fitted Value") + labs(x = "Random Forest Fitted Value", y = "Residual") + 
  theme_bw() + coord_cartesian(ylim = c(2, -6), xlim = c(14,22))
ggplot(data = rf_data, aes(x = linear_log, y = res_linear)) + geom_point() +ggtitle("Residual VS. Fitted Value") + labs(x = "LM Fitted Value", y = "Residual") + 
  theme_bw() + coord_cartesian(ylim = c(2, -6), xlim = c(14,22))

ggplot(data = rf_data, aes(x = Stack, y = res_rf)) + geom_point() +
  geom_point(data = subset(rf_data, price_indicator == 1), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 2), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 3), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 4), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 5), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 6), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 7), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 8), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 9), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 10), aes(color = price_indicator)) +
  ggtitle("Residual VS. Fitted Value") + labs(x = "Random Forest Fitted Value", y = "Residual") + 
  theme_bw()

ggplot(data = rf_data, aes(x = linear_log, y = res_linear)) + geom_point() +
  geom_point(data = subset(rf_data, price_indicator == 1), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 2), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 3), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 4), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 5), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 6), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 7), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 8), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 9), aes(color = price_indicator)) +
  geom_point(data = subset(rf_data, price_indicator == 10), aes(color = price_indicator)) +
  ggtitle("Residual VS. Fitted Value") + labs(x = "LM Fitted Value", y = "Residual") + 
  theme_bw()

ggplot(data = rf_data, aes(x = Stack, y = res_rf,color = "red")) + geom_point() +
  geom_point(data = rf_data, aes(x = linear_log, y = res_linear, color = "blue"))





names(rf_predict)

rf_train <- rf_predict %>% 
  dplyr::select(id, price_doc, linear_predict, Stack, train_or_test) %>%
  dplyr::mutate(log_price = log(price_doc),
                log_linear = log(linear_predict),
                diff_linear = abs(log_linear - log_price),
                diff_rf = abs(Stack - log_price)) %>%
  dplyr::filter(train_or_test == "train")

names(rf_train)
rf_train$minimum <- 0
rf_train[which(rf_train$diff_rf <= rf_train$diff_linear),"minimum"] <- rf_train[which(rf_train$diff_rf <= rf_train$diff_linear),"Stack"]
rf_train[which(rf_train$diff_rf > rf_train$diff_linear),"minimum"] <- rf_train[which(rf_train$diff_rf > rf_train$diff_linear),"log_linear"]
names(rf_train)
View(rf_train)
rf_train1<-rf_train %>% dplyr::select(id, minimum)


rf_test <- rf_predict %>% 
  dplyr::filter(train_or_test == "test") %>%
  dplyr::select(id, Stack)

names(rf_test)
rf_test <- rf_test %>% dplyr::rename(minimum = Stack)

final_data <- rbind(rf_train1,rf_test)

write.csv(final_data,"id_minimum.csv")

View(total_full %>% group_by(sub_area) %>% summarise(count=n()) %>% arrange(desc(count)))
hist(total_full$full_sq, breaks = 100)

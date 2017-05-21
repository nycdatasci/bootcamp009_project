######### Kaggle Project, Identifying Important Variables ###############

library(dplyr)
library(glmnet)
library(data.table)
library(leaps)
library(caret)


#Read in the data
sberCC = read.csv('trainCC.csv', stringsAsFactors = FALSE)

#basic investigation of the data frame
str(sberCC)
names(sberCC)
dim(sberCC)

#Look at all columns to see what additional changes need to be made:

#all variables, with class type and index
for (i in c(1:length(names(sberCC)))){
  print(c(names(sberCC)[i],class(sberCC[,i]),i))
}

#Helpful to actually look at the data too:
View(sberCC)
View(sberCC[,100:200])
View(sberCC[,200:292])

#Drop ID
# timestamp (2) to numeric ? (there should be a closeness btw. dates)
#state (11) numeric --> factor (????)
#subarea (13): length(unique(sub_area)) = 80
#culture_objects_top_25 (binary: 30) (factor)
#normalize all the Gender/Age count groupings? (index 42-68)
#same for build-count-type (70-78)
#same for build-date (79-84)
#metro ID number remove (85)
#ID railroad station walk? (100)
#ID Bigroad(1/2)  (114/117)
#ID railroad terminal (121)
#ID railroad (123)
#ecology (153)
#Rest seems pretty good
#These IDs should be factors, not numeric?

# First step of lasso/ridge: x = model.matrix(price_doc ~ ., sberCC)[, -1]
# returns the error: contrasts can be applied only to factors with 2 or more levels

#Which variable is of type "character" that has only one class?
for (i in c(1:length(names(sberCC)))){
  if ((length(unique(sberCC[,i]))) == 1) {
  print(names(sberCC)[i])
  }
}

# "incineration_raion" is the bad column (~28500 'no', ~2500 'yes' in the original)
# in the complete cases: incineration_raion contains all 'no', so remove it.

sberCC = select(sberCC, -incineration_raion)

#Drop id#, it's meaningless:
sberCC = select(sberCC, -id)

#Fix the date column:

#Convert timestamp colummn to the appropriate format:
sberCC$timestamp = as.Date(sberCC$timestamp)

#Define a function that we can sapply
dateconversion <- function(x){
  return(as.numeric(julian(x,origin = sberCC$timestamp[1])))
}

#Apply to the timestamp column, and refine column
sberCC$timestamp = sapply(sberCC$timestamp,dateconversion)

#Creating the data matrices for the glmnet() function.
x = model.matrix(price_doc ~ ., sberCC)[, -1]
y = sberCC$price_doc

#Creating training and test sets with an 80-20 split, respectively.
set.seed(0)
train = sample(1:nrow(x), 8*nrow(x)/10)
test = (-train)
y.test = y[test]
length(train)/nrow(x)
length(y.test)/nrow(x)

#Values of lambda over which to check.
grid = 10^seq(10, 2, length = 100)
# 
# #Fitting the ridge regression. Alpha = 0 for ridge regression.
# ridge.models = glmnet(x[train, ], y[train], alpha = 0, lambda = grid)
# 
# #3
# plot(ridge.models, xvar = "lambda", label = TRUE, main = "Ridge Regression")
# 
# #4
# set.seed(0)
# cv.ridge.out = cv.glmnet(x[train, ], y[train], alpha = 0, nfolds = 10, lambda = grid)
# 
# #5 & 6
# plot(cv.ridge.out, main = "Ridge Regression\n")
# bestlambda.ridge = cv.ridge.out$lambda.min
# bestlambda.ridge
# log(bestlambda.ridge)
# 
# #7
# ridge.bestlambdatrain = predict(ridge.models, s = bestlambda.ridge, newx = x[test, ])
# mean((ridge.bestlambdatrain - y.test)^2)
# 
# #8
# ridge.out = glmnet(x, y, alpha = 0)
# predict(ridge.out, type = "coefficients", s = bestlambda.ridge)
# 
# #9
# ridge.bestlambda = predict(ridge.out, s = bestlambda.ridge, newx = x)
# mean((ridge.bestlambda - y)^2)

#MSE = 1.33* 10^13

#All coefficients quite large, not helpful for eliminating unhelpful variables, move on to Lasso:

############################ LASSO ###################################

#Fitting the lasso regression. Alpha = 1 for lasso regression.
lasso.models = glmnet(x[train, ], y[train], alpha = 1, lambda = grid)
plot(lasso.models, xvar = "lambda", label = TRUE, main = "Lasso Regression")

set.seed(0)
cv.lasso.out = cv.glmnet(x[train, ], y[train], alpha = 1, nfolds = 10, lambda = grid)
plot(cv.lasso.out, main = "Lasso Regression\n")
bestlambda.lasso = cv.lasso.out$lambda.min
bestlambda.lasso
log(bestlambda.lasso)

#MSE is locally minimized when log(lambda) ~= 9.81

lasso.out = glmnet(x, y, alpha = 1)
lasso.coef = predict(lasso.out, type = "coefficients", s = bestlambda.lasso)[1:371,]
#125 coefficients used (some from the same variable)

lasso.bestlambda = predict(lasso.out, s = bestlambda.lasso, newx = x)
mean((lasso.bestlambda - y)^2)
MSE = 1.31 * 10^13

#Exploratory:
nonzeroCoef(predict(lasso.out, type = "coefficients", s = bestlambda.lasso))
#RETURNS INDICES (NOT SO HELPFUL CAUSE OF INTRODUCED DUMMY VARIABLES)

#or

#Define a function that returns nonzero coeffcients of a lasso model for a given lambda (MSE not included):
nonzeroCs <- function(lambda) {
  P = predict(lasso.out, type = "coefficients", s = lambda)
  P = as.matrix(P)
  P = as.data.frame(P)
  P$varname = rownames(P)
  rownames(P) <- 1:nrow(P)
  return(P[P[1] != 0,]$varname)
}

#Print the important coefficients for models with less than 20 non-zero coefficients
for (ele in grid){
  if (length(nonzeroCs(ele)) < 25) {
    print(nonzeroCs(ele))
    print(ele)
    print('')
  }
}

#Compare with Troys:                   TOP20:    OVERALL:
## full_sq                      100.00  T         T
## life_sq                       86.79  T         T
## num_room                      86.77  F         T
## kitch_sq                      74.05  T         T
## build_year                    67.96  F         F
## max_floor                     54.31  F         T
## product_typeOwnerOccupier     51.06  F         T
## state                         40.94  T         T
## theater_km                    38.91  F         T
## metro_km_avto                 38.63  F         F
## railroad_km                   37.97  F         T
## workplaces_km                 37.92  F         T
## stadium_km                    37.87  F         F
## metro_min_avto                37.80  F         T
## cafe_sum_3000_min_price_avg   37.75  F         T
## cemetery_km                   37.62  F         T
## hospice_morgue_km             37.59  F         F
## sport_count_2000              37.57  F         F
## ice_rink_km                   37.53  F         T
## railroad_station_avto_km      37.42  F         T

#Nonzero coefficients for the "bestlambda"
nonzeroCs(bestlambda.lasso) #There are 146, many are dummys from the same variable name

nonzeroCs(exp(12))

# [1] "(Intercept)"                 "timestamp"                   "full_sq"                    
# [4] "num_room"                    "kitch_sq"                    "state"                      
# [7] "sub_areaHamovniki"           "sub_areaLomonosovskoe"       "sub_areaPresnenskoe"        
# [10] "sub_areaSokol'niki"          "indust_part"                 "culture_objects_top_25yes"  
# [13] "build_count_frame"           "ID_metro"                    "green_zone_km"              
# [16] "sadovoe_km"                  "railroad_km"                 "office_km"                  
# [19] "theater_km"                  "catering_km"                 "ecologysatisfactory"        
# [22] "trc_sqm_500"                 "church_count_500"            "leisure_count_500"          
# [25] "trc_sqm_1000"                "cafe_count_1000_price_high"  "mosque_count_1500"          
# [28] "prom_part_2000"              "cafe_sum_2000_min_price_avg" "prom_part_3000"             
# [31] "office_sqm_5000"             "cafe_sum_5000_min_price_avg" "cafe_count_5000_price_high" 
# [34] "mosque_count_5000"           "sport_count_5000"  

#Alternatively:
lasso.coef = predict(lasso.out, type = "coefficients", s = exp(13))[1:371,]
lasso.coef[lasso.coef != 0]

####### PICK A SUBSET OF VARIABLES THAT MAKE SENSE TO CONSIDER, TO BE PARSED DOWN FOR 
####### SIGNIFICANCE AND MISSINGNESS LATER ################

selected_features = c('timestamp',
                     'full_sq',
                     'kitch_sq',
                     'floor',
                     'build_year',
                     'num_room',
                     'max_floor',
                     'material',
                     'state',
                     'product_typeOwnerOccupier',
                     'sub_area',
                     'theater_km',
                     'metro_km_avto',
                     'railroad_km',
                     'workplaces_km',
                     'stadium_km',
                     'metro_min_avto',
                     'cafe_sum_3000_min_price_avg',
                     'cemetery_km',
                     'hospice_morgue_km',
                     'sport_count_2000',
                     'ice_rink_km',
                     'railroad_station_avto_km',
                     'indust_part',
                     'culture_objects_top_25yes',
                     'build_count_frame',
                     'green_zone_km'
                     
                     )
                     
                     
############ Reproducing Troy's Tree ############################

#Get complete cases of dtrain
# Set training control so that we only 1 run forest on the entire set of complete cases
trControl <- trainControl(method='none')

# Run random forest on complete cases of sberCC. Exclude incineration_raion since it
# only has 1 factor level
rfmod <- train(price_doc ~ . - timestamp,
               method='rf',
               data=sberCC,
               trControl=trControl,
               tuneLength=1,
               importance=TRUE)

varImp(rfmod)

#Idea: Pick 20 top from RF, ~top 20 from lasso, take a union of that set:


#Get N most important from Random Forest:
NImportant <-function(N) {
  D = data.frame(varImp(rfmod)$importance)
  D$varname = rownames(D)
  rownames(D) <- 1:nrow(D)
  return(arrange(D, desc(Overall))[1:N,'varname']) #get the top n nam
}

#Get the top 20 returned as a list:
RFCoefs = NImportant(20)

#OUTPUT:
# [1] "full_sq"                     "life_sq"                     "num_room"                   
# [4] "kitch_sq"                    "build_year"                  "max_floor"                  
# [7] "big_market_km"               "prom_part_3000"              "oil_chemistry_km"           
# [10] "product_typeOwnerOccupier"   "trc_sqm_3000"                "cafe_sum_2000_min_price_avg"
# [13] "thermal_power_plant_km"      "metro_min_walk"              "floor"                      
# [16] "state"                       "power_transmission_line_km"  "additional_education_km"    
# [19] "trc_sqm_1500"                "university_km"


# To get ~top 20 from lasso, run the loop defined above (and commented out below)
# and record the value of lambda for which number of non-zerocoefficients first exceeds 20:

# for (ele in grid){
#   if (length(nonzeroCs(ele)) < 25) {
#     print(nonzeroCs(ele))
#     print(ele)
#     print('')
#   }
# }

#This value of lambda = 298364.7

LassoCoefs = nonzeroCs(298364.7)

#OUTPUT:
# [1] "(Intercept)"                 "timestamp"                   "full_sq"                    
# [4] "kitch_sq"                    "state"                       "sub_areaHamovniki"          
# [7] "sub_areaLomonosovskoe"       "sub_areaPresnenskoe"         "ID_metro"                   
# [10] "sadovoe_km"                  "office_km"                   "ecologysatisfactory"        
# [13] "trc_sqm_500"                 "church_count_500"            "leisure_count_500"          
# [16] "trc_sqm_1000"                "cafe_count_1000_price_high"  "prom_part_2000"             
# [19] "office_sqm_5000"             "cafe_sum_5000_min_price_avg" "mosque_count_5000"          
# [22] "sport_count_5000" 

# Note that all variables with "sub_area<<INSERTNAME>>" are part of the same original
# feature (i.e. remove all of them and insert "sub_area")
#ID_metro is numeric, and arbitrary, so it should've been removed from the start.
# 
LassoCoefs = LassoCoefs[LassoCoefs != "(Intercept)"]
LassoCoefs = LassoCoefs[LassoCoefs != "sub_areaHamovniki"]
LassoCoefs = LassoCoefs[LassoCoefs != "sub_areaLomonosovskoe"]
LassoCoefs = LassoCoefs[LassoCoefs != "sub_areaPresnenskoe"]
LassoCoefs = c(LassoCoefs,"sub_area")
LassoCoefs = LassoCoefs[LassoCoefs != "ID_metro"]


#Take a Union of the 2 sets (RF Union Lasso):
OverallCoefs = union(RFCoefs,LassoCoefs)
#Add a price_doc column:
OverallCoefs=  c(OverallCoefs,'price_doc')

# [1] "full_sq"                     "life_sq"                     "num_room"                   
# [4] "kitch_sq"                    "build_year"                  "max_floor"                  
# [7] "big_market_km"               "prom_part_3000"              "oil_chemistry_km"           
# [10] "product_typeOwnerOccupier"   "trc_sqm_3000"                "cafe_sum_2000_min_price_avg"
# [13] "thermal_power_plant_km"      "metro_min_walk"              "floor"                      
# [16] "state"                       "power_transmission_line_km"  "additional_education_km"    
# [19] "trc_sqm_1500"                "university_km"               "timestamp"                  
# [22] "sadovoe_km"                  "office_km"                   "ecologysatisfactory"        
# [25] "trc_sqm_500"                 "church_count_500"            "leisure_count_500"          
# [28] "trc_sqm_1000"                "cafe_count_1000_price_high"  "prom_part_2000"             
# [31] "office_sqm_5000"             "cafe_sum_5000_min_price_avg" "mosque_count_5000"          
# [34] "sport_count_5000"            "sub_area"

#################  One more last type of feature selection: Forward #################
### Restrict original data set to only the variables listed above

sberFeatSelected = sberCC[which(colnames(sberCC) %in% OverallCoefs)]

#Convert state to character
sberFeatSelected$state = as.character(sberFeatSelected$state)

#Best Feature Selection:

regfit.fwd = regsubsets(price_doc~., data = sberFeatSelected, nvmax = 20, method = "forward")
summary(regfit.fwd)
coef(regfit.fwd, 10)
coef(regfit.fwd, 20)

#Try to parse down to ~10:
# 1. timestamp (may be redunandant when we factor in Rachel's stuff)
# 2. full_sq
# NOTE  Not including num_room, very positively correlated with full_sq
# NOTE Not including life_sq, not too significant here and lots of missingness
# 3. State, but change it to categorical
# 4. sub_area, pain in the ass but apparently important
# 5. sadovoe_km
# 6. oil_chemistry_km
# 7. church_count_500
# 8. leisure_count_500
# 9. prom_part_3000
# 10. office_sqm_5000
# 11. mosque_count_5000

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
               'mosque_count_5000')

#Before running a multilinear regression, we should investigate missingness of these variables:
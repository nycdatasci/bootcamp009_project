library(zoo)

# Loading Zipcode Data Set
load("./zipcode_data.rda")

# Converting class of Dates into Year and Month format
merged_rent_value$Dates = as.yearmon(merged_rent_value$Dates)
merged_rent_value$Zipcode = as.factor(merged_rent_value$Zipcode)

# Loading Zipcode Spatial Data
load("./zipcode_shape_data2.rda") 


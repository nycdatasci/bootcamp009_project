library(dplyr)
library(ggplot2)
library(plotly)
library(tidyr)
library(zoo)
library(zipcode)
library(rgdal)
library(rgeos)
library(leaflet)
library(maps)

zip_rent = read.csv("~/Desktop/NYCDataScience/BootCamp/Projects/Project1_Shiny/MHD_Proj1_ShinyApp/RawData_Zillow_rent_singlefam.csv")
zip_val = read.csv("~/Desktop/NYCDataScience/BootCamp/Projects/Project1_Shiny/MHD_Proj1_ShinyApp/RawData_Zillow_val_singlefam.csv")

rows = intersect(zip_rent$RegionID, zip_val$RegionID)
cols <- intersect(colnames(zip_rent), colnames(zip_val))

rent = zip_rent[zip_rent$RegionID %in% rows, cols]
val = zip_val[zip_val$RegionID %in% rows, cols]
 
# 5 years from 1/2012 to 12/2016       
rent = rent[,c(8:21,82,83) * -1] 
val = val[,c(8:21,82,83) * -1]       

# Sorted by RegionID
rent = rent %>%
        rename(RegionID_rent = RegionID)
rent = arrange(rent, RegionID_rent)

val = val %>%
        rename(RegionID_val = RegionID)
val = arrange(val, RegionID_val)

rent_tidy = gather(rent, key = "Dates", value = "Rent", 8:length(names(rent)))
val_tidy = gather(val, key = "Dates", value = "Value", 8:length(names(val)))

merged_rent_value = 0
merged_rent_value = cbind(rent_tidy, val_tidy[,c(1,9)])

merged_rent_value = merged_rent_value %>%
        mutate(Rent_Value_Ratio = Rent/Value, Rent_Value_Percent = (Rent/Value) * 100)

merged_rent_value$Dates = sapply(merged_rent_value$Dates, function(x) gsub("X", "", x))
merged_rent_value$Dates = sapply(merged_rent_value$Dates, function(x) gsub("[.]", "-", x))
# Fixing the Date format
merged_rent_value$Dates = as.yearmon(merged_rent_value$Dates)
merged_rent_value$Dates = as.Date(merged_rent_value$Dates)

# Cleaning the Zipcodes
data(zipcode)
merged_rent_value$Zipcode = clean.zipcodes(merged_rent_value$RegionName)

# Sorting Variables
merged_rent_value = select(merged_rent_value, 1, 10, 2, Zipcode, 3:9, 11:14)
merged_rent_value = merge(merged_rent_value, zipcode, by.x='Zipcode', by.y='zip')
merged_rent_value = rename(merged_rent_value, zip_city = city, zip_state = state)
merged_rent_value = select(merged_rent_value, 2,3,4,1,5,6,15,16,7,8,9,17,18,10:14)

# After cleaning the data, writing it to a new file to be read later (without having to clean data again)
write.csv(merged_rent_value, file = "~/Desktop/NYCDataScience/BootCamp/Projects/Project1_Shiny/zipcode_data_clean.csv", row.names = F)
save(merged_rent_value, file = "~/Desktop/NYCDataScience/BootCamp/Projects/Project1_Shiny/MHD_P1/zipcode_data.rda")

# More manipulation for bar plots (Doing this in Shiny instead)
rent = merged_rent_value %>% filter(Dates == "Jan 2012" | Dates == "Dec 2016") %>% select(-(contains("Val"))) %>% group_by(Zipcode)
value = merged_rent_value %>% filter(Dates == "Jan 2012" | Dates == "Dec 2016") %>% select(-(contains("Rent"))) %>% group_by(Zipcode)

rent_wide = spread(rent, key = "Dates", value = "Rent" )
rent_wide$Percent_Change = ((rent_wide$`Dec 2016` - rent_wide$`Jan 2012`) / rent_wide$`Jan 2012`) * 100
rent_wide$Source = "Rent"

val_wide = spread(value, key = "Dates", value = "Value" )
val_wide$Percent_Change = ((val_wide$`Dec 2016` - val_wide$`Jan 2012`) / val_wide$`Jan 2012`) * 100
val_wide$Source = "Value"

rent_val_wide = full_join(rent_wide, val_wide, by = intersect(names(rent_wide), names(val_wide))) %>%
        select(-starts_with("RegionID"))

write.csv(rent_val_wide, file='zipcode_data_bar.csv', row.names=F)
save(rent_val_wide, file = "zipcode_bar.rda")

# Getting the zipcode spatial data ready
url <- "http://www2.census.gov/geo/tiger/GENZ2014/shp/cb_2014_us_zcta510_500k.zip"
setwd("~/Desktop/NYCDataScience/BootCamp/Projects/Project1_Shiny/")
downloaddir = getwd()
destname<-"tiger_zip.zip"
download.file(url, destname)
unzip(destname, exdir=downloaddir, junkpaths=TRUE)

filename<-list.files(downloaddir, pattern=".shp", full.names=FALSE)
filename<-gsub(".shp", "", filename)

# ----- Read in shapefile (NAD83 coordinate system)
# ----- this is a fairly big shapefile and takes 1 minute to read
dat = readOGR(downloaddir, "cb_2014_us_zcta510_500k") 

# Getting only the zipcodes that match my data set
dat2 = dat[dat$GEOID10 %in% unique(merged_rent_value$Zipcode),]

# Saving the Zipcode Spatial Data for easy loading
# save(dat, file = "MHD_Proj1_ShinyApp/zipcode_shape_data.rda") # Larger file with more zipcodes than I need 
save(dat2, file = "MHD_Proj1_ShinyApp/zipcode_shape_data2.rda") # Smaller file with just the zipcodes that match my data set




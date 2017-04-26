library(shiny)
library(leaflet)
library(RColorBrewer)
library(plyr)
library(dplyr)
library(ggplot2)
library(DT)
library(maptools)
library(rgdal)
library(geojsonio)
library(ggthemes)

######################Data cleaning##################################
#nyc.airbnb <- read.csv("~/Desktop/Data Science Acadamy/NYC_airbnb/NYC_Airbnb_listings.csv")
nyc.airbnb <- read.csv("./NYC_Airbnb_listings.csv")
# Clean the datas that has no reviews
nyc.airbnb1 <- nyc.airbnb[!is.na(nyc.airbnb$reviews_per_month),]
# Convert the date from factor to date fomat
nyc.airbnb1$last_review = as.Date(nyc.airbnb1$last_review)

# Keep the active account in the recent 2 years.
# Count the last review date that before 2015 which is 518 obs. Remove those
nyc.airbnb1 %>% filter(last_review<'2015-01-01') %>% summarise(n())
nyc_bnb <- nyc.airbnb1 %>% filter(last_review>'2015-01-01')

# Each room type number in each neighbourhood
roomtype_neigh <- nyc_bnb %>% group_by(room_type,neighbourhood_group) %>% summarise(count=n())

roomtype_man <- nyc_bnb %>% 
  filter(neighbourhood_group=="Manhattan") %>% # Reactive this part. Change to different neigbourhood
  group_by(neighbourhood) %>% 
  summarise(count=n()) 

# Find the common names
common_name <- nyc_bnb %>% 
  group_by(host_name) %>% 
  summarise(name_num=n()) %>% 
  arrange(desc(name_num)) %>% 
  head(10)
common_name_bnb <- filter(nyc_bnb, host_name %in% common_name$host_name)

# Find the hosts with multipal lists
multi_list <- nyc_bnb%>% group_by(host_id,host_name,neighbourhood_group) %>% summarise(count=n(),dayily_income=sum(price)) %>% arrange(desc(count)) %>% filter(count>2)
multi_list_loc <- filter(nyc_bnb, nyc_bnb$host_id %in% multi_list$host_id)
multi_list_bnb <- left_join(multi_list_loc,multi_list,by="host_id")
mynyc_1 <- readLines("./NYC_Airbnb_listings.csv")
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

######################Data cleaning##################################
# Clean the datas that has no reviews
nyc.airbnb1 <- nyc.airbnb[!is.na(nyc.airbnb$reviews_per_month),]
# Convert the date from factor to date fomat
nyc.airbnb1$last_review = as.Date(nyc.airbnb1$last_review)
# Keep the active account in the recent 2 years.
# Count the last review date that before 2015 which is 518 obs. Remove those
nyc.airbnb1 %>% filter(last_review<'2015-01-01') %>% summarise(n())
nyc_bnb <- nyc.airbnb1 %>% filter(last_review>'2015-01-01')
roomtype_neigh <- nyc_bnb %>% group_by(room_type,neighbourhood_group) %>% summarise(count=n())
roomtype_man <- nyc_bnb %>% 
  filter(neighbourhood_group=="Manhattan") %>% ####Change to different neig
  group_by(neighbourhood) %>% 
  summarise(count=n()) 
common_name <- nyc_bnb %>% 
  group_by(host_name) %>% 
  summarise(name_num=n()) %>% 
  arrange(desc(name_num)) %>% 
  top_n(10)

mynyc = geojson_read("~rdong/Downloads/neighbourhoods.geojson")
multi_list <- nyc_bnb%>% group_by(host_id,host_name,neighbourhood_group) %>% summarise(count=n(),dayily_income=sum(price)) %>% arrange(desc(count)) %>% filter(count>=3)
multi_list_loc <- filter(nyc_bnb, nyc_bnb$host_id %in% multi_list$host_id)
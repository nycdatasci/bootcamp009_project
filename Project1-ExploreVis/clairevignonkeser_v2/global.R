library(reshape2)
library(plyr)
library(dplyr)
library(ggplot2)
library(tidyr)
library(ggthemes)
library(leaflet)
library(shiny)
library(googleVis)
library(data.table)
library(scales)
library(plotly)
library(ggmap)
library(shinydashboard)
library(googleway)

#import df
df = readRDS('./www/201605-citibike-tripdata_df.rda')
melt_df = readRDS('./www/201605-citibike-tripdata_melt.rda')
dir_df = readRDS('./www/201605-citibike-tripdata_direction.rda')

#import icons
bike_icon = makeIcon('www/bike_icon.png', iconWidth = 30, iconHeight = 35)

#gMap API key
key = "AIzaSyB1Oq-rYunwKh-I0Cgx0z2nCy0m8T5FukA"

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
source('key.R') # import the gmap API key from different R doc

#import df
df = readRDS('./www/201605-citibike-tripdata_df.rda')
melt_df = readRDS('./www/201605-citibike-tripdata_melt.rda')
dir_df = readRDS('./www/201605-citibike-tripdata_direction.rda')

#import icons
bike_icon = makeIcon('www/bike_icon.png', iconWidth = 30, iconHeight = 35)



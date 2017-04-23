#require(RSQLite)
#require(zipcode)
# data frame creation, cleaning, and manipulation
require(dplyr)
# For plottings
require(ggplot2)
# Need for rendering the data table
require(DT)
# Label creation for the map
require(htmltools)
# For the mosaic plots
require(graphics)
#require(geojsonio)
# For the polygon layers
library(rgdal)
require(shiny)
# For the map
require(leaflet)
#library(mapdata)
#library(mapproj)
#library(rgeos)
# For the creation of the wordcloud
require(tm)
require(wordcloud)

setwd("~/data/consumer_complaints")

### Read in main data frame
complaints = readRDS('data/complaints.Rda')

### Read in json SpatialPolygonsDataFrame with default count info
##states = readOGR('data/states.json')

## Read in the SpatialPolygonsDataFrame with default counts
states = readOGR('data/states.json')
states$NAME = as.character(states$NAME)

## Read in state names and populations
pops = read.csv("data/us_populations.csv", stringsAsFactors = F)

## Create choices for selection input
complaint_vars = names(complaints %>% select(-c(Date.received, Date.sent.to.company, 
                                                latitude, longitude)))
## Add blank choice to selection input
complaint_vars = c(complaint_vars,"All")

## Read in Rda of the consumer text input for each complaint grouped by each company
narratives = readRDS('data/narratives.Rda')
## Create a character vector of all the companies for the word bubble (the blank ones have been filtered)
companies = sort(unique(narratives$Company))

library(shiny)
library(rworldmap)
library(mapdata)
library(leaflet)
library(leaflet.extras)
library(data.table)
library(ggplot2) 
library(dplyr)
library(plotly)
library(sp)
library(maps)
library(maptools)
library(googleVis)
library(gridExtra)
library(bubbles)
library(RColorBrewer)
library(ggthemes)
library(scales)
library(shinysky)


Sys.setenv('MAPBOX_TOKEN'='pk.eyJ1IjoiY2hhc2VlZGdlIiwiYSI6ImNqMXRwc2s1eDAwZzIzMnBiZnN2dWIxcXIifQ.pxKeEr0yx2ouPCjmVyxANg')
source('./modules/homePage.R')
source('./modules/mapPage.R')
source('./modules/summaryPage.R')
source('./modules/econPage.R')

africa = readRDS('./data/africa.Rds')
setkey(africa,year,country)

econData = readRDS('./data/econData.rds')
ethnicMap = readRDS('./data/ethnicity_map.rds')


# list of all countries
allCountries = unique(africa[,.(deaths=sum(fatalities),by=country)][order(-deaths)]$by)
allEvents = unique(africa$event_type)
allActors = unique(africa$actor1)

# z = merge(africa$country, econData


# geo coords for ggplot
mapWorld = map('world', plot=F, fill=T)

# malawi and eg are referenced only by subregion
mapAfrica = as.data.table(fortify(mapWorld))
mapAfrica = mapAfrica[region %in% allCountries & (
  is.na(subregion) | region=="Equatorial Guinea" | region=="Malawi")]
mapAfrica[,subregion := NULL]


# all sp map to check points against
mapWorldSP = map2SpatialPolygons(
  mapWorld, IDs=sapply(strsplit(mapWorld$names, ":"), "[", 1L),
  proj4string=CRS("+proj=longlat +datum=WGS84"))

# returns the country based x, y coords
getCountry = function(x,y) {
  coords = data.frame(x=x,y=y)
  
  # convert points to a sp
  pointsSP = SpatialPoints(coords, proj4string=CRS(proj4string(mapWorldSP)))
  
  # returns the index of the polygons object each point is over
  index = over(pointsSP, mapWorldSP)
  
  # returns the country name
  mapWorldSP[index]@polygons[[1]]@ID
}


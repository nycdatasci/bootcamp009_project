library(shiny)
library(shinyBS)
library(shinydashboard)
library(leaflet)
library(ggplot2)
library(dplyr)
library(plotly)
library(RColorBrewer)
library(geojsonio)
library(data.table)
library(tidyr)
library(rgdal)
library(scales)

#main dataset (from US Dept of Education, joined with Treasury data)
univDT_Cut <- 
  fread('univDT_JoinedWcorrectROI1_Cut.csv', 
        stringsAsFactors = F)
#100 cities with the most universities
cc100DT <- fread(input = 'cc100DT.csv', stringsAsFactors = F)

#colors set for theamtic map in "Earnings in the US" tab
pal <- colorNumeric("Blues", domain = NULL, 
                    reverse = FALSE)

#metro/micropolitan shapefile
usMetrosJson5Simp <- 
  geojsonio::geojson_read("metros5Simp.geojson", what = "sp")

#fields converted into numeric 
#shown when hovering over the map
usMetrosJson5Simp$metroJoin_DifBAHS15 <- as.numeric(levels(usMetrosJson5Simp$metroJoin_DifBAHS15))[usMetrosJson5Simp$metroJoin_DifBAHS15]
usMetrosJson5Simp$metroJoin_HSorGED15 <- as.numeric(levels(usMetrosJson5Simp$metroJoin_HSorGED15))[usMetrosJson5Simp$metroJoin_HSorGED15]
usMetrosJson5Simp$metroJoin_Bachelorsdegree15 <- as.numeric(levels(usMetrosJson5Simp$metroJoin_Bachelorsdegree15))[usMetrosJson5Simp$metroJoin_Bachelorsdegree15]
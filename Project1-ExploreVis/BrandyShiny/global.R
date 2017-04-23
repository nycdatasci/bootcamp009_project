##############################################
###  Data Science Bootcamp 9               ###
###  Project 1 - Exploratory Visualization ###
###  Brandy Freitas  / April 23, 2017      ###
###     Trends in Risk Behavior in NYC     ###
###           Teens from 2001-2015         ###
##############################################


library(DT)
library(shiny)
library(shinydashboard)
library(googleVis)
library(ggplot2)
library(dplyr)
library(scales)
library(RColorBrewer)
library(ggmap)
library(leaflet)
library(maps)
library(tidyr)
library(plotly)



content_M <- paste(sep = "<br/>", "Manhattan", "White: 6%", "Black: 27%", "Asian: 8%", "Hispanic: 53%")
content_Q <- paste(sep = "<br/>", "Queens", "White: 12%", "Black: 22%", "Asian: 22%", "Hispanic: 37%")
content_BK <- paste(sep = "<br/>", "Brooklyn", "White: 9%", "Black: 44%", "Asian: 9%", "Hispanic: 33%")
content_S <- paste(sep = "<br/>", "Staten Island", "White: 47%", "Black: 13%", "Asian: 11%", "Hispanic: 25%")
content_BX <- paste(sep = "<br/>", "Bronx", "White: 3%", "Black: 27%", "Asian: 5%", "Hispanic: 60%")

BoroData <- read.csv('FullBoroData.csv')
BoroData$year <- strftime(as.Date(as.character(BoroData$year), "%Y"), '%Y')
Boros_AllDrugs <- BoroData %>% drop_na(Marijuana, Cocaine, Heroin, Meth, Molly, BingeDrink, Smoker)
Boros_Depression <- BoroData %>% drop_na(ContSuicide, AttSuicide)
BoroTableDisplay <- select(BoroData, 'Boro'= sitename, 'Year' = year, 'Age' = age, 'Gender' = sex, 
                           'Grade' = grade, 'Race' = race, 'BMI' = bmi)



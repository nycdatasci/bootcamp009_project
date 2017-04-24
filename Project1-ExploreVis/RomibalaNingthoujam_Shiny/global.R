# Romibala Ningthoujam
# NYC DSA: Project - DataVizShiny

library(lubridate)
library(dplyr)
library(shiny)
library(ggplot2)
library(plotly)
library(zipcode)
library(Hmisc)
library(leaflet)

hospitals_data <- read.csv("./data/hospitals_transformed.csv", stringsAsFactors = FALSE)

# Convert columns 'Denominator', 'Score', 'Lower.Estimate', 'Higher.Estimate' to numeric
hospitals_data$Denominator <- as.numeric(hospitals_data$Denominator)
hospitals_data$Score <- as.numeric(hospitals_data$Score)
hospitals_data$Lower.Estimate <- as.numeric(hospitals_data$Lower.Estimate)
hospitals_data$Higher.Estimate <- as.numeric(hospitals_data$Higher.Estimate)

# create variable with States as choice
choice <- unique(hospitals_data$Measure.Name)

dev.off()



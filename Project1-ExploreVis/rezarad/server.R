library(dplyr)
library(dbplyr)
library(tidyr)
library(shiny)
library(shinydashboard)

## server.R ##

source("helpers.R")

fares_by_date = getFaresData()

function(input, output) {
  
  output$fares_data = DT::renderDataTable(fares_by_date)
}


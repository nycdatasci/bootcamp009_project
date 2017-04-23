library(shiny)

## server.R ##

source("helpers.R")

fares_by_date = getFaresData()
stations_data = getStationData("./data/Stations.csv")

function(input, output) {
  
  output$mtamap = renderLeaflet(getBaseMap())
  # output$q_train = renderLeaflet(addMTAStations() )
  # event = input$mtamap_marker_click 
  
  output$fares_data = DT::renderDataTable(fares_by_date)

  }


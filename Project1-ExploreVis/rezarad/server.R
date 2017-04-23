## server.R ##
source("helpers.R")

fares_by_date = getFaresData()
stations_data = getStationData("./data/Stations.csv")


function(input, output) {
  
  line_reactive = reactive({
    getBaseMap() %>% mapLineData(
                      filteredLineData(input$do, stations_data),
                      color = mta_lines[input$do][[1]]
                      )
  })
  
  output$mtamap = renderLeaflet(line_reactive())

  output$fares_data = DT::renderDataTable(fares_by_date)

  }


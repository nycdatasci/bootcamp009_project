## server.R ##

function(input, output, session) {
  require(dbplyr)
  require(dplyr)
  
  # Filter by MTA line from user input 
  stations_data = getStationData("./data/Updated_Stations.csv")
  line_reactive = reactive({
    getBaseMap() %>% mapLineData(
                      filteredLineData(input$line, stations_data),
                      color = mta_lines[input$line][[1]]
                      )
  })
  
  output$mtamap = renderLeaflet(line_reactive())
  
  
  observeEvent(input$mtamap_marker_click, 
               {
                station_nm = (stations_data %>% 
                                filter(`GTFS Latitude` == input$mtamap_marker_click$lat & 
                                         `GTFS Longitude` ==  input$mtamap_marker_click$lng) %>% 
                                transmute(`Stop Name`))[[1]]
  
                output$station_name = renderUI(station_nm)
                
                ts_data = read.csv("./data/turnstile_count.csv")
                output$ts_per_station = renderPrint((ts_data %>%
                                                       filter(Stop.Name == station_nm) %>% 
                                                       select(Number.of.Turnstiles))[1,1]
                                                    )
                output$entries_year = renderPrint((ts_data %>%
                                                       filter(Stop.Name == station_nm) %>% 
                                                       select(Number.of.Turnstiles))[1,1]
                )
                
                output$exits_year = renderPrint((ts_data %>%
                                                       filter(Stop.Name == station_nm) %>% 
                                                       select(Number.of.Turnstiles))[1,1]
                )
                output$entries_all = renderPrint((ts_data %>%
                                                       filter(Stop.Name == station_nm) %>% 
                                                       select(Number.of.Turnstiles))[1,1]
                )
                output$exits_all = renderPrint((ts_data %>%
                                                       filter(Stop.Name == station_nm) %>% 
                                                       select(Number.of.Turnstiles))[1,1]
                )
               })
    
  # observeEvent(input$station_name,
  #                {
  #                  ts_data = read.csv("./data/turnstile_count.csv")
  #                  output$ts_per_station = renderPrint((ts_data %>%
  #                                                     filter(Stop.Name == input$station_name) %>% 
  #                                                     select(Number.of.Turnstiles))[1,1]
  #                                             )
  #                                   })
    
  # output$ts_per_station = renderPrint(ts_data_reactive())
  
  # output$fares_data = DT::renderDataTable(getFaresData("fares_data"), server = T)

}



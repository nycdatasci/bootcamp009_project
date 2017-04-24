## server.R ##
fares_by_date = getFaresData()

function(input, output) {
  
  # Filter by MTA line from user input 
  line_reactive = reactive({
    getBaseMap() %>% mapLineData(
                      filteredLineData(input$do, stations_data),
                      color = mta_lines[input$do][[1]]
                      )
  })
  output$mtamap = renderLeaflet(line_reactive())
  
  # Display additional station details
  observeEvent(input$mtamap_marker_click, {
    output$station_stats = renderPrint(stations_data %>% 
                                          filter(`GTFS Latitude` == input$mtamap_marker_click$lat & 
                                                  `GTFS Longitude` ==  input$mtamap_marker_click$lng) %>% 
                                          select(`Stop Name`))
  })

  # output$ts_per_station = DT::renderDataTable(collect(turnstile_db %>%
  #   filter(STATION == input$station_stats) %>% 
  #   distinct(SCP)))
  # 
  output$fares_data = DT::renderDataTable(fares_by_date)

  }


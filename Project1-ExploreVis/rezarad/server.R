## server.R ##
function(input, output, session) {
  require(dbplyr)
  require(dplyr)
  
# Filter by MTA line from user input 
  line_reactive = reactive({
    getBaseMap() %>% mapLineData(
                      filteredLineData(input$line, stations_data),
                      color = mta_lines[input$line][[1]]
                      )
  })
  
  output$mtamap = renderLeaflet(line_reactive())
  
  observeEvent(input$mtamap_marker_click,{
    
      filtered_station = stations_data %>%
                        filter(`GTFS Latitude` == input$mtamap_marker_click$lat &
                               `GTFS Longitude` ==  input$mtamap_marker_click$lng)
      
      # internal_station_name = stations_data %>%
      #   filter(`Stop Name` == station_nm) %>% 
      #   select(`Turnstile Station Name`)
      # 
      # internal_station_name = toupper(internal_station_name[[1]])
      # 
      # totals = station_details %>% 
      #   filter(STATION %in% internal_station_name)
      # 
      # output$entries_year = renderText(totals$Total_Entries[1])
      # output$exits_year = renderText(totals$Total_Exits[1])
      # 
      # 
      output$station_name = renderUI(station_nm)
    
      
     }
     )
  output$stations_compare = DT::renderDataTable(station_details)
  
}
    



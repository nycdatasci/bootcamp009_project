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
  
  observeEvent(input$mtamap_marker_click,
     {
       
      station_nm = (stations_data %>%
                      filter(`GTFS Latitude` == input$mtamap_marker_click$lat &
                               `GTFS Longitude` ==  input$mtamap_marker_click$lng) %>%
                      transmute(`Stop Name`))[[1]]

      output$station_name = renderUI(station_nm)
      
      output$ts_per_station = renderText((ts_data %>%
                                             filter(Stop.Name == station_nm) %>%
                                             select(Number.of.Turnstiles))[1,1])
      
      observeEvent(input$button,
                   {
                     station_filter = ts_data %>%
                       filter(Stop.Name == station_nm) %>%
                       select(STATION)
                     
                     entries_year = collect(getTurnstileData("turnstile_data") %>%
                                              filter(STATION %in% station_filter$STATION) %>% 
                                              select(SCP, STATION, DATE, TIME, ENTRIES, EXITS))
                     
                     entries_year = entries_year %>%
                       mutate(DATE = as.Date(DATE,format = "%m/%d/%Y")) %>%
                       arrange(DATE, TIME)
                     
                     total_year = entries_year %>%
                       filter(DATE >= input$daterange_turnstile[1] & DATE <= input$daterange_turnstile[2]) %>%
                       group_by(SCP) %>% 
                       arrange(DATE) 
                       
                     
                     by_weekday = entries_year %>% 
                       mutate(Weekday = weekdays(DATE)) %>% 
                       group_by(STATION)
                     
                     
                     
                     # %>%
                     #   summarise(ENTRIES = max(ENTRIES)-min(ENTRIES),EXITS = max(EXITS) - min(EXITS)) %>% 
                     #   group_by(SCP, DATE)
                     
                     output$entries_year = DT::renderDataTable(total_year)
                     output$by_day = DT::renderDataTable(by_weekday)
                     # total = total_year[-1,] - total_year[-nrow(total_year),]

                     # 
                     # output$plot1 = renderPlot(ggplot(total_year,
                     #                                  aes(x = DATE,
                     #                                      y = max(ENTRIES))
                     # ) + geom_smooth())
                     
                   }
      )    
     }
     )
  output$stations_compare = renderPrint(station_nm)
  
}
    



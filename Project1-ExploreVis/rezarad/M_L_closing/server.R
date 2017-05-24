## server.R ##
function(input, output) {
    
    # render map of subway stations impacted by linework
    output$mtamap = renderLeaflet(map)
    
    observeEvent(input$mtamap_marker_click,{
      
      filtered_station = stations_data[`GTFS Latitude` == input$mtamap_marker_click$lat & 
                                         `GTFS Longitude` ==  input$mtamap_marker_click$lng,]
      
      turnstile_data_name = filtered_station[,"Turnstile Station Name"][[1]]
      
      output$station_name = renderText(filtered_station[,"Stop Name"][[1]])
      
    }
    )      

    output$dateText  <- renderText({
      paste("input$date is", as.character(input$date))
    })
    
    output$dateText2 <- renderText({
      paste("input$date2 is", as.character(input$date2))
    })
    
    output$dateRangeText  <- renderText({
      paste("input$dateRange is", 
            paste(as.character(input$dateRange), collapse = " to ")
      )
    })
    
    output$dateRangeText2 <- renderText({
      paste("input$dateRange2 is", 
            paste(as.character(input$dateRange2), collapse = " to ")
      )
    })
}
  

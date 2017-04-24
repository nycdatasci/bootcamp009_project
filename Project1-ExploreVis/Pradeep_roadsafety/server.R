shinyServer(function(input, output){
  
  
  output$map1 <- renderLeaflet({
    leaflet() %>%
      addTiles(
        urlTemplate = "http://{s}.tile.osm.org/{z}/{x}/{y}.png",
        attribution = '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors') %>%
      setView(lng = -73.97, lat = 40.75, zoom = 12)
  }
  )
  
observeEvent(input$borough,{
  observeEvent(input$vehicle,{
          observeEvent(input$time,{
            
  data1=filter_(mvc_major,input$borough)
  data2=filter_(data1,input$vehicle)
  data3=filter_(data2, input$time)
    x=mean(data1$LONGITUDE)
    y=mean(data1$LATITUDE)
  
    icons <- awesomeIcons(
      icon = 'ios-close',
      iconColor = 'black',
      library = 'ion',
      markerColor = data1$color
    )
    
    
      proxy <- leafletProxy("map1")%>%clearMarkerClusters()%>%clearMarkers()%>%
      setView(x, y, zoom=13) %>%
      addAwesomeMarkers(data = data3,
                                     lat=~LATITUDE,
                                     lng=~LONGITUDE,
                        icon=icons,
                                  
                 popup = ~paste("Total Accidents:", n, "Fatalities:", total_fatalities, "Injuries:", total_injuries, sep=" |")
                                     
      )
  })
        })
  
})

  })



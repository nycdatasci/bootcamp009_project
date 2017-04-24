
function(input, output, session) {

  
#=================================================taxi revenue map=======================================  
  output$nhMap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("OpenMapSurfer.Grayscale")  %>%
      setView(lng=-73.92910,lat=40.7731,zoom=12) %>%
      addPolygons(data=nhMap,
                  # to label neighborhood names, average tip %, tip revenue and taxi revenue
                  label= mapply(function(x,y,z,q) {
                    HTML(sprintf("<em>%s<br></em> %s<br></em> %s<br></em> %s", htmlEscape(x), htmlEscape(y),htmlEscape(z),htmlEscape(q)))},
                    nhMap$NTAName,paste0("Tip % : ",round(nhMap$tip_per,digit=2),"%"),
                    paste0("Tip Revenue : ","$",as.character(formatC(nhMap$tip_value,format='f',digits=0,big.mark=","))),
                    paste0("Taxi Revenue : ","$",as.character(formatC(nhMap$taxi_revenue,format='f',digits=0,big.mark=","))), SIMPLIFY = F),
                  
                  # fill color by taxi revenue 
                  fillColor = ~colorNumeric("YlOrBr",taxi_revenue,n=10)(taxi_revenue),
                  fillOpacity = 0.8,
                  color = "#BDBDC3",
                  weight = 1) %>% 
      addLegend("topleft", pal = colorNumeric(palette = "YlOrBr", domain = nhMap$taxi_revenue), values =nhMap$taxi_revenue,
                title = "Taxi Revenue By Neighborhood",
                labFormat = labelFormat(prefix = "$"),
                opacity = 0.5,bins=10)
    
  })

  
  
#==============================render time vs tip revenue map============================================================
 
   chooseMap=reactive({
    pickupTipLt=
      timeData %>%
      filter(pickup_datetime==input$time)
    
    # to merge filtered data with neighborhood spacial polygon dataframe
    leafmap2=sp::merge(nh,pickupTipLt,by.x="NTACode",by.y="NTACode",duplicateGeoms=TRUE)
    
    # remove missing values
    leafmap2=sp.na.omit(leafmap2)
    
    # to make filtered data global
    assign("leafmap2", leafmap2, envir = .GlobalEnv) 
    return (leafmap2)


  })
  output$timeMap <- renderLeaflet({
    leaflet(chooseMap()) %>%
      addProviderTiles("OpenMapSurfer.Grayscale") %>%
      setView(lng=-73.92910,lat=40.7731,zoom=13)%>%
      addPolygons(label= mapply(function(x,y,z,q) {
                             HTML(sprintf("<em>%s<br></em> %s<br></em> %s<br></em> %s", htmlEscape(x), htmlEscape(y),htmlEscape(z),htmlEscape(q)))},
                             leafmap2$NTAName,paste0("Tip % : ",round(leafmap2$avg_tip_per,digit=2),"%"),
                             paste0("Tip Revenue : ","$",as.character(formatC(leafmap2$tip_value,format='f',digits=0,big.mark=","))),
                             paste0("Taxi Revenue : ","$",as.character(formatC(leafmap2$taxi_revenue,format='f',digits=0,big.mark=","))), SIMPLIFY = F),
                  fillColor = ~colorQuantile("YlOrRd",leafmap2$avg_tip_per)(leafmap2$avg_tip_per),
                  fillOpacity = 0.8,
                  color = "#BDBDC3",
                  weight = 1) %>% 
      addLegend("topleft", pal = colorNumeric(palette = "YlOrRd", domain = leafmap2$avg_tip_per), values =~avg_tip_per,
                title = "Tip % By Neighborhood",
                labFormat = labelFormat(suffix = "%"),
                opacity = 0.5)
  })
  
  # to add column chart of neighborhoods with highest tips
  chartTip <- reactive({
    #chooseMap()@data %>% 
    leafmap2@data %>% 
      dplyr::select(NTAName,avg_tip_per) %>% 
      arrange(avg_tip_per) %>% 
      top_n(.,6)
      
  })
  
  # render column chart
  output$nhHistogram <- renderPlot({
    
  gvisColumnChart(chartTip())
                    # options = list(height = 350, width = 350,
                    #                colors = "#5ab4ac",
                    #                legend = "{position: 'none'}",
                    #                titleTextStyle="{fontSize: 12 }",
                    #                title = paste("Top 6 Neighborhood")))

    
})
  
  # link to my LinkedIn
  output$lk_in = renderMenu ({
    menuItem("LinkedIn", icon = icon("linkedin-square"),
             href = "https://www.linkedin.com/in/choutine")
  })
  
  # link to my blog
  output$blg = renderMenu ({
    menuItem("Blog", icon = icon("link"),
             href = "http://blog.nycdatascience.com/author")
  })
    
}


  
  
      
  # userFare=reactive({
  # 
  #   userPickup<- strsplit(as.character(geocodeAdddress(input$pickUp))," ")
  #   userDropoff <-  strsplit(as.character(geocodeAdddress(input$dropOff))," ")
  #   
  #   long <- as.vector(userPickup[[1]])
  #   lat <- as.vector(userPickup[[2]])
  #   long <- append(long,userDropoff[[1]])
  #   lat <- append(lat,userDropoff[[2]])
  #   address<-as.vector(input$pickup)
  #   address<-append(address,as.vector(input$dropoff))
  #   
  #   userData<-data.frame(long,lat,address)
  #   assign("userData", userData, envir = .GlobalEnv)
  #   return (userData)
  #   
  # 
  # })
  # 
  # 
  # 
  # output$total_payment <- renderText({
  #   # 
  #   # pickupAdd=input$pickUp
  #   # dropoffAdd=input$dropOff
  #   # userPickup<- strsplit(as.character(geocodeAdddress(input$pickUp))," ")
  #   # userDropoff <-  strsplit(as.character(geocodeAdddress(input$dropOff))," ")
  #   # userPickupLong <-userPickup[1]
  #   # userPickupLat <-userPickup[2]
  #   # userDropLong <- userDropoff[1]
  #   # userDropLat <- userDropoff[2]
  #   # assign("userPickupLong", userPickupLong, envir = .GlobalEnv) 
  #   # assign("userPickupLat", userPickupLat, envir = .GlobalEnv) 
  #   # assign("userDropLong", userDropLong, envir = .GlobalEnv) 
  #   # assign("userDropLat", userDropLat, envir = .GlobalEnv) 
  #   
  # 
  #   # long <- as.vector(userPickup[1])
  #   # lat <- as.vector(userPickup[2])
  #   # long <- as.vector(userDropoff[1])
  #   # lat <- as.vector(userDropoff[2])
  #   # address<-as.vector(input$pickup)
  #   # address<-as.vector(input$dropoff)
  #   # userData<-data.frame(long,lat,address)
  #   taxi_fare=22940+141.3*userFare()$long[1] -73.58* userFare()$lat[1] 
  #   + 92.22* userFare()$long[2]  -65.06*userFare()$lat[2]+0.03823* input$hr+ 0.07082*input$passenger_count
  #   # taxi_fare=22940+141.3*userPickupLong -73.58* userPickupLat 
  #   #   + 92.22* userDropLong -65.06*userDropLat+0.03823* input$hr+ 0.07082*input$passenger_count
  #   # assign("userData", userData, envir = .GlobalEnv)
  #   # return (userData)
  #   paste0("Estimated Taxi Fare : $",taxi_fare)
  # })
  # 
  # 
  
  # output$fareMap <- renderLeaflet({
  #   leaflet(userFare()) %>%
  #     addTiles() %>% 
  #     setView(lng=-73.92910,lat=40.7731,zoom=12)%>%
  #     addMarkers(long,lat) 
  #     
  # })

#   
#   output$speedTip=renderGvis(
#     # gvisLineChart(speedTip))
#     gvisScatterChart(speedTip))
  










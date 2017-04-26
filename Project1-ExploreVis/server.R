library(shiny)
library(DT)
library(plyr)
library(dplyr)
library(googleVis)
library(maps)
library(geojsonio)
function(input, output) {
}

shinyServer(function(input, output){
 
  ###Topic 1
  roomtype_neigh <- nyc_bnb %>% group_by(room_type,neighbourhood_group) %>% summarise(count=n())
  fact1_roomtype <- reactive({roomtype_neigh %>% 
      filter(neighbourhood_group %in% input$fact1_1)})
  
  output$fact1_2 <- renderPlot({fact1_roomtype() %>% 
      ggplot(aes(x=room_type, y=count)) + 
      geom_bar(stat = 'identity', aes(fill=room_type)) +
      facet_grid(.~input$fact1_1, scales="free",space="free") + 
      theme_economist() + 
      scale_fill_economist() + 
      labs(x="Room Type", y="Number")+ 
      theme(axis.text.x = element_blank())
  })
  
  ###Topic 2
  fact2_boro <- reactive({nyc_bnb %>% 
      filter(neighbourhood_group==input$fact2_1) %>% 
      group_by(neighbourhood) %>% 
      summarise(count=n())})
  
  output$fact2_2 <- renderPlot({fact2_boro() %>% ggplot(aes(x=neighbourhood, y=count))+
      coord_polar(theta = "x")+geom_bar(stat = "identity")+
      theme_economist() + scale_fill_economist()+labs(x="Boro", y="Number")
    },width = 600, height = 580)
  
  output$hotareabox <- renderInfoBox({
    infoBox("HOT AREA",
      fact2_boro() %>% filter(count==max(count)),
      paste0("Percentage:",round(max(fact2_boro()$count)/sum(fact2_boro()$count)*100,digits = 2),"%"),
      icon = icon("thumbs-up"),
      color = "maroon"
    )
  })
  
  ###Topic 3
  fact4_name <- nyc_bnb %>% 
    group_by(host_name) %>% 
    summarise(name_num=n()) %>% 
    arrange(desc(name_num))%>% 
    head(10)
  
  output$top_names <- renderGvis({gvisBarChart(
    fact4_name,xvar = "host_name", yvar = "name_num",options = list(hAxis="{title:'Name Number'}",
                                                                    vAxis="{title:'Common Name'}",
                                                                    width="900px", height="400px",
                                                                    series = "{labelInLegend: 'Numbers'}",
                                                                    legend = "{position: 'none'}"))
  })
  
  
  output$text3 <- renderUI({obj <-  t.test(common_name_bnb$number_of_reviews, nyc_bnb$number_of_reviews,alternative = "greater")
  HTML(
    paste0( "Average common name review numbers = 21.26",'<br/>',
            "Average all review numbers = 21.02",'<br/>',
            "t = ", round(obj[[3]],3), '<br/>', 
            "df = ", round(obj[[2]],3), '<br/>',
            "p-value = ", round(obj[[3]],5),'<br/>',
            h3("CONCLUSION: The popular host name doesn't increase the chance of the rent.")))
  })
  
  ###Topic 4
   fact3_map<- nyc_bnb %>% filter(number_of_reviews>mean(number_of_reviews), 
                                  #availability_365>360, 
                                  minimum_nights>=30)
   
  output$map <- renderLeaflet({
    leaflet(fact3_map) %>% 
    setView(lng = -73.98631,
            lat = 40.72203, zoom = 12) %>%
      addProviderTiles("Esri.WorldStreetMap") %>%
      addMarkers(~longitude, ~latitude,
                 clusterOptions = markerClusterOptions(),
                 popup=~paste0("Host Name:",
                 as.character(host_name),
                 "<br>",
                 "Neighbourhood:",
                 as.character(neighbourhood),
                 "<br>",
                 "Price:",
                 as.character(price))
      )
  })
  

    ###Topic 5：
    multi_list_bnb <- left_join(multi_list_loc,multi_list,by="host_id")
    reactive_multi <- reactive({
      multi_list_bnb[multi_list_bnb$count >= input$fact5_1[1] & multi_list_bnb$count<= input$fact5_1[2],]
    })    
    mynyc_1 <- readLines("./neighbourhoods.geojson")
    output$map2 = renderLeaflet({
       leaflet(multi_list_bnb) %>% setView(-73.944911, 40.732839, zoom = 12) %>%
         addTiles() %>%
         addGeoJSON(mynyc_1, 
                    weight = 1,
                    color = "#555555", 
                    fillColor='grey',
                    options=pathOptions(clickable=FALSE),
                    opacity = 1,
                    fillOpacity = 0.1)%>%
         addCircleMarkers(~longitude, ~latitude,
                          fill=TRUE,weight=0.8,opacity = 8,
                          radius = 5, color='green',
                          popup=~paste("Host Name:",
                                       as.character(host_name.x),
                                       "<br>",
                                       "Listing Numbers:",
                                       as.character(count),
                                       "<br>",
                                       "Daily Income:",
                                       as.character(dayily_income),
                                       "<br>",
                                       "Neighbourhood:",
                                       as.character(neighbourhood)))
     })
     
     observe({
       leafletProxy("map2", data = reactive_multi())%>%
         clearMarkers() %>%
         addCircleMarkers(~longitude, ~latitude,
                          fill=TRUE,weight=0.8,opacity =8,
                          radius = 3, color='green',
                          popup=~paste("Host Name:",
                                       as.character(host_name.x),
                                       "<br>",
                                       "Listing Numbers:",
                                       as.character(count),
                                       "<br>",
                                       "Daily Income:",
                                       as.character(dayily_income),
                                       "<br>",
                                       "Neighbourhood:",
                                       as.character(neighbourhood)))%>%
       addGeoJSON(mynyc_1, 
                  weight = 1,
                  color = "#555555", 
                  fillColor='grey',
                  options=pathOptions(clickable=FALSE),
                  opacity = 1,
                  fillOpacity = 0.1)})

     
##########################Ignore this. It's my debug and experiment process########################
    #observeEvent(input$fact5_1,{
     # proxy <-  leafletProxy("map2") %>%
    #    if(reactive_multi()) {
     #   proxy %>% 
    #     addCircleMarkers(~longitude, ~latitude,
    #                      fill=FALSE,weight=0.8,opacity = 1,
     #                     radius = 3, color="green",
    #                      popup=~as.character(host_name.x))
    #} else {
     # proxy %>% clearMarkers()}})
 
   # fact5_price <- reactive({nyc_bnb$price==input$fact5_1 
     # nyc_bnb$reviews_per_month==input$fact5_2
   #   })
    #output$fact5_3 <- renderPlot({fact5_price() %>% ggplot(aes(x=price, y=reviews_per_month))+
     # geom_smooth(method = "lm")+
      #geom_point(aes(color=room_type),size=0.5)+
     # facet_grid(~room_type)+
      #coord_cartesian(xlim = c(0,2000))+
      #theme_economist() + scale_fill_economist()})
##############################################################################################    
     
  ###Put table in server
output$table <- renderDataTable({
  datatable(nyc_bnb)})
     
})


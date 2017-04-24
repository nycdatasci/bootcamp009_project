library(shiny)
library(dygraphs)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
# let's get it.
  
  
  leaf_map <- reactive({
    leaf_data %>% 
      filter(Year %in% input$year_range)
    })
  
  
  output$map <- renderLeaflet({
    leaflet(leaf_map()) %>% setView(lng = -98.5556, lat = 39.8097, zoom = 4) %>% 
      addProviderTiles(providers$Stamen.Terrain) %>%
      addCircles(lng = ~Longitude, lat = ~Latitude, weight = 1, 
                 radius = ~(all_claims) * 1000, popup = ~Airport.Code,
                 label = ~paste0(Airport.Code, ": ", all_claims),
                 labelOptions = labelOptions(noHide = T))
  })
  
    
  output$timeSeries <- renderDygraph({
    
    dygraph(x_by_date, main = "Claims") %>%
      dyRangeSelector()
    
  })
  
  output$facetPlot <- renderPlot({
    
    by_month %>% filter(Year == input$general_year & avg_claim_amount != 0) %>%
    ggplot(aes(x = Month, y = avg_claim_amount)) + 
      geom_histogram(binwidth = 0.2, stat = "identity") + facet_wrap( ~ Claim.Type) +
      scale_x_discrete(limits = c("Jan", "Feb", "Mar", "Apr",
                                               "May", "June", "July", "Aug",
                                               "Sept", "Oct", "Nov", "Dec")) +
      theme(axis.text.x = element_text(angle = 90))
    
    
  })
  
  
  ### heatmap 1
  output$airportItems <- renderPlotly({
    
    top_air_items <- items_by_airport %>% filter(Year == input$airport_year 
                                                 & Disposition == input$disposition) %>%
      group_by(Airport.Code) %>% select(-Year, -Disposition)
    
    row.names(top_air_items) <- top_air_items$Airport.Code
    
    airport_matrix <- data.matrix(top_air_items)[,2:27]
    
    plot_ly(data = top_air_items, 
            x = c("ATL", "CLT", "DEN", "DFW", "JFK", 
                  "LAS","LAX", "ORD", "SFO",  "PHX"), 
            y = c("audio_video", "automobile", "baggage",               
                  "books", "cameras", "clothing", "computer",              
                  "cosmetics", "crafting", "currency", "food",                   
                  "home_decor", "household_items", "hunting_items",          
                  "jewelry", "medical", "music_instruments",      
                  "office_supplies", "outdoor_items", "pers_accessories",       
                  "pers_electronics", "pers_navigation", "sport_supplies",         
                  "home_improve_supplies", "toys", "travel_accessories"),
            z = t(airport_matrix), type = "heatmap") %>%
      layout(yaxis = list(tickangle = 30), margin = list(l=100))
  })
  
  ### for heatmap 2
  output$airlineItems <- renderPlotly({
    
    top_line_items <- items_by_airline %>% filter(Year == input$airline_year
                                                  & Disposition == input$disposition2) %>%
      group_by(Airline.Name) %>% select(-Year, -Disposition)
    
    row.names(top_line_items) <- top_line_items$Airline.Name
    
    airline_matrix <- data.matrix(top_line_items)[,2:27]
    
    plot_ly(data = top_line_items, 
            x = c("Alaska", "American", "Delta", "JetBlue", 
                  "Southwest", "Spirit","United"), 
            y = c("audio_video", "automobile", "baggage",               
                  "books", "cameras", "clothing", "computer",              
                  "cosmetics", "crafting", "currency", "food",                   
                  "home_decor", "household_items", "hunting_items",          
                  "jewelry", "medical", "music_instruments",      
                  "office_supplies", "outdoor_items", "pers_accessories",       
                  "pers_electronics", "pers_navigation", "sport_supplies",         
                  "home_improve_supplies", "toys", "travel_accessories"),
            z = t(airline_matrix), type = "heatmap") %>%
      layout(yaxis = list(tickangle = 30), margin = list(l=100))
  })
  
  output$airportTable <- renderDataTable({
    datatable(airport_table)
    })
  
  
  output$airlineTable <- renderDataTable({
    datatable(airline_table)
  })
  
  
  output$airportRate <- renderPlot({
    
    top10ac %>% filter(Airport.Code != 'SFO') %>%
      group_by(Airport.Code, Year) %>%
      summarise(total_claims = sum(total),
                total_flights = mean(flights)) %>%
      mutate(claim_rate = total_claims / total_flights) %>%
      select(-total_claims, -total_flights) %>%
      ggplot(aes(x = Airport.Code, y = claim_rate)) + 
      geom_col(aes(fill = Year), position = "dodge") +
      scale_y_continuous(labels = scales::percent) +
      ylab("Scale Rate") + xlab("Airport")
  
    })
  
  output$airlineRate <- renderPlot({
    
    top10al %>% filter(Airline.Name != "Republic Airways") %>%
      group_by(Airline.Name, Year) %>%
      summarise(Total_Claims = sum(total_claims),
                Total_Flights = mean(Flights)) %>%
      mutate(claim_rate = Total_Claims / Total_Flights) %>%
      select(-Total_Claims, -Total_Flights) %>%
      ggplot(aes(x = Airline.Name, y = claim_rate)) +
      geom_col(aes(fill = Year), stat = "identity", position = "dodge") +
      scale_y_continuous(labels = scales::percent) +
      ylab("Claim Rate") + xlab("Airline") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
  })
  
  output$airlineAndType <- renderPlot({
    
    top10al %>% filter(Airline.Name != "Republic Airways") %>%
      group_by(Airline.Name, Claim.Type) %>%
      summarise(Total_Claims = sum(total_claims),
                Total_Flights = mean(Flights)) %>%
      mutate(claim_rate = Total_Claims / Total_Flights) %>%
      select(-Total_Claims, -Total_Flights) %>%
      ggplot(aes(Airline.Name, claim_rate)) + 
      geom_col(aes(fill = Claim.Type), position = "dodge") +
      scale_y_continuous(labels = scales::percent) +
      ylab("Claim Rate") + xlab("Airline and Claim Type") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
  })
  
})

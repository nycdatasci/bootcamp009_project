# Romibala Ningthoujam
# NYC DSA : Project - DataVizShiny


library(DT)
library(shiny)
library(shinydashboard)
library(RColorBrewer)


shinyServer(function(input, output){
  
  output$geoMap <- renderLeaflet({
    mapdata <- filter(hospitals_data, Measure.Name == input$selected)
    
    pal <- colorNumeric(
      palette = "Accent",
      domain = hospitals_data$Score
    )
    
    leaflet(data = mapdata) %>% addTiles() %>%
      addCircleMarkers(~longitude, ~latitude, popup = ~paste0(Hospital.Name, '<br>', Address, ', ', City, ', ', State,
                                                        '<br>','Score: ', Score, '<br>', Compared.to.National),
                 radius = ~Score, color = ~pal(Score), fillColor = TRUE) %>%
      addLegend("bottomright", pal = pal, values = ~Score,
                title = "Complication Score",
                opacity = 1
      )
  })
  
  
  output$scatter <- renderPlot({
    hosp_by_measure <- filter(hospitals_data, Measure.Name == input$selected)
    
    ggplot(data = hosp_by_measure, aes(x = State, y = Score)) +
      geom_point(aes(color = Score)) +
      scale_color_gradientn(colours = terrain.colors(20)) +
      labs(title = "Nation-wide score by complication case",
           x = "State",
           y = "Complication Rate (Score)") +
      theme_dark() +
      theme(axis.text.x = element_text(angle = 60))
  })
  
  output$boxplt <- renderPlot({
    hosp_by_measure <- filter(hospitals_data, Measure.Name == input$selected)
    
    ggplot(data = na.omit(hosp_by_measure), aes(x = Region, y = Score, fill = Region)) +
      geom_boxplot() +
      labs(title = "Complication Score - Regional Comparison",
           x = "Region",
           y = "Complication Rate (Score)") +
      theme_bw()
  })
  
  output$table <- DT::renderDataTable({
    datatable(hospitals_data, rownames=FALSE)
  })
  
})

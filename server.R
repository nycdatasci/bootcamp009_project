library(ggplot2)
library(googleVis)
library(leaflet)
library(DT)

shinyServer(function(input, output, session) {
  
## "Top 20 Complaints Total"
  output$top20 <- renderPlot({
    ggplot(top20, aes(x = reorder(type, count), y = count)) +
      geom_bar(stat='identity') +
      scale_y_continuous(labels=function(x) x/1000) +
      xlab('Complaint Category') +
      ylab('Count (in thousands)') +
      ggtitle('Top 311 Service Request (2010-Present)') +
      coord_flip()
  })
  
  output$top20_data <- DT::renderDataTable({
    datatable(top20, rownames=FALSE)
  })
  
## "Noise vs Traffic By Year"
  output$noise_traffic <- renderPlot({
    ggplot(noisetrafficbyyr, aes(x = year, y = count, color = type)) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE)
  }) 
  
  output$noise_traffic_data <- DT::renderDataTable({
    datatable(noisetrafficbyyr, rownames=FALSE)
  })

## "Top 10 Complaints By Year"
  output$top10 <- renderGvis({
    gvisLineChart(top10byyr,
                  options=list(width = 1400,
                               height = 800,
                               title = '311 Service Requests (2010-2016)',
                               titleTextStyle = "{ color: 'black',
                               fontSize: '24',
                               bold: 'TRUE' }",
                               hAxis = "{ title: 'Year',
                               ticks: [2010, 2011, 2012, 2013, 2014, 2015, 2016],
                               format: ''}",
                               vAxis = "{ title: 'Count',
                               format: 'short'}",
                               pointSize = '10',
                               series="{
                               0: { pointShape: 'circle' },
                               1: { pointShape: 'triangle' },
                               2: { pointShape: 'square' },
                               3: { pointShape: 'diamond' },
                               4: { pointShape: 'star' },
                               5: { pointShape: 'polygon' },
                               6: { pointShape: 'circle' },
                               7: { pointShape: 'triangle' },
                               8: { pointShape: 'square' },
                               9: { pointShape: 'diamond' },
                               10: { pointShape: 'star' }
                               }"))
  }) 
  
  output$top10_data <- DT::renderDataTable({
    datatable(top10byyr, rownames=FALSE)
  })

  

## "Noise vs Illegal Parking By Year"
  
  output$noise_parking <- renderPlot({
    ggplot(noiseparkbyyr, aes(x = year, y = count, color = type)) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE)
  }) 
  
  output$noise_parking_data <- DT::renderDataTable({
    datatable(noiseparkbyyr, rownames=FALSE)
  })
  
## "Noise vs Illegal P. - Heatmap"
  
  output$heatmap <- renderLeaflet({
    
    pal_noise <- colorNumeric(
      palette = "Blues",
      domain = leafletnoise[, input$year])
    
    pal_parking <- colorNumeric(
      palette = "Reds",
      domain = leafletpark[, input$year])
    
    leaflet(zipshapefile) %>% 
      addTiles() %>% 
      addPolygons(color = "#444444",
                  fillColor = pal_noise(leafletnoise[, input$year]),
                  weight = 1.0,
                  fillOpacity = 1.0,
                  label = paste('City:', as.character(leafletnoise$Neighborhood), ', ',
                                'Noise Count:', as.character(leafletnoise[, input$year])),
                  highlightOptions = highlightOptions(
                    weight = 3,
                    color = "red",
                    fillOpacity = 1.0),
                  group = 'Noise Complaints') %>% 
      addPolygons(color = "#444444",
                  fillColor = pal_parking(leafletpark[, input$year]),
                  weight = 1.0,
                  fillOpacity = 1.0,
                  label = paste('City:', as.character(leafletpark$Neighborhood), ', ',
                                'Noise Count:', as.character(leafletpark[, input$year])),
                  highlightOptions = highlightOptions(
                    weight = 3,
                    color = "red",
                    fillOpacity = 1.0),
                  group = 'Illegal Parking Complaints') %>% 
      addPolygons(group = 'None',
                  stroke = FALSE,
                  fillOpacity = 0) %>% 
      addLayersControl(
        baseGroups = c('Noise Complaints', 'Illegal Parking Complaints', 'None'),
        options = layersControlOptions(collapsed = FALSE)
      )
    
  }) 
  
  output$noise_traffic_data <- DT::renderDataTable({
    datatable(noisetrafficbyyr, rownames=FALSE)
  })
  
  
})


# appendix

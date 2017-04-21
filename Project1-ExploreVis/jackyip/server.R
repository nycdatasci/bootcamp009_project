shinyServer(function(input, output, session) {
  
## "Top 20 Complaints Total"
  output$top20 <- renderPlot({
    ggplot(top20, aes(x = reorder(type, count), y = count, fill = count)) +
      geom_bar(stat='identity') +
      scale_fill_gradient(low = "green", high = "red") +
      scale_y_continuous(labels=function(x) x/1000) +
      xlab('Complaint Category') +
      theme(text = element_text(size=20),
            axis.text.x = element_text(angle=0, hjust=1)) +
      ylab('Count (K)') +
      ggtitle('New York City\'s Top 311 Complaint Categories', 
              subtitle = 'Total Counts from Jan 2010 to April 2017') +
      coord_flip()
  })
  
  output$top20_data <- DT::renderDataTable({
    datatable(top20, rownames=FALSE)
  })
  
## "Noise vs Traffic By Year"
  output$noise_traffic <- renderPlot({
    ggplot(noisetrafficbyyr, aes(x = year, y = count, color = type)) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE) +
      theme(text = element_text(size=20),
            axis.text.x = element_text(angle=0, hjust=1)) +
      scale_x_continuous(breaks = round(seq(min(2010), max(2016), by = 1))) +
      scale_y_continuous(labels=function(x) x/1000) +
      ylab('Count (K)') +
      ggtitle('Noise vs Street/Traffic Count Comparison By Year',
              subtitle = 'Note: Partial year counts (i.e. 2017) were excluded from this yearly trend analysis')
  }) 

## "Top 10 Complaints By Year"
  
  sliderValues <- reactive({
    
    # Compose data frame
    top10byyr[year %in% input$range[1]:input$range[2], ]
  })
  
  output$top10 <- renderGvis({
    gvisLineChart(sliderValues(),
                  options=list(width = 1150,
                               height = 625,
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

  

## "Noise vs Illegal Parking By Year"
  
  output$noise_parking <- renderPlot({
    ggplot(noiseparkbyyr, aes(x = year, y = count, color = type)) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE) +
      theme(text = element_text(size=20),
            axis.text.x = element_text(angle=0, hjust=1)) +
      scale_x_continuous(breaks = round(seq(min(2010), max(2016), by = 1))) +
      scale_y_continuous(labels=function(x) x/1000) +
      ylab('Count (K)') +
      ggtitle('Noise vs Illegal Parking Count Comparison By Year',
              subtitle = 'Note: Partial year counts (i.e. 2017) were excluded from this yearly trend analysis')
    
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
      setView(lat = 40.699429, lng = -73.959209, zoom = 11) %>% 
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
  
  
})

# appendix

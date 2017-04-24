shinyServer(function(input, output, session) {
  
## "1. Complaints Ranking"
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
  
## "2a. Noise: Hour of Day Heatmap"
  
  noisehour <- reactive({
    noisebyhour[[as.character(input$integer)]]
  })
  
  output$heatbyhour <- renderLeaflet({
    
    pal_noise <- colorNumeric(
      palette = "Blues",
      domain = noisehour())
    
    leaflet(zipshapefile) %>% 
      addTiles() %>%
      setView(lat = 40.699429, lng = -73.959209, zoom = 11) %>% 
      addPolygons(color = "#444444",
                  fillColor = pal_noise(noisehour()),
                  weight = 1.0,
                  fillOpacity = 1.0,
                  label = paste('City:', as.character(noisebyhour$Neighborhood), ', ',
                                'Zip Code:', as.character(noisebyhour$zip), ',',
                                'Noise Count:', as.character(noisebyhour[[as.character(input$integer)]])),
                  highlightOptions = highlightOptions(
                    weight = 3,
                    color = "red",
                    fillOpacity = 1.0))
    
  })
  
## "2b. Noise: Hour of Day Graph"
  
  output$heatbyhourgraph <- renderPlot({
    ggplot(skinnynoisebyhour, aes(x = hour)) + 
      theme(text = element_text(size=20),
            axis.text.x = element_text(angle=0, hjust=1)) +
      geom_line(aes(y = count)) +
      scale_x_continuous(breaks = 0:23) +
      scale_y_continuous(labels=function(x) x/1000) +
      ylab('Count (K)') +
      ggtitle("Noise Complaints by Hour of Day (Jan 2010 to Apr 2017)")
  })
  
## "2c. Noise: Hour of Day Data"
  
  output$hourlynoisedata <- DT::renderDataTable({
    datatable(noisebyhour) %>% 
      formatStyle(input$selected, background="skyblue", fontWeight='bold')
  })

## "3. Complaints By Year"
  
  sliderValues <- reactive({
    top10byyr[year %in% input$range[1]:input$range[2], ]
  })
  
  output$top10 <- renderGvis({
    gvisLineChart(sliderValues(),
                  options=list(width = 1000,
                               height = 600,
                               title = 'Top 10 Complaint Counts By Year (Jan 2010 - Apr 2017)',
                               titleTextStyle = "{ color: 'black',
                               fontSize: '24',
                               bold: 'FALSE' }",
                               hAxis = "{ title: 'Year',
                               ticks: [2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017],
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

## "4a. Noise vs Parking Correlation"
  
  output$noise_parking <- renderPlot({
    ggplot(noiseparkbyyr, aes(x = year, y = count, color = type)) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE) +
      theme(text = element_text(size=20),
            axis.text.x = element_text(angle=0, hjust=1)) +
      scale_x_continuous(breaks = round(seq(min(2010), max(2016), by = 1))) +
      scale_y_continuous(labels=function(x) x/1000) +
      ylab('Count (K)') +
      ggtitle('Noise vs Illegal Parking Count Comparison (Jan 2010 to Dec 2016)',
              subtitle = 'Note: Partial year counts (i.e. 2017) were excluded from this graphic')
    
  }) 
  
## "4b. Noise vs Parking Heatmap"
  
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
                                'Zip Code:', as.character(leafletnoise$zip), ',',
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
                                'Zip Code:', as.character(leafletpark$zip), ',',
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


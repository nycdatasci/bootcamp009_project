library(ggplot2)
library(googleVis)
library(leaflet)
library(DT)

shinyServer(function(input, output){
  
  output$plot <- renderPlot({
    ggplot(noisetrafficbyyr, aes(x = year, y = count, color = type)) +
      geom_point() +
      geom_smooth(method = "lm", se = FALSE)
  })
  
  output$bar <- renderPlot({
    ggplot(top20, aes(x = reorder(type, count), y = count)) +
      geom_bar(stat='identity') +
      scale_y_continuous(labels=function(x) x/1000) +
      xlab('Complaint Category') +
      ylab('Count (in thousands)') +
      ggtitle('Top 311 Service Request (2010-Present)') +
      coord_flip()
  }) 
  
  output$data <- DT::renderDataTable({
    datatable(noisyparkingzip, rownames=FALSE)
  })
  
})
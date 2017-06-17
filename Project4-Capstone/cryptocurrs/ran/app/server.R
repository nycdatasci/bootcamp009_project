library(shiny)
source('helper.R')

function(input, output) {
  
  # Fill in the spot we created for a plot
  output$plot_power <- renderPlot({
    plot_power(p=input$p, N=input$N, dmin=as.numeric(input$dmin), threshold=input$threshold)
  })
}
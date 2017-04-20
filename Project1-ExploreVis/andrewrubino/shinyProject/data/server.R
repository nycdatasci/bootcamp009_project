#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
   
  output$timeSeries <- renderPlot({
    
    ggplot(by_date, aes(x = Month_Yr, y = n, color = Claim.Type, group = Claim.Type)) + 
      geom_point() + geom_line() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
  })
  
  output$facetPlot <- renderPlot({
    
    ggplot(by_month, aes(x = Month, y = avg_claim_amount)) + 
      geom_histogram(binwidth = 0.2, stat = "identity") + facet_wrap( ~ Claim.Type)
    
  })
  
})

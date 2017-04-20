library(shiny)
library(shinydashboard)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("*Seinfeld Voice* What's the deal with TSA?"),
  
  #Sidebar with a slider input for number of bins
  # sidebarLayout(
  #   sidebarPanel(
  #      sliderInput("",
  #                  "Number of bins:",
  #                  min = 1,
  #                  max = 50,
  #                  value = 30)
  #   ),

    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("timeSeries"),
       plotOutput("facetPlot")
    )
  )
)

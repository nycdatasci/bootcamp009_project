library(dplyr)
library(ggplot2)
library(shiny)
#source("./preProc.R")
DC = read.csv("./DC.csv")
ALASKA = read.csv("./ALASKA.csv")
CHICAGO = read.csv("./CHICAGO.csv")
COLORADO = read.csv("./COLORADO.csv")
NEWYORK = read.csv("./NEWYORK.csv")

#things to analyze, winddir vs wind speed
#'cold fronts', see if cold weather moves locations
#weather changes over time
#wind patterns

ui <- fluidPage(
  titlePanel("Weather Patterns"),
  sidebarLayout(
    sidebarPanel = sidebarPanel(
      selectInput(inputId = "location",
                  label= "location",
                  choices=c("ALASKA","DC","COLORADO","NEWYORK","CHICAGO")
                  ),
      selectInput(inputId = "xaxis", 
                  label = "x-axis",
                  choices = c("precipitation","Date","temperature","humidity","pressure")
                  ),
      selectInput(inputId = "yaxis", 
                  label = "y-axis",
                  choices= c("precipitation","Date","temperature","humidity","pressure")

    )),
    mainPanel = mainPanel(plotOutput("Values")),
)
)

server <- function(input, output,session) {
  dataInput <- reactive({
    
    dataset = switch(input$location,
              "ALASKA" = ALASKA,
              "DC" = DC,
              "COLORADO" = COLORADO,
              "NEWYORK" = NEWYORK,
              "CHICAGO" = CHICAGO)
    dataset
  })
  output$Values <- renderPlot({
    ggplot(data=dataInput(), 
           aes_string(x=input$xaxis,y=input$yaxis)) + geom_point() + geom_smooth(method='lm')

    
    })
  
}

# Run the application 
shinyApp(ui = ui, server = server)


library(dplyr)
library(ggplot2)
library(shiny)
#run preProc.R to get the .csvs loaded below
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
                  choices = c("WeeklyAverages","precipitation","temperature","humidity","pressure","windSpeed")
                  ),
      selectInput(inputId = "yaxis", 
                  label = "y-axis",
                  choices= c("precipitation","temperature","humidity","pressure","windSpeed")

    )),
    mainPanel = mainPanel(plotOutput("Values"),
                          verbatimTextOutput("Regression"))
    ,
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
  })
  xAxisLabel = reactive({
    t = function(x){
      print ("test")
    ifelse(input$xaxis == 'WeeklyAverages',
           return (as.Date(as.POSIXct(x,origin="1970-01-01"))),
           return (x))
    }
  })
  output$Values <- renderPlot({
    ggplot(data=dataInput(), 
           aes_string(x=input$xaxis,y=input$yaxis)) + 
      geom_point(aes(color=cut(dataInput()$temperature, c(-Inf,35,65,95,Inf))),
                 size = 2) + 
       
      scale_color_manual(name="temperature",
                         values = c("(-Inf,35]" = "blue",
                                    "(35,65]" = "green",
                                    "(65,95]" = "red",
                                    "(95,Inf]" = "orange")) +
                      
      scale_x_continuous(label= xAxisLabel()) +
      geom_smooth(method='lm') +
      theme(axis.title.x = element_text(size=18),
            axis.title.y = element_text(size=18),
            legend.position = "none",
            plot.title = element_text(hjust = 0.5, size=24))
    })
  xValue = reactive({
    switch(input$xaxis,
           "WeeklyAverages" = dataInput()$WeeklyAverages,
           "precipitation" = dataInput()$precipitation,
           "temperature"=dataInput()$temperature,
           "humidity"=dataInput()$humidity,
           "pressure"=dataInput()$pressure,
           "windSpeed" = dataInput()$windSpeed)
  })
  yValue = reactive({
    switch(input$yaxis,
           "precipitation" = dataInput()$precipitation,
           "temperature"=dataInput()$temperature,
           "humidity"=dataInput()$humidity,
           "pressure"=dataInput()$pressure,
           "windSpeed" = dataInput()$windSpeed)
  })
  
  model = reactive({
    model = lm(yValue() ~ xValue(), data=dataInput())
    summary(model)
    
  })
  output$Regression = renderPrint({
    
    #y = switch(input$axis,
    #           "precipitation" = precipitation,
    #           "temperature"=temperature,
    #           "humidity"=humidity,
    #           "pressure"=pressure,
    #           "windSpeed" = windSpeed)
    model()
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)


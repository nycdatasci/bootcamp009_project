library(dplyr)
library(ggplot2)
library(shiny)
#run preProc.R to get the .csvs loaded below
DC = read.csv("./DC.csv")
ALASKA = read.csv("./ALASKA.csv")
CHICAGO = read.csv("./CHICAGO.csv")
NEWYORK = read.csv("./NEWYORK.csv")
LA = read.csv("./LA.csv")
SANFRANCISCO = read.csv("./SANFRANCISCO.csv")
MIAMI = read.csv("./MIAMI.csv")

ui <- fluidPage(
  titlePanel("Weather Patterns"),
  sidebarLayout(
    #the user selects a location and two observations to compare
    sidebarPanel = sidebarPanel(
      selectInput(inputId = "location",
                  label= "location",
                  choices=c("ALASKA","DC","LA","NEWYORK","CHICAGO","MIAMI","SANFRANCISCO")
                  ),
      selectInput(inputId = "xaxis", 
                  label = "x-axis",
                  choices = c("WeeklyAverages","precipitation","temperature","humidity","pressure","windSpeed")
                  ),
      selectInput(inputId = "yaxis", 
                  label = "y-axis",
                  choices= c("temperature","precipitation","humidity","pressure","windSpeed")

    )),
    #they see a plot of the observations, information about linear regression of the plot
    #and information about multi-regression of all variables against the y-value
    mainPanel = mainPanel(plotOutput("Values"),
                          verbatimTextOutput("Regression"),
                          verbatimTextOutput("multiRegression"))
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
              "CHICAGO" = CHICAGO,
              "SANFRANCISCO" = SANFRANCISCO,
              "LA" = LA,
              "MIAMI" = MIAMI)
  })
  #the date is stored as a POSIX numeric value so we can perform regression on it
  #but is converted back to a date when it's on the x-axis
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
      #we color code our temperatures, blue = cold, green = normal, red = hot
      geom_point(aes(color=cut(dataInput()$temperature, c(-Inf,45,60,95,Inf))),
                 size = 2) + 
       
      scale_color_manual(name="temperature",
                         values = c("(-Inf,45]" = "blue",
                                    "(45,60]" = "green",
                                    "(60,95]" = "red",
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
    #switch(input$yaxis,
    #       "precipitation" = precipitation,
    #       "temperature"=temperature,
    #       "humidity"=humidity,
    #       "pressure"=pressure,
    #       "windSpeed" = windSpeed)
  })
  

  output$Regression = renderPrint({
    model = lm(yValue() ~ xValue(), data=dataInput())
    summary(model)

  })
  output$multiRegression = renderPrint({
    #we have to do as.formula here so that our y-value is interpreted literally
    #and excluded from the multi-regression
    model = lm(as.formula(paste(input$yaxis, "~. -WeeklyAveragesString")),data=dataInput())
    summary(model)
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)


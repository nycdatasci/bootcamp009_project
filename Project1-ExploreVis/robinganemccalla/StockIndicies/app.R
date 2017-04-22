#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#things to add
#other types of graph
#identify points
library(shiny)
library(dplyr)

formatData = function(indexTable){
  indexTable$Date = as.Date(indexTable$Date,"%Y-%m-%d")
  #something to convert Date from character here
  #we add the day of the week as a number to make sorting easier
  #perhaps we can reformulate later
  indexTable$DayOfWeek = strftime(indexTable$Date, '%w---%A')
  indexTable$MonthOfYear = strftime(indexTable$Date, '%m')
  indexTable$Year = strftime(indexTable$Date, '%Y')
  #we arrange them starting at the begining to make our analysis more intuitive
  indexTable = arrange(indexTable,Date)
  #a basic sum, not incredibly useful
  #we get the change from the previous day
  indexTable$CloseChange = c(0,diff(indexTable$Close))
  indexTable$PercentCloseChange = 100* (indexTable$CloseChange/lag(indexTable$Close-1))
  #remove the first row to get rid of the NA value
  indexTable = indexTable[-1,]
  return (indexTable)
}
NASDAQ = read.csv("./NASDAQ.csv")
SandP = read.csv("./SandP.csv")
DowJones = read.csv("./dow_jones.csv")

NASDAQ = formatData(NASDAQ)
SandP = formatData(SandP)
DowJones = formatData(DowJones)


ui <- fluidPage(
   
   # Application title
   titlePanel("Patterns in Stock Indicies"),
   sidebarLayout(
     sidebarPanel = sidebarPanel(
       selectInput(inputId = "Index", 
                      label = "Index",
                      choices = c("NASDAQ","S&P","Dow Jones")),
       selectInput(inputId = "TimePeriod", 
                      label = "Time Period",
                      choices= c("DayOfWeek","Monthly","Yearly")),
       selectInput(inputId = "Observation",
                   label = "Observation",
                   choices = c("CloseChange","High","Volume","PercentCloseChange")),
       dateInput(inputId = "startDate",
                 label = "Start Date",
                 value = "1987-04-13",
                 min = "1987-04-13",
                 max = "2017-04-13"),
       dateInput(inputId = "endDate",
                 label = "End Date",
                 value = "2017-04-13",
                 min = "1987-04-13",
                 max = "2017-04-13")
       
     ),
     mainPanel = mainPanel(plotOutput("Values"),
                           tableOutput("text1")
     ),

     )
)


# Define server logic required to draw a histogram
server <- function(input, output, session) {
  datasetInput <- reactive({

    dataset = switch(input$Index,
              "NASDAQ" = NASDAQ,
              "S&P" = SandP,
              "Dow Jones" = DowJones)
    filter(dataset, input$startDate < dataset[,"Date"] & dataset[,"Date"] < input$endDate)
    
  })
  timeInput = reactive({
    switch(input$TimePeriod,
           "DayOfWeek" = "DayOfWeek",
           "Monthly" = "MonthOfYear",
           "Yearly" = "Year")
  })


   output$Values <- renderPlot({

     ggplot(data = datasetInput(), 
            aes_string(x=timeInput(),y=input$Observation,color=timeInput())) +
       #this enables a zoom but it's hard to make it look good
       #coord_cartesian(ylim=c(mean(datasetInput()[,input$Observation]) - (2 * mean(datasetInput()[,input$Observation])), mean(datasetInput()[,input$Observation]) + (2 * mean(datasetInput()[,input$Observation])))) +
       theme(axis.title.x = element_text(size=24),
             axis.title.y = element_text(size=24)) +
       geom_boxplot() #+
      
       #geom_tufteboxplot()
   })
   output$text1 = renderTable({
     #paste("test")
     #mean(datasetInput()[,input$Observation]) - (.5 *mean(datasetInput()[,input$Observation]))
     #mean(datasetInput()[,input$Observation]) + (.5 *mean(datasetInput()[,input$Observation]))
     #summary(aov(NASDAQ$Close ~ NASDAQ$MonthOfYear))
     as.data.frame(summary(aov(datasetInput()[,input$Observation] ~ datasetInput()[,timeInput()]))[[1]])

   })

}

# Run the application 
shinyApp(ui = ui, server = server)


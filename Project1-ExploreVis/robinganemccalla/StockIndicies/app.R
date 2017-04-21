#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#things to add
#colors 
#zoom
#statistical analysis of differences
#other types of graph
#volume selector
#% change in closing
#axis and title labels on graph

library(shiny)
library(dplyr)
NASDAQ$MonthOfYear = strftime(NASDAQ$Date, '%m')
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
  #NASDAQ %>% group_by(DayOfWeek) %>% summarize(avgClose =mean(Close)) %>% arrange(DayOfWeek)
  #we get the change from the previous day
  indexTable$CloseChange = c(0,diff(indexTable$Close))
  indexTable$PercentCloseChange = 100* (indexTable$CloseChange/lag(indexTable$Close-1))
  #remove the first row to get rid of the NA value
  indexTable = indexTable[-1,]
  #indexTable$PercentCloseChange = c(0,diff(indexTable$Close)/indexTable$Close)
  #we add the name of the index so we can specify it when we join
  #colnames(indexTable)[7] = paste(colnames(indexTable)[7],indexName)
  #colnames(indexTable)[10] = paste(colnames(indexTable)[10],indexName)
  return (indexTable)
}
NASDAQ = read.csv("./NASDAQ.csv")
SandP = read.csv("./SandP.csv")
DowJones = read.csv("./dow_jones.csv")

NASDAQ = formatData(NASDAQ)
SandP = formatData(SandP)
DowJones = formatData(DowJones)

#FirstJoin = inner_join(NASDAQ,SandP, by = "Date")
#AllData = inner_join(FirstJoin,DowJones, by="Date")
#NASDAQ %>% group_by(DayOfWeek) %>% summarize(mean(CloseChange)) %>% arrange(DayOfWeek)


# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Patterns in Stock Indicies"),
   
   # Sidebar with a slider input for number of bins 
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
                   choices = c("CloseChange","High","Low","Volume","PercentCloseChange"))
     ),
     mainPanel = mainPanel(plotOutput("Values"),
                           textOutput("text1")
     )
)
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  datasetInput <- reactive({
    switch(input$Index,
           "NASDAQ" = NASDAQ,
           "S&P" = SandP,
           "Dow Jones" = DowJones)
  })
  timeInput = reactive({
    switch(input$TimePeriod,
           "DayOfWeek" = "DayOfWeek",
           "Monthly" = "MonthOfYear",
           "Yearly" = "Year")
  })
  zoom = reactive({
  mean(datasetInput()[,input$Observation] - .1 * mean(datasetInput()[,input$Observation]))
  lowerZoom = mean(datasetInput()[,input$Observation] - .1 * mean(datasetInput()[,input$Observation]))
  return (coord_cartesian(ylim=c(  mean(datasetInput()[,input$Observation] - .1 * mean(datasetInput()[,input$Observation]))
,mean(datasetInput()[,input$Observation] - .1 * mean(datasetInput()[,input$Observation])))))
  })
  head(NASDAQ$MonthOfYear)
  head(NASDAQ$Year)
  #input$Index, {choices = c("NASDAQ","S&P","Dow Jones")}
   output$Values <- renderPlot({
     #dataGraph %>%
       #filter()
     ggplot(data = datasetInput(), 
            aes_string(x=timeInput(),y=input$Observation)) +
       #this enables a zoom but it's hard to make it look good
       #coord_cartesian(ylim=c(mean(datasetInput()[,input$Observation]) - (.5 * mean(datasetInput()[,input$Observation])), mean(datasetInput()[,input$Observation]) + (.5 * mean(datasetInput()[,input$Observation])))) +
     geom_boxplot() 
   })
   output$text1 = renderText({
     #paste("test")
     mean(datasetInput()[,input$Observation]) - (.5 *mean(datasetInput()[,input$Observation]))
     mean(datasetInput()[,input$Observation]) + (.5 *mean(datasetInput()[,input$Observation]))
     
   })
}

# Run the application 
shinyApp(ui = ui, server = server)


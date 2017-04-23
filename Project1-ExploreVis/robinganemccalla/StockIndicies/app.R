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
#research on indices
library(shiny)
library(dplyr)
library(ggplot2)

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
  indexTable$DailyPercentCloseChange = 100* (indexTable$CloseChange/lag(indexTable$Close-1))
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

#write.csv(NASDAQ,"./NASDAQ.csv")
#write.csv(SandP,"./SandP.csv")
#write.csv(DowJones,"./DowJones.csv")

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
                      choices= c("Daily","Monthly","Yearly")),
       selectInput(inputId = "Observation",
                   label = "Observation",
                   choices = c("CloseChange","High","Volume","DailyPercentCloseChange")),
       dateInput(inputId = "startDate",
                 label = "Start Date",
                 value = "1987-10-13",
                 min = "1987-04-13",
                 max = "2017-04-13"),
       dateInput(inputId = "endDate",
                 label = "End Date",
                 value = "2017-04-13",
                 min = "1987-04-13",
                 max = "2017-04-13")
       
     ),
     mainPanel = mainPanel(plotOutput("Values"),
                           tableOutput("StatsTable"),
                           plotOutput("Scatter"),
                           textOutput("text")
     ),

     )
)


# Define server logic
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
           "Daily" = "DayOfWeek",
           "Monthly" = "MonthOfYear",
           "Yearly" = "Year")
  })
  ScatterParameters = reactive({
    #we set the Observation to the appropriate column 
    #because sending a string or variable to dplyr is difficult
  summarize(group_by(datasetInput(), #Year),# datasetInput()[[timeInput]]),
                       period = switch(input$TimePeriod,
                              "Daily" = DayOfWeek,
                              "Monthly" = MonthOfYear,
                              "Yearly" = Year)), 
            avg=mean(
                                switch(input$Observation,
                                       "CloseChange" = CloseChange,
                                        "High" = High,
                                      "Volume" = Volume,
                                      "DailyPercentCloseChange" = DailyPercentCloseChange)))
  })

   output$Values <- renderPlot({

      title =   paste(input$Index,paste(input$TimePeriod,input$Observation))#cat(input$Index, input$Observation, "by", input$TimePeriod)  
     ggplot(data = datasetInput(), 
            aes_string(x=timeInput(),y=input$Observation,color=timeInput())) +
       theme(axis.title.x = element_text(size=24),
             axis.title.y = element_text(size=24),
             plot.title = element_text(hjust = 0.5, size=36)) +
       geom_boxplot() + ggtitle(title)#+ggtitle(cat(input$Index, input$Observation, "by", input$TimePeriod))#+
      
       #geom_tufteboxplot()
   })
   output$StatsTable = renderTable({
     as.data.frame(summary(aov(datasetInput()[,input$Observation] ~ datasetInput()[,timeInput()]))[[1]])

   })
   output$Scatter = renderPlot({
     #time = datasetInput()[c(timeInput(),input$Observation)]
     print(head(ScatterParameters()))
     ggplot(data = ScatterParameters(), 
            aes_string(x="period",y="avg")) +
       geom_point(size=3)# + stat_smooth(method = "lm") 
   })
   output$text = renderText({
     paste(cat(input$Observation,input$TimePeriod))
   })
   #summarise(group_by(NASDAQ, NASDAQ[,"Year"]),mean=mean(Close))
}

# Run the application 
shinyApp(ui = ui, server = server)


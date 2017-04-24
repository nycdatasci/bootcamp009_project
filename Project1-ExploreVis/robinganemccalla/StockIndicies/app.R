library(shiny)
library(dplyr)
library(ggplot2)

formatData = function(indexTable){
  indexTable$Date = as.Date(indexTable$Date,"%Y-%m-%d")
  #we add the day of the week as a number to make sorting easier
  #perhaps we can reformulate later
  indexTable$Daily = strftime(indexTable$Date, '%w---%A')
  indexTable$Monthly = strftime(indexTable$Date, '%m')
  indexTable$Yearly = strftime(indexTable$Date, '%Y')
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
#the data needs to be stored locally, it was downloaded from Yahoo financecs
NASDAQ = read.csv("./NASDAQ.csv")
SandP = read.csv("./SandP.csv")
DowJones = read.csv("./dow_jones.csv")

#formatting it is relatively quick
NASDAQ = formatData(NASDAQ)
SandP = formatData(SandP)
DowJones = formatData(DowJones)

#we can write the data so we don't need to reformat if necessary
#write.csv(NASDAQ,"./NASDAQ.csv")
#write.csv(SandP,"./SandP.csv")
#write.csv(DowJones,"./DowJones.csv")

ui <- fluidPage(
   
   # Application title
   titlePanel("Patterns in Stock Indicies"),
   sidebarLayout(
     sidebarPanel = sidebarPanel(
       #our inputs let users choose the Index, Time Period, Observation and Time Frame
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
                           plotOutput("Scatter")
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

  ScatterParameters = reactive({
    #we reactively define a dataset based on what the user has selected
  summarize(group_by(datasetInput(),
                       period = switch(input$TimePeriod,
                              "Daily" = Daily,
                              "Monthly" = Monthly,
                              "Yearly" = Yearly)), 
            avg=mean(
                                switch(input$Observation,
                                       "CloseChange" = CloseChange,
                                        "High" = High,
                                      "Volume" = Volume,
                                      "DailyPercentCloseChange" = DailyPercentCloseChange)))
  })

   output$Values <- renderPlot({
  #the title is constructed from what the user has selected
      title =   paste(input$Index,paste(input$TimePeriod,input$Observation))
      # we plot all of the specified index by the timeperiod and observation the user has chosen
     ggplot(data = datasetInput(), 
            aes_string(x=input$TimePeriod,y=input$Observation,color=input$TimePeriod)) +
       theme(axis.title.x = element_text(size=24),
             axis.title.y = element_text(size=24),
             plot.title = element_text(hjust = 0.5, size=36)) +
       geom_boxplot() + ggtitle(title)
   })
   #this table shows whether the differences are statistically significant
   output$StatsTable = renderTable({
     as.data.frame(summary(aov(datasetInput()[,input$Observation] ~ datasetInput()[,input$TimePeriod]))[[1]])

   })
   output$Scatter = renderPlot({
     title =   paste(input$Index,paste(input$TimePeriod,input$Observation))
    #this is similar to the above plot but we're plotting the averages using a scatterplot
     ggplot(data = ScatterParameters(), 
            aes_string(x="period",y="avg")) +
       theme(axis.title.x = element_text(size=18),
             axis.title.y = element_text(size=18),
             plot.title = element_text(hjust = 0.5, size=24)) +
       geom_point(size=3) + ggtitle(title) + xlab(input$TimePeriod) + ylab(paste("average" ,input$Observation))
        
   })
}

# Run the application 
shinyApp(ui = ui, server = server)


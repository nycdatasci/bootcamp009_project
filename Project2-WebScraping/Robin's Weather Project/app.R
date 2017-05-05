#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(dplyr)
library(ggplot2)
library(stringr)
library(shiny)

formatData = function(file){
 Table = read.csv(file, stringsAsFactors = FALSE)
 #this might be necessary for earlier tables
 #Table = select(Table, -conditions, -events )
 Table$temperature = as.numeric(Table$temperature)
 Table$Date = as.Date(Table$Date,'%A, %b %d, %Y')
 Table$time = strptime(Table$time, "%I:%M %p" )
 Table$hour = strftime(Table$time, "%I-%p")
 #time uses today's date and is stored as a unix object
 #we're only interested in the hour so we remove the rest from our table
 Table = select(Table, -time)
 Table$Month = strftime(Table$Date, '%m-%b')
 Table$Year = strftime(Table$Date, '%Y')
 Table$precipitation[Table$precipitation == "N/A"] = "0"
 Table$windSpeed[Table$windSpeed == 'Calm'] = "0"
 Table$precipitation = as.numeric(Table$precipitation)
 Table$pressure = as.numeric(Table$pressure)
 Table$windSpeed = as.numeric(Table$windSpeed)
 Table$humidity = gsub("%","",Table$humidity)
 Table$humidity = as.numeric(Table$humidity)
 # a small percentage of rows are missing data
 Table = na.omit(Table)
 return (Table)
}



#things to analyze, winddir vs wind speed
#'cold fronts', see if cold weather moves locations
#weather changes over time
#wind patterns
#summarize(group_by(TEXAS,Month),mean(temperature))
summarize(group_by(TEXAS, Date),mean(temperature),mean(precipitation),mean(humidity),mean(pressure))
ui <- fluidPage(
   
   # Application title
   titlePanel("Old Faithful Geyser Data"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
      x    <- faithful[, 2] 
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      hist(x, breaks = bins, col = 'darkgray', border = 'white')
   })
}

# Run the application 
shinyApp(ui = ui, server = server)




library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
  titlePanel("Movie Data"),
  
  sidebarLayout(
    
    sidebarPanel(
      sidebarMenu(
        menuItem(tabName = 'Histagram', sliderInput("bin_width", "Width of bins:",  
                  min = .001, max = .1, value = .05, step = .005),
        selectInput('Budget_Bin', 'Size of Budget', unique(Movie_Name$Budget_Bins))),
        menuItem(tabName= 'Twin Graphs', 'Twin Graphs'),
        menuItem(tabName = 'F-D Scatter by Budget', 
                 selectInput('Budget_Bin', 'Size of Budget', unique(Movie_Name$Budget_Bins))),
        menuItem(tabName = 'Profit per Budget by Date', selectInput('Date_Bin', 'Pre or Post 2005',
                                                                    unique(Movie_Name$Date_Bins)))
        )
    ),
    mainPanel(
      tabsetPanel(
      tabPanel('Histagram', plotOutput("distPlot")),
      tabPanel('Twin Graphs', plotOutput('Twin')),
      tabPanel('F-D Scatter by Budget', plotOutput('F.D_by_Budget'), plotOutput('F.D_by_Budget1')),
      tabPanel('Foreign and Domestic Marketshare by Date', plotOutput('For_by_Date'),
                plotOutput('For_by_Date1')),
      tabPanel('Worldwide Sales', plotOutput('For_vs_Dom_Wrld_Sales')),
      tabPanel('For v Domestic Log Scale', plotOutput('For_v_Dom_Log')),
      tabPanel('Profit per Budget by Date', plotOutput('Date_Bins'), plotOutput('Date_Bins1'))
      ))
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$distPlot<- renderPlot({
    bin_width <- input$bin_width
    Budget_Bin <- input$Budget_Bin
    Movie_Budget_Filter <- filter(Movie_Name, Budget_Bins == Budget_Bin)
    Movie_Name %>% filter(Budget_Bins == Budget_Bin) %>% ggplot(aes(x=F.D)) + geom_histogram(binwidth = bin_width) +
      geom_vline(xintercept=mean(Movie_Name$F.D), color="red", lwd=1, lty=2) +
      geom_vline(xintercept = mean(Movie_Budget_Filter$F.D), color='blue', lwd=1, lty=2)
  })
  output$Twin <- renderPlot({
    c <- ggplot(Movie_Name, aes(x = Budget, y = Domestic)) + ggtitle('Domestic Sales by Budget')
    d <- ggplot(Movie_Name, aes(x = Budget, y = Foreign)) + ggtitle('Foreign Sales by Budget')
    
    scatter_c <- c + geom_point(size = .5) + geom_smooth(method = loess, color="red", se=TRUE) + 
      coord_cartesian(ylim = c(0, 750), xlim = c(0,310)) +
      annotate("rect", xmin = 0, xmax = 8, ymin = 0, ymax = 1250, alpha = .2, fill='darkred') +
      annotate("rect", xmin = 8, xmax = 20, ymin = 0, ymax = 1250, alpha = .2, fill='darkblue') +
      annotate("rect", xmin = 20, xmax = 40, ymin = 0, ymax = 1250, alpha = .2, fill='darkgreen') 
    scatter_d <- d + geom_point(size = .5) + geom_smooth(method = loess, color="red", se=TRUE) +
      coord_cartesian(ylim = c(0, 750),xlim = c(0,310)) +
      annotate("rect", xmin = 0, xmax = 8, ymin = 0, ymax = 1250, alpha = .2, fill='darkred') +
      annotate("rect", xmin = 8, xmax = 20, ymin = 0, ymax = 1250, alpha = .2, fill='darkblue') +
      annotate("rect", xmin = 20, xmax = 40, ymin = 0, ymax = 1250, alpha = .2, fill='darkgreen')
    grid.arrange(scatter_c,scatter_d,ncol=1)
  })
  output$F.D_by_Budget <- renderPlot({
   
    h <- Movie_Name %>% ggplot(aes(x = F.D, y = Budget,color = Worldwide_Bins))
    h + geom_point(size = .75) + geom_smooth(method = loess, color='red', se=TRUE) +
      coord_cartesian(xlim = c(-.7, .7), ylim = c(0,250)) + ggtitle('Foreign to Domestic Ratio by Budget') +
      geom_vline(xintercept = 0) + scale_fill_brewer(palette="Set1")
  })
  output$F.D_by_Budget1 <- renderPlot({
    Budget_Bin <- input$Budget_Bin
    h <- Movie_Name %>% filter(Budget_Bins == Budget_Bin) %>% ggplot(aes(x = F.D, y = Budget,color = Worldwide_Bins))
    h + geom_point(size = .75) + geom_smooth(method = loess, color='red', se=TRUE) +
      coord_cartesian(xlim = c(-.7, .7), ylim = c(0,250)) + ggtitle('Foreign to Domestic Ratio by Budget') +
      geom_vline(xintercept = 0) + scale_fill_brewer(palette="Set1")
  })
  output$For_by_Date <- renderPlot({
    f <- ggplot(Movie_Name, aes(x = Date)) 
    f + geom_point(aes(y=log(Foreign)),color='Red') + geom_point(aes(y=log(Domestic)),color = 'Blue') +
      geom_smooth(aes(Date,log(Foreign)), color='Red') + geom_smooth(aes(Date,log(Domestic)),color='Blue')
  })
  output$For_by_Date1 <- renderPlot({
    Budget_Bin <- input$Budget_Bin
    f <- Movie_Name  %>% filter(Budget_Bins == Budget_Bin) %>% ggplot(aes(x = Date)) 
    f + geom_point(aes(y=log(Foreign)),color='Red') + geom_point(aes(y=log(Domestic)),color = 'Blue') +
      geom_smooth(aes(Date,log(Foreign)), color='Red') + geom_smooth(aes(Date,log(Domestic)),color='Blue')
  })
  output$For_vs_Dom_Wrld_Sales <- renderPlot({
    g <- ggplot(Movie_Name, aes(x = Budget, y = Worldwide, color = Ratio)) 
    g + geom_point() + geom_smooth() + coord_cartesian(ylim = c(0, 1200)) + 
      ggtitle('Foreign vs Domestic Worldwide Sales')
  })
  output$For_v_Dom_Log <- renderPlot({
    j <- ggplot(Movie_Name, aes(x = Foreign, y = Domestic, color = Ratio))
    j + geom_point() + coord_trans(x = "log", y = 'log')  + ggtitle('Foreign vs Domestic: Log Scale')
  })
  output$Date_Bins <- renderPlot({
    a <- ggplot(Movie_Name, aes(x = Budget, y = Profit, color = Date_Bins))
    a + geom_point() + geom_abline(slope = 1, intercept = 0)
  })
  output$Date_Bins1 <- renderPlot({
    Date_Bin <- input$Date_Bin
    a <- Movie_Name %>% filter(Date_Bins == Date_Bin) %>% ggplot(aes(x = Budget, y = Profit))
    a + geom_point() + geom_abline(slope = 1, intercept = 0)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)


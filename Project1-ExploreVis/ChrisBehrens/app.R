library(dplyr)
library(ggplot2)
library(gridExtra)

Budget_df = read.csv('Budget.csv', stringsAsFactors = FALSE, encoding = 'latin1')
Int_df = read.csv('Int_Data.csv', stringsAsFactors = FALSE, encoding = 'latin1')

Budget_df$Title <- tolower(Budget_df$Title)
Int_df$Title <- tolower(Int_df$Title)

Int_df <- mutate(Int_df, Title = gsub(pattern = " :", replacement = ":",Title))
Int_df <- mutate(Int_df, Title = gsub(pattern = "&", replacement = "and",Title))
Budget_df <- mutate(Budget_df, Title = gsub(pattern = "&", replacement = "and",Title))
Int_df$Gross.As.Of. <- as.Date(Int_df$Gross.As.Of., format = '%m/%d/%y')


Movie = left_join(Int_df,Budget_df,by='Title')
Movie = mutate(Movie, Ratio = ifelse(F.D >= 0, 'For', 'Dom'))

Movie_Name = na.omit(Movie)
Movie_Name = Movie_Name %>% select(Ratio, Title, International, Domestic.x, Worldwide.x, 
                                   Gross.As.Of., X..Foreign, X..Domestic, F.D, Budget)
Movie_Name = Movie_Name %>% dplyr::rename(Foreign = International, Domestic = Domestic.x, 
                                          Worldwide = Worldwide.x, Date = Gross.As.Of., 
                                          Foreign_Per = X..Foreign, Domestic_Per = X..Domestic)
Movie_Name <- mutate(Movie_Name, Budget_Bins = ifelse(Movie_Name$Budget < 35, 'Small Budget', 
                                                      ifelse(Movie_Name$Budget > 90, 'Large Budget', 'Medium Budget' )))
Movie_Name <- mutate(Movie_Name, Profit = Worldwide - Budget)
Movie_Name <- mutate(Movie_Name, Worldwide_Bins = ifelse(Movie_Name$Worldwide < 131.4, 'Small Worldwide', 
                                                         ifelse(Movie_Name$Worldwide > 332.5, 'Large Worldwide', 'Medium Worldwide')))
Movie_Name <- mutate(Movie_Name, Date_Bins = ifelse(Movie_Name$Date < '2005-01-01', 'Pre-2005', 'Post-2005'))
Movie_Name <- mutate(Movie_Name, ROI = Profit/Budget)
Movie_Name <- mutate(Movie_Name, Profit_Bins = ifelse(Profit < 78.38, 'Small Profit', 
                                                      ifelse(Profit > 245.9, 'Large Profit', 'Medium Profit')))
Movie_Name <- mutate(Movie_Name, Foreign_Per = Foreign/Worldwide)
Movie_Name <- mutate(Movie_Name, Domestic_Per = Domestic/Worldwide)

library(shiny)

ui <- fluidPage( theme = 'bootstrap.css',
   
  titlePanel("Analyzing Hollywood Movies"),
  
  sidebarLayout(
    
    sidebarPanel(
      conditionalPanel(condition = "input.conditional == 'Foreign Percentage by Budget, Scatter'",
        sidebarMenu(
          menuItem(tabName = 'Foreign Percentage by Budget, Scatter', 
                   selectInput('Budget_Bin', 'Size of Budget', unique(Movie_Name$Budget_Bins)))
        )),
      conditionalPanel(condition = 'input.conditional == "Foreign Percentage by Budget, Histogram"',
       sidebarMenu(
         menuItem(tabName = 'Histagram',selectInput('Budget_Binz', 'Size of Budget', unique(Movie_Name$Budget_Bins)),
                  sliderInput("bin_width", "Width of bins:", min = .001, max = .1, value = .05, step = .005))
    )),
   conditionalPanel(condition = 'input.conditional == "Profit per Budget by Date"',
      sidebarMenu(
        menuItem(tabName = 'Profit per Budget by Date', selectInput('Date_Bin', 'Pre or Post 2005',
                                                               unique(Movie_Name$Date_Bins)))
   )),
   conditionalPanel(condition = "input.conditional == 'Foreign and Domestic Percentage by Date'",
                    sidebarMenu(
                      menuItem(tabName = 'Foreign and Domestic Percentage by Date', 
                               selectInput('Budget_Bink', 'Size of Budget', unique(Movie_Name$Budget_Bins)))
                    )),
   conditionalPanel(condition = 'input.conditional == "Movie Profits over Time"',
                    sidebarMenu(
                      menuItem(tabName = 'Profit_over_time', 
                               selectInput('Budget_Binzz', 'Size of Budget', unique(Movie_Name$Budget_Bins)))
                    )),
   conditionalPanel(condition = 'input.conditional == "Profit vs Foreign Percentage"',
                    sidebarMenu(
                      menuItem(tabName = 'Profit vs Foreign Percentage', 
                               selectInput('B_Bins', 'Size of Budget', unique(Movie_Name$Budget_Bins)))
                    ))
   ),
    mainPanel(
      tabsetPanel(
      tabPanel('Foreign Percentage by Budget, Histogram', plotOutput('distPlot1'), plotOutput("distPlot")),
      tabPanel('Foreign Percentage by Budget, Scatter', plotOutput('Foreign_Per_by_Budget'), plotOutput('Foreign_Per_by_Budget1')),
      tabPanel('Domestic / Foreign Sales by Budget', plotOutput('Twin')),
      tabPanel('Foreign and Domestic Log Scale', plotOutput('For_v_Dom_Log')),
      tabPanel('Worldwide Sales', plotOutput('For_vs_Dom_Wrld_Sales')),
      tabPanel('Foreign and Domestic Percentage by Date', plotOutput('For_by_Date'),
                plotOutput('For_by_Date1')),
      tabPanel('Movie Profits over Time', plotOutput('Profit_over_time'), plotOutput('Profit_over_time1')),
      tabPanel('Profit vs Foreign Percentage', plotOutput('Profit_over_ratio'), plotOutput('Profit_over_ratio1')),
      # tabPanel('Profit per Budget by Date', plotOutput('Date_Bins'), plotOutput('Date_Bins1')),
      tabPanel('Movie Data', dataTableOutput('Movie_Table')),
      id="conditional"
      ))
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  output$Movie_Table = renderDataTable({
    Movie_Name
  })
  output$distPlot<- renderPlot({
    bin_width <- input$bin_width
    Budget_Bin <- input$Budget_Binz
    Movie_Budget_Filter <- filter(Movie_Name, Budget_Bins == Budget_Bin)
    Movie_Name %>% filter(Budget_Bins == Budget_Bin) %>% ggplot(aes(x=Foreign_Per), stat='count') + geom_histogram(binwidth = bin_width) +
      geom_vline(xintercept=mean(Movie_Name$Foreign_Per), color="red", lwd=1, lty=2) +
      geom_vline(xintercept = mean(Movie_Budget_Filter$Foreign_Per), color='blue', lwd=1, lty=2) +
      labs(x = 'Foreign Percentage of Worldwide Gross', y = 'Count') + ggtitle('Foreign Percentage of Gross by Budget') +
      scale_x_continuous(breaks = round(seq(min(Movie_Name$Foreign_Per), max(Movie_Name$Foreign_Per), by = 0.05),2))
  })
  output$distPlot1 <- renderPlot({
    bin_width <- input$bin_width
    Movie_Name %>% ggplot(aes(x=Foreign_Per), stat='count') + geom_histogram(binwidth = bin_width) +
      geom_vline(xintercept=mean(Movie_Name$Foreign_Per), color="red", lwd=1, lty=2) +
      labs(x = 'Foreign Percentage of Worldwide Gross', y = 'Count') + ggtitle('Foreign Percentage of Gross') +
      scale_x_continuous(breaks = round(seq(min(Movie_Name$Foreign_Per), max(Movie_Name$Foreign_Per), by = 0.05),2))
  }) 
  output$Twin <- renderPlot({
    c <- ggplot(Movie_Name, aes(x = Budget, y = Domestic)) + ggtitle('Domestic Sales by Budget')
    d <- ggplot(Movie_Name, aes(x = Budget, y = Foreign)) + ggtitle('Foreign Sales by Budget')
    
    scatter_c <- c + geom_point(size = .5) + geom_smooth(method = loess, color="red", se=TRUE) + 
      coord_cartesian(ylim = c(0, 750), xlim = c(0,310)) +
      annotate("rect", xmin = 0, xmax = 80, ymin = 0, ymax = 1250, alpha = .2, fill='darkred') +
      annotate("rect", xmin = 80, xmax = 200, ymin = 0, ymax = 1250, alpha = .2, fill='darkblue') +
      annotate("rect", xmin = 200, xmax = 400, ymin = 0, ymax = 1250, alpha = .2, fill='darkgreen') 
    scatter_d <- d + geom_point(size = .5) + geom_smooth(method = loess, color="red", se=TRUE) +
      coord_cartesian(ylim = c(0, 750),xlim = c(0,310)) +
      annotate("rect", xmin = 0, xmax = 80, ymin = 0, ymax = 1250, alpha = .2, fill='darkred') +
      annotate("rect", xmin = 80, xmax = 200, ymin = 0, ymax = 1250, alpha = .2, fill='darkblue') +
      annotate("rect", xmin = 200, xmax = 400, ymin = 0, ymax = 1250, alpha = .2, fill='darkgreen')
    grid.arrange(scatter_c,scatter_d,ncol=1)
  })
  output$Foreign_Per_by_Budget <- renderPlot({
   
    h <- Movie_Name %>% ggplot(aes(y = Foreign_Per, x = Budget,color = Worldwide_Bins))
    h + geom_point(size = .75) + geom_smooth(method = loess, color='red', se=TRUE) +
      # coord_cartesian(xlim = c(-.7, .7), ylim = c(0,250)) + 
      ggtitle('Foreign Percent of Ticket Sales by Budget') +
      scale_fill_brewer(palette="Set1") + labs(y = 'Foreign Percentage of Worldwide Gross', x='Budget') +
      scale_y_continuous(breaks = round(seq(min(Movie_Name$Foreign_Per), max(Movie_Name$Foreign_Per), by = 0.1),1))
  })
  output$Foreign_Per_by_Budget1 <- renderPlot({
    Budget_Bin <- input$Budget_Bin
    h <- Movie_Name %>% filter(Budget_Bins == Budget_Bin) %>% ggplot(aes(y = Foreign_Per, x = Budget,color = Worldwide_Bins))
    h + geom_jitter(width = 1.1) + geom_smooth(method = loess, color='red', se=TRUE) +
      # coord_cartesian(xlim = c(-.7, .7), ylim = c(0,250)) + 
      ggtitle('Foreign Percent of Ticket Sales by Budget') + labs(y = 'Foreign Percentage of Worldwide Gross', x='Budget') +
      scale_y_continuous(breaks = round(seq(min(Movie_Name$Foreign_Per), max(Movie_Name$Foreign_Per), by = 0.1),1)) 
  })
  output$For_by_Date <- renderPlot({
    f <- ggplot(Movie_Name, aes(x = Date)) 
    f + geom_point(aes(y=log(Foreign)),color='Red') + geom_point(aes(y=log(Domestic)),color = 'Blue') +
      geom_smooth(aes(Date,log(Foreign)), color='Red') + geom_smooth(aes(Date,log(Domestic)),color='Blue') +
      labs(y = 'Log of Foreign and Domestic Gross') + ggtitle('Both Foreign and Domestic Gross per Movie over Time')
  })
  output$For_by_Date1 <- renderPlot({
    Budget_Bin <- input$Budget_Bink
    f <- Movie_Name  %>% filter(Budget_Bins == Budget_Bin) %>% ggplot(aes(x = Date)) 
    f + geom_point(aes(y=log(Foreign)),color='Red') + geom_point(aes(y=log(Domestic)),color = 'Blue') +
      geom_smooth(aes(Date,log(Foreign)), color='Red') + geom_smooth(aes(Date,log(Domestic)),color='Blue') +
      labs(y = 'Log of Foreign and Domestic Gross') + ggtitle('Both Foreign and Domestic Gross per Movie over Time by Budget')
  })
  output$For_vs_Dom_Wrld_Sales <- renderPlot({
    g <- ggplot(Movie_Name, aes(x = Budget, y = Worldwide, color = Ratio)) 
    g + geom_point() + geom_smooth() + coord_cartesian(ylim = c(0, 1200)) + 
      ggtitle('Worldwide Gross over Budget') + labs(y = 'Worldwide Gross')
  })
  output$For_v_Dom_Log <- renderPlot({
    j <- ggplot(Movie_Name, aes(x = Foreign, y = Domestic, color = Ratio))
    j + geom_point() + coord_trans(x = "log", y = 'log')  + ggtitle('Foreign vs Domestic: Log Scale') +
      labs(y='Domestic Gross', x = 'Foreign Gross')
  })
  output$Date_Bins <- renderPlot({
    a <- ggplot(Movie_Name, aes(x = Budget, y = Profit, color = Date_Bins))
    a + geom_point() + ggtitle('Profit by Budget, Pre and Post 2005')
  })
  output$Date_Bins1 <- renderPlot({
    Date_Bin <- input$Date_Bin
    a <- Movie_Name %>% filter(Date_Bins == Date_Bin) %>% ggplot(aes(x = Budget, y = Profit))
    a + geom_point() 
  })
  output$Profit_over_time <- renderPlot({
    z <- Movie_Name %>% ggplot(aes(x = Date, y = Profit, color = Budget_Bins))
    z + geom_point() + geom_smooth() + coord_cartesian(y=c(0,1000)) + ggtitle('Movie Profits over Time')
  })
  output$Profit_over_time1 <- renderPlot({
    Budget_Bin <- input$Budget_Binzz
    zz <- Movie_Name %>% filter(Budget_Bins == Budget_Bin) %>% ggplot(aes(x = Date, y = Profit, color = Budget_Bins))
    zz + geom_point() + geom_smooth() + coord_cartesian(y=c(0,1000)) + ggtitle('Movie Profits over Time by Budget')
  })
  output$Profit_over_ratio <- renderPlot({
    Movie_Name %>% ggplot(aes(x=Foreign_Per, y=Profit, color = Budget_Bins)) + geom_point() + geom_smooth() +
      ggtitle('Profit given Foreign Percentage') + labs(x='Foreign Percentage of Worldwide Gross')
  })
  output$Profit_over_ratio1 <- renderPlot({
    Budget_Bin <- input$B_Bins
    Movie_Name %>% filter(Budget_Bins == Budget_Bin) %>% ggplot(aes(x=Foreign_Per, y=Profit, color = Budget_Bins)) + 
      geom_point() + geom_smooth() + ggtitle('Profit given Foreign Percentage by Budget') + 
      labs(x='Foreign Percentage of Worldwide Gross')
})
}

# Run the application 
shinyApp(ui = ui, server = server)


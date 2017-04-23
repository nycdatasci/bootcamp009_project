shinyUI(dashboardPage(
  dashboardHeader(title = 'My Dashboard'),
  dashboardSidebar(
    sidebarUserPanel(
      tags$head(tags$style(HTML('.info {
                                background-color: transparent;
                                }'))),
      name = 'Jack Yip', 
      image = "https://media.licdn.com/mpr/mpr/shrinknp_100_100/p/2/005/09b/2d1/0089217.jpg"),
    sidebarMenu(
      menuItem("1. Complaints Ranking", tabName = "top20", icon = icon("sort-amount-desc")),
      menuItem("2a. Noise: Hour of Day Heatmap", tabName = "heatbyhour", icon = icon("map")),
      menuItem("2b. Noise: Hour of Day Graph", tabName = "heatbyhourgraph", icon = icon("line-chart")),
      menuItem("2c. Noise: Hour of Day Data", tabName = "heatbyhourdata", icon = icon("table")),
      menuItem("3. Complaints By Year", tabName = "top10", icon = icon("line-chart")),
      menuItem("4a. Noise vs Parking Correlation", tabName = "noise_parking", icon = icon("line-chart")),
      menuItem("4b. Noise vs Parking Heatmap", tabName = "heatmap", icon = icon("map")))
  ),
  
  dashboardBody(
    tabItems(
      
## "1. Complaints Ranking"
      tabItem(tabName = "top20",
              fluidRow(plotOutput("top20", height = 600, width = 1000))),
      
## "2a. Noise: Hour of Day Heatmap"
      tabItem(tabName = "heatbyhour",
              h3("Density of 311 Noise Complaints by Hour of Day (Jan 2010 to Apr 2017)"),
              sliderInput("integer", "Select Hour of Day",
                          min = 0, max = 23, value = 0),
              fluidRow(leafletOutput("heatbyhour", height = 750, width = 1000))),
      
## "2b. Noise: Hour of Day Graph"
      tabItem(tabName = "heatbyhourgraph",
              fluidRow(plotOutput("heatbyhourgraph", height = 600, width = 1000))),
      
## "2c. Noise: Hour of Day Data"
      tabItem(tabName = "heatbyhourdata",
              tabItem(tabName = "hourlynoisedata",
                      fluidRow(box(
                        title = 'Cumulative Noise Complaints by Hour of Day (Jan 2010 to Apr 2017)',
                        div(style = 'overflow-x: scroll', DT::dataTableOutput("hourlynoisedata")), width = 24)))),
      
## "3. Complaints By Year"
      tabItem(tabName = "top10",
              sliderInput("range", "Select Year(s) Range",
                          min = 2010, max = 2017, value = c(2010, 2017)),
              fluidRow(htmlOutput("top10"))),

## "4a. Noise vs Parking Correlation"
      tabItem(tabName = "noise_parking",
              fluidRow(plotOutput("noise_parking", height = 600, width = 1000))),
      
## "4b. Noise vs Parking Heatmap"
      tabItem(tabName = "heatmap",
              h3("Density of Noise & Illegal Parking Complaints by Neighborhood (Jan 2010 to Apr 2017)"),
              selectizeInput("year",
                             "Select Year",
                             colnames(leafletnoise)[3:10]),
              fluidRow(leafletOutput("heatmap", height = 750, width = 1000)))
    )
  )
))

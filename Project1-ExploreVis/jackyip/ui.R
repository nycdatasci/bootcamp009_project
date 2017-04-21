shinyUI(dashboardPage(
  dashboardHeader(title = 'My Dashboard'),
  dashboardSidebar(
    sidebarUserPanel(
      tags$head(tags$style(HTML('
                              .info {
                                background-color: transparent;
                                }'))),
      name = 'Jack Yip', 
                     image = "https://media.licdn.com/mpr/mpr/shrinknp_100_100/p/2/005/09b/2d1/0089217.jpg"),
    sidebarMenu(
      menuItem("Top 20 Complaints Total", tabName = "top20", icon = icon("map")),
      menuItem("Noise vs Traffic By Year", tabName = "noise_traffic", icon = icon("map")),
      menuItem("Top 10 Complaints By Year", tabName = "top10", icon = icon("map")),
      menuItem("Noise vs Illegal Parking By Year", tabName = "noise_parking", icon = icon("map")),
      menuItem("Noise vs Illegal P. - Heatmap", tabName = "heatmap", icon = icon("map")))
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "top20",
              fluidRow(plotOutput("top20", height = 700, width = 1100))),
      tabItem(tabName = "noise_traffic",
              fluidRow(plotOutput("noise_traffic", height = 600, width = 1100))),
      tabItem(tabName = "top10",
              sliderInput("range", "Select Year(s) Range",
                          min = 2010, max = 2016, value = c(2010, 2016)),
              fluidRow(htmlOutput("top10"))),
      tabItem(tabName = "noise_parking",
              fluidRow(plotOutput("noise_parking", height = 600, width = 1100))),
      tabItem(tabName = "heatmap",
              h3("Yearly Density of Noise & Illegal Parking 311 Complaint Counts by Neighborhood"),
              selectizeInput("year",
                             "Select Year",
                             colnames(leafletnoise)[3:10]),
              fluidRow(leafletOutput("heatmap", height = 800)))
    )
  )
))

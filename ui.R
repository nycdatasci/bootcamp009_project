library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = 'My Dashboard'),
  dashboardSidebar(
    sidebarUserPanel("Jack Yip",
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
              fluidRow(plotOutput("top20"), height = 600, width = 600)),
      tabItem(tabName = "noise_traffic",
              fluidRow(plotOutput("noise_traffic"), height = 600, width = 600),
              fluidRow(box(DT::dataTableOutput("noise_traffic_data"),
                           width = 12))),
      tabItem(tabName = "top10",
              fluidRow(htmlOutput("top10"), height = 300),
                           width = 12),
      tabItem(tabName = "noise_parking",
              fluidRow(plotOutput("noise_parking"), height = 600, width = 600),
              fluidRow(box(DT::dataTableOutput("noise_parking_data"),
                           width = 12))),
      tabItem(tabName = "heatmap",
              selectizeInput("year",
                             "Select Item to Display",
                             colnames(leafletnoise)[3:10]),
              fluidRow(leafletOutput("heatmap", height = 1000)))
    )
  )
))

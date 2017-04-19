library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = 'My Dashboard'),
  dashboardSidebar(
    sidebarUserPanel("Jack Yip",
                     image = "https://media.licdn.com/mpr/mpr/shrinknp_100_100/p/2/005/09b/2d1/0089217.jpg"),
    sidebarMenu(
      menuItem("Scatter Plot", tabName = "plot", icon = icon("map")),
      menuItem("Bar chart", tabName = "bar", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("map")))
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "plot",
              fluidRow(plotOutput("plot"), height = 300, width = 300)),
      tabItem(tabName = "bar",
              fluidRow(plotOutput("bar"), height = 300, width = 300)),
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("data"),
                           width = 12)))
    )
  )
))
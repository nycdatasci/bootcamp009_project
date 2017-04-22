


library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title="Lending Club 07-11"),
  dashboardSidebar(
    sidebarUserPanel("Kim"),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Data", tabName = "data", icon = icon("database"))),
    selectizeInput("selected", "Parameter to Display", choice)
   # selectizeInput("selected2","Parameter2 to Display", choice) 
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              
              fluidRow(infoBoxOutput("Box1"),
                       infoBoxOutput("minBox"),
                       infoBoxOutput("avgBox"),
                       infoBoxOutput("medianBox"),
                       infoBoxOutput("stdevBox")),
              
              fluidRow(box(htmlOutput("map"), height = 300),
                       box(htmlOutput("hist"), height = 300),
                       box(htmlOutput("bar"), height = 300),
                       box(htmlOutput("gradebar"), height = 300))
      ),
      tabItem(tabName = "data",
              
              downloadButton('downloadData', 'Download'),
              # datatable
              fluidRow(box(DT::dataTableOutput("table"),width=12)))
    )
  )
))

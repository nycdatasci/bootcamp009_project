## ui.R ##
library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = "My Dashboard"),
  dashboardSidebar(
    sidebarUserPanel("NYC DSA",
                     image = 'https://course_report_production.s3.amazonaws.com/rich/rich_files/rich_files/567/s300/data-science-logos-final.jpg'
    ),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Charts", tabName = "ch", icon = icon("chart")),
      menuItem("Data", tabName = "data", icon = icon("database"))),
    
    selectizeInput(inputId="deg_length",
                   label="Select Degree Length",
                   choices=choice),
    selectizeInput(inputId="state_choice",
                   label="Select State",
                   choices=state_vector)
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              # fluidRow(infoBoxOutput("maxBox"),
              #          infoBoxOutput("minBox"),
              #          infoBoxOutput("avgBox")),
              # gvisGeoChart
              fluidRow(box(plotOutput("statePlot"), height=300))
              #          # gvisHistoGram
              #          box(htmlOutput("hist"), height=300))),
      ),
      tabItem(tabName = 'ch',
              fluidRow(box(plotOutput('controlPlot')))
      ),
      tabItem(tabName = "data"
              # datatable
              # fluidRow(box(DT::dataTableOutput("table"))))
      )
  ))
))
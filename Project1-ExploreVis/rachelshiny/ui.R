## ui.R ##
library(shinydashboard)
library(leaflet)
library(maps)

shinyUI(dashboardPage(
  dashboardHeader(title = "College Comparison Dashboard", titleWidth = 350),
  dashboardSidebar(
    sidebarUserPanel("Tabs",
                     image = 'https://course_report_production.s3.amazonaws.com/rich/rich_files/rich_files/567/s300/data-science-logos-final.jpg'
    ),
    sidebarMenu(
      menuItem("By Location", tabName = "map", icon = icon("map")),
      menuItem("Charts", tabName = "ch", icon = icon("chart")),
      menuItem("Scatter Plots", tabName = "sc", icon = icon("chart")),
      menuItem("Data", tabName = "data", icon = icon("database"))),
    
    selectizeInput(inputId="deg_length",
                   label="Select Degree Length",
                   choices=choice)
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              # fluidRow(infoBoxOutput("maxBox"),
              #          infoBoxOutput("minBox"),
              #          infoBoxOutput("avgBox")),
              # gvisGeoChart
              fluidRow(box(
                selectizeInput(inputId="region_choice",
                               label=h4("Select Region"),
                               selected=NULL,
                               choices=region_vector)),
                box(
                selectizeInput(inputId="state_choice",
                             label=h4("Select State"),
                             selected="all",
                             choices=state_vector)) 
                ),
              fluidRow(box(leafletOutput("statePlot"), height=420, width=200)),
              fluidRow()
              #          # gvisHistoGram
              #          box(htmlOutput("hist"), height=300))),
      ),
      tabItem(tabName = 'ch',
              fluidRow(box(plotOutput('controlPlot'))),
              fluidRow(box(plotOutput('graddensityPlot')))
      ),
      tabItem(tabName = 'sc', 
              fluidRow(
                column(4,
                       wellPanel(
                         h4("Filter"),
                         sliderInput("ugrads", "Minimum number of undergraduate students",
                                     0, 30000, 50, step = 100),
                         selectInput(inputId="highest_deg",
                                    label="Highest Degree Awarded",
                                    choices=names(highest_degree),
                                    selected = 'All'),
                         textInput("collegeName", "College name contains (e.g., Nursing)")
                       ),
                       wellPanel(
                         selectInput(inputId='xvar', 
                                     label="X-axis variable",
                                     choices= x_vars),
                         selectInput("yvar", "Y-axis variable", 
                                     choices = y_vars, 
                                     selected = 'MN_EARN_WNE_P7'),
                         tags$small(paste0(
                           "Note: The Tomato Meter is the proportion of positive reviews",
                           " (as judged by the Rotten Tomatoes staff), and the Numeric rating is",
                           " a normalized 1-10 score of those reviews which have star ratings",
                           " (for example, 3 out of 4 stars)."
                         ))
                       )
                ),
                column(8, ggvisOutput("plot1")))
              
            ),
      tabItem(tabName = "data",
              # datatable
              fluidRow(box(DT::dataTableOutput("table")))
      )
    ))
))
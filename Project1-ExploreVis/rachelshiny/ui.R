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
      menuItem("Overview", tabName = "home", icon = icon("map")),
      menuItem("By Location", tabName = "map", icon = icon("map")),
      menuItem("Scatter Plots", tabName = "sc", icon = icon("chart")),
      menuItem("Charts", tabName = "ch", icon = icon("chart")),
      menuItem("Comparator", tabName = "cp", icon = icon("chart")),
      menuItem("Data", tabName = "data", icon = icon("database")))
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = 'home',
              fluidRow(
                box(paste0(
                "A few years ago, the U.S. Department of Education began aggregating ",
                "data related to student demographics and outcomes by college.  ",
                "Their goal was to enable high schoolers to make more informed decisions ",
                "about their futures.  Over 1700 columns of data on over 7000 institutions ",
                "is available at https://collegescorecard.ed.gov/. ")
              )),
              fluidRow(
                img(src='http://i0.wp.com/flowingdata.com/wp-content/uploads/2015/09/College-Scorecard.png?fit=720%2C357', 
                    width='75%', height = '75%', caption="test")
              )
      ),
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
              fluidRow(box(selectizeInput(inputId="deg_length",
                                          label="Select Degree Length",
                                          choices=choice)),
                       box(selectizeInput(inputId="filt",
                                          label="Filter by",
                                          choices=names(filts), selected='None')
                         
                       )),
              fluidRow(box(plotOutput('graddensityPlot')),
                       box(
                         plotOutput('blackdensityPlot')
                       )),
              
              fluidRow(box(plotOutput('controlPlot')))
      ),
      tabItem(tabName = 'sc', 
              fluidRow(
                column(4,
                       wellPanel(
                         h4("Filter"),
                         sliderInput("ugrads", "Number of undergraduates",
                                     0, 50000, 50, step = 100, value=c(100, 50000)),
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
                                     selected = 'MN_EARN_WNE_P7')
                         
                       )
                ),
                column(8, ggvisOutput("plot1")))
              
            ),
      tabItem(tabName = "data",
              # datatable
              fluidRow(box(width=12, DT::dataTableOutput("table")))
      ),
      tabItem(tabName = "cp",
              fluidRow(box(selectizeInput(inputId="col_comp",
                                          label=h4("Select College"),
                                          selected='',
                                          choices=c('', unique(data$INSTNM))))),
              # datatable
              fluidRow(box(width=12, DT::dataTableOutput("comp")))
      )
    ))
))
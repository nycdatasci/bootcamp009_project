## ui.R ##
library(shinydashboard)
library(leaflet)
library(maps)

shinyUI(dashboardPage(
  dashboardHeader(title = "College Comparison Dashboard", titleWidth = 350),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "home", icon = icon("bank")),
      menuItem("By Location", tabName = "map", icon = icon("map")),
      menuItem("Scatter Plots", tabName = "sc", icon = icon('stats', lib='glyphicon')),
      menuItem("Charts", tabName = "ch", icon = icon('stats', lib='glyphicon')),
      menuItem("Comparator", tabName = "cp", icon = icon('thumbs-up', lib='glyphicon')))
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
              fluidRow(
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
                                    selected = 'All')
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
      tabItem(tabName = "cp",
              fluidRow(box(selectizeInput(inputId="col_comp",
                                          label=h4("Select College"),
                                          selected='',
                                          choices=c('', unique(data$INSTNM)))),
                       box(
                         selectInput(inputId='state', label=h4('In State Only?'),
                                     selected='False', choices=c('True', 'False'))
                       )
                       ),
              # datatable
              fluidRow(box(width=12, DT::dataTableOutput("comp")))
      )
    ))
))
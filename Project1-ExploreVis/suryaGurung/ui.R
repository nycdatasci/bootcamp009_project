#library(shiny)
#library(shinydashboard)
#library(plotly)
shinyUI(
    dashboardPage(
        skin = "red",
        dashboardHeader(title = h4("Bankruptcy Predictor"),
                        dropdownMenuOutput("messageMenu"),
                        disable = TRUE
                        
        ),
        dashboardSidebar(
            disable = TRUE,
            
            sidebarSearchForm(textId = "tickerSearch", buttonId = "searchButton",
                              label = "Ticker Search"),
           
            dateRangeInput("dates", 
                           "Date range",
                           start = "2013-01-01", 
                           end = as.character(Sys.Date())),
            
            sidebarMenu(
                menuItem("Map", tabName = "map", icon = icon("map")),
                menuItem("Data", tabName = "data", icon = icon("database")))
        ),
        dashboardBody(
            fluidRow(
                column(
                    img(src = "chart.jpg",height = 80, width = "100%"),
                    width = 12
                    #background = "light-blue"
                    #strong("Bankruptcy Predictor")
                )
            ),
            fluidRow(box(width=12, height = "0px")),
            fluidRow(
                
                tabBox(
                    #title = "Surya Gurung",
                    # The id lets us use input$tabset1 on the server to find the current tab
                    id = "tabset1", height = "500px",
                    width = 9, 
                    tabPanel("Z-Score: (NYSE)",
                        plotlyOutput("all")
                    ),
                    tabPanel("Industries", 
                             plotlyOutput("sector")         
                    ),
                    tabPanel("Company", 
                        plotlyOutput("company")         
                    ),
                    tabPanel("Features", 
                             plotlyOutput("features")         
                    )
                ),
                box(
                    #title = h4("Bankruptcy Predictor"),
                    background = 'aqua',
                    width = 3, 
                    height = "500px",
                    #dateRangeInput("dates", 
                    #               "Date Range",
                    #               start = "2013-01-01", 
                    #               end = as.character(Sys.Date())),
                    selectizeInput('selectSector', label = h4('Industries'),
                                   choices = fundamentals$Sector, selected = ''
                    ),
                    
                    selectizeInput('selectCompany', label = h4('Symbol'),
                                   choices = unique(fundamentals$Ticker), selected = ''
                    ),
                    hr(),
                    br(),
                    br()
                    
                )
            ),
            fluidRow(
                box(width = 12, background = 'blue',
                    strong("by: Surya Gurung")    
                )
            )
        )
            
            
))
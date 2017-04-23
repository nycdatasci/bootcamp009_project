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
                box(
                    h4("Bankruptcy Predictor:"),
                    width = 12, background = "light-blue"
                    #strong("Bankruptcy Predictor")
                )
            ),
            fluidRow(
                
                tabBox(
                    #title = "Surya Gurung",
                    # The id lets us use input$tabset1 on the server to find the current tab
                    id = "tabset1", height = "550px",
                    width = 9, 
                    tabPanel("Z-Score",
                        plotlyOutput("plot")
                    ),
                    tabPanel("Features")
                ),
                box(
                    #title = h4("Bankruptcy Predictor"),
                    background = 'aqua',
                    width = 3, 
                    height = "550px",
                    #dateRangeInput("dates", 
                    #               "Date Range",
                    #               start = "2013-01-01", 
                    #               end = as.character(Sys.Date())),
                    selectizeInput('selectSector', label = h4('Sector'),
                                   choices = fundamentals$Sector, selected = 'Industrials'
                    ),
                    hr(),
                    sidebarSearchForm(textId = "tickerSearch", buttonId = "searchButton",
                                      label = "Ticker Search")
                    
                    
                )
            ),
            fluidRow(
                box(width = 12, background = 'light-blue',
                strong("by: Surya Gurung")    
                )
            )
        )
            
            
))
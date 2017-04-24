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
                             strong("What is Altman's Z-Score?"),
                             tags$ul(
                                 tags$li("NYU Prof. Edward Altman developed in 1968."),
                                 tags$li("Based on linear discriminant analysis (LDA)."),
                                 tags$li("and following financial numbers:"),
                                 tags$ul(
                                     tags$li(
                                         HTML(paste('X', tags$sub(1), 
                                            '= Working Capital / Total Asset'))),
                                     tags$li(
                                         HTML(paste('X', tags$sub(2), 
                                                    '= Retained Earnings / Total Asset'))),
                                     tags$li(
                                         HTML(paste('X', tags$sub(3), 
                                                    '= EBIT / Total Asset'))),
                                     tags$li(
                                         HTML(paste('X', tags$sub(4), 
                                                    '= Market Value Of Equity/ Total Liability'))),
                                     tags$li(
                                         HTML(paste('X', tags$sub(5), 
                                                    '= Sales / Total Asset')))
                                    
                                 ),
                                 tags$li(
                                    HTML(paste('Z = 1.2X', tags$sub(1), '+ 1.4X', tags$sub(2), 
                                            '+ 3.3X', tags$sub(3), '+ 0.6X', tags$sub(4),
                                            '+ 0.999X', tags$sub(5)))
                                 ),
                                 tags$li("Unlikely to default: Z > 3.0"),
                                 tags$li("On alert: 2.7 < Z < 3.0"),
                                 tags$li("Good chance to default: 1.8 < Z < 2.7"),
                                 tags$li("Highly likely to default: Z < 1.8"),
                                 tags$li("72% accurate in predicting bankruptcy two years before the event, with a Type II error of 6%"),
                                 tags$li("In 1999, 80%–90% accurate in predicting bankruptcy one year before the event, with a Type II 
                                        error approximately 15%–20% ")
                                         
                                        
                             )         
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
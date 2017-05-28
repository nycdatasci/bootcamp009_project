## ui.R ##

navbarPage("NYC MTA Subway Ridership",
           id = "nav",
           position = "fixed-bottom",
           collapsible = TRUE,
           fluid = TRUE,
           
           tabPanel("Map",
                    icon = icon("subway"),
                    div(class="outer",
                        tags$head(includeCSS("./www/custom.css")),
                        leafletOutput("mtamap", width = "100%", height = "100%"),
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = FALSE,
                                      draggable = TRUE, top = 40, left = 60, right = "auto", bottom = "auto",
                                      width = 480, height = "auto"

                        ),
                        tags$div(id="cite", "Data Provided by New York City's Metropolitan Transportation Authority (MTA).")
                      )
                    ),
           tabPanel("Data",
                      column(4, wellPanel(
                        dateInput('date',
                                  label = 'Filter by Day:',
                                  value = Sys.Date()
                        ),
                        
                        dateInput('time',
                                  label = 'Filter by Time of Day:',
                                  value = as.character(Sys.Date()),
                                  min = Sys.Date() - 5, max = Sys.Date() + 5,
                                  format = "dd/mm/yy",
                                  startview = 'year', language = 'zh-TW', weekstart = 1
                        ),
                        
                        dateRangeInput('dateRange',
                                       label = 'Date range input: yyyy-mm-dd',
                                       start = Sys.Date() - 2, end = Sys.Date() + 2
                        ),
                        
                        dateRangeInput('dateRange2',
                                       label = paste('Date range input 2: range is limited,',
                                                     'dd/mm/yy, language: fr, week starts on day 1 (Monday),',
                                                     'separator is "-", start view is year'),
                                       start = Sys.Date() - 3, end = Sys.Date() + 3,
                                       min = Sys.Date() - 10, max = Sys.Date() + 10,
                                       separator = " - ", format = "dd/mm/yy",
                                       startview = 'year', language = 'fr', weekstart = 1
                        )
                      )),
                      
                      column(6,
                             verbatimTextOutput("dateText"),
                             verbatimTextOutput("dateText2"),
                             verbatimTextOutput("dateRangeText"),
                             verbatimTextOutput("dateRangeText2")
                      )
                    ),
           tabPanel("Station Name",
                    icon = icon("subway"),
                    uiOutput("station_name")
           )
)

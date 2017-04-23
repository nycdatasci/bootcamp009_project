library(shiny)
library(shinydashboard)


# Define UI for application that draws a histogram
dashboardPage(skin = "blue",
              dashboardHeader(title = "Where the Angriest Passengers Are", titleWidth = 400),
              dashboardSidebar(
                sidebarMenu(
                  menuItem("Map of Total Claims", tabName = "map", icon = icon("map")),
                  menuItem("Claims Over Time", tabName = "claimTS", icon = icon("line-chart"),
                           menuSubItem("Time Series", tabName = "month_and_day"),
                           menuSubItem("Month Breakdown", tabName = "facet_wrap")),
                  menuItem("Itemized Breakdown", tabName = "prop", icon = icon("thermometer"),
                           menuSubItem("Airport Heatmap", tabName = "airport_heat"),
                           menuSubItem("Airline Heatmap", tabName = "airline_heat")),
                  menuItem("Flight and Passenger Data", tabName = "flights", icon = icon("plane"),
                           menuSubItem("Airport Flight Data", tabName = "airport_table"),
                           menuSubItem("Airline Flight Data", tabName = "airline_table")),
                  menuItem("Claim Rates", tabName = "rates", icon = icon("rocket"),
                           menuSubItem("Claim Rate by Airport per Year", tabName = "airport_rate"),
                           menuSubItem("Claim Rate by Airline per Year", tabName = "airline_rate"),
                           menuSubItem("Claim Rate by Airline and Type", tabName = "airline_and_type")
                )
                )
              ),
              
              dashboardBody(
                tabItems(
                  tabItem(tabName = "map",
                          h2("Geographic Claims"),
                          fluidRow(
                            absolutePanel(top = 10, right = 10,
                                          sliderInput("year_range", h4("Select Year"),
                                                      min = min(leaf_data$Year),
                                                      max = max(leaf_data$Year),
                                                      value = 2010:2015)
                                          ),
                          leafletOutput("map", height = 600, width = "100%")
                            )
                          ),
                  tabItem(tabName = "month_and_day",
                          h2("Time Series of Claims"),
                          fluidRow(
                            box(width = 12,
                                dygraphOutput("timeSeries"))
                            )
                          ),
                  tabItem(tabName = "facet_wrap",
                          h2("Average Claim Type Per Month"),
                          fluidRow(box(
                            selectInput("general_year", h4("Select Year"),
                                      choices = sort(unique(by_month$Year)))
                          )),
                          
                          fluidRow(
                            box(width = 12,
                                plotOutput("facetPlot"))
                            )
                          ),
                  tabItem(tabName = "airport_table",
                          h2("Airport Flight Data for 2014-2015"),
                          fluidRow(box(
                            DT::dataTableOutput('airportTable'), width = 12)
                            )
                          ),
                  tabItem(tabName = "airline_table",
                          h2("Airline Flight Data for 2014-2015"),
                          fluidRow(box(
                            DT::dataTableOutput('airlineTable'), width = 12)
                            )
                          ),
                  tabItem(tabName = "airport_heat",
                          h2("Airport Heatmap"),
                          fluidRow(
                            absolutePanel(top = 125, left = 250, 
                                          selectInput('airport_year', h4("Select Year"), 
                                                      choices = sort(unique(items_by_airport$Year))))
                            ),
                          fluidRow(
                            absolutePanel(top = 125, right = 10,
                                          selectInput('disposition', h4("Select Status"), 
                                                      choices = sort(unique(items_by_airport$Disposition))))
                            ),
                                   
                          fluidRow(
                            absolutePanel(top = 200, width = 12,
                              box(status = "success",
                                  plotlyOutput("airportItems")))
                            )
                          ),
                  tabItem(tabName = "airline_heat",
                          h2("Airline Heatmap"),
                          fluidRow(absolutePanel(top = 125, left = 250,
                                                 selectInput("airline_year", h4("Select Year"),
                                                             choices = sort(unique(items_by_airline$Year)))
                          )),
                          fluidRow(absolutePanel(top = 125, right = 10,
                                                 selectInput("disposition2", h4("Select Status"),
                                                             choices = sort(unique(items_by_airline$Disposition)))
                          )),
                          fluidRow(
                            absolutePanel(top = 200, width = 12,
                                          box(status = "success",
                                          plotlyOutput("airlineItems"))
                            )
                          )
                          ),
                  tabItem(tabName = "airport_rate",
                          h2("Claim Rates by Airport"),
                          plotOutput("airportRate")
                          ),
                  
                  tabItem(tabName = "airline_rate",
                          h2("Claim Rates by Airline"),
                          plotOutput("airlineRate")
                            ),
                  
                  tabItem(tabName = "airline_and_type",
                          h2("Claim Rates by Airline and Type"),
                          plotOutput("airlineAndType")
                          )
              )
              )
)



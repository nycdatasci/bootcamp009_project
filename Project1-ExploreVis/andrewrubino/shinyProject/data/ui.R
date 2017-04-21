library(shiny)
library(shinydashboard)


# Define UI for application that draws a histogram
dashboardPage(skin = "blue",
              dashboardHeader(title = "What's the deal with TSA?", titleWidth = 400),
              dashboardSidebar(
                sidebarMenu(
                  menuItem("Claims Over Time", tabName = "claimTS", icon = icon("line-chart"),
                           menuSubItem("Time Series", tabName = "month_and_day"),
                           menuSubItem("Month Facet", tabName = "facet_wrap")),
                  menuItem("Itemized Breakdown", tabName = "prop", icon = icon("thermometer"),
                           menuSubItem("Airport Heatmap", tabName = "airport_heat"),
                           menuSubItem("Airline Heatmap", tabName = "airline_heat"))
                )
              ),
              
              dashboardBody(
                tabItems(
                  tabItem(tabName = "month_and_day",
                          h2("Time Series of Claims"),
                          fluidRow(
                            box(width = 15,
                                dygraphOutput("timeSeries"))
                            )
                          ),
                  
                  tabItem(tabName = "facet_wrap",
                          h2("Average Claim Type Per Month"),
                          selectInput("general_year", h4("Select Year"),
                                      choices = sort(unique(by_month$Year))),
                          
                          fluidRow(
                            box(width = 15,
                                plotOutput("facetPlot"))
                            )
                          ),
                  
                  tabItem(tabName = "airport_heat",
                          h2("Airport Heatmap"),
                          selectInput("airport_year", h4("Select Year"),
                                      choices = sort(unique(items_by_airport$Year))),
                          selectInput("disposition", h4("Select Status"),
                                      choices = sort(unique(items_by_airport$Disposition))),
                          fluidRow(
                            box(width = 12, status = "success", solidHeader = TRUE,
                                title = "Count of Claimed Items by Airport",
                                plotlyOutput("airportItems"))
                            )
                          ),
                          
                  tabItem(tabName = "airline_heat",
                          h2("Airline Heatmap"),
                          selectInput("airline_year", h4("Select Year"),
                                      choices = sort(unique(items_by_airline$Year))),
                          selectInput("disposition2", h4("Select Status"),
                                      choices = sort(unique(items_by_airline$Disposition)))
                          ),
                          fluidRow(
                            box(width = 12, status = "success", solidHeader = TRUE,
                                title = "Count of Claimed Items by Airline",
                                plotlyOutput("airlineItems"))
                            )
                          )
              )
)

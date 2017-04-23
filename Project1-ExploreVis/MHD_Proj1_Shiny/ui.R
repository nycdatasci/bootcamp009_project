library(shiny)
library(shinydashboard)
library(plotly)
library(leaflet)



dashboardPage(skin = "black", 
        dashboardHeader(title = "Real Estate Trends"),
        
        dashboardSidebar(width = 200,
                sidebarMenu(
                        menuItem("Plots", tabName = "plots", icon = icon("line-chart")),
                        menuItem("Map", tabName = "map", icon = icon("map"))
                ),
                        
                selectizeInput("state", label = "State", choices = sort(unique(merged_rent_value[ , "State"])), selected = "AK"),
                selectizeInput("county", label = "County", choices = sort(unique(merged_rent_value[ , "CountyName"])), selected = "All Counties"),
                selectizeInput("city", label = "City", c("All Cities", sort(unique(merged_rent_value[ , "zip_city"], selected = "All Cities"))))
        ),
        dashboardBody(
                tabItems(
                        tabItem(tabName = "plots",
                                tabsetPanel(
                                        tabPanel("Plot",
                                        plotlyOutput("plot", height = 450),
                                        hr(),
                                        fluidRow(
                                                column(radioButtons("plot_options", label = h4("Plot Options"),
                                                              choices = list("Mean" = 1, "All" = 2), 
                                                        selected = 1),
                                                width = 3
                                                ),
                                                column(radioButtons("plot_var", label = h4("Variable to Plot"),
                                                                    choices = list("Value" = 1, "Rent" = 2, "Rent/Value" = 3), 
                                                                    selected = 1),
                                                       width = 3
                                                ),
                                                column(sliderInput("plotslider", 
                                                                   "Date Range", 
                                                                   min = as.Date("2012-01-01"),
                                                                   max =as.Date("2016-12-01"),
                                                                   value=c(as.Date("2012-01-01"), as.Date("2016-12-01")),
                                                                   timeFormat="%b %Y",
                                                                   dragRange = TRUE),
                                                       width = 5
                                                       )
                                                )
                                        ),
                                        tabPanel("Bar",
                                                 plotlyOutput("bar", height = 500),
                                                 hr(),
                                                 fluidRow(column(width = 1),
                                                         column(sliderInput("barslider", 
                                                                            "Date Range", 
                                                                            min = as.Date("2012-01-01"),
                                                                            max =as.Date("2016-12-01"),
                                                                            value=c(as.Date("2012-01-01"), as.Date("2016-12-01")),
                                                                            timeFormat="%b %Y",
                                                                            dragRange = TRUE),
                                                 width = 5
                                                 )
                                                 )
                                                 )
                                        )
                                ),
                        tabItem(tabName = "map",
                                fluidRow(column(leafletOutput("map1", height = 500),
                                                width = 6
                                         ),
                                         column(leafletOutput("map2", height = 500),
                                                 width = 6
                                         )
                                         ),
                                fluidRow(column(radioButtons("map1_var", label = h4("Variable to Map"),
                                                             choices = list("Value" = 1, "Rent" = 2, "Rent/Value" = 3), 
                                                             selected = 1),
                                                width = 2
                                ),
                                         column(fluidRow(sliderInput("map1slider", 
                                                            "Date", 
                                                            min = as.Date("2012-01-01"),
                                                            max = as.Date("2016-12-01"),
                                                            value= as.Date("2016-12-01"),
                                                            timeFormat="%b %Y")
                                         ),
                                         fluidRow(radioButtons("map1_mark", label = "Marker",
                                                               choices = list("Circles" = 1, "Polygons" = 2), 
                                                               selected = 1)
                                                 
                                         ),
                                         width = 3
                                         ),
                                column(width = 1),
                                column(radioButtons("map2_var", label = h4("Variable to Map"),
                                                    choices = list("Value" = 1, "Rent" = 2, "Rent/Value" = 3), 
                                                    selected = 1),
                                       width = 2
                                ),
                                column(fluidRow(sliderInput("map2slider", 
                                                            "Date", 
                                                            min = as.Date("2012-01-01"),
                                                            max = as.Date("2016-12-01"),
                                                            value= as.Date("2016-12-01"),
                                                            timeFormat="%b %Y")
                                ),
                                fluidRow(radioButtons("map2_mark", label = "Marker",
                                                      choices = list("Circles" = 1, "Polygons" = 2), 
                                                      selected = 1)
                                         
                                ),
                                width = 3
                                )
                                )
                                )
                        )
                )
        )
        

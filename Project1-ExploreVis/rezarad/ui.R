## ui.R ##
library(shinythemes)
library(shiny)

fillPage(theme = shinytheme("simplex"),
    includeCSS("./www/custom.css"),
    leafletOutput("mtamap", height = "100%", width = "100%"),
    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                  draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                  width = 330, height = "auto",
                  actionButton("q_train","on")
    )
  )
  
    # dashboardSidebar
    # sidebarUserPanel(
    #   "Reza Rad"),
    # 
    # sidebarMenu(
    #   menuItem("NYC Subway Map", tabName = "mta", icon = icon("map")),
    #   menuItem("Fares Data", tabName = "fares", icon = icon("database")),
    #   menuItem("Turnstile Data", tabName = "turnstile", icon = icon("database"))
    # )
    # ),
    # 
   # dashboardBody(
   #  tabItems(
   #    tabItem(tabName = "mta",
   #            fluidRow(
   #              box(width = 6,
   #                leafletOutput("mtamap")),
   #              box(width = 6,
   #                textOutput("station_name"))
   #              )
   #            ),
   #    tabItem(tabName = "fares",
   #            DT::dataTableOutput("fares_data")),
   #    tabItem(tabName = "turnstile",
   #            "to be replaced")
   #    )
   #  )
    

# icon("refresh") for updated status  

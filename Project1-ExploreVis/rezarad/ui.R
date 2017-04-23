## ui.R ##
library(shinydashboard)

dashboardPage(skin = "black",
  
  dashboardHeader(
    title = "NYC Subway Viz <temp>",
    dropdownMenuOutput("messageMenu")
            
    ),
  
  dashboardSidebar(
    sidebarUserPanel(
      "Reza Rad"),
    
    sidebarMenu(
      menuItem("NYC Subway Map", tabName = "mta", icon = icon("map")),
      menuItem("Fares Data", tabName = "fares", icon = icon("database")),
      menuItem("Turnstile Data", tabName = "turnstile", icon = icon("database"))
    )
    ),

   dashboardBody(
    tabItems(
      tabItem(tabName = "mta",
              fluidRow(
                box(width = 6,
                  leafletOutput("mta_map")
                )
              )),
      tabItem(tabName = "fares",
              DT::dataTableOutput("fares_data")),
      tabItem(tabName = "turnstile",
              "to be replaced")
      )
    )
    
  )
  

 

# icon("refresh") for updated status  

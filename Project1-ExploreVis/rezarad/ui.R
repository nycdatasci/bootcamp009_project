## ui.R ##
library(shinydashboard)

dashboardPage(
  
  dashboardHeader(
    title = "NYC Subway Viz <temp>"
    ),
  
  dashboardSidebar(
    sidebarUserPanel(
      "Reza Rad"),
    
    sidebarMenu(
      menuItem("Fares Data", tabName = "fares", icon = icon("database")),
      menuItem("Turnstile Data", tabName = "turnstile", icon = icon("database"))
    )
    ),

   dashboardBody(
    tabItems(
      tabItem(tabName = "fares",
              DT::dataTableOutput("fares_data")),
      tabItem(tabName = "turnstile",
              "to be replaced"))
    )

  )
  

 


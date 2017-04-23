## ui.R ##
library(shinydashboard)

fluidPage(
  DT::dataTableOutput("fares_data")

          )
 


# Romibala Ningthoujam
# NYC DSA: Project - DataVizShiny

library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(skin = "black",
  dashboardHeader(title = "Hospital Comparator: Surgical Complication Scores"),
  dashboardSidebar(
    
    sidebarUserPanel("Romibala Ningthoujam",
                     image = "https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s100-c-k-no-rj-c0xffffff/photo.jpg"),
   
    selectizeInput("selected",
                   "Select Complication Case",
                   choice),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Nation-wide", tabName = "scatter", icon = icon("bar-chart")),
      menuItem("Regional", tabName = "boxplt", icon = icon("bar-chart")),
      menuItem("Data", tabName = "data", icon = icon("database"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(
      tabItem(tabName = "map",
              fluidRow(leafletOutput("geoMap"))
              ),
      tabItem(tabName = "scatter",
              fluidRow(box(plotOutput("scatter"), width = 12))
              ),
      tabItem(tabName = "boxplt",
              fluidRow(box(plotOutput("boxplt"), width = 12))
              ),
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), width = 12)))
    )
  )
))

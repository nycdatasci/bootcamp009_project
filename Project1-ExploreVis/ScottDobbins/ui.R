# @author Scott Dobbins
# @version 0.7
# @date 2017-04-22 20:50

### import useful packages ###
library(shiny)            # app formation
library(shinydashboard)   # web display
library(leaflet)          # map source

### UI component ###
shinyUI(dashboardPage(
  
  # major component #1: Title Panel
  dashboardHeader(title = "Aerial Bombing Operations", titleWidth = 360), 
  
  dashboardSidebar(width = 240, 
    
    # major component #2: Sidebar Panel
    sidebarUserPanel("Scott Dobbins", 
                     image = "https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s100-c-k-no-rj-c0xffffff/photo.jpg"), 
    
    sidebarMenu(id = "tabs", 
                menuItem("Map", tabName = "map", icon = icon("map")), 
                menuItem("Data", tabName = "data", icon = icon("database")), 
                menuItem("WW I", tabName = "WW1", icon = icon('map')), 
                menuItem("WW II", tabName = "WW2", icon = icon('map')), 
                menuItem("Korea", tabName = "Korea", icon = icon('map')), 
                menuItem("Vietnam", tabName = "Vietnam", icon = icon('map'))
    ), 
    
    selectizeInput(inputId = "pick_map",
                   label = "Pick Map",
                   choices = c("Color Map", "Plain Map", "Terrain Map", "Street Map", "Satellite Map"),
                   selected = "Color Map",
                   multiple = FALSE),

    selectizeInput(inputId = "pick_labels",
                   label = "Pick Labels",
                   choices = c("Borders", "Text"),
                   selected = c("Borders","Text"),
                   multiple = TRUE),

    br(),

    # I had to keep these checkboxInputs separate (i.e. not a groupCheckboxInput)
    # so that only redraws of the just-changed aspects occur (i.e. to avoid buggy redrawing)
    checkboxInput(inputId = "show_WW1",
                  label = "Show WW1 Bombings",
                  value = FALSE),

    checkboxInput(inputId = "show_WW2",
                  label = "Show WW2 Bombings",
                  value = FALSE),

    checkboxInput(inputId = "show_Korea",
                  label = "Show Korea Bombings",
                  value = FALSE),

    checkboxInput(inputId = "show_Vietnam",
                  label = "Show Vietnam Bombings",
                  value = FALSE)
  ),
  
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")), 
    
    tabItems(
      tabItem(tabName = "map", 
              
              # fluidRow(infoBoxOutput("maxBox"),
              #   infoBoxOutput("minBox"),
              #   infoBoxOutput("avgBox")
              # ), 
              
              # major component #3: Main Panel
              fluidRow(
                box(leafletOutput("overview_map", width = "100%", height = 768), width = 1024, height = 768)
              )
      ), 
      
      tabItem(tabName = "data", 
        fluidRow()#box(DT::dataTableOutput("table"), width = 12))
      ), 
      
      tabItem(tabName = "WW1",
              fluidRow()
      ),

      tabItem(tabName = "WW2",
              fluidRow()
      ),

      tabItem(tabName = "Korea",
              fluidRow()
      ),

      tabItem(tabName = "Vietnam",
              fluidRow()
      )
    )
  )
))

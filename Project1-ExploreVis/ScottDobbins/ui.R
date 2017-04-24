# @author Scott Dobbins
# @version 0.9
# @date 2017-04-23 23:45

### import useful packages ###
library(shiny)            # app formation
library(shinydashboard)   # web display
library(leaflet)          # map source


### constants ###

# appearance
sidebar_width = 240
title_width = 360


### UI component ###
shinyUI(dashboardPage(
  
  # Title Panel
  dashboardHeader(title = "Aerial Bombing Operations", titleWidth = title_width), 
  
  dashboardSidebar(width = sidebar_width, 
    
    # Sidebar Panel
    sidebarUserPanel("Scott Dobbins", 
                     image = "https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s100-c-k-no-rj-c0xffffff/photo.jpg"), 
    
    sidebarMenu(id = "tabs", 
                menuItem("Overview", tabName = "overview", icon = icon("map")), 
                # menuItem("Data", tabName = "data", icon = icon("database")), 
                menuItem("WW I", tabName = "WW1", icon = icon('bar-chart', lib = 'font-awesome')), 
                menuItem("WW II", tabName = "WW2", icon = icon('bar-chart', lib = 'font-awesome')), 
                menuItem("Korea", tabName = "Korea", icon = icon('bar-chart', lib = 'font-awesome')), 
                menuItem("Vietnam", tabName = "Vietnam", icon = icon('bar-chart', lib = 'font-awesome'))#, 
                # menuItem("Be a pilot", tabName = "pilot", icon = icon('fighter-jet', lib = 'font-awesome')), 
                # menuItem("Be a commander", tabName = "commander", icon = icon('map-o', lib = 'font-awesome')), 
                # menuItem("Be a civilian", tabName = "civilian", icon = icon('life-ring', lib = 'font-awesome'))
    ), 
    
    # date picker
    dateRangeInput(inputId = "dateRange", 
                   label = "Select which dates to show", 
                   start = "1914-07-28", 
                   end = "1975-04-30", 
                   min = "1914-07-28", 
                   max = "1975-04-30", 
                   startview = "year", 
                   width = sidebar_width), 
    
    # selectizeInput(inputId = "country", 
    #                label = "Which country's air force?", 
    #                choices = c("one"), 
    #                selected = c(), 
    #                width = sidebar_width), 
    # 
    # selectizeInput(inputId = "aircraft", 
    #                label = "Which types of aircraft?", 
    #                choices = c("one"), 
    #                selected = c(), 
    #                width = sidebar_width), 
    # 
    # selectizeInput(inputId = "weapon", 
    #                label = "Which types of bombs?", 
    #                choices = c("one"), 
    #                selected = c(), 
    #                width = sidebar_width), 
    
    numericInput(inputId = "sample_num", 
                 label = "Sample size = ?", 
                 value = 1024, 
                 min = 1, 
                 max = 2048)
    
  ),
  
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")), #***really wish this would also apply my desired formatting to the sidebar, but it seems not
    
    tabItems(
      
      # main panel with map and simple stats
      tabItem(tabName = "overview", 
              
              # some stats
              fluidRow(
                infoBoxOutput(outputId = "num_missions"),
                infoBoxOutput(outputId = "num_bombs"),
                infoBoxOutput(outputId = "total_weight")
              ), 
              
              # map
              fluidRow(
                box(leafletOutput("overview_map", width = "100%", height = 640), width = 1024, height = 640)
              ), 
              
              # selection widgets
              fluidRow(
                
                # map picker
                box(selectizeInput(inputId = "pick_map", 
                                   label = "Pick Map", 
                                   choices = c("Color Map", "Plain Map", "Terrain Map", "Street Map", "Satellite Map"), 
                                   selected = "Color Map", 
                                   multiple = FALSE), 
                    width = 4),
                
                # label picker
                box(selectizeInput(inputId = "pick_labels", 
                                   label = "Pick Labels", 
                                   choices = c("Borders", "Text"), 
                                   selected = c("Borders","Text"), 
                                   multiple = TRUE), 
                    width = 4), 
                
                # war picker
                box(selectizeInput(inputId = "which_war", 
                                   label = "Which wars?", 
                                   choices = c(WW1_string, WW2_string, Korea_string, Vietnam_string), 
                                   selected = c(), 
                                   multiple = TRUE), 
                    width = 4)
              )
      ), 
      
      # # a closer look at the data
      # tabItem(tabName = "data", 
      #   fluidRow(box(DT::dataTableOutput("table"), width = 12))
      # ), 
      
      # WW1-specific stats
      tabItem(tabName = "WW1",
              fluidRow(box(plotOutput("WW1_hist"))), 
              fluidRow(box(sliderInput(inputId = "WW1_hist_slider", label = "# of bins", min = 4, value = 30, max = 48, step = 1)))
      ),
      
      # WW2-specific stats
      tabItem(tabName = "WW2",
              
              fluidRow(
                box(plotOutput("WW2_hist")), 
                box(plotOutput("WW2_sandbox"))
              ), 
              
              fluidRow(
                box(sliderInput(inputId = "WW2_hist_slider", label = "# of bins", min = 7, value = 30, max = 84, step = 1), width = 6), 
                box(selectizeInput(inputId = "WW2_sandbox_ind", label = "Which independent variable?", choices = c("Year", WW2_all_choices), selected = c("Year"), multiple = FALSE), width = 6)
              ), 
              
              fluidRow(
                box(selectizeInput(inputId = "WW2_sandbox_group", label = "Group by what?", choices = c("None", WW2_categorical_choices), selected = c("None"), multiple = FALSE), width = 6), 
                box(selectizeInput(inputId = "WW2_sandbox_dep", label = "Which dependent variable?", choices = WW2_continuous_choices, selected = c("Number of Attacking Aircraft"), multiple = FALSE), width = 6)
              )
      ),
      
      # Korea-specific stats
      tabItem(tabName = "Korea",
              fluidRow(box(plotOutput("Korea_hist"))), 
              fluidRow(box(sliderInput(inputId = "Korea_hist_slider", label = "# of bins", min = 4, value = 30, max = 48, step = 1)))
      ),
      
      # Vietnam-specific stats
      tabItem(tabName = "Vietnam",
              fluidRow(box(plotOutput("Vietnam_hist"))), 
              fluidRow(box(sliderInput(inputId = "Vietnam_hist_slider", label = "# of bins", min = 4, value = 30, max = 240, step = 1)))
      )#, 
      
      # # pilot stats
      # tabItem(tabName = "pilot", 
      #         fluidRow()
      # ), 
      # 
      # # commander stats
      # tabItem(tabName = "commander", 
      #         fluidRow()
      # ), 
      # 
      # # civilian stats
      # tabItem(tabName = "civilian", 
      #         box(plotOutput("civilian_density", width = "100%"), width = 12)#, height = 768)
      # )
    )
  )
))

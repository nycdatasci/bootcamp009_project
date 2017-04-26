##EDA Project Version 6
## Issue with rendering if multiple plots on one tab
## Added check for facet



library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(
  
  #Header
  dashboardHeader(title = "Conference Finalists in the NBA Regular Season"),
  
  #Sidebar
  dashboardSidebar(
    
    sidebarUserPanel("Kai Chan",
                     image = "https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s100-c-k-no-rj-c0xffffff/photo.jpg"),
    sidebarMenu(
      menuItem("Main", icon = icon("info"), tabName = "main"),
      
      menuItem("Density Functions", icon = icon("area-chart"), tabName = "graphs",
        menuSubItem("Offense", tabName = "offense"),
        menuSubItem("Defense", tabName = "defense"),
        menuSubItem("Other", tabName = "other")),
      
      menuItem("Boxplot", tabName = "statbox", icon=icon("line-chart"))

      )
    ),
  
  #Body
  dashboardBody(
      
    tabItems(
      tabItem(
        tabName = "main", strong("Please use the dashboard to begin."), br(),
        img(src='http://www.logodesignlove.com/wp-content/uploads/2011/04/nba-logo-on-wood.jpg')),
      
      tabItem(tabName = "offense",
              fluidPage(
                box(plotOutput("densityAT"), width=6),
                box(plotOutput("densityshotprop"), width=6),
                box(plotOutput("densityftpct"), width=6),
                box(plotOutput("densitypts"), width=6)
              )),
              
      tabItem(tabName = "defense",
              fluidPage(
              box(plotOutput("densitydrebs"), width=4),
              box(plotOutput("densitydrebs"), width=4),
              box(plotOutput("densityfouls"), width=4)
                  )),       
      
      tabItem(tabName = "other",
              fluidPage(
              box(plotOutput("densitypminus"),width=6),
              selectizeInput(inputId = 'year1',
                             label = 'Team 1 Year',
                             choices = t_df$y,
                             selected = 'None Selected')
              )),
      
      tabItem(tabName = "statbox",
              
              selectizeInput(inputId= 'stat1',
                             label = 'Please choose a statistic.',
                             choices = fltrs),
              checkboxInput(inputId = 'fcheck',
                            label = 'Facet by Year?',
                            value = FALSE),
              box(plotOutput("box1")))
              
      
    ) #tabItems close

    
  ) #dashboardBody close
)) #ShinyUI/dashboardPage Close

library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(
  
  #Header
  dashboardHeader(title = "Conference Finals Teams in the NBA Regular Season"),
  
  #Sidebar
  dashboardSidebar(
    
    sidebarUserPanel("Kai Chan",
                     image = "https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s100-c-k-no-rj-c0xffffff/photo.jpg"),
    sidebarMenu(
      menuItem("Main", icon = icon("info"), tabName = "main"),
      menuItem("Graphs", icon = icon("line-chart"), tabName = "graphs",
        menuSubItem("Offense", tabName = "offense"),
        menuSubItem("Defense", tabName = "defense"),
        menuSubItem("Other", tabName = "other"))
      )
    ),
  
  #Body
  dashboardBody(
    
      
    tabItems(
      tabItem
             (tabName = "main", "Welcome!"),
      
      tabItem(tabName = "offense",
              
              fluidRow(
                box(plotOutput("densityAT")),
                box(plotOutput("densityshotprop")),
                box(plotOutput("densityftpct")),
                box(plotOutput("densitypts"))
                
              )
      ),
      
      tabItem(tabName = "defense",
              plotOutput("densitydrebs"),
              plotOutput("densitydrebs"),
              plotOutput("densityfouls")),
      
      tabItem(tabName = "other",
              plotOutput("densitypminus"))
              
      
    ) #tabItems close
      
    
  ) #dashboardBody close
)) #ShinyUI/dashboardPage Close
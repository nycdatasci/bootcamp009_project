
library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = "EDA: NBA Regular Season"),
  dashboardSidebar(
    
    sidebarUserPanel("NYC DSA",
                     image = "https://yt3.ggpht.com/-04uuTMHfDz4/AAAAAAAAAAI/AAAAAAAAAAA/Kjeupp-eNNg/s100-c-k-no-rj-c0xffffff/photo.jpg"),
    sidebarMenu(
      menuItem("Main", text = 'Please select a graph in the submenu below.'),
      menuItem("Graphs", tabName = 'graphs'),
        menuSubItem("Assists to Turnover", tabName = 'atov'),
        menuSubItem("Field Goals to 3 Point Attempts", tabName = 'fg3p'),
        menuSubItem("Free Throw Percentage", tabName = 'freethrows'),
        menuSubItem("Average Points Scored", tabName = 'avg_pts'),
        menuSubItem("Average Defensive Rebounds", tabName = 'drebs'),
        menuSubItem("Plus Minus", tabName = 'pminus'),
        menuSubItem("Density Fouls", tabName = 'fouls')
    
    ),
  dashboardBody(
    tabItems(
      tabItem(tabName = 'atov',
              plotOutput('density_AT')),
      tabItem(tabName = 'fg3p',
              plotOutput('density_shotprop')),
      tabItem(tabName = 'freethrows',
              plotOutput('density_ftpct')),
      tabItem(tabName = 'avg_pts',
              plotOutput('density_pts')),
      tabItem(tabName = 'drebs',
              plotOutput('density_drebs')),
      tabItem(tabName = 'pminus',
              plotOutput('density_pminus')),
      tabItem(tabName = 'fouls',
              plotOutput('density_fouls'))
              
    )
  )
)))
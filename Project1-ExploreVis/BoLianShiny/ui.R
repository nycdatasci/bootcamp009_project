library(shiny)
library(shinydashboard)
# put some text words
dashboardPage(
  dashboardHeader(title = "Mental Health in Tech Survey"),
  dashboardSidebar(
    
    sidebarUserPanel("Bo lian",
                     image = "https://media.licdn.com/mpr/mpr/shrinknp_400_400/AAEAAQAAAAAAAAfmAAAAJGZiN2U1NzFkLTg4Y2MtNGE3MS1iZGVmLTM4ZjI5YTYwZjgxNw.jpg"),
    br(),
    
    sidebarMenu(
      menuItem("Surveyee Population", tabName = "population", icon = icon("globe")),
      br(),
      menuItem("Surveyee Age", tabName = "age", icon = icon("users")),
      br(),
      br(),
      br(),
      menuItem("Treatment: Mental Health", tabName = "treatment", icon = icon("user-md"))),
  
      br(),
    
    selectizeInput("selected",
                   "Select a Factor VS 
                    Mental Health",choices= choice1)),
  
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tabItems(
 
      tabItem(tabName = "population", 
             
            fluidRow(box(plotOutput("population"), height = 500),
                        box(plotOutput("US_state"), height = 500))

              ),
      
      tabItem(tabName = "age",
              fluidRow(box(plotOutput("age"), height = 500),
                       box(plotOutput("agebox"), height = 500) )
              ),
      
      tabItem(tabName = "treatment",
              fluidRow(infoBoxOutput("X_Square"),
                       infoBoxOutput("DF"),
                       infoBoxOutput("P_Value")),
              br(),
              fluidRow(box(plotOutput("comparison"),height = 430),
                           box(plotOutput("comparison1")) )
              
              )
      
    
    )
  )
)

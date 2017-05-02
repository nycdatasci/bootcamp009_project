## ui.R ##
library(shiny)
library(shinydashboard)

shinyUI(dashboardPage(
  dashboardHeader(title = "My Dashboard"),
  dashboardSidebar(
    
        sidebarUserPanel("NBA Shot Data",
        image = "https://cdn1.iconfinder.com/data/icons/smallicons-sport/32/basketball-512.png"),
        
        sidebarMenu(
          menuItem("Welcome", tabName = "mainpage", icon = icon("sign-in")),
          menuItem("Accuracy", tabName = "accuracy", icon = icon("bullseye"), 
                     menuSubItem('1-Variable', tabName = 'subItemOne', icon = icon("angle-right")),
                     menuSubItem('2-Variable', tabName = 'subItemTwo', icon = icon("angle-double-right"))
                   ),
          menuItem("Frequency", tabName = "freq", icon = icon("bar-chart"),
                     menuSubItem('1-Variable', tabName = 'subItemThree', icon = icon("angle-right")),
                     menuSubItem('2-Variable', tabName = 'subItemFour', icon = icon("angle-double-right"))
                   ),
          menuItem("Comparative", tabName = "comparative", icon = icon("line-chart")),
          menuItem("Expected Value", tabName = "ev", icon = icon("dollar")),
          menuItem("Top Shooters", tabName = "dataset", icon = icon("database"))
          )
        
  ),
  dashboardBody(
    
    tabItems(
      tabItem(tabName = "mainpage",
              h2("Select any tab to start learning"),
              imageOutput("mainpage"),
              textOutput("mainpage2")
      ),
      tabItem(tabName = 'subItemOne',
              h2('Accuracy, Select a Variable'),
              selectizeInput("selected1",
                             NULL,
                             items),
              imageOutput("subItemOne")
      ),
      tabItem(tabName = 'subItemTwo',
              h2('Accuracy, Select 2 Different Variables'),
              selectizeInput("selected2a",
                             NULL,
                             items),
              selectizeInput("selected2b",
                             NULL,
                             items,
                             selected = "CLOSE_DEF_DIST"),
              imageOutput("subItemTwo")
      ),
      tabItem(tabName = 'subItemThree',
              h2('Frequency, Select a Variable'),
              selectizeInput("selected3",
                             NULL,
                             items),
              imageOutput("subItemThree")
      ),
      tabItem(tabName = 'subItemFour',
              h2('Frequency, Select 2 Different Variables'),
              selectizeInput("selected4a",
                             NULL,
                             items),
              selectizeInput("selected4b",
                             NULL,
                             items,
                             selected = "CLOSE_DEF_DIST"),
              imageOutput("subItemFour")
      ),
      tabItem(tabName = "comparative",
              h2('Compare 2 Different Variables'),
              fluidRow(box(
              selectizeInput("selected6a",
                             "Select Independent Variable",
                             items)),
              box(
              selectizeInput("selected6b",
                             "Select Dependent Variable",
                             items,
                             selected = "CLOSE_DEF_DIST"))),
              plotOutput(outputId="comparative")
      ),
    tabItem(tabName = "ev",
            h2('Expected value vs. Shot Distance/Type'),
            imageOutput("ev")
    ),
      tabItem(tabName = "dataset",
              selectizeInput("selected7",
                             "Select a column",
                             items2),
              fluidRow(box(DT::dataTableOutput("table"), width =12))
              )
    
    )
  )
))
library(shinydashboard)

shinyUI(
  dashboardPage(
  dashboardHeader(title = "Lending  cloub Loan Default Data Visualization"),
  dashboardSidebar(sidebarUserPanel("Fu-Yuan Cheng",
                                    image = "https://i1.ruliweb.com/ori/16/12/08/158dc3659a62d6bd5.jpg"),
                    sidebarMenu(
                    menuItem("Map",  tabName = "map", icon = icon("map")),
                    menuItem("Data", tabName = "data", icon = icon("database")),
                    menuItem("Chart",  tabName = "chart", icon = icon("area-chart")))
                    ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "map",
        fluidRow(
          box(
            selectizeInput("year","Select Item to Display",choice_4)  
          )
        ),column(12, plotOutput("demograph"))
        ),
      tabItem(tabName = "data",
              fluidRow(box(DT::dataTableOutput("table"), width = 12))),
      tabItem(tabName = "chart",
              fluidRow(box(
                selectizeInput("select_con_1","Select Item to Display",choice_1)),
                      box(
                selectizeInput("select_dis_1","Select Item to Display",choice_2)  
                )
                ), 
              column(12, plotOutput("delay")))
      )
      )
    )
)

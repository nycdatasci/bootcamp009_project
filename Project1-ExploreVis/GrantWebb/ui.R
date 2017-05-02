library(shinydashboard)
imgURL <- "http://www.nanpa.org/wp-content/uploads/Meetup.png"

shinyUI(dashboardPage(
  dashboardHeader(title = "Shiny on Meetup"),
  dashboardSidebar(
    sidebarUserPanel("Grant Webb", image = imgURL),
    sidebarMenu(
      menuItem("Info", tabName = "Info", icon = icon("info")),
      menuItem("Distributions", tabName = "Distributions", icon = icon("bar-chart")),
      menuItem("ScatterPlots", tabName = "ScatterPlots", icon = icon("square")),
      menuItem("BarCharts", tabName = "BarCharts", icon = icon("meetup")),
      menuItem("Map", tabName = "Map", icon = icon("map"))
     
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName =  "Distributions",
              fluidRow(
                box(
                selectInput("selected","Select Group Feature to Display",choice,selected = "group_members", selectize = FALSE),
                selectInput("city_select","Select First City Choice",city_choice,selected = "New York City",selectize = FALSE),
                selectInput("city_select_2",
                            "Select Second City to Display",
                            city_choice1, selected = "Chicago",selectize = FALSE),
                selectInput("cat_select","Select Category Choice",cat_choice,selected = "tech", selectize = FALSE), width = 6),
                box(title = "T-Test:",solidHeader = TRUE,status = "info",
                  h2(textOutput("ttest")),
                  h2(textOutput("pvalue"))
                ), width = 6 ),

              fluidRow(
                infoBoxOutput("maxBox"),
                infoBoxOutput("minBox"),
                infoBoxOutput("avgBox")),
              fluidRow(
                box(
                plotOutput("histogram1"),width=6),
                box(
                plotOutput("histogram2"),width = 6)
              )
      ),
      tabItem(tabName = "Info",
              box(width = 10, status = "info", solidHeader = TRUE, title = "",
                  tags$iframe(src="https://www.youtube.com/embed/M4MqIdKJYdM",width="840", height="400", align="center"),
                  h1("MEET-UP"),
                  h2("We look down so often, phones in hand."),
                  h2("Let's look up, stand tall, and", tags$b("meet"), "someone."),
                  h3(tags$ul(tags$li("City (char)"),
                             tags$li("Category (char)"),
                             tags$li("Upcoming Meeting Price (int)"),
                             tags$li("Group Reviews (int)"),
                             tags$li("Group Members (int)"),
                             tags$li("Upcoming Meetings (int)"),
                             tags$li("Past Meetings (int)"),
                             tags$li("Upcoming Meeting RSVP (int)"),
                             tags$li("Length of Group Description (int)")))
                  )
              ),
      tabItem(tabName = "Map",
              fluidRow(
                box(
              leafletOutput("map", height = 800), width = 12))
      ),
      tabItem(tabName = "ScatterPlots",
              fluidRow(
                column(3,
                       wellPanel(
                         selectInput("cat_select2","Select Category Choice",cat_choice,selected = "All", selectize = FALSE),
                         selectInput("xvar", "X-axis variable", choice, selected = "group_reviews"),
                         selectInput("yvar", "Y-axis variable", choice, selected = "group_members"),
                         tags$small(paste0(
                           "Note: The parameters are logarithmic",
                           ""
                         ))
                       )
                ),
                column(9,
                       ggvisOutput("plot1"),
                       wellPanel(
                         span("Correlation:",
                              textOutput("corr")
                         )
                       )
                )
                )
      ),
      tabItem(tabName = "BarCharts",
              fluidRow(
                box(
                  plotOutput("barcharts", height = 700),width=12)
              ),
              selectInput("selected2","Select Group Feature to Display",choice,selected = "group_members", selectize = FALSE)
      )
    )
  )
))

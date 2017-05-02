
shinyUI(dashboardPage(
  dashboardHeader(title="My Shiny Dashboard"),
  dashboardSidebar(
    sidebarUserPanel("NEAL DRAKOS",
                     image= "http://cdn.newsapi.com.au/image/v1/external?url=http%3A%2F%2Fvideomam.news.com.au.s3.amazonaws.com%2Fgenerated%2Fprod%2F05%2F06%2F2015%2F29717%2Fimage1024x768.jpg%3Fcount%3D5&width=650&api_key=kq7wnrk4eun47vz9c5xuj3mc"),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("map")),
      menuItem("Graph", tabName = "graph", icon = icon("area-chart")),
      menuItem("Table", tabName = "scatter", icon = icon("tasks")))
  ),
  
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "map",
              h2("All reported Shark Attacks from 1900-2016"),
              fluidRow(box(htmlOutput('map'),
                           height=300))),
      
      tabItem(tabName= 'graph',

              fluidRow(box(plotOutput('graph'))),
              fluidRow(box(plotOutput('activity'))),
              fluidRow(box(plotOutput('Type_attack')))),
              
                      
      tabItem(tabName= "scatter",
              selectizeInput(inputId = 'attack_type',
                             label = 'Select the type of Attack',
                             choices),
              fluidRow(box(plotOutput("scatter_all"))))
      
  )
  )
)
)



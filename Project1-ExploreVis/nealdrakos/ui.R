
shinyUI(dashboardPage(
  dashboardHeader(title="My Shiny Dashboard"),
  dashboardSidebar(
    sidebarUserPanel("NEAL DRAKOS",
                     image= "http://cdn.newsapi.com.au/image/v1/external?url=http%3A%2F%2Fvideomam.news.com.au.s3.amazonaws.com%2Fgenerated%2Fprod%2F05%2F06%2F2015%2F29717%2Fimage1024x768.jpg%3Fcount%3D5&width=650&api_key=kq7wnrk4eun47vz9c5xuj3mc"),
    sidebarMenu(
      menuItem("Map", tabName = "map", icon = icon("globe")),
      menuItem("Class", tabName = "scatter", icon = icon("wheelchair")),
      menuItem("Graph", tabName = "graph", icon = icon("area-chart")),
      menuItem("Activity", tabName='outliers', icon = icon("anchor")))
  ),
    
  dashboardBody(
    tabItems( 
      tabItem(tabName = "map",
              h2("All reported Shark Attacks from 1900-2016"),
              fluidRow(htmlOutput('map'),
                           height=300),
              br(),
              fluidRow(plotOutput('graph'))),
              
      
      
      tabItem(tabName= "scatter",
              selectizeInput(inputId = 'attack_type',
                             label = 'Select the type of Attack',
                             choices),
              fluidRow(plotOutput("scatter_all")
              )),
      
      tabItem(tabName= 'graph',
              fluidRow(column(width=12),
                       column(width=12),
                       (plotOutput('activity'))),
              br(),
              br(),
              fluidRow((plotOutput('Type_attack')))),
      
              
      tabItem(tabName= 'outliers',
              fluidRow((plotOutput('Fatal_Activity'))),
              (textOutput("text1")),
              actionButton("go", label='Outliers')
              

    )
            
          
                     )
))
)









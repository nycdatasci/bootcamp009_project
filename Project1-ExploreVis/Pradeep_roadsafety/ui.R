shinyUI(
  dashboardPage(
    skin = 'green',
    dashboardHeader(title = 'NYC Accidents'),
    dashboardSidebar(
      sidebarMenu(
        id = 'sideBarMenu',
        menuItem("Road safety map1", tabName = "map1", icon = icon("map")),
        menuItem("Borough by year", tabName = "plot1")),
    
      conditionalPanel("input.sideBarMenu == 'map1'",
        selectizeInput('borough',
                       'Choose Your Borough',
                       choices = c(
                                   'Brooklyn' = 'BOROUGH == "BROOKLYN"',
                                   'Bronx' = 'BOROUGH == "BRONX"',
                                   'Queens' = 'BOROUGH == "QUEENS"',
                                   'Staten Island' = 'BOROUGH == "STATEN ISLAND"',
                                   'Manhattan' = 'BOROUGH == "MANHATTAN"')),
        selectizeInput('vehicle',
                        'commute',
                         choices = c('All' = 'commute != ""',
                                    'car' = 'commute == "CAR"',
                                    'cycle' = 'commute == "CYCLE"',
                                    'walk' = 'commute == "WALK"')),
                      
      radioButtons("time", "Time",
                                      c('All' = "TIME >= 00:00:00 & TIME <= 06:00:00",
                                        "12:00 am - 6:00 am" = "TIME >= '00:00:00' & TIME <= '06:00:00'",
                                        "6:00 am - 12:00 pm" = "TIME >= '06:00:00' & TIME <= '12:00:00'",
                                        "12:00 pm - 6:00 pm" = "TIME >= '12:00:00' & TIME <= '18:00:00'",
                                        "6:00 pm - 12:00 am" = "TIME >= '18:00:00' & TIME <= '23:59:59'"))

      ),
      conditionalPanel("input.sideBarMenu == 'plot1'",
                       selectizeInput('borough1',
                                      'Choose Your Borough',
                                      choices = c('All'='BOROUGH != ""',
                                        'Brooklyn' = 'BOROUGH == "BROOKLYN"',
                                        'Bronx' = 'BOROUGH == "BRONX"',
                                        'Queens' = 'BOROUGH == "QUEENS"',
                                        'Staten Island' = 'BOROUGH == "STATEN ISLAND"',
                                        'Manhattan' = 'BOROUGH == "MANHATTAN"'))
                       
      
      )),
      
    
      dashboardBody(tabItems(tabItem(
        tabName = "map1",
        fluidPage(
        fluidRow(box(
          leafletOutput("map1",
                        height = 650),
          width = 12)
        )
      )
      )),
      tabItem(
        tabName = "plot1",
        fluidPage(
        fluidRow(plotOutput("plot1", height = 600, width = 1000)),
            width = 300))
          ))
      )
     








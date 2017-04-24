


dashboardPage(skin="black",
  dashboardHeader(title = span(tagList(icon("fa-taxi",class="fa fa-taxi",lib = "font-awesome"), "  NYC Yellow Taxi")),
                  titleWidth = 400),
  # add drop down menu
  #                 # dropdownMenu(notificationItem(HTML("Data provided by NYC Taxi & Limousine Commission <br>  "), 
  #                 #                               icon = icon('question'), status = "info", 
  #                 #                               href = 'http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml'), 
  #                 #              badgeStatus = NULL, type = "notification",
  #                 #              icon = icon("question"))
  # ),

  dashboardSidebar(width = 400,
    sidebarMenu(
      menuItem("Taxi Revenue", tabName = "generalMap", icon = icon("fa-money ",class="fa fa-money",lib = "font-awesome")),
      menuItem("Time of a Day", tabName = "timeMap", icon = icon("fa-clock-o",class="fa fa-clock-o",lib = "font-awesome")),
      # menuItem("Fare Estimation", tabName = "fareEstimate", icon = icon("fa-bolt",class="fa fa-bolt",lib = "font-awesome")),
      menuItem("Data Source", tabName = "dataSource", icon = icon("fa-table",class="fa fa-table",lib = "font-awesome")),
      helpText("About Author",  align = "center"),
      menuItemOutput("lk_in"),
      menuItemOutput("blg")
    )
  ), 
  
  dashboardBody(
    tags$head(tags$style(HTML('/* logo */
                                .skin-black .main-header .logo {
                              font-weight: bold;
                              font-size: 25px;
                              background-color: #ffffff;
                              }
                              
                              /* logo when hovered */
                              .skin-black .main-header .logo:hover {
                              background-color: #ffffff;
                              }
                              
                              /* navbar (rest of the header) */
                              .skin-blue .main-header .navbar {
                              background-color: #fcfcd9;
                              } 
                              /* toggle button when hovered  */                    
                              .skin-blue .main-header .navbar .sidebar-toggle:hover{
                              background-color: #01665e;
                              }
                              
                              /* main sidebar */
                              .skin-black .main-sidebar {
                              font-weight: bold;
                              color: #f4a460; 
                              font-size: 20px;
                              background-color: #fccd6a;
                              }
                              
                              /* active selected tab in the sidebarmenu */
                              .skin-black .main-sidebar .sidebar .sidebar-menu .active a{
                              background-color: #01665e;
                              }
                              /* other links in the sidebarmenu when hovered */
                              .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                              background-color: #01665e;
                              }'))),
    
    tabItems(
        tabItem(tabName ="generalMap",
        leafletOutput("nhMap", height = 920)
               ),
        tabItem(tabName = "timeMap",
             leafletOutput("timeMap", height = 920),
             absolutePanel(

               id = "controls", class = "panel panel-default", fixed = TRUE,
                           draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                           width = 350, height = 200,style="padding-left: 8px; padding-right: 8px;",
                           
                           h2("Select Time",align = "center"),
                           selectizeInput(inputId = "time",
                                          label = "  Time of a Day: hr",
                                          choices = unique(timeData[,"pickup_datetime"]),
                                          selected = 8)
                          
                            
                            # tags$head( tags$style(type='text/css', "#time { width:100%; margin-left: 25px;}"),
                            # tags$style(HTML(".selectize-input.input-active, .selectize-input.input-active:hover, 
                            # .selectize-control.multi .selectize-input.focus {border-color: red !important;}
                            # .selectize-dropdown .active {background: yellow !important;}"))
                              #)
             ),
             htmlOutput("nhHistogram",height = 250)
            )
  )
)
)


  
#======================================= another output tab=============================================================

    #   tabPanel("Fare Estimation",
    #        leafletOutput("fareMap",width="100%", height="100%"),
    #        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
    #                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
    #                      width = 330, height = "auto",
    #                      
    #                      h2("Fare Estimator"),
    #                      textInput(inputId="pickUp", label = strong("Pickup: "),
    #                                value = "Time Square, New York City"),
    #                      textInput(inputId="dropOff", label = strong("Destination: "),
    #                                value="columbia university, New York City"),
    #                      selectizeInput(inputId="hr", label = strong("What Time ? "),
    #                                     choices = unique(timeData[,"pickup_datetime"]),
    #                                     selected = 10),
    #                      numericInput(inputId="passenger_count", label = strong("No. of Passenger(s):"),
    #                                   value = 1,step = 1),
    #                      actionButton("submit", "OK", class = "btn-primary")),
    # 
    #                     h3("Estimated Taxi Fare:"),
    #                     textOutput("total_payment"))
#     )
#   
#   )
# 
#   
# )
#   
  


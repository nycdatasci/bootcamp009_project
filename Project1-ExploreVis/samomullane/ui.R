shinyUI(dashboardPage(
  dashboardHeader(title = "Meteor Data Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Meteor Classes",
               tabName = "classes",
               icon = icon("bar-chart")),
      menuItem("Potential Impacts",
               tabName = "impacts",
               icon = icon("exclamation-triangle"))
      )
    ),
  dashboardBody(
    tabItems(
      #1) Class individual stats and info
      #2) Class total stats and info
      tabItem(tabName = "classes",
              #Choice of meteor class for information display
              #Can add wiki link (NASA or open) to the right of selection
              fluidPage(tabBox(id = "tabset1", width = 12,
                       tabPanel("Class descriptions and statistics",
                         fluidRow(
                           box(selectizeInput(inputId = "meteor_class", 
                                              label = "Meteor Class",
                                              #should arrange alphabetically eventually
                                              choices = meteor_descriptions$meteor_classes, 
                                              selected = 'APO'), width = 2, height = 75),
                           
                           #Class descriptions and prerendered image
                           box(htmlOutput("class_description"))),
                         
                         #Want characteristic plots of 'a' and 'q', and 'd' counts
                         fluidRow(box(plotlyOutput("characteristic_plot_a"),
                                    title = 'Semi-major axis (a)',
                                    status = 'primary',
                                    solidHeader = TRUE,
                                    width = 4, align = 'center'),
                                box(plotlyOutput("characteristic_plot_q"),
                                    title = 'Aphelion distance (q)',
                                    status = 'warning',
                                    solidHeader = TRUE,
                                    width = 4),
                                box(plotlyOutput("diameter_plot"),
                                    title = 'Diameter (d)',
                                    status = 'primary',
                                    solidHeader = TRUE,
                                    width = 4)),
                         fluidRow(box('The semi-major axis (a) is the longer 
                                      of the two radii that define
                                      an ellipse.',
                                      width = 4),
                                  box('The aphelion distance (q) is the point on 
                                      the orbit furthest from the Sun. The closer
                                      that the aphelion is to the semi-major axis,
                                      the more circular the orbit.',
                                      width = 4),
                                  box('The diameter (d) is an estimated quantity
                                      based on other more readily measureable
                                      parameters. Specifically, it is calculated
                                      from the albedo (a, reflectance) and absolute
                                      magnitude (H, intensity).',
                                      width = 4))
                       ),
                       
                       tabPanel("Population statistics",
                                fluidRow(
                                  box(plotlyOutput("total_diameter_plot"),
                                      title = 'Diameter-Count Statistics',
                                      status = 'primary',
                                      solidHeader = TRUE,
                                      width = 6),
                                  box(plotlyOutput("kepler_plot"),
                                      title = 'Kepler\'s Third Law',
                                      status = 'primary',
                                      solidHeader = TRUE,
                                      width = 6)
                                  ))
                       ))),
                         

      tabItem(tabName = "impacts",
              fluidPage(tabBox(id = "tabset1", width = 12,
                               tabPanel("Crater Application",
                                        fluidRow(
                                          box(leafletOutput("crater_map"), width = 12)
                                        ),
                                        fluidRow(
                                          box(selectizeInput(inputId = "target_material", 
                                                             label = "Target material",
                                                             choices = materials$name, 
                                                             selected = "soft rock"), width = 3, height = 75),
                                          box(selectizeInput(inputId = "meteor_material",
                                                             label = "Meteor material (g/cm^3)",
                                                             choices = impactor$name,
                                                             selected = "c-type (1.8)"), width = 3, height = 75),
                                          box(selectizeInput(inputId = "city",
                                                             label = "Impact city",
                                                             choices = city_dt$name,
                                                             selected = "New York"), width = 3, height = 75),
                                          box(selectizeInput(inputId = "crater_name",
                                                             label = "Meteor name",
                                                             choices = small_body_join$Object.Designation..,
                                                             selected = "1950 DA"), width = 3, height = 75)
                                          ),
                                        fluidRow(
                                          valueBoxOutput("valuebox1", width = 2),
                                          valueBoxOutput("valuebox2", width = 2),
                                          valueBoxOutput("valuebox3", width = 2),
                                          valueBoxOutput("valuebox4", width = 2),
                                          valueBoxOutput("valuebox5", width = 2),
                                          valueBoxOutput("valuebox6", width = 2)
                                          )
                                        ),
                               tabPanel("Potentially Hazardous Object Statitics",
                                        fluidRow(
                                          box("To be replaced with object statistics")
                                          )
                                        )
                               
                               )
              )
      )
    )
  )
))
shinyUI(dashboardPage(
  dashboardHeader(title = "Meteor Data Analysis"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview",
               tabName = "overview",
               icon = icon("info")),
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
      tabItem(tabName = "overview",
              fluidPage(tabBox(id = 'tabset5', width = 12,
                fluidRow(box("Will include introduction info")),
                fluidRow(box(plotlyOutput("all_class_orbits"))),
                fluidRow(box(plotlyOutput("total_diameter_plot"),
                               title = 'Diameter-Count Statistics',
                               status = 'primary',
                               solidHeader = TRUE,
                               width = 6),
                         box(plotlyOutput("kepler_plot"),
                               title = 'Kepler\'s Third Law',
                               status = 'primary',
                               solidHeader = TRUE,
                               width = 6)
                         )
              ))),
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
                                              choices = meteor_descriptions[order(meteor_classes),1], 
                                              selected = 'APO'), width = 2, height = 210),
                           
                           #Class descriptions
                           box(htmlOutput("class_description"),
                               h6('(from Wikipedia)'),
                               width = 7, height = 210),
                           #Orbit plot
                           box(plotlyOutput("single_class_orbits"),
                               width = 3, height = 210)
                         ),
                         
                         #Want characteristic plots of 'a' and 'q', and 'd' counts
                         fluidRow(box(plotlyOutput("characteristic_plot_a"),
                                    title = 'Semi-major axis (a)',
                                    status = 'primary',
                                    solidHeader = TRUE,
                                    width = 4, align = 'center'),
                                box(plotlyOutput("characteristic_plot_q"),
                                    title = 'Perihelion distance (q)',
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
                                  box('The perihelion distance (q) is the point on 
                                      the orbit closest to the Sun. The closer
                                      that the perihelion is to the semi-major axis,
                                      the more circular the orbit.',
                                      width = 4),
                                  box('The diameter (d) is an estimated quantity
                                      based on other more readily measureable
                                      parameters. Specifically, it is calculated
                                      from the albedo (a, reflectance) and absolute
                                      magnitude (H, intensity).',
                                      width = 4))
                       ),
                       tabPanel("Data and Information",
                                fluidRow(
                                  box(tags$div(
                                    tags$b("Selected data from all non-MBA objects"), 
                                    tags$br(),
                                    "Source: ", tags$html(
                                      tags$body(a('JPL Solar System Dynamics',
                                        href="https://ssd.jpl.nasa.gov/")))
                                  ), width = 12, align = 'center')
                                ),
                                fluidRow(
                                  column(12, dataTableOutput('small_body_dt'))
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
                                          box(plotlyOutput("hazard_a"), width = 4),
                                          box(plotlyOutput("hazard_q"), width = 4),
                                          box(plotlyOutput("hazard_d"), width = 4)
                                          ),
                                        fluidRow(box(plotlyOutput("hazard_prob"), width = 12))
                                        ),
                               tabPanel("Data and Information",
                                        fluidRow(
                                          box(tags$div(
                                            tags$b("Selected data from all potentially hazardous NEOs"), 
                                            tags$br(),
                                            "Source: ", tags$html(
                                              tags$body(a('JPL Sentry - Earth Impact Monitoring',
                                                          href="https://cneos.jpl.nasa.gov/sentry/")))
                                          ), width = 12, align = 'center')
                                        ),
                                        fluidRow(
                                          column(12, dataTableOutput('small_body_join'))
                                        ))
                               
                               )
              )
      )
    )
  )
))

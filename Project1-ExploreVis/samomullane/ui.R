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
                tabPanel("Base Information",
                               fluidRow(box(tags$div(
                                 'Meteors are mainly classified by the perihelion distance and
                                 semi-major axis of their orbit. As seen in the class-specific
                                 plots, these are artificial definitions which can lead to
                                 one-sided normal distributions of orbital parameters.',
                                 tags$br(),
                                 'Two distint datasets were used for this project:',
                                 tags$br(),
                                 tags$b('1. Small body object database'),
                                 tags$ul(
                                   tags$li('a) Contains info on all observed asteroids and 
                                           comets in the solar system'),
                                   tags$li('b) Focuses on orbital parameters and classification info')),
                                 tags$br(),
                                 tags$b('2. Sentry potential impact detection database'),
                                 tags$ul(
                                   tags$li('a) Contains info on only NEOs that could impact Earth'),
                                   tags$li('b) Does not have detailed orbit info'),
                                   tags$li('c) Provides info on probability of impact, velocity,
                                           estimated year range of impact')),
                                 'By combining these datasets, we gain an understanding of potential risk
                                 due to meteor impact. Included is an interactive application for plausible
                                 impacts that calculates potential crater depth and radius.'
                               ), width = 12)),
                
                fluidRow(box(imageOutput("orbital_parameters"), width = 8, height = 220),
                         box(plotlyOutput("inner_orbits"), width = 4, height = 220)),
                
                fluidRow(box(plotlyOutput("total_diameter_plot"),
                               title = tags$div(
                                 'Diameter of Meteor (km) v.', 
                                 tags$br(),
                                 'Observed Distance from Sun (AU, calculated)'),
                               status = 'primary',
                               solidHeader = TRUE,
                               width = 6),
                         box(plotlyOutput("kepler_plot"),
                               title = tags$div('Kepler\'s Third Law', tags$br(),
                                                'Orbital Period (y) v. Semi-Major Axis (AU)'),
                               status = 'primary',
                               solidHeader = TRUE,
                               width = 6)
                         )
                ),
                tabPanel("Meteor infographic",
                         fluidRow(box(h2("Infographic from the American Meteor Society"), width = 12, align = 'center')),
                         fluidRow(box(imageOutput("meteor_image"), width = 12, height = 1000))
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
                           box(tags$div(selectizeInput(inputId = "meteor_class", 
                                              label = "Meteor Class",
                                              #should arrange alphabetically eventually
                                              choices = meteor_descriptions[order(meteor_classes),1], 
                                              selected = 'APO'), 
                                        tags$b('Legend for orbit schematic'),
                                        tags$br(),
                                        tags$span(style="color:blue", 'Earth'),
                                        tags$br(),
                                        tags$span(style="color:red", 'Mars'),
                                        tags$br(),
                                        tags$span(style="color:purple", 'Jupiter')),
                           width = 2, height = 210),
                           
                           #Orbit plot
                           box(plotlyOutput("single_class_orbits"),
                               width = 3, height = 210),
                           
                           #Class descriptions
                           box(htmlOutput("class_description"),
                               h6('(from Wikipedia)'),
                               width = 7, height = 210)
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
                                                             selected = "New York"), width = 2, height = 75),
                                          box(selectizeInput(inputId = "crater_name",
                                                             label = "Meteor name",
                                                             choices = small_body_join$Object.Designation..,
                                                             selected = "1950 DA"), width = 2, height = 75),
                                          box(sliderInput(inputId = "theta_in",
                                                          label = "Angle of impact",
                                                          min = 10,
                                                          max = 90,
                                                          value = 90,
                                                          step = 5), width = 2, height = 75)
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

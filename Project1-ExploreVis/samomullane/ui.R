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
                         fluidRow(box(
                           selectizeInput(inputId = "meteor_class", 
                                      label = "Meteor Class",
                                      #should arrange alphabetically eventually
                                      choices = meteor_descriptions$meteor_classes, 
                                      selected = 'APO'), width = 2, height = 75)),
                         
                         #Equations of definition
                         #fluidRow(box(textOutput("class_definition"))),
                         
                         #Class descriptions and prerendered image
                         fluidRow(box(textOutput("class_description"),
                                      width = 4),
                                  box(htmlOutput(outputId="class_image"),
                                      width = 4),
                                  box(plotlyOutput("diameter_plot"),
                                      title = 'Count v. Diameter',
                                      status = 'primary',
                                      solidHeader = TRUE,
                                      width = 4)
                         ),
                         
                         #Want characteristic plots of 'a' and 'q'
                         fluidRow(box(plotlyOutput("characteristic_plot_a"),
                                    title = 'Semi-major axis (a)',
                                    status = 'primary',
                                    solidHeader = TRUE),
                                box(plotlyOutput("characteristic_plot_q"),
                                    title = 'Aphelion distance (q)',
                                    status = 'primary',
                                    solidHeader = TRUE)),
                         fluidRow(box('Will add description of a here',
                                      width = 6),
                                  box('Will add description of q here',
                                      width = 6))
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
                               tabPanel("Info on Potentially Dangerous Objects",
                                        fluidRow(
                                          box("To be replaced with object statistics")
                                          )
                                        ),
                               tabPanel("Crater Application",
                                        fluidRow(
                                          box(selectizeInput(inputId = "target_material", 
                                                             label = "Target material",
                                                             choices = materials$name, 
                                                             selected = "cold ice"), width = 4, height = 75),
                                          box(selectizeInput(inputId = "meteor_material",
                                                             label = "Meteor material",
                                                             choices = impactor$name,
                                                             selected = "c-type"))
                                          ),
                                        fluidRow(
                                          box(textOutput("crater"))
                                          )
                                        )
                               )
              )
      )
    )
  )
))

#shinyUI(fluidPage(
#  titlePanel("Meteor Data Analysis"),
#  sidebarLayout(
#    sidebarPanel(
      #selectizeInput(inputId = "plot_column", 
      #               label = "Column",
      #               choices = names(small_body_join)[sapply(small_body_join, is.numeric)],
      #               selected = 'e'),
      #sliderInput(inputId = "radius",
      #            label = "Threshold distance from Sun",
      #            min = 0.5,
      #            max = 10,
      #            value = 2),
      #sliderInput(inputId = "r_range",
      #            label = "Radial filter (range)",
      #            min = 0.5,
      #            max = 10,
      #            value = c(1.0, 2.0),
      #            step = 0.5)
#    ),
#    mainPanel(
#      tabsetPanel(
        #tabPanel("Plot",
          #htmlOutput("histogram1")
          #plotlyOutput("radialplot"),
          #plotlyOutput("heatplot")
          #plotlyOutput("cartesianplot")
#        tabPanel("Meteor Classes",
#                 "TBD"),
#        tabPanel("Potential Impacts",
#                 "TBD")
#        )
#      )
#  )
#))
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
      tabItem(tabName = "classes",
              #Choice of meteor class for information display
              fluidRow(selectizeInput(inputId = "meteor_class", 
                                      label = "Meteor Class",
                                      #should arrange alphabetically eventually
                                      choices = meteor_descriptions$meteor_classes, 
                                      selected = 'ATE')),
              
              #Equations of definition
              #fluidRow(box(textOutput("class_definition"))),
              
              #Want characteristic plots of 'a' and 'q'
              fluidRow(box(htmlOutput("characteristic_plot_a")),
                       box(htmlOutput("characteristic_plot_q"))),
              
              #Class descriptions and prerendered image
              fluidRow(box(textOutput("class_description")),
                       box(plotOutput("class_image"))
                       )
              ),
      tabItem(tabName = "impacts",
              "To be replaced with potential impact information, graphs, etc.")
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


shinyUI(pageWithSidebar(
  
  headerPanel(
              tags$div(
                tags$h4(
                  tags$a(href = "https://catalog.data.gov/dataset/consumer-complaint-database#topic=consumer_navigation", "Consumer Complaint Database")
                ),
                tags$h4(
                  tags$a(href = "https://cfpb.gov", "Consumer Financial Protection Bureau")
                  ))),
    sidebarPanel(
      width = 3,
      #### Map panel
      conditionalPanel(condition="input.conditionedPanels==1",
                       dateRangeInput('dateRange',
                                      label = 'Date range input: yyyy-mm-dd',
                                      start = min(complaints$Date.received), 
                                      end = max(complaints$Date.received)
                     ),
                       checkboxInput("normalize", "Normalize Map Counts by Population", value = FALSE),
                     #checkboxInput("normalize", "Normalize Map Counts by Total State Count", value = FALSE),
                       selectInput("map_var", "Choose a variable:",
                                   choices = complaint_vars,
                                   selected = complaint_vars[1]),
                       selectizeInput(
                         'dep_list', 'Items of interest', 
                         choices = "", 
                         multiple = TRUE
                       ),
                     fluidRow(
                        column(width = 4,
                          radioButtons("period", label = h3("Grouping Period"),
                                  choices = list("Daily" = 1, "Weekly" = 2, 
                                                 "Monthly" = 3, "Quarterly" = 4), 
                                  selected = 1)),
                        column(width = 4, offset = 2,
                          radioButtons("period_func", label = h3("Period Function"),
                                  choices = list("Mean" = "mean",
                                                 "Sum" = "sum", 
                                                 "Std" = "sd"), 
                                  selected = "mean"))
                     ),
                       plotOutput("ts_plot")
                       
                       
      ),
      ##### Bar plot panel
      conditionalPanel(condition="input.conditionedPanels==2",
                       selectInput("primary", "Choose a primary variable:",
                                   choices = complaint_vars),
                       # top n for primary variable
                       sliderInput("n1", "Top N counts for primary:",
                                   min=0, max=100, value=30),
                       selectInput("secondary", "Choose a secondary variable:",
                                   choices = complaint_vars),
                       # top n for secondary variable
                       sliderInput("n2", "Top N counts for secondary:",
                                   min=0, max=100, value=30),
                       checkboxInput("probs", "Show Probabilities", value = F),
                       checkboxInput("no_leg", "Suppress Legend", value = F),
                       dataTableOutput("df")
      ),
    ###### Mosaic panel
      conditionalPanel(condition="input.conditionedPanels==3",
                       selectInput("mosaic_var1", "Choose a variable:",
                                   choices = complaint_base,
                                   selected = complaint_base[1]),
                       selectizeInput('mosaic_list1', 'Possible values', 
                         choices = "", 
                         multiple = TRUE
                       ),
                       selectInput("mosaic_var2", "Choose a variable:",
                                   choices = complaint_base,
                                   selected = complaint_base[1]),
                       selectizeInput('mosaic_list2', 'Possible values', 
                         choices = "", 
                         multiple = TRUE
                       )
      ),
      ##### Wordcloud panel
      conditionalPanel(condition="input.conditionedPanels==4",
                       selectizeInput(
                         'wordcloud_var', 'Grouping variable', choices = complaint_vars,
                         selected = complaint_vars[1],
                         multiple = F
                       ),
                       
                       selectizeInput(
                         'wordcloud_dep_list', 'Specific Item(s)', choices = "",
                         multiple = T
                       ),
                      
                       actionButton("update", "Update Word Bubble"),
                       hr(),
                       sliderInput("freq",
                                   "Minimum Word Frequency:",
                                   min = 1,  max = 50, value = 15),
                       sliderInput("max",
                                   "Maximum Number of Words:",
                                   min = 1,  max = 300,  value = 100)
      )
    ),
    mainPanel(
        tabsetPanel(
          #### map tab
	        tabPanel("Map and Time Series", value = 1, 
                leafletOutput("usmap", width = "100%", height = 500),
                fluidRow(
                  column(width = 6, plotOutput("day_freq")),
                  column(width = 6, plotOutput("month_freq"))
                )
	    ),
	    ######## bar tab
	        tabPanel("Bar Plots", value = 2,
	                 plotOutput("bars", width = "100%", height = 800)
	    ),
	    ####### mosaic tab
	        tabPanel("Mosaic Plots", value = 3,
	             plotOutput("mosaic", width = "100%", height = 800)
	    ),
	    ###### wordcloud tab
	        tabPanel("Word Cloud", value = 4,
	             plotOutput("bubbles")
	    ),
	    id = "conditionedPanels"

                   )
            )
  )
)


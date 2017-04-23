

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
      #width = 3,
      conditionalPanel(condition="input.conditionedPanels==1",
                       dateRangeInput('dateRange',
                                      label = 'Date range input: yyyy-mm-dd',
                                      start = min(complaints$Date.received), 
                                      end = max(complaints$Date.received)
                       ),
                       checkboxInput("normalize", "Normalize Counts", value = FALSE),
                       selectInput("map_var", "Choose a variable:",
                                   choices = complaint_vars),
                       selectizeInput(
                         'dep_list', 'Items of interest', choices = var_list(), multiple = F
                       )
                       
      ),
      
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
  
      conditionalPanel(condition="input.conditionedPanels==4"
      ),
      
      conditionalPanel(condition="input.conditionedPanels==5",
                       selectizeInput(
                         'company_var', 'Company', choices = companies, multiple = F
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
	        tabPanel("map", value = 1, 
                leafletOutput("usmap", width = "100%", height = 500)
	    ),
	        tabPanel("bar_plots", value = 2,
	                 plotOutput("bars", width = "100%", height = 800)
	    ),
	    #     tabPanel("data_frame", value = 2,
	    #          dataTableOutput("df")
	    # ),
	        tabPanel("mosaic_plots", value = 4,
	             plotOutput("mosaics")
	    ),
	        tabPanel("word_counts", value = 5,
	             plotOutput("bubbles")
	    ),
	    id = "conditionedPanels"
            # tabPanel("plot",
            #     fluidRow(
            #         column(6, plotOutput("count")),
            #         column(6, plotOutput("delay"))
            #             )
            #         ),
            # tabPanel("dataset",
            #          dataTableOutput("old_faithful")
            #         )
                   )
            )
  )
)


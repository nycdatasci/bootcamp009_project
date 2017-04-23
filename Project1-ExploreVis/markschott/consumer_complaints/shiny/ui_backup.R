

fluidPage(
  titlePanel("Consumer Complaints concerning Financial Products and Services"),
  sidebarLayout(
    sidebarPanel(
         dateRangeInput('dateRange',
                         label = 'Date range input: yyyy-mm-dd',
                         start = min(complaints$Date.received), 
                         end = max(complaints$Date.received)
          ),
        checkboxInput("normalize", "Normalize Counts", value = FALSE),
        hr(),
        selectInput("bar_group", "Choose a variable:",
                    choices = complaint_vars),
        # Simple integer interval
        sliderInput("n", "Top N counts:",
                    min=0, max=100, value=30),
        selectInput("company_var", "Choose a company:",
                    choices = companies),
        selectizeInput(
          'company_var', 'Company', choices = state.name, multiple = TRUE
        ),
        actionButton("update", "Update Word Bubble"),
        hr(),
        sliderInput("freq",
                    "Minimum Word Frequency:",
                    min = 1,  max = 50, value = 15),
        sliderInput("max",
                    "Maximum Number of Words:",
                    min = 1,  max = 300,  value = 100)
    ),
    mainPanel(
        tabsetPanel(
	        tabPanel("map",
	           sliderInput("freq",
	                             "In a tab yes!!!!!:",
	                             min = 1,  max = 50, value = 15),
                leafletOutput("usmap")
	    ),
	    tabPanel("bar_plots",
	             plotOutput("bars")
	    ),
	    tabPanel("data_frame",
	             dataTableOutput("df")
	    ),
	    tabPanel("mosaic_plots",
	             plotOutput("mosaics")
	    ),
	    tabPanel("word_counts",
	             plotOutput("bubbles")
	    )
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


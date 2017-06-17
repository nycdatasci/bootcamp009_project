fluidPage(    
  
  # Give the page a title
  titlePanel("Visualize Power of Test"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
      sliderInput("N", "Number of Samples:", min=2000, 
                  max=10000, value=3000, step=500),
      sliderInput("p", "Probability:", min=0, 
                  max=1, value=0.2, step=0.05),
      selectInput("dmin", "dmin:", choices=c(0.01, 0.02, 0.03, 0.04, 0.05),
                  selected = 0.02),
      sliderInput("threshold", "Threshold:", min=0.01, 
                  max=0.1, value=0.05, step=0.01)
    ),
    
    # Create a spot for the barplot
    mainPanel(
      plotOutput("plot_power")  
    )
    
  )
)


library(DT)
library(ggplot2)
library(dplyr)
## server.R ##
shinyServer(function(input, output, session){
  output$controlPlot <- renderPlot({
    ggplot(data=data_1(), aes(x=x_var, y=y_var)) + geom_boxplot()
  })
  
  output$statePlot <- renderPlot({
    leaflet() %>% addPolygons(data=state_map_info(), fillColor='red') %>% 
      addCircles(lng=data_state_lng(), lat=data_state_lat(), color = 'green', popup='da')
  })
  
  data_1 <- reactive({
    if (input$deg_length=='4 year') {
      data %>% filter(SCH_DEG==3) %>%
        select(x_var=CONTROL_2, y_var=C150_4)
      
    } else {
      data %>% filter(SCH_DEG==2 | SCH_DEG==1) %>%
        select(x_var=CONTROL_2, y_var=C150_L4)
    }
  })
  
  data_state_lng <- reactive({
    data %>% filter(STATE==input$state_choice) %>% select(LONGITUDE)
  })
  
  data_state_lat <- reactive({
    data %>% filter(STATE==input$state_choice) %>% select(LATITUDE)
  })
  
  state_map_info <- reactive({
    state_name <- tolower(state.name[which(state.abb==input$state_choice)])
    map("state", region=state_name, plot=T, col=, fill = T)
  })
  
  
  
  
  # observe({
  #   updateSelectizeInput(
  #     session, inputId = "deg_length",
  #     choices = choice)
  # })
})



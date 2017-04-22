library(DT)
library(ggplot2)
library(ggvis)
library(leaflet)
library(dplyr)
## server.R ##
shinyServer(function(input, output, session){
  output$controlPlot <- renderPlot({
    ggplot(data=data_1(), aes(x=x_var, y=y_var)) + geom_violin()
  })
  
  output$graddensityPlot <- renderPlot({
    ggplot(data=data_1(), aes(x=y_var)) + geom_density() + xlim(0, 1)
  })
  
  output$statePlot <- renderLeaflet({
    leaflet() %>% addTiles() %>%
      addPolygons(data=state_map_info(), weight = 1) %>%
      addMarkers(data=state_school(), lng=~LONGITUDE, lat=~LATITUDE, 
                 clusterOptions = markerClusterOptions(),
                 popup=~ paste('<b><font color="Red">', INSTNM, '</font></b><br/>', 
                               'acceptance rate: ', ADM_RATE, '<br/>',
                               'undergrads: ', UGDS, '<br/>',
                               '4 year graduation rate: ', C150_4, '<br/>', 
                               'median earnings: ', MN_EARN_WNE_P7, '<br/>'))
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
  
  
  
  state_school <- reactive({
    data %>% filter(STABBR==input$state_choice)
  })
  
  region_school <- reactive({
    data %>% filter(REGION_2==input$region_choice)
  })
  
  data_scatter <- reactive({
    # Due to dplyr issue #318, we need temp variables for input values
    ugrads <- input$ugrads
    highest_deg <- input$highest_deg
    
    # Apply filters
    ds <- data %>%
      filter(
        UGDS >= ugrads
      ) %>%
      arrange(UNITID)
    
    if(highest_deg!='All') {
      ds <- ds %>% filter(HIGHDEG==highest_degree[[highest_deg]])
    }
    
    
    if(input$highest_deg == "all"){
      map("state", plot=F, fill = T)
    }else{
    }
    
    # Optional: filter by college name
    if (!is.null(input$collegeName) && input$collegeName != "") {
      college_name <- paste0(input$collegeName, "")
      ds <- ds[grep(pattern=input$collegeName, x=ds$INSTNM),]
    }

    ds <- as.data.frame(ds)
    
    # Add column which says whether the movie won any Oscars
    # Be a little careful in case we have a zero-row data frame
    ds
  })
  
  vis <- reactive({
    # Lables for axes
    xvar_name <- names(x_vars)[x_vars == input$xvar]
    yvar_name <- names(y_vars)[y_vars == input$yvar]
    
    # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
    # but since the inputs are strings, we need to do a little more work.
    xvar <- prop("x", as.symbol(input$xvar))
    yvar <- prop("y", as.symbol(input$yvar))
    
    data_scatter %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 50, size.hover := 200, stroke:='blue',
                   fillOpacity := 0.2, fillOpacity.hover := 0.5) %>%
      #add_tooltip(movie_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) %>%
      layer_smooths() %>%
      #add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
      scale_nominal("stroke", domain = c("Yes", "No"),
                    range = c("orange", "#aaa"))
  })
  
  vis %>% bind_shiny("plot1")
  
  
  state_map_info <- reactive({
    state_name <- tolower(state.name[which(state.abb==input$state_choice)])
    if(input$state_choice == "all"){
      map("state", plot=F, fill = T)
    }else{
      map("state", region=state_name, plot=F, col=, fill = T)
    }
  })
  
  output$table <- DT::renderDataTable({
    datatable(data=data, rownames=FALSE) 
  })
  
  
  
  # observe({
  #   updateSelectizeInput(
  #     session, inputId = "deg_length",
  #     choices = choice)
  # })
})
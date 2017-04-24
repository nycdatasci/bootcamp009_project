library(DT)
library(ggplot2)
library(ggvis)
library(leaflet)
library(dplyr)
## server.R ##
shinyServer(function(input, output, session){
  output$controlPlot <- renderPlot({
    ggplot(data=data_1(), aes(x=x_var, y=y_var)) + geom_violin() +
      labs(x='control', y='grad rate', title='Graduation Rates by Control')
  })
  
  output$graddensityPlot <- renderPlot({
    ggplot(data=data_1(), aes(x=y_var)) + stat_density(geom='line') + 
      labs(title='Density of Graduation Rates', x='graduation rate')
  })
  
  output$gradPlot <- renderPlot({
    ggplot(data=data_1(), aes(x=C150_L4)) + geom_density() 
  })
  
  output$blackdensityPlot <- renderPlot({
    g <- ggplot(data=data, aes(x=MN_EARN_WNE_P7))  + xlim(0, 1e5) +
      labs(title='Density of Mean Earnings', x='Earnings')
    if(input$filt!='None') {
      g <- g + stat_density(aes_string(color=filts[[input$filt]]), position='dodge', geom='line')
    }else {g <- g + stat_density(geom='line')}
    g
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
        select(x_var=CONTROL_2, y_var=C150_L4, HIGHDEG)
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
        UGDS >= ugrads[1],
        UGDS <= ugrads[2]
      ) %>%
      arrange(UNITID)
    
    if(highest_deg!='All') {
      ds <- ds %>% filter(HIGHDEG==highest_degree[[highest_deg]])
    }
    
    
    if(input$highest_deg == "all"){
      map("state", plot=F, fill = T)
    }else{
    }
    
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
    
    data_scatter <- data_scatter()[complete.cases(data_scatter()[,c(input$xvar,input$yvar)]),]
    
    #if(xvar_name=='ADM_RATE') data_scatter <- data_scatter %>% filter(ADM_RATE > 0)
    
    
    data_scatter %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 50, size.hover := 200, stroke:='blue',
                   fillOpacity := 0.2, fillOpacity.hover := 0.5, 
                   key := ~UNITID) %>%
      add_tooltip(college_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) %>%
      layer_smooths()
      #add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
      #scale_nominal("stroke", domain = c("Yes", "No"),
                    #range = c("orange", "#aaa")
    
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
    datatable(data=data %>% select(college=INSTNM, state=STABBR, undergrads=UGDS, 
                                   median_income=MN_EARN_WNE_P7,
                                   grad_rate_4yr=C150_4, grad_rate_2yr=C150_L4), rownames=F) 
  })
  
  data_comp <- reactive({
    college <- input$col_comp
    
    if(nchar(college)>0) {
      five_data <- filter(data, INSTNM==college) %>% select(TUITIONFEE_IN, ADM_RATE, REGION_2, STABBR, HIGHDEG)
      d <- data %>% filter(abs(TUITIONFEE_IN-five_data[1,1])<1e4, 
                    abs(ADM_RATE-five_data[1,2])<.1, 
                    REGION_2==five_data[1,3],
                    HIGHDEG==five_data[1,5]) %>% 
        select(college=INSTNM, state=STABBR, control=CONTROL_2, tuition=TUITIONFEE_IN,
               median_fam_income=FAMINC,
               undergrads=UGDS, admit_rate=ADM_RATE, high_deg=HIGHDEG, pct_pell=PCTPELL, 
               median_grad_income=MN_EARN_WNE_P7, grad_rate_4yr=C150_4, grad_rate_2yr=C150_L4)
      if(as.logical(input$state)){
        d <- d %>% filter(state==five_data[1,4])
      }
    }else {d <- select(data, college=INSTNM, state=STABBR, control=CONTROL_2, tuition=TUITIONFEE_IN,
                       undergrads=UGDS, admit_rate=ADM_RATE, pct_pell=PCTPELL, 
                       median_income=MN_EARN_WNE_P7, grad_rate_4yr=C150_4, grad_rate_2yr=C150_L4)
    }
    d
  })
  
  output$comp <- DT::renderDataTable({
    datatable(data=data_comp(), rownames = F)
    
  })
  
  college_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$UNITID)) return(NULL)
    
    # Pick out the college with this ID
    all_colleges <- isolate(data_scatter())
    college <- all_colleges[all_colleges$UNITID == x$UNITID, ]
    
    paste0("<b>", college$INSTNM, "</b><br>",
           'undergrads: ', college$UGDS, "<br>"
    )
  }
  
  
  
  # observe({
  #   updateSelectizeInput(
  #     session, inputId = "deg_length",
  #     choices = choice)
  # })
})
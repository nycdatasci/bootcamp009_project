library(shiny)
library(DT)
library(googleVis)

shinyServer(function(input, output){
  # show map using googleVis
  output$map <- renderGvis({
    gvisGeoChart(state_stat, "state.name", input$selected,
                 options=list(region="US", displayMode="regions", 
                              resolution="provinces",
                              width="auto", height="auto",title=input$selected))
    # using width="auto" and height="auto" to
    # automatically adjust the map size
  })
  # show histogram using googleVis
  output$hist <- renderGvis(
    gvisHistogram(loan[,input$selected, drop=FALSE],
                  options=list(legend='top',title='Histogram, across all regions')))
  
  output$bar <- renderGvis(
    gvisBarChart(data=state_stat,xvar="state.name",yvar=input$selected,
                 options=list(legend='top',title='Bar chart, grouped by region')))
  
  output$gradebar <- renderGvis(
    gvisBarChart(data=loangroupbygrade,xvar="grade",yvar=input$selected,
                 options=list(legend='top',title='Bar chart, grouped by grade')))
  
  # show data using DataTable
  output$table <- DT::renderDataTable({
    datatable(loan, rownames=FALSE) %>% 
      formatStyle(input$selected,  
                  background="skyblue", fontWeight='bold')
    
    # Highlight selected column using formatStyle
  })
  
  # show statistics using infoBox
  output$Box1 <- renderInfoBox({
    #value1 <- sum(loan[,input$selected]*loan[,"loan_amnt"])/totalloanbal
    max_value <- max(state_stat[,input$selected],na.rm=T)
    max_state <- state_stat$state.name[state_stat[,input$selected]==max_value]
    infoBox(max_state, max_value, icon = icon("hand-o-up"))
  })
  output$minBox <- renderInfoBox({
    min_value <- min(state_stat[,input$selected],na.rm=T)
    min_state <- 
      state_stat$state.name[state_stat[,input$selected]==min_value]
    infoBox(min_state, min_value, icon = icon("hand-o-down"))
  })
  output$avgBox <- renderInfoBox(
    infoBox("Average",
            round(mean(state_stat[,input$selected],na.rm=T),2), 
            icon = icon("calculator"), fill = TRUE))
  
  output$medianBox <- renderInfoBox(
    infoBox("Median",
            median(state_stat[,input$selected],na.rm=T), 
            icon = icon("calculator"), fill = TRUE))
  
  output$stdevBox <- renderInfoBox(
    infoBox("StandDev.",
            round(sd(state_stat[,input$selected],na.rm=T),2), 
            icon = icon("calculator"), fill = TRUE))
  
  output$downloadData <- downloadHandler(
    filename = 'lendingclubloandata.csv' ,
    content = function(file) {
      write.csv(state_stat, file)
    }
  )
  
})
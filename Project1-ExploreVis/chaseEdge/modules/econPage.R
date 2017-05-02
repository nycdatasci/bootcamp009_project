econPageUI <- function(id){
  ns <- NS(id)
  
  fluidPage({
    fluidRow(
      column(3,
        selectizeInput(ns('statistic'), 'Econ Statistic',
                       choices=unique(econData$stat),
                       selected='GDP per capita (current US$)',
                       multiple=F),
        numericInput(ns('statYear'), 'Statistic Year',
                     value = 2015, min = 1997, max = 2016),
        numericInput(ns('eventYear'), 'Event Year',
                     value = 2016, min = 1997, max = 2016)
      ),
      column(7, offset = 1,
        plotlyOutput(ns('scatter'))
      )
    )
  })
}

econPage <- function(input,output,session) {
  ns <- session$ns
  
  statYear <- reactive({input$statYear})
  eventYear <- reactive({input$eventYear})
  
  stat <- reactive({
    x <- econData[stat==input$statistic,c('country',statYear())]
    colnames(x) = c('country','stat')
    x$stat = as.numeric(x$stat)
    x
  })
  
  events <- reactive({
    africa[year==eventYear(),.N, by=country]
  })
  
  filteredData <- reactive({
    merge(events(), stat(), by='country')
  })
  
  output$scatter <- renderPlotly({
    x = filteredData()
    ggplotly(
      ggplot(data=x, aes(x=x$stat, y=x$N, color=x$country)) + 
        geom_point() + theme(legend.position = 'none') + 
        labs( x = input$statistic, y= 'Incidents', color= 'country')
    )
  })
  
  
}
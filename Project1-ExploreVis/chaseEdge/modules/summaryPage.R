summaryPageUI <- function(id) {
  ns <- NS(id)
  fluidPage(
    tabsetPanel(
      tabPanel("Events by Country", 
               sidebarLayout(
                 sidebarPanel(numericInput(ns('year1'), 'Year', value = 2016, min = 1997, max = 2016)),
                 mainPanel(plotOutput(ns("countryChart")))
               )),
      tabPanel("Events by Group", 
               sidebarLayout(
                 sidebarPanel(
                   numericInput(ns('year2'), 'Year', value = 2016, min = 1997, max = 2016),
                   selectizeInput(ns('countries'), 'Country',
                                choices = c('',allCountries),
                                selected = '',
                                multiple = F),
                   br(),
                   checkboxGroupInput(ns('events'), 'Types of Event',
                                choices = allEvents,
                                selected = allEvents)
                   ),
                 mainPanel(plotOutput(ns("actorChart")))
               )),         
      tabPanel("Total Events",
               fluidRow(
                 column(width=1,
                        checkboxInput(ns('deaths'),'# of Deaths')),
                column(width=10,offset=1,
                       plotlyOutput(ns('lineChart'), width="95%")))
        )
      )
    )
}

summaryPage <-  function(input, output, session) {
  events <- reactive({input$events})
  
  country <- reactive({ 
    if(input$countries == '') {
      x = allCountries
    }else
      x = input$countries
    return(x)
  })
  
  
  observe({print(length(input$countries))})
  
  filteredActor <- reactive({ africa[year==input$year2 & 
                                       country %in% country() & 
                                       event_type %in% events(),
                                     .(Incidents=.N), by=actor1][order(-Incidents)][1:10] })
  
  filteredEvents <- reactive({
    africa[event_type %in% events(),.(Incidents=.N, Deaths=sum(fatalities)),by=.(year,event_type)][order(-year)]
  })
  
  
  filteredCountries <- reactive({
    x = africa[year==input$year1,.(Total=.N),by=country][order(-Total)][1:10]
    y = africa[year==input$year1,.N,by=.(country,event_type)]
  
    # return the events for the top ten countries
    y[country %in% unique(x$country)]
    
  })
  
  
  output$countryChart <- renderPlot({
    filteredCountries() %>% 
    ggplot(aes(x = country, y = N, fill = event_type)) + 
      geom_col() + coord_flip() + theme(legend.position = 'bottom')
      
  })
  
  output$lineChart <- renderPlotly({
    x = africa[,.(Incidents=.N, Deaths=sum(fatalities)),by=.(year,event_type)][order(-year)] 
    if(input$deaths){
    plot_ly(x, x = ~year, y = ~Deaths, color = ~event_type) %>%
      add_lines() %>% 
      layout(title = 'Armed Conflicts in Africa by Type',
             yaxis = list (title = 'Number of Deaths'),
             legend = list(x = 0.1, y = 0.9))
    } else {
      plot_ly(x, x = ~year, y = ~Incidents, color = ~event_type) %>%
        add_lines() %>% 
        layout(title = 'Armed Conflicts in Africa by Type',
               yaxis = list (title = 'Number of Incidents'),
               legend = list(x = 0.1, y = 0.9))
    }
      
  })
  
  output$actorChart <- renderPlot({
    filteredActor() %>% 
      ggplot(aes(x = actor1, y = Incidents, fill = actor1)) + 
      geom_col() + coord_flip() + theme(legend.position = 'None')
    
  })
  
  
}
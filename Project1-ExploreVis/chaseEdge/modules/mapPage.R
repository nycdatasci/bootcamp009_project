mapPageUI <- function(id){
  ns <- NS(id)
  
  fluidPage({
    sidebarLayout(
      sidebarPanel(
        select2Input(ns('countries'), 'Country',
                       choices = c('',allCountries),
                       selected = allCountries[1],
                       multiple = T),
        select2Input(ns('events'), 'Types of Event',
                     choices = allEvents,
                     selected = "Battles",
                     multiple = T
        ),
        selectizeInput(ns('groups'), 'Militant Groups',
                     choices = allActors,
                     selected = "",
                     multiple = T
        ),
        numericInput(ns('year'), 'Year',
                     value = 2016,
                     min = 1997,
                     max = 2016
                     ),
        checkboxInput(ns('fatalitiesFlag'), 'Fatal conflicts only',
                      value = F)
      ),
      mainPanel(
        tabsetPanel(
          tabPanel("Map", leafletOutput(ns('countriesMap'), height=600)),
          tabPanel('Ethnicities', tags$img(src='http://media2.policymic.com/ad3ae1bb14f217f36d74193f02b7813f.png', width='100%')),
          tabPanel("Data", dataTableOutput(ns('details')))
        )
        )
      )
  })
}

mapPage <- function(input,output,session) {
  ns <- session$ns

  year <- reactive({input$year})
  
  country <- reactive({
    if(length(input$countries)==0){
      return(allCountries)
    } else{input$countries} 
    
    })
  
  events <- reactive({
    if(length(input$events)==0){
      return(allEvents)
    } else{input$events} 
    
  })
  
  groups <- reactive({
    if(length(input$groups)==0) {
      return(allActors)
    } else { input$groups }
  })
  
  
  filteredData <- reactive({
    
    x = africa[year==year()]
    x = x[country %in% country()]
    x = x[event_type %in% events()]
    x = x[actor1 %in% groups()]
    if(input$fatalitiesFlag){
      x[fatalities > 0]
    }
    x
  })
  
  
  output$countriesMap <- renderLeaflet({
    leaflet(data = africa[year==2016 & country=='Algeria'], options = leafletOptions(minZoom=3)) %>%
      addProviderTiles('Esri.WorldImagery') %>% 
      addProviderTiles('Stamen.TonerLines') %>%
      addProviderTiles('Stamen.TonerLabels') %>% 
      setView(lng = 16.96, lat = 1.46 , zoom = 3) %>% 
      addMarkers(lng = ~longitude, lat = ~latitude, clusterOptions = markerClusterOptions())
  })
  
  observe({
    proxy <- leafletProxy(ns("countriesMap"), data=filteredData())
    proxy %>%
      clearMarkerClusters() %>%
      addMarkers(lng = ~longitude, lat = ~latitude, clusterOptions = markerClusterOptions())
  })
  
  output$details <-  renderDataTable(options = list(pageLength=5),{
    filteredData()[,.('Number of Incidents'=.N,Deaths=sum(fatalities)),by=.(country,event_type,actor1)][order(-Deaths)]
  })
  
}
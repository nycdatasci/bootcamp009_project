homePageUI <- function(id) {
  ns <- NS(id)
  tags$div(
    fluidRow(
      column(4, offset=1,
             sliderInput(ns("year"), NULL, 1997, 2017, 1, step = 1, sep = "",
                         animate=animationOptions(interval=500, loop=TRUE))
      ),
      column(4, offset=1,
             tableOutput(ns('details'))
             )
    ),
    fluidRow(
    leafletOutput(ns("heatmap"), height="550", width="100%")
  )
  )
}


homePage <- function(input, output, session) {
  ns <- session$ns
  filteredData = reactive({ africa[year==input$year] })
  filteredTotals = reactive({filteredData()[, .(.N, deaths=sum(fatalities))]})
  
  output$heatmap <- renderLeaflet({
    leaflet(options = leafletOptions(minZoom=3)) %>%
      addProviderTiles('Esri.WorldImagery') %>% 
      addProviderTiles('Stamen.TonerLines') %>%
      addProviderTiles('Stamen.TonerLabels') %>% 
      setView(lng = 16.96, lat = 1.46 , zoom = 3) 
  })
  
  output$details <- renderTable(digits=0,{
    data.frame('Total Events' = filteredTotals()$N,
               'Total Deaths' = filteredTotals()$deaths)
  })
  
  observe({
    proxy <- leafletProxy(ns("heatmap"), data = filteredData())
    proxy %>%
      clearHeatmap() %>%
      addHeatmap(
        lng = ~longitude, lat = ~latitude,
        blur = 20, max = 0.05, radius = 15)
  })
}



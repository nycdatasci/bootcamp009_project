library(shiny)
library(shinyjs)
library(shinysky)

source('global.R')

menu <- (
  navbarPage(
    useShinyjs(debug = TRUE),
    "Conflict in Africa",
      tabPanel("Home",homePageUI('home')),
      tabPanel("Summary", summaryPageUI('summary')),
      tabPanel("Maps", mapPageUI('map')),
      tabPanel("Econ", econPageUI('econ'))
  )
)



# Creat output for our router in main UI of Shiny app.
ui <- shinyUI(
  tagList(
    bootstrapPage(
      theme="style.css",
      menu
    )
  )
)



server <- shinyServer(function(input, output, session) {
  callModule(homePage, 'home')
  callModule(summaryPage, 'summary')
  callModule(mapPage, 'map')
  callModule(econPage, 'econ')
})


shinyApp(ui, server)

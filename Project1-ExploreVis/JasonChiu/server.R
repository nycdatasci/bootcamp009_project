library(shiny)
library(shinydashboard)

server <- function(input, output) {
  varbox <- reactive(
    switch(input$`y-value`,
           "Healthcare Access" = 42,
           "Routine Doctor Checkup" = 16,
           "Cholesterol Screening" = 17,
           "Colorectal Cancer Screening" = 18,
           "Preventative Care among Elderly (Men)" = 19,
           "Preventative Care among Elderly (Women)" = 20,
           "Breast Cancer Screening" = 23,
           "Cervical Cancer Screening" = 26,
           "Binge Drinking" = 14,
           "Smoking" = 21,
           "No Exercise" = 22,
           "Obesity" = 24,
           "Insufficient Sleep" = 25)
  )
  
  output$boxplot <- renderPlot(
    ggplot(data = graph_hosp, aes(x = factor(graph_hosp$overall_f), y = graph_hosp[,varbox()])) +
      geom_boxplot() +
      ggtitle(paste(input$`y-value`,"by Hospital Quality Rating")) +
      xlab("Hospital Overall Quality Rating") + ylab(notes_list[match(input$`y-value`,name_list)]) +
      guides(fill=FALSE) + theme_few()
  )
  
  output$boxplot_by_owner <- renderPlot(
    ggplot(data = graph_hosp, aes(x = factor(graph_hosp$overall_f), y = graph_hosp[,varbox()])) +
      geom_boxplot() +
      ggtitle("By Ownership Type") +
      xlab("Hospital Overall Quality Rating") + ylab(notes_list[match(input$`y-value`,name_list)]) +
      facet_grid(.~hosp_owner_tri) + guides(fill=FALSE) + theme_few()
  )
  
  mapdata <- reactive({
    df <- exclude %>% filter(hcoverage >= input$insurance,
                             CHECKUP_city >= input$checkup,
                             CHOLSCREEN_city >= input$chol,
                             COREM_city >= input$elderly,
                             COREW_city >= input$elderlyf,
                             MAMMOUSE_city >= input$breast,
                             PAPTEST_city >= input$cervical,
                             mean_star %in% input$checkGroup)
  })
  
  output$number <- renderText(paste(input$checkGroup[1], "HOW MANY?"))
  
  output$map <- renderLeaflet(
    leaflet(data = mapdata()) %>%
      addProviderTiles("Esri.WorldGrayCanvas") %>%  # Add default OpenStreetMap map tiles
      addCircleMarkers(lng = mapdata()$long, lat = mapdata()$lati, label = mapdata()$PlaceName,
                       radius = mapdata()$count_hosp, color = ifelse(mapdata()$mean_star==5,"Blue",ifelse(mapdata()$mean_star==4,"Green",ifelse(mapdata()$mean_star==3,"Gold",ifelse(mapdata()$mean_star==2,"Orange","Red")))))
  )
}


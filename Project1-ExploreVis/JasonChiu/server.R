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
           "Insufficient Sleep" = 25,
           "High Bloodpressure Prevalence" = 27,
           "Cancer Prevalence" = 28,
           "Asthma Prevalence" = 29,
           "Coronary Heart Disease Prevalence" = 30,
           "Chronic Obstructive Pulmonary Disease Prevalence" = 31,
           "Diabetes Prevalence" = 32, 
           "High Cholesterol" = 33,
           "Mental Health Condition Prevalence" = 34,
           "Stroke Prevalence" = 35)
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
    df <- switch(input$graph_v,
                 "Mean" = exclude %>% filter(hcoverage >= input$insurance,
                                             CHECKUP_city >= input$checkup,
                                             CHOLSCREEN_city >= input$chol,
                                             COREM_city >= input$elderly,
                                             COREW_city >= input$elderlyf,
                                             mean_star %in% input$checkGroup),
                 "Median" = exclude %>% filter(hcoverage >= input$insurance,
                                               CHECKUP_city >= input$checkup,
                                               CHOLSCREEN_city >= input$chol,
                                               COREM_city >= input$elderly,
                                               COREW_city >= input$elderlyf,
                                               median_star %in% input$checkGroup))
  })
  
  mvalue <- reactive({
    switch(input$graph_v,
           "Mean" = "mean_star",
           "Median" = "median_star")
  })
  
  output$map <- renderLeaflet(
    leaflet(data = mapdata()) %>%
      addProviderTiles("Esri.WorldGrayCanvas") %>%  # Add default OpenStreetMap map tiles
      addCircleMarkers(lng = mapdata()$long, lat = mapdata()$lati, label = mapdata()$PlaceName,
                       radius = mapdata()$count_hosp, color = ifelse(mapdata()[,mvalue()]==5,"Blue",ifelse(mapdata()[,mvalue()]==4,"Green",ifelse(mapdata()[,mvalue()]==3,"Gold",ifelse(mapdata()[,mvalue()]==2,"Orange","Red")))))
  )
  
  mvalue1 <- reactive({
    switch(input$graph_v1,
           "Mean" = "mean_star",
           "Median" = "median_star")
  })
  
  mapdata_h <- reactive({
    df <- switch(input$graph_v1,
                 "Mean" = exclude %>% filter(BINGE_city >= input$binge,
                                             CSMOKING_city>= input$smoking,
                                             LPA_city >= input$exercise,
                                             SLEEP_city >= input$sleep,
                                             OBESITY_city >= input$obesity,
                                             mean_star %in% input$checkGroup1),
                 "Median" = exclude %>% filter(BINGE_city >= input$binge,
                                               CSMOKING_city>= input$smoking,
                                               LPA_city >= input$exercise,
                                               SLEEP_city >= input$sleep,
                                               OBESITY_city >= input$obesity,
                                               median_star %in% input$checkGroup1))
  })
  
  output$map_h <- renderLeaflet(
    leaflet(data = mapdata_h()) %>%
      addProviderTiles("Esri.WorldGrayCanvas") %>%  # Add default OpenStreetMap map tiles
      addCircleMarkers(lng = mapdata_h()$long, lat = mapdata_h()$lati, label = mapdata_h()$PlaceName,
                       radius = mapdata_h()$count_hosp,
                       color = ifelse(mapdata_h()[,mvalue1()]==5,"Blue",ifelse(mapdata_h()[,mvalue1()]==4,"Green",ifelse(mapdata_h()[,mvalue1()]==3,"Gold",ifelse(mapdata_h()[,mvalue1()]==2,"Orange","Red")))))
  )
  
  mvalue2 <- reactive({
    switch(input$graph_v2,
           "Mean" = "mean_star",
           "Median" = "median_star")})
  
  mapdata_d <- reactive({
    df <- switch(input$graph_v2,
                 "Mean" = exclude %>% filter(BPHIGH_city >= input$hbp,
                                             CANCER_city >= input$cancer,
                                             CASTHMA_city >= input$asthma,
                                             CHD_city >= input$chd,
                                             COPD_city >= input$copd,
                                             DIABETES_city >= input$dia,
                                             HIGHICHOL_city >= input$hc,
                                             MHLTH_city >= input$mh,
                                             STROKE_city >= input$stk,
                                             mean_star %in% input$checkGroup2),
                 "Median" = exclude %>% filter(BPHIGH_city >= input$hbp,
                                               CANCER_city >= input$cancer,
                                               CASTHMA_city >= input$asthma,
                                               CHD_city >= input$chd,
                                               COPD_city >= input$copd,
                                               DIABETES_city >= input$dia,
                                               HIGHICHOL_city >= input$hc,
                                               MHLTH_city >= input$mh,
                                               STROKE_city >= input$stk,
                                               median_star %in% input$checkGroup2))
  })
  
  output$map_d <- renderLeaflet(
    leaflet(data = mapdata_d()) %>%
      addProviderTiles("Esri.WorldGrayCanvas") %>%  # Add default OpenStreetMap map tiles
      addCircleMarkers(lng = mapdata_d()$long, lat = mapdata_d()$lati, label = mapdata_d()$PlaceName,
                       radius = mapdata_d()$count_hosp,
                       color = ifelse(mapdata_d()[,mvalue2()]==5,"Blue",ifelse(mapdata_d()[,mvalue2()]==4,"Green",ifelse(mapdata_d()[,mvalue2()]==3,"Gold",ifelse(mapdata_d()[,mvalue2()]==2,"Orange","Red")))))
  )
  
}


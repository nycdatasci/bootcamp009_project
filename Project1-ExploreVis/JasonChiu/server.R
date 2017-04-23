library(shiny)
library(shinydashboard)

server <- function(input, output) {
  mapdata <- reactive({
    df <- switch(input$type,
                 "Health Behavior" = exclude %>% filter(BINGE_city >= input$binge,
                                                        CSMOKING_city>= input$smoking,
                                                        LPA_city >= input$exercise,
                                                        SLEEP_city >= input$sleep,
                                                        OBESITY_city >= input$obesity),
                 "Disease Prevalence" = exclude %>% filter(BPHIGH_city >= input$hbp,
                                                           CANCER_city >= input$cancer,
                                                           CASTHMA_city >= input$asthma,
                                                           CHD_city >= input$chd,
                                                           COPD_city >= input$copd,
                                                           DIABETES_city >= input$dia,
                                                           HIGHCHOL_city >= input$hc,
                                                           MHLTH_city >= input$mh,
                                                           STROKE_city >= input$stk),
                 "Preventative Care" = exclude %>% filter(hcoverage_city >= input$insurance,
                                                          CHECKUP_city >= input$checkup,
                                                          CHOLSCREEN_city >= input$chol,
                                                          COREM_city >= input$elderly,
                                                          COREW_city >= input$elderlyf,
                                                          MAMMOUSE_city >= input$breast,
                                                          PAPTEST_city >= input$cervical))
  })
  
  mapdata_final <- reactive({
    df <- switch(input$mm,
                 "Mean" = mapdata() %>% filter(mean_rating %in% input$checkGroup),
                 "Median" = mapdata() %>% filter(median_rating %in% input$checkGroup))
  })
  
  var_name <- reactive({
    switch(input$mm,
           "Mean" = "mean_rating",
           "Median" = "median_rating")
  })
  
  output$map <- renderLeaflet(
    leaflet(data = mapdata_final()) %>%
      addProviderTiles("Esri.WorldGrayCanvas") %>%  # Add default OpenStreetMap map tiles
      addCircleMarkers(lng = mapdata_final()$long, lat = mapdata_final()$lati, label = mapdata_final()$label,
                       radius = mapdata_final()$hosp_count, color = ifelse(mapdata_final()[,var_name()]==5,"Blue",ifelse(mapdata_final()[,var_name()]==4,"Green",ifelse(mapdata_final()[,var_name()]==3,"Gold",ifelse(mapdata_final()[,var_name()]==2,"Orange","Red"))))) %>%
      addLegend("bottomright", colors = c("Blue", "Green", "Yellow", "Orange","Red"), title = "Hospital Rating", labels = c("5 Stars", "4 Stars","3 Stars","2 Stars","1 Star"))
  )
  
  yvar <- reactive({
    switch(input$type1,
           "Preventative Care" = switch(input$prevent,
                                        "Health Insurance Coverage" = 9,
                                        "Colorectal Cancer Screening" = 18,
                                        "Preventative Care Coverage among Elderly Men" = 20,
                                        "Preventative Care Coverage among Elderly Women" = 21),
           "Health Behavior" = switch(input$behavior,
                                      "Binge Drinking" = 10,
                                      "Smoking" = 22,
                                      "Insufficient Exercise" = 26,
                                      "Insufficient Sleep" = 31),
           "Disease Prevalence" = switch(input$disease,
                                         "High Blood Pressure Prevalence" = 11,
                                         "Asthma Prevalence" = 14,
                                         "COPD Prevalence" = 19,
                                         "Coronary Heart Disease Prevalence" = 15,
                                         "Diabetes Prevalence" = 23,
                                         "High Cholesterol Prevalence" = 24,
                                         "Mental Health Conditions Prevalence" = 28,
                                         "Stroke Prevalence" = 32)
           )
  })
  
  title <- reactive({
    switch(input$type1,
           "Preventative Care" = switch(input$prevent,
                                        "Health Insurance Coverage" = "Health Insurance Coverage",
                                        "Colorectal Cancer Screening" = "Colorectal Cancer Screening",
                                        "Preventative Care Coverage among Elderly Men" = "Preventative Care Coverage among Elderly Men",
                                        "Preventative Care Coverage among Elderly Women" = "Preventative Care Coverage among Elderly Women"),
           "Health Behavior" = switch(input$behavior,
                                      "Binge Drinking" = "Binge Drinking",
                                      "Smoking" = "Smoking",
                                      "Insufficient Exercise" = "Insufficient Exercise",
                                      "Insufficient Sleep" = "Insufficient Sleep"),
           "Disease Prevalence" = switch(input$disease,
                                         "High Blood Pressure Prevalence" = "High Blood Pressure Prevalence",
                                         "Asthma Prevalence" = "Asthma Prevalence",
                                         "COPD Prevalence" = "COPD Prevalence",
                                         "Coronary Heart Disease Prevalence" = "Coronary Heart Disease Prevalence",
                                         "Diabetes Prevalence" = "Diabetes Prevalence",
                                         "High Cholesterol Prevalence" = "High Cholesterol Prevalence",
                                         "Mental Health Conditions Prevalence" = "Mental Health Conditions Prevalence",
                                         "Stroke Prevalence" = "Stroke Prevalence")
    )
  })
  
  output$boxplot <- renderPlotly(
   ggplotly(ggplot(data = exclude, aes(x=factor(mean_rating), y = exclude[,yvar()])) +
              geom_boxplot() + ggtitle(paste(title(),"by Hospital Rating")) + 
              xlab("Hospital Rating") + theme_few() + ylab(notes_list[match(title(),name_list)]) 
              ) 
  )
  
  output$density <- renderPlotly(
    ggplotly(ggplot(data = exclude, aes(x = exclude[,yvar()])) + 
               geom_density(aes(color = factor(mean_rating))) +
               ggtitle(paste(title())) + xlab(title()) + labs(color = "Hospital Rating"))
  )
  
  output$city_state <- renderText(
    input$citystate
  )
  
  city_level <- reactive({
    df <- exclude %>% filter(label == input$citystate)
  })
  
  output$avg_star <- renderInfoBox({
    infoBox(
      "Avg. Hospital Rating", paste(city_level()$mean_rating, "Stars"), icon = icon("star"),
      color = "yellow"
    )
  })
  
  output$n_hosp <- renderInfoBox({
    infoBox(
      "No. of Hospitals", paste(as.character(city_level()$hosp_count), "Hospitals"), icon = icon("hospital-o"),
      color = "red"
    )
  })
  
  output$total <- renderInfoBox({
    infoBox(
      "Total Population", paste(as.character(city_level()$Population_city), "Residents"), icon = icon("users"),
      color = "blue"
    )
  })
  
  city_specific <- reactive({
    df <- city_hosp %>% filter(label == input$citystate) %>% filter(!is.na(Hospital.overall.rating))
  })
  
  output$quality_chart <- renderPlotly(
    ggplotly(ggplot(data = city_specific(), aes(x = Hospital.overall.rating)) + geom_bar() + 
               ggtitle("Hospital Overall Rating") + theme_few() + ylab("Count") + xlab("Rating") +
               scale_x_discrete(drop=FALSE))
  )
  
  
  
}
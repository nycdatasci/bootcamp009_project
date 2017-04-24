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
  
  city_plot_data <- reactive({
    df <- plotdata %>% filter(label == input$citystate)
  })
  
  city_plot_hosp <- reactive({
    df <- city_hosp %>% filter(label == input$citystate)
  })
  
  graph_factor <- reactive({
    switch(input$factor,
           "Health Insurance Coverage" = 44,
           "Colorectal Cancer Screening" = 18,
           "Preventative Care (Elderly Men)" = 20,
           "Preventative Care (Elderly Women)" = 21,
           "High Blood Pressure Prevalence" = 11,
           "Asthma Prevalence" = 14,
           "COPD Prevalence" = 19,
           "Coronary Heart Disease Prevalence" = 15,
           "Diabetes Prevalence" = 24, 
           "High Cholesterol Prevalence" = 25,
           "Mental Health Conditions Prevalence" = 29,
           "Stroke Prevalence" = 34,
           "Binge Drinking" = 10,
           "Smoking" = 22,
           "Insufficient Exercise" = 27,
           "Insufficient Sleep" = 33)
  })
  
  cols <- reactive({
    c("1" = "red", "2" = "orange", "3" = "yellow", "4" = "green", "5" = "blue")
  })
  
  output$city_map <- renderPlot({
    ggplot() +
      geom_polygon(data = city_plot_data(), aes(x = long, y = lat, group = group,
                                         fill = city_plot_data()[,graph_factor()]), color = "white", size = 0.25) +
      coord_map() + 
      geom_point(data = city_plot_hosp(), aes(x = long.x, y = lati.x, color = factor(Hospital.overall.rating)), size = 3) +
      theme_few() + scale_color_manual(values = cols(), limits = c("1", "2","3","4","5")) +
      scale_fill_gradient(low = "white", high = "black") +
      guides(fill = guide_legend(title=input$factor)) +
      guides(color = guide_legend(title="Hospital Rating")) + ggtitle("City Map")
  })
  
  city_perf <- reactive({
    df <- exclude %>%
      select(label, ends_with("_city")) %>%
      gather(varname, Data_value, 3:27) %>%
      filter(label == input$citystate) %>%
      select(varname, Data_value) %>% 
      filter(varname != "ACCESS2_city")
  })
  
  total_perf <- reactive({
    df <- rbind(city_perf(), national) %>% 
      separate(varname, into = c("mea", "level")) %>% 
      mutate(Measure = ifelse(mea == "hcoverage","Health Insurance Coverage",
                              ifelse(mea == "COLONSCREEN","Colorectal Cancer Screening",
                                     ifelse(mea == "COREM","Preventative Care (Elderly Men)",
                                            ifelse(mea == "COREW","Preventative Care (Elderly Women)",
                                                   ifelse(mea == "BINGE","Binge Drinking",
                                                          ifelse(mea == "CSMOKING","Smoking",
                                                                 ifelse(mea == "LPA","Insufficient Exercise",
                                                                        ifelse(mea == "SLEEP", "Insufficient Sleep",
                                                                               ifelse(mea == "BPHIGH","High Bloodpressure",
                                                                                      ifelse(mea == "CASTHMA","Asthma",
                                                                                             ifelse(mea == "COPD","COPD",
                                                                                                    ifelse(mea == "CHD", "CHD",
                                                                                                           ifelse(mea == "DIABETES", "Diabetes",
                                                                                                                  ifelse(mea == "HIGHCHOL","High Cholesterol",
                                                                                                                         ifelse(mea == "MHLTH","Mental Health",
                                                                                                                                ifelse(mea == "STROKE","Stroke","Stroke")))))))))))))))))
  })
  
  bar_data_p <- reactive({
    df <- total_perf() %>% filter(mea %in% prevention_list)
  })
  
  output$bar_p <- renderPlotly(
    ggplotly(ggplot(data = bar_data_p(), aes(x = reorder(Measure,-Data_value), y = Data_value, fill=level)) +
      geom_bar(stat = "identity", position=position_dodge()) + coord_flip() + ggtitle("City Performance") +
      theme_few() + ylab("Prevalence") + xlab("Prevention")+theme(text = element_text(size=8)))
  )
  
  bar_data_h <- reactive({
    df <- total_perf() %>% filter(mea %in% behavior_list)
  })
  
  output$bar_h <- renderPlotly(
    ggplotly(ggplot(data = bar_data_h(), aes(x = reorder(Measure,-Data_value), y = Data_value, fill=level)) +
               geom_bar(stat = "identity", position=position_dodge()) + coord_flip() + ggtitle("City Performance") +
               theme_few() + ylab("Prevalence") + xlab("Health Behavior") + theme(text = element_text(size=8)))
  )
  
  bar_data_d <- reactive({
    df <- total_perf() %>% filter(mea %in% disease_list)
  })
  
  output$bar_d <- renderPlotly(
    ggplotly(ggplot(data = bar_data_d(), aes(x = reorder(Measure,-Data_value), y = Data_value, fill=level)) +
               geom_bar(stat = "identity", position=position_dodge()) + coord_flip() + ggtitle("City Performance") +
               theme_few() + ylab("Prevalence") + xlab("Disease") + theme(text = element_text(size=8)))
  )
  
}
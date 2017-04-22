#enable small_body_dt in global and dataframe selection for final submission

shinyServer(function(input, output, session) {
  output$class_description <- renderText({
    
  })
  
  output$characteristic_plot_a <- renderPlotly({
    class_select() %>% 
      filter(!is.na(a)) %>% 
      ggplot(aes(x = a)) + 
      geom_density(fill='blue', alpha=0.2) + 
      geom_vline(aes(xintercept=avg_calc_a()[1]),
                 linetype='dashed') +
      geom_vline(aes(xintercept=avg_calc_a()[2]),
                 linetype='dotted')
  })

  output$characteristic_plot_q <- renderPlotly({
    class_select() %>% 
      filter(!is.na(q)) %>% 
      ggplot(aes(x = q)) + 
      geom_density(fill='red', alpha=0.2) + 
      geom_vline(aes(xintercept=avg_calc_q()[1]),
                 linetype='dashed') +
      geom_vline(aes(xintercept=avg_calc_q()[2]),
                 linetype='dotted')
  })
    
  avg_calc_q <- reactive({
    class_select() %>% 
      filter(!is.na(q)) %>% 
      dplyr::summarise(mean = mean(q), median = median(q))
  })
  
  avg_calc_a <- reactive({
    class_select() %>% 
      filter(!is.na(a)) %>% 
      dplyr::summarise(mean = mean(a), median = median(a))
  })
  
  class_select <- reactive({
    small_body_dt %>% 
      filter(class == input$meteor_class)
  })
  
  kepler_react <- reactive({
    small_body_dt %>% 
      filter(!is.na(per_y), !is.na(a), !is.na(diameter)) %>% 
      ggplot(., aes(x = per_y, y = a)) +
      scale_x_log10() + scale_y_log10() +
      geom_point(aes(size = diameter, color = class)) +
      xlab("Semi-major axis (AU)") + ylab("Orbital period (year)") +
      labs(color = "Class", size = "")
  })
  
  output$kepler_plot <- renderPlotly({
    kepler_react() %>%
      ggplotly()
  })
  
  output$diameter_plot <- renderPlotly({
    ggplotly(class_select() %>% 
      filter(!is.na(diameter)) %>% 
      ggplot(aes(x = diameter)) +
        geom_density(fill='purple', alpha=0.2) + 
        geom_vline(aes(xintercept=avg_calc_diam()[1]),
                 linetype='dashed') +
        geom_vline(aes(xintercept=avg_calc_diam()[2]),
                 linetype='dotted'))
  })
  
  avg_calc_diam <- reactive({
    class_select() %>% 
      filter(!is.na(diameter)) %>% 
      dplyr::summarise(mean = mean(diameter), median = median(diameter))
  })
  
  output$total_diameter_plot <- renderPlotly({
    small_body_dt %>% 
      filter(!is.na(diameter)) %>% 
      ggplot(aes(x = diameter)) +
      scale_x_log10() + scale_y_log10() +
      geom_histogram(binwidth = 0.25)
  })
  
  meteor_select_reactive <- reactive({
    small_body_join %>% 
      filter(Object.Designation.. == input$crater_name)
  })
  
  crater <- eventReactive({input$target_material
                          input$meteor_material
                          input$crater_name},{
    target <- materials %>% filter(name == input$target_material)

    meteor_vel <- meteor_select_reactive() %>% 
        select(Vinfinity) %>% as.numeric()
    
    meteor_diam <- meteor_select_reactive() %>% 
      select(Estimated.Diameter) %>% as.numeric()

    #crater_formation output: 
    #output <- data.frame(name=c('V_cr', 'V_ej', 'r_cr', 'd_cr', 'T_form'),
    #                     value_cm=value_cm,
    #                     value_km=value_km,
    #                     value_mi=value_mi)

    crater_formation(k_1 = target$k_1,
                     k_2 = target$k_2,
                     mu = target$mu,
                     nu = target$nu,
                     rho_t = target$rho_t,
                     y_t = target$y_t,
                     k_r = target$k_r,
                     k_d = target$k_d,
                     u_s = 1e5*meteor_vel, #Meteor velocity in km/s trans to cm/s
                     a_s = 0.5e5*meteor_diam, #Meteor diameter in km trans to radius of cm
                     delta_s = impactor[name == input$meteor_material, delta_s])
  })

  output$crater_map <- renderLeaflet({
    city <- city_dt %>% filter(name == input$city)
    crater_diam <- crater()$value_km[3]
    
    leaflet() %>%
      addTiles() %>% 
      fitBounds(lng1 = city$lon-crater_diam*0.6124/55,
                lat1 = city$lat-crater_diam*0.6124/37,
                lng2 = city$lon+crater_diam*0.6124/55,
                lat2 = city$lat+crater_diam*0.6124/37) %>% 
      addCircles(lng = city$lon, lat = city$lat, radius = crater_diam*1e3) %>% 
      addPopups(lng = city$lon, lat = city$lat,
                popup=paste(city$name, '-- Crater diameter (km) = ', round(crater_diam,2)))
  })
  
  output$valuebox1 <- renderValueBox({
    valueBox("Crater radius (miles)",
            value = round(crater()$value_mi[3],2),
            color = "red")
  })
  
  output$valuebox2 <- renderValueBox({
    valueBox("Crater depth (miles)",
            value = round(crater()$value_mi[4],2),
            color = "red")
  })
  
  output$valuebox3 <- renderValueBox({
    valueBox("Time (s) for crater formation",
            value = round(crater()$value_mi[5],2),
            color = "red")
  })

  output$valuebox4 <- renderValueBox({
    valueBox("Meteor diameter (miles)",
            value = round(meteor_select_reactive() %>% 
              select(Estimated.Diameter) %>%
              as.numeric(),
              2),
            color = "aqua")
  })
  
  output$valuebox5 <- renderValueBox({
    valueBox("Meteor velocity (Thousand mph)",
            value = round(meteor_select_reactive() %>% 
              select(Vinfinity) %>%
              as.numeric()*2.237,
              2),
            color = "aqua")
  })
  
  output$valuebox6 <- renderValueBox({
    valueBox("Impact Probability (Thousandths of percent)",
            value = round(meteor_select_reactive() %>% 
              select(Impact.Probability) %>%
              as.numeric()*1e5,
              1),
            color = "aqua")
  })
  
  output$class_description <- renderUI({
    #str1 <- strsplit(temp[1], split = '\\n')[1]
    #str2 <- strsplit(temp[1], split = '\\n')[3]
    HTML(meteor_descriptions$meteor_blurb[meteor_descriptions$meteor_classes == input$meteor_class])
  })
})
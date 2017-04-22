#enable small_body_dt in global and dataframe selection for final submission

shinyServer(function(input, output, session) {
  output$class_definition <- renderText({
    #TBD
    #1 or 2 equations/statements on definition
  })
  
  output$class_description <- renderText({
    meteor_descriptions$meteor_blurb[meteor_descriptions$meteor_classes == input$meteor_class]
  })
  
  output$class_image <- renderImage({
    filename <- meteor_descriptions$meteor_img[meteor_descriptions$meteor_classes == input$meteor_class]
    
    list(src = filename)
    }, deleteFile = FALSE)
  
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
  
  output$Kformula <- renderPrint({
    '$$x$$ test'
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
  
  output$class_image <- renderText({
    src = 'http://www.permanent.com/images/a-amor-apollo-aten.gif'
    paste('<img src="',src,'">')
    })
  
  output$crater <- renderText({
    target <- target_choice()
    
    meteor_vel <- small_body_join[1, Vinfinity]
    meteor_diam <- small_body_join[1, Estimated.Diameter]
    
    #crater_formation output: 
    #output <- data.frame(name=c('V_cr', 'V_ej', 'r_cr', 'd_cr', 'T_form'),
    #                     value_cm=value_cm,
    #                     value_km=value_km,
    #                     value_mi=value_mi)
    crater <- crater_formation(k_1 = target$k_1,
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
    
    paste("Testing crater volume (cubic miles) = ", round(crater$value_mi[3],2))
  })
  
target_choice <- reactive({
  materials %>% 
    filter(materials_name == input$target_material)
  })

  
})
  
  
  
  
  #For web-hosted images
  #output$image <- renderUI({
  #src = input$image_url
  #tags$img(src=src)
  #})
  
#  column_select <- reactive({
#    dots = paste0("mean(", input$plot_column, ")")
#    small_body_join %>%
#      group_by(class) %>%
#      dplyr::summarise_(., .dots = setNames(dots, "mean")) 
#  })
  
#  output$histogram1 <- renderGvis({
#    column_select() %>% 
#      gvisColumnChart(.,
#                      xvar='class',
#                      yvar='mean')
#  })
  
#  radius_select <- reactive({
#    dots <- paste0("radius < ", input$radius)
#    small_body_join %>% 
#      filter_(.dots = dots)
#  })
  
#  output$cartesianplot <- renderPlotly({
#    radius_select() %>% 
#      plot_ly(., x=~x, y=~y, z=~z) %>% 
#      add_markers()
#  })

#  radial_range <- reactive({
#    dots = paste0("radius > ", input$r_range[1], " & radius < ", input$r_range[2])
#    small_body_join %>% 
#      filter_(.dots = dots)
#  })
  
#  output$radialplot <- renderPlotly({
#    radial_range() %>% 
#      plot_ly(., x=~x, y=~y) %>%
#      add_markers() 
#  })

  
  #output$heatplot <- renderPlotly({
  #  
  #})
  
#})
shinyServer(function(input, output, session) {
  #Commonly used function for selecting class based on user input
  class_select <- reactive({
    small_body_dt %>% 
      filter(class == input$meteor_class)
  })
######################################################################
  #Plot for semi-major axis on class page
  output$characteristic_plot_a <- renderPlotly({
    avgs <- avg_calc_a() #pre-calculate average values for dashed lines in plot
    mean_val <- unlist(avgs[1])
    median_val <- unlist(avgs[2])
    
    class_select() %>% #reactive based on user input meteor class
      filter(!is.na(a)) %>% #remove NAs from plot
      ggplot(aes(x = a)) + 
      geom_density(fill='blue', alpha=0.2) + 
      geom_vline(aes(xintercept=mean_val), #dashed line = mean value
                 linetype='dashed') +
      geom_vline(aes(xintercept=median_val), #dotted line = median value
                 linetype='dotted')
  })
  
  avg_calc_a <- reactive({
    class_select() %>% 
      filter(!is.na(a)) %>% 
      dplyr::summarise(mean = mean(a), median = median(a))
  })
  
  output$class_label_a <- renderText(
    class_select() %>% 
      distinct(class) %>% 
      unlist() %>% 
      paste('Distribution for ',
            .,
            ' class')
  )
######################################################################
  #Same schema as for semi-major axis, here for perihelion distance
  output$characteristic_plot_q <- renderPlotly({
    avgs <- avg_calc_q()
    mean_val <- unlist(avgs[1])
    median_val <- unlist(avgs[2])
    
    class_select() %>% 
      filter(!is.na(q)) %>% 
      ggplot(aes(x = q)) + 
      geom_density(fill='green', alpha=0.2) + 
      geom_vline(aes(xintercept=mean_val),
                 linetype='dashed') +
      geom_vline(aes(xintercept=median_val),
                 linetype='dotted') +
      labs(x = 'Perhelion distance (AU)')
  })
  
  avg_calc_q <- reactive({
    class_select() %>% 
      filter(!is.na(q)) %>% 
      dplyr::summarise(mean = mean(q), median = median(q))
  })
  
  output$class_label_q <- renderText(
    class_select() %>% 
      distinct(class) %>% 
      unlist() %>% 
      paste('Distribution for ',
            .,
            ' class')
  )
######################################################################  
  #Kepler's law plot generation (orbital period v semi-major axis)
  output$kepler_plot <- renderPlotly({
    ggplotly(small_body_dt %>% 
      filter(!is.na(per_y), !is.na(a), !is.na(diameter)) %>% 
      ggplot(., aes(x = per_y, y = a)) +
      scale_x_log10() + scale_y_log10() +
      geom_point(aes(size = diameter, color = class), alpha = 0.5) +
      xlab("Semi-major axis (log AU)") + ylab("Orbital period (log year)") +
      labs(color = "Class", size = ""))
  })
######################################################################    
  #Diameter density plot for meteor class page (same schema as q and a)
  output$diameter_plot <- renderPlotly({
    avgs <- avg_calc_diam()
    mean_val <- unlist(avgs[1])
    median_val <- unlist(avgs[2])
           
    ggplotly(class_select() %>% 
               filter(!is.na(diameter)) %>% 
               ggplot(aes(x = diameter)) +
               geom_density(fill='red', alpha=0.2) + 
               geom_vline(aes(xintercept=mean_val),
                          linetype='dashed') +
               geom_vline(aes(xintercept=median_val),
                          linetype='dotted') +
               coord_cartesian(xlim = c(0, 2*mean_val)))
  })
  
  avg_calc_diam <- reactive({
    class_select() %>% 
      filter(!is.na(diameter)) %>% 
      dplyr::summarise(mean = mean(diameter), median = median(diameter))
  })
  
  output$class_label_d <- renderText(
    class_select() %>% 
      distinct(class) %>% 
      unlist() %>% 
      paste('Distribution for ',
            .,
            ' class')
  )
######################################################################
  #Overview page distance from sun v diameter plot
  output$total_diameter_plot <- renderPlotly({
    small_body_dt %>% 
      filter(!is.na(diameter), !is.na(radius)) %>%
      ggplot(aes(x = radius, y = diameter)) +
      scale_x_log10() + scale_y_log10() +
      geom_jitter(aes(color=class), alpha = 0.6) +
      xlab('Distance from the sun (AU)') + ylab('Diameter (km)') +
      labs(color = 'Class')
  })
######################################################################   
  #Schema for possible impact plots, here for diameter
  output$hazard_d <- renderPlotly({
    temp <- small_body_join %>%
      filter(!is.na(Estimated.Diameter))
    avg_diam <- temp %>% 
      dplyr::summarise(mean = mean(Estimated.Diameter), median = median(Estimated.Diameter))
    
    mean_val <- unlist(avg_diam[1])
    
    ggplotly(temp %>% 
               ggplot(aes(x = Estimated.Diameter)) +
               geom_density(fill='red', alpha=0.2) + 
               geom_vline(aes(xintercept=avg_diam[1]),
                          linetype='dashed') +
               geom_vline(aes(xintercept=avg_diam[2]),
                          linetype='dotted') +
               coord_cartesian(xlim = c(0, 0.2)) +
               labs(x = 'Diameter (km)', y = '', title = 'Diameter (km) distribution'))
  })
###################################################################### 
  #Likewise for hazardous semi-major axis
  output$hazard_a <- renderPlotly({
    temp <- small_body_join %>%
      filter(!is.na(a))
    avg_a <- temp %>% 
      dplyr::summarise(mean = mean(a), median = median(a))
    
    mean_val <- unlist(avg_a[1])
    
    ggplotly(temp %>% 
               ggplot(aes(x = a)) +
               geom_density(fill='blue', alpha=0.2) + 
               geom_vline(aes(xintercept=avg_a[1]),
                          linetype='dashed') +
               geom_vline(aes(xintercept=avg_a[2]),
                          linetype='dotted') +
               coord_cartesian(xlim = c(0.5, 3.5)) +
               labs(x = 'Semi-major axis (AU)', y = '', title = 'a axis (AU) distribution'))
  })
######################################################################   
  #For q, same schema as above
  output$hazard_q <- renderPlotly({
    temp <- small_body_join %>%
      filter(!is.na(q))
    avg_q <- temp %>% 
      dplyr::summarise(mean = mean(q), median = median(q))
    
    mean_val <- unlist(avg_q[1])
    
    ggplotly(temp %>% 
               ggplot(aes(x = q)) +
               geom_density(fill='green', alpha=0.2) + 
               geom_vline(aes(xintercept=avg_q[1]),
                          linetype='dashed') +
               geom_vline(aes(xintercept=avg_q[2]),
                          linetype='dotted') +
               coord_cartesian(xlim = c(0, 1)) +
               labs(x = 'Perihelion (AU)', y = '', title = 'Perihelion (AU) distribution'))
  })
####################################################################### 
  #For probability, similar schema to above, here comparing with d too
  output$hazard_prob <- renderPlotly({
    temp <- small_body_join %>%
      filter(!is.na(Impact.Probability), !is.na(Estimated.Diameter))
    
    ggplotly(temp %>% 
               ggplot(aes(x = Estimated.Diameter, y = Impact.Probability)) +
               geom_jitter(aes(color=class)) + geom_smooth(method='lm') +
               scale_y_log10() + scale_x_log10() +
               labs(x = 'Diameter (km)', y = 'Impact Probability', title = 'Impact Probability v. Diameter'))
  })
  
###################################################################### 
  #Reactive meteor (single) selection based on user input
  meteor_select_reactive <- reactive({
    small_body_join %>% 
      filter(Object.Designation.. == input$crater_name)
  })
###################################################################### 
  #Calculate crater parameters based on sum of all input data
  crater <- eventReactive({input$target_material
                          input$meteor_material
                          input$crater_name
                          input$theta_in},{
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
                     delta_s = impactor[name == input$meteor_material, delta_s],
                     theta = input$theta_in)
  })
###################################################################### 
  #Plot the calculated crater on map with example cities
  output$crater_map <- renderLeaflet({
    city <- city_dt %>% filter(name == input$city)
    crater_diam <- crater()$value_km[3]
    
    leaflet() %>%
      addTiles() %>% 
      fitBounds(lng1 = city$lon-crater_diam*0.6124/55,
                lat1 = city$lat-crater_diam*0.6124/37,
                lng2 = city$lon+crater_diam*0.6124/55,
                lat2 = city$lat+crater_diam*0.6124/37) %>% 
      addCircles(lng = city$lon, lat = city$lat, radius = crater_diam*1e3, color='red') %>% #crater circles
      addPopups(lng = city$lon, lat = city$lat,
                popup=paste(city$name, '-- Crater diameter (km) = ', round(crater_diam,2))) #info popup
  })
  
###################################################################### 
  #Infoboxes below contain calculated and input parameters of interest
  #From crater formation equation
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
###################################################################### 
  #Include searchable tables for added interactivity with dataset
  output$small_body_dt <- renderDataTable(
    small_body_dt %>% 
      select(Class=class,
             Name=full_name,
             Semimajor_axis_a=a,
             Perihelion_q=q,
             ellipticity_e=e,
             Orbital_period=per_y,
             Minimum_earth_approach=moid),
    options = list(pageLength = 10,
                   lengthMenu = c(5, 10, 15, 20))
  )
  
  output$small_body_join <- renderDataTable(
    small_body_join %>% 
      select(Class=class,
             Name = Object.Designation..,
             Diameter = Estimated.Diameter,
             Velocity = Vinfinity,
             Probability_of_impact = Impact.Probability,
             Potential_impact_year_range=Year.Range..),
    options = list(pageLength = 10)
  )
###################################################################### 
  #Plot orbits on unlabeled graphs
  output$all_class_orbits <- renderPlotly({
    m <- list( #set margins of final plot
      l = 20,
      r = 20,
      b = 0,
      t = 30,
      pad = 1)

    ggplotly(orbital_plot + #base plot (planets + sun)
               add_to_orbit('AMO') + #add all object classes of interest
               add_to_orbit('APO') +
               add_to_orbit('AST') +
               add_to_orbit('ATE') +
               add_to_orbit('CEN') +
               add_to_orbit('CTc') +
               add_to_orbit('ETc') +
               add_to_orbit('HTC') +
               add_to_orbit('IEO') +
               add_to_orbit('IMB') +
               add_to_orbit('JFc') +
               add_to_orbit('JFC') +
               add_to_orbit('MBA') +
               add_to_orbit('MCA') +
               #add_to_orbit('TJN')) +
               add_to_orbit('OMB')) %>% 
      layout(autosize = F, width = 250, height = 200, margin = m)
  })
  
  output$inner_orbits <- renderPlotly({
    m <- list(
      l = 20,
      r = 20,
      b = 0,
      t = 30,
      pad = 1)
    
    ggplotly(ggplot(data = NULL, aes(x=out1, y=out2)) +
               geom_polygon(data = df_sun, fill='black') +
               geom_path(data = df_earth, color = 'black') +
               geom_path(data = df_mars, color = 'black') + 
               add_to_orbit('AMO', 'blue') +
               add_to_orbit('APO', 'green') +
               add_to_orbit('ATE', 'pink') +
               add_to_orbit('IEO', 'orange') +
               coord_fixed() + labs(x='', y='', title='NEO orbits') +
               theme_minimal() +
               theme(axis.title=element_blank(),
                     axis.text=element_blank(),
                     panel.grid=element_blank())) %>% 
      layout(autosize = F, width = 200, height = 200, margin = m)
  })
  
  output$single_class_orbits <- renderPlotly({
    m <- list(
      l = 20,
      r = 20,
      b = 0,
      t = 30,
      pad = 1)
    
    ggplotly(orbital_plot + 
               add_to_orbit(input$meteor_class) +
               labs(title = paste(input$meteor_class, ' (black)'))) %>% 
      layout(autosize = F, width = 175, height = 175, margin = m)
  })
###################################################################### 
  #Include a couple of prerendered images stored in /img
  output$meteor_image <- renderImage({
    src = './img/meteor_terminology.jpg'
    width  <- session$clientData$output_meteor_image_width
    height <- 1000
    
    list(src = src,
         contentType = 'image/jpg',
         width = width,
         height = height,
         alt = "Meteor graphic from American Meteor Society")
  }, deleteFile = F)
  
  output$orbital_parameters <- renderImage({
    src = './img/orbitimg.jpg'
    width  <- session$clientData$output_orbital_parameters_width
    height <- session$clientData$output_orbital_parameters_height/2
    
    list(src = src,
         contentType = 'image/jpg',
         width = width,
         height = height,
         alt = "Orbital parameters schematic")
  }, deleteFile = F)
  
######################################################################  
  #meteor class descriptions 
  output$class_description <- renderUI({
    HTML(meteor_descriptions$meteor_blurb[meteor_descriptions$meteor_classes == input$meteor_class])
  })
})
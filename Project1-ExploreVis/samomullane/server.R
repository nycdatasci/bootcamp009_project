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
  
  output$characteristic_plot_a <- renderGvis({
    class_select() %>%
      select(a) %>% 
      gvisHistogram(options = list(
        title='Semi-major axis (a)',
        legend="{ position: 'none' }",
        colors="['#e7711c']",
        histogram="{ bucketSize: 0.5 }")
        )
  })
  
  output$characteristic_plot_q <- renderGvis({
    class_select() %>%
      select(q) %>% 
      gvisHistogram(options = list(
        title='Aphelion distance (q)',
        legend="{ position: 'none' }",
        colors="['#e7711c']",
        histogram="{ bucketSize: 0.5 }")
      )
  })
  
  class_select <- reactive({
    #Change from *_join to *_dt in final analysis
    small_body_join %>% 
      filter(class == input$meteor_class)
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
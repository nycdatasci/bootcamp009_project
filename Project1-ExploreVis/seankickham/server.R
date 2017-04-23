library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(DT)
library(googleVis)

shinyServer(function(input, output, session){
  ########################
  ### map ################
  ########################
  
  
  ########################
  ### gender #############
  ########################
  output$femaleBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'straight'])/59946 * 100)
    infoBox('Straight', paste0(percent, '%'), icon = icon('hand-o-up'))
  })
  
  output$maleBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'gay'])/59946 * 100)
    infoBox('Gay', paste0(percent, '%'), icon = icon('hand-o-down'))
  })
  
  output$sexBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'bisexual'])/59946 * 100)
    infoBox('Bisexual', paste0(percent, '%'), icon = icon('hand-o-down'))
  })
  
  
  output$sexBar = renderPlot({
    print("test")
    ggplot(p2, aes(x = orientation)) +
      geom_bar(aes(fill = ethnicity), position = 'fill')
    
    
  }, height = 450)
  
  output$sexBoxPlot = renderPlot({
    print("test")
    ggplot(p2, aes(x = orientation, y = as.numeric(income))) +
      coord_trans(y = 'log10') +
      geom_boxplot(aes(color = orientation))
    
    
  }, height = 450)
  
  
  ########################
  ### orientation ########
  ########################
  output$straightBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'straight'])/59946 * 100)
    infoBox('Straight', paste0(percent, '%'), icon = icon('hand-o-up'))
  })

  output$gayBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'gay'])/59946 * 100)
    infoBox('Gay', paste0(percent, '%'), icon = icon('hand-o-down'))
  })

  output$bisexualBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'bisexual'])/59946 * 100)
    infoBox('Bisexual', paste0(percent, '%'), icon = icon('hand-o-down'))
  })

  # output$bisexualBox = renderInfoBox(
  #   infoBox(paste("AVG.", input$selected),
  #           mean(state_stat[,input$selected]),
  #           icon = icon('calculator'), fill = T))

  
  output$orientationBar = renderPlot({
    print("test")
      ggplot(p2, aes(x = orientation)) +
        geom_bar(aes(fill = ethnicity), position = 'fill')
    
    
  }, height = 450)
  
  output$orientationBoxPlot = renderPlot({
    print("test")
    ggplot(p2, aes(x = orientation, y = as.numeric(income))) +
      coord_trans(y = 'log10') +
      geom_boxplot(aes(color = orientation))
    
    
  }, height = 450)
  
  
  
  ########################
  ### ethnicity ##########
  ########################
  output$whiteBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'straight'])/59946 * 100)
    infoBox('Straight', paste0(percent, '%'), icon = icon('hand-o-up'))
  })
  
  output$multiethnicBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'gay'])/59946 * 100)
    infoBox('Gay', paste0(percent, '%'), icon = icon('hand-o-down'))
  })
  
  output$otherBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'bisexual'])/59946 * 100)
    infoBox('Bisexual', paste0(percent, '%'), icon = icon('hand-o-down'))
  })
  
  
  output$ethnicityBar = renderPlot({
    print("test")
    ggplot(p2, aes(x = orientation)) +
      geom_bar(aes(fill = ethnicity), position = 'fill')
    
    
  }, height = 450)
  
  output$ethnicityBoxPlot = renderPlot({
    print("test")
    ggplot(p2, aes(x = orientation, y = as.numeric(income))) +
      coord_trans(y = 'log10') +
      geom_boxplot(aes(color = orientation))
    
    
  }, height = 450)
  
  
  
  ########################
  ### religion ###########
  ########################
  output$religiousBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'straight'])/59946 * 100)
    infoBox('Straight', paste0(percent, '%'), icon = icon('hand-o-up'))
  })
  
  output$relseriousBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'gay'])/59946 * 100)
    infoBox('Gay', paste0(percent, '%'), icon = icon('hand-o-down'))
  })
  
  output$christianBox = renderInfoBox({
    percent = round(length(p2$orientation[p2$orientation == 'bisexual'])/59946 * 100)
    infoBox('Bisexual', paste0(percent, '%'), icon = icon('hand-o-down'))
  })
  
  
  output$religionBar = renderPlot({
    print("test")
    ggplot(p2, aes(x = orientation)) +
      geom_bar(aes(fill = ethnicity), position = 'fill')
    
    
  }, height = 450)
  
  output$religionBoxPlot = renderPlot({
    print("test")
    ggplot(p2, aes(x = orientation, y = as.numeric(income))) +
      coord_trans(y = 'log10') +
      geom_boxplot(aes(color = orientation))
    
    
  }, height = 450)
  
  
  
  ########################
  ### age ################
  ########################
  
  
  ########################
  ### word cloud #########
  ########################
  
  
  
  ########################
  ### data ###############
  ########################

  output$table = DT::renderDataTable({
    datatable(p3, rownames = T) %>%
      formatStyle(input$selected,
                  background = 'skyblue', 
                  fontWeight = 'bold')

  })
  # ,
  # options = list(scrollX = TRUE))
  
  ###############################
  #EXAMPLES
  ##############################
 
  
})
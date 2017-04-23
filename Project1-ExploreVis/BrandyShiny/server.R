##############################################
###  Data Science Bootcamp 9               ###
###  Project 1 - Exploratory Visualization ###
###  Brandy Freitas  / April 23, 2017      ###
###     Trends in Risk Behavior in NYC     ###
###           Teens from 2001-2015         ###
##############################################

function(input, output, session) {

  
  output$leaflet_map <- renderLeaflet ({
    leaflet() %>%
      addTiles() %>%
      setView(lng=-74.00, lat=40.71, zoom = 10) %>%
      addMarkers(lng=-73.9718, lat=40.7745, popup=content_M) %>%
      addMarkers(lng=-73.7694, lat=40.7420, popup=content_Q) %>%
      addMarkers(lng=-73.9636, lat=40.6708, popup=content_BK) %>%
      addMarkers(lng=-74.1398, lat=40.5623, popup=content_S) %>%
      addMarkers(lng=-73.8662, lat=40.8501, popup=content_BX)
    
  })
  
  output$drugPlot <- renderPlotly({
    x <- Boros_AllDrugs
    x$plotValue <- x[, input$drugChoice]
    
    Boros_AllDrugs_Year <- x %>% 
      group_by(year, sitename) %>% 
      summarise(Percent_Pop = 100 * (sum(plotValue == 1)/sum(Marijuana == 1 | Marijuana == 0)))
    
    ggplot(Boros_AllDrugs_Year, aes(x=year, y=Percent_Pop, group=sitename)) +
      geom_line(aes(color = sitename)) +
      scale_x_discrete(limits=c("2003", "2005", "2007", "2009"), expand = c(0, 0)) +
      theme_bw() +
      theme(panel.grid = element_blank(), panel.border = element_blank()) +
      labs(color = "Borough", x = "Year", y = "Percent of Teens Using", caption = "(drug use data only available for years 2003-2009)")
  })
  
  output$gradePlot <- renderPlotly({
  
    Average_BMI_gradeyear <- BoroData %>% 
      filter(year == input$yearChoice)
  
    ggplot(Average_BMI_gradeyear, aes(x = grade, y = bmi)) +
      geom_boxplot(aes(color = grade), outlier.alpha = 0.25) +
      facet_wrap(~sitename) +
      coord_cartesian(ylim = c(18, 28)) +
      labs(title = "BMI by Grade Level", x = "Grade", y = "BMI") +
      theme_bw() +
      theme(plot.title = element_text(hjust = 0.5)) +
      theme(legend.position="none")
  
  })
  
  output$sadPlot <- renderPlotly({
    
    Depression_Gender_boro <- Boros_Depression %>%
      filter(year == input$yearChoose) %>% 
      group_by(sitename, sex) %>% 
      summarise(Mental = 100 * (sum(ContSuicide == 1 | AttSuicide == 1) / sum(ContSuicide == 1 | AttSuicide == 1 | ContSuicide == 0 | AttSuicide == 0)))
    
    ggplot(Depression_Gender_boro, aes(x = sitename, y = Mental)) +
      geom_bar(stat = 'Identity', aes(fill = sex), position = 'dodge') +
      coord_cartesian(ylim = c(7, 23)) +
      labs(fill = "Gender", x = NULL, y = "Percent Reporting Suicidal Thoughts or Actions") +
      theme_bw()
    
  })
  
  output$sexPlot <- renderPlotly({
    
    Depression_boro <- Boros_Depression %>%
      filter(sex == input$sexChoice) %>% 
      group_by(year, sitename) %>% 
      summarise(Mental = 100 * (sum(ContSuicide == 1 | AttSuicide == 1) / sum(ContSuicide == 1 | AttSuicide == 1 | ContSuicide == 0 | AttSuicide == 0)))
    
    ggplot(Depression_boro, aes(x = year, y = Mental)) +
      geom_bar(stat = 'Identity', aes(fill = 'blue')) +
      facet_wrap(~sitename) +
      coord_cartesian(ylim = c(8, 23)) +
      labs(x = NULL, y = "Percent Reporting Suicidal Thoughts or Actions") +
      theme_bw() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      theme(legend.position="none")
    
  })
  
  output$table <- DT::renderDataTable({
    datatable(BoroTableDisplay)
    
  })
}

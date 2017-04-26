
library(shiny)


shinyServer(function(input, output){
  ##Text
  
  ##Reactive Functions
  
  ##Static Graphs
  output$densityAT <- renderPlot({
    a_tov %>%
    ggplot(aes(x=ast/tov)) +
    geom_density(colour = 'red', fill = 'white') + 
    facet_grid(~conf_finals) +
    ggtitle("Assist to Turnover by C.F. Status")
    })
  
  output$densityshotprop <- renderPlot({
    fga_3pa %>%
    ggplot(aes(x=fg3a/fga)) +
    geom_density(colour = 'blue',fill='white')+
    facet_grid(~conf_finals) +
    ggtitle("3-Point Attempts in Proportion to Overall FGs")
    })
    
  
  output$densityftpct <- renderPlot({
    freethrows %>%
    ggplot(aes(x=ftacc, y=ft)) +
    geom_point(colour = 'orange') + 
    facet_grid(~conf_finals) +
    ggtitle("Free Throw Percentage to Free Throw Attempts")
    })
  
  output$densitypts <- renderPlot({
    avg_pts %>%
    ggplot(aes(x=avgpts)) +
    geom_density(colour = 'green', fill='white') +
    facet_grid(~conf_finals) +
    ggtitle("Average Points Scored")
    })
    
  output$densitydrebs <- renderPlot({
    drebs %>%
    ggplot(aes(x=rebound)) +
    geom_density(colour = 'red2', fill = 'white') +
    facet_grid(~conf_finals) +
    ggtitle("Average Defensive Rebounds")
    })
  
  output$densitypminus <- renderPlot({
    plus_minus %>%
      ggplot(aes(x=pminus)) +
      geom_density(colour='blue2', fill = 'white') +
      facet_grid(~conf_finals) +
      ggtitle("Plus Minus")
    })
  
  output$densityfouls <- renderPlot({
    fouls %>%
      ggplot(aes(x=fouls)) +
      geom_density(fill='white') +
      facet_grid(~conf_finals) +
      ggtitle("Average Fouls")
    })
  
})

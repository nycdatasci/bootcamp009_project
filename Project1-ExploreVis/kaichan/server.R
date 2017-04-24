
library(shiny)


shinyServer(function(input, output){
  
  #######Assists/Turnovers######
  
  ##Tables
  a_tov <- 
    t_df %>%
    group_by(conf_finals,tname,y,game_id) %>%
    summarise(ast=sum(ast), tov=sum(tov))
  
  fga_3pa <- t_df %>%
    group_by(conf_finals,tname,y,game_id) %>%
    summarise(fga=sum(fga), fg3a=sum(fg3a))
  
  freethrows <- t_df %>%
    group_by(conf_finals,tname,y,game_id) %>%
    summarise(ftacc = sum(ft_pct), ft = sum(fta))
  
  avg_pts <- t_df %>%
    group_by(conf_finals,tname,y) %>%
    summarise(avgpts = round(mean(pts),0))
  

  drebs <- t_df %>%
    group_by(conf_finals,tname,y,game_id) %>%
    summarise(rebound = round(mean(dreb),0))

  plus_minus <- t_df %>%
    group_by(conf_finals,tname,y,game_id) %>%
    summarise(pminus = sum(plus_minus))
  
  fouls <- t_df %>%
    group_by(conf_finals,tname,y,game_id) %>%
    summarise(fouls = round(mean(pf),0))
  
  
})

  ##Graphs
  output$density_AT <- renderPlot(
    a_tov %>%
    ggplot(aes(x=ast/tov)) +
    geom_density(colour = 'red', fill = 'white') + 
    facet_grid(~conf_finals) +
    ggtitle("Assist to Turnover by C.F. Status"))
  
  output$density_shotprop <- renderPlot(fga_3pa %>%
    ggplot(aes(x=fg3a/fga)) +
    geom_density(colour = 'blue',fill='white')+
    facet_grid(~conf_finals) +
    ggtitle("3-Point Attempts in Proportion to Overall FGs"))
    
  
  output$density_ftpct <- renderPlot(freethrows %>%
    ggplot(aes(x=ftacc, y=ft)) +
    geom_point(colour = 'orange') + 
    facet_grid(~conf_finals) +
    ggtitle("Free Throw Percentage to Free Throw Attempts"))
  
  output$density_pts <- renderPlot(avg_pts %>%
    ggplot(aes(x=avgpts)) +
    geom_density(colour = 'green', fill='white') +
    facet_grid(~conf_finals) +
    ggtitle("Average Points Scored"))
    
  output$density_drebs <- renderPlot(drebs %>%
    ggplot(aes(x=rebound)) +
    geom_density(colour = 'red2', fill = 'white') +
    facet_grid(~conf_finals) +
    ggtitle("Average Defensive Rebounds"))
  
  output$density_pminus <- renderPlot(plus_minus %>%
  ggplot(aes(x=pminus)) +
  geom_density(colour='blue2', fill = 'white') +
  facet_grid(~conf_finals) +
  ggtitle("Plus Minus"))
  
  output$density_fouls <- renderPlot(
    fouls %>%
    ggplot(aes(x=fouls)) +
    geom_density(fill='white') +
    facet_grid(~conf_finals) +
    ggtitle("Average Fouls")
  )

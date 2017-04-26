
library(shiny)


shinyServer(function(input, output){

  
####Dynamic Boxplot####
  
  output$box1 <- reactive({
    renderPlot({
    
      t_df %>%
        group_by(conf_finals,y, tname, game_id) %>%
        summarise(stat = sum(input$stat1)) %>%
      ggplot(aes(x=conf_finals, y= input$stat1, colour=conf_finals))+
        labs(title="Conference Finalist Comparisons", x="Conf. Finalists?", y="Points")+
        geom_boxplot()+
        facet_grid(~y)
    
      })
    
    
####Static Plots####
    
    output$densityAT <- renderPlot({
      
      t_df %>%
        group_by(conf_finals,tname,y,game_id) %>%
        summarise(ast=sum(ast), tov=sum(tov)) %>%
      ggplot(aes(x=ast/tov, colour=conf_finals)) +
        geom_density() + 
        ggtitle("Assist to Turnover")
      
      
    })
    
    output$densityshotprop <- renderPlot({
      t_df %>%
      group_by(conf_finals,tname,y,game_id) %>%
        summarise(fga=sum(fga), fg3a=sum(fg3a)) %>%
      ggplot(aes(x=fg3a/fga, colour=conf_finals)) +
        geom_density()+
        ggtitle("3-Point Attempts in Proportion to Overall FGs")
    })
    
    
    output$densityftpct <- renderPlot({
      t_df %>%
        group_by(conf_finals,tname,y,game_id) %>%
        summarise(ftacc = sum(ft_pct), ft = sum(fta)) %>%
      ggplot(aes(x=ftacc, y=ft, colour=conf_finals)) +
        labs(y="FT Attempts") +
        geom_point() +
        geom_smooth(method='glm') +
        ggtitle("Free Throw Percentage to Free Throw Attempts")
    })
    
    output$densitypts <- renderPlot({
      t_df %>%
        group_by(conf_finals,tname,y) %>%
        summarise(avgpts = round(mean(pts),0)) %>%
        ggplot(aes(x=avgpts, colour=conf_finals)) +
        geom_density() +
        ggtitle("Average Points Scored")
    })
    
    output$densitydrebs <- renderPlot({
      t_df %>%
        group_by(conf_finals,tname,y,game_id) %>%
        summarise(rebound = round(mean(dreb),0)) %>%
        ggplot(aes(x=rebound, colour=conf_finals)) +
        geom_density() +
        ggtitle("Average Defensive Rebounds")
    })
    
    output$densitypminus <- renderPlot({
      t_df %>%
        group_by(conf_finals,tname,y,game_id) %>%
        summarise(pminus = sum(plus_minus)) %>%
        ggplot(aes(x=pminus, colour=conf_finals)) +
        geom_density() +
        ggtitle("Plus Minus")
    })
    
    output$densityfouls <- renderPlot({
      t_df %>%
        group_by(conf_finals,tname,y,game_id) %>%
        summarise(fouls = round(mean(pf),0)) %>%
        ggplot(aes(x=fouls, colour=conf_finals)) +
        geom_density() +
        ggtitle("Average Fouls")
    })
    
    
  })  
})

library(shiny)
library(ggplot2)
library(hexbin)
library(shinydashboard)

shinyServer(function(input, output) {
  
  #3
  output$winrate<- renderPlot({
    
    ggplot(Agencies_success_rate, 
           aes(x = season , y= Agencies_success_rate, label= paste(round(Agencies_success_rate*100, digits= 2),"%"))) + 
    geom_text(size = 4,position = position_stack(vjust = 1.05)) + 
      geom_bar(stat='identity') + ggtitle("Favored result success rate") + ylab('agencies success rate')
    
  })
  #4
  output$game_winner <- renderPlot({
    print(input$Agencies_fav_success_rate)
    ggplot(game_winner_table, aes(x= reorder(game_winner,-Percent_of_total_games_played) , y= Percent_of_total_games_played,
    label = paste(round(Percent_of_total_games_played*100, digits= 2),"%")))+ geom_bar(stat = 'identity')+
    geom_text(size = 4, position = position_stack(vjust = 0.5)) +
      ggtitle("Actual Matche Results") + ylab('percent of games played') + xlab('game winner')


  })
  
  #2
  output$min_max <- renderPlot({
    
    
    ggplot(min_max_odds, aes(x=max_odd,y=min_odd)) + geom_point(size = 0.005) + 
      scale_x_continuous(limits = c(1,12)) + ylim(1,3) + stat_binhex() + 
      ggtitle("Scatter Plot Of Minimum and Maximum Odds Of Observations") +
      xlab('maximum odds') + ylab('minimum odds')
      
 
  
  }) 
  
  #4
  output$agencies_fav <- renderPlot({

    if(input$Agencies_fav_success_rate=="Agencies Favorite"){


    ggplot(agencies_fav_table, aes(x= reorder(Agencies_fav,-Percent_of_total_games_played_af), y= Percent_of_total_games_played_af,
    label = paste(round(Percent_of_total_games_played_af*100, digits= 2),"%")))+ geom_bar(stat = 'identity') +
    geom_text(size = 4, position = position_stack(vjust = 0.5))+
      ggtitle("Agencies Favored Result") + xlab('locality') + ylab('percent of games played')
    } else {

    ggplot(results_table,aes(x=reorder(Agencies_fav,-values),y=values,label = paste(round(values*100, digits= 2),"%"))) +
    geom_bar(aes(fill=Type), stat = 'identity') + geom_text(size = 4, position = position_stack(vjust = 0.5))
    }

  })
  #5
  output$success_rates <- renderTable({ 
    
  success_rates_table <- matches %>% group_by(season,Agencies_fav, Agencies_fav_level) %>% 
  summarise(count_games = n(), success_ = sum(AgenciesVsgame_winner=="yes"), 
            s_rate = paste(round(success_/count_games*100, digits=2),"%")) %>% 
  filter(Agencies_fav_level == input$Agencies_fav_level & Agencies_fav == input$Agencies_fav) %>% 
    select(Season=season, Success_Rate = s_rate)
  
  
  
  }) 
  
  
  output$avg_success_rates <- renderInfoBox({ 
    
  avg_success_rate <- paste(round(((matches %>% summarise(count_games = n(), success_ = sum(AgenciesVsgame_winner=="yes"), 
                                            s_rate = success_/count_games))[,3])*100, digits = 2),'%') 
  
  infoBox("Success Rate",avg_success_rate, icon = icon("hand-o-up"))
  
  }) 
  
  #8
  # output$avg_success_rate_breakdown <- renderInfoBox({ 
  # 
  # 
  #   avg_success_rate <- (success_rates_table %>% 
  #   group_by(Agencies_fav,Agencies_fav_level) %>% 
  #   summarise(count_game = sum(count_games), 
  #             success= sum(success_), 
  #             s_rate = paste(round(success/count_game*100, digits=2),"%")) %>% 
  #   filter(Agencies_fav_level == input$Agencies_fav_level & Agencies_fav == input$Agencies_fav))[,5]
  # 
  #   infoBox("Avg. Success Rate",avg_success_rate, icon = icon("hand-o-up"))
  # })
  
  
  
  
  output$favor_count <- renderPlot({
    
    ggplot(favorite_table,aes(x= " ",y=count1, fill=Agencies_fav_level, label = count1)) + 
      geom_bar(width=1,stat = 'identity') +
      coord_polar(theta = "y") + 
      ylab('Count of Matches')
    
    
  })  
  
  output$drow_analysis <- renderPlot({
  
  ggplot(drow_breakdown, aes(x=reorder(Agencies_fav_level,-drow_percentage),
                            y=drow_percentage, 
                            label = paste(round(drow_percentage*100, digits= 2),"%"))) +
    geom_bar(stat = 'identity') + ggtitle("Percentage of draw results from favored level")+
     geom_text(size = 4, position = position_stack(vjust = 0.5)) + xlab('favored level') +
      ylab('draw percentage')
  
    
  })    
  
  
  min_max_odds_byseason <- reactive ({
    
    min_max_odds %>% filter(season==input$season, 
                            Agencies_fav=='home team' | Agencies_fav== 'away team')
    
    })
  
  output$min_odd_boxplot <- renderPlot({
  ggplot(min_max_odds_byseason(),aes(x=Agencies_fav_level,y=min_odd))+ geom_boxplot() +
      facet_wrap(~Agencies_fav)
    
  })  
    
  output$map <- renderLeaflet({
    if (input$show) {
      europe_map_max
    } else {
      europe_map
  }
  }) 
  
  # league_analysis %>% 
  #   group_by(name) %>% 
  #   summarise(game_count1 = sum(game_count), count_of_won2=sum(count_of_won))%>% 
  #   mutate(success_rate = count_of_won2/game_count1)
  # 
  # league_analysis_max = league_analysis %>% 
  #   group_by(name) %>% 
  #   filter(Agencies_fav!='drow') %>% 
  #   summarise(success_rate= max(success_rate)) 
  # 
  # left_join(league_analysis_max,league_analysis,by='success_rate')[,c(1,2,4,5)]
  # 
   # fail high favored actul result
  ggplot(high_favored_analysis,aes(x= reorder(Agencies_fav,-rates),y= rates, label = paste(round(rates*100, digits= 2),"%"))) + 
    geom_bar(aes(fill= game_winner),stat = 'identity', position = 'dodge') + 
    ggtitle("What was the result when a high favored didn't win?")
  

  
  output$min_max_hist <- renderPlot({

    if (input$show_hist) {

      ggplot(min_max_odds,aes(x=max_odd)) +
        geom_histogram(bins =20) +scale_x_continuous(limits = c(1,15)) +
        ggtitle('Maximum Odds Histogram') + xlab('minimum odds')

    } else {
      ggplot(min_max_odds,aes(x=min_odd)) +
        geom_histogram(bins =20) + xlab('maximum odds') +
        ggtitle('Minimum Odds Histogram')
      
    } 
      
  }) 
  
  
  output$mid_odd_hist <- renderPlot({  
  
  ggplot(mid_odds,aes(x=mid_odd)) +
  geom_histogram(bins = 20) +
  ggtitle('Middle Odds Histogram') + 
  scale_x_continuous(limits = c(1,10)) + xlab('middle odds') 
  
  
  
  })
 
  

  
  
})
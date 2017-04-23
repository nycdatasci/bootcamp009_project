library(data.table)
library(ggplot2)
library(dplyr)
library(leaflet)

matches <- fread("matches.csv")

results_table <- fread("agencies_results.csv")

drow_breakdown <- fread('drow_breakdown.csv')

league <- fread('european_leagues.csv')

min_max_odds = matches %>% 
  mutate(min_odd=(apply(matches[,c(35,36,37)],1, min)), 
                                  max_odd = apply(matches[,c(35,36,37)],1, max))


Agencies_success_rate = matches %>% 
  select(season, AgenciesVsgame_winner, Agencies_fav_level) %>% 
  group_by(season) %>% summarize (Agencies_success = sum(AgenciesVsgame_winner=='yes'), 
                                  count_of_games = n() ,Agencies_success_rate= Agencies_success / count_of_games)

min_max_odds = matches %>% 
  mutate(min_odd = apply(matches[,c(36,37,38)],1, min),
                                  max_odd = apply(matches[,c(36,37,38)],1, max)) 


game_winner_table = matches %>% group_by(., game_winner) %>% 
summarize(., count_of_game_winner = n(), total_games_played= 22434,Percent_of_total_games_played= count_of_game_winner/total_games_played)

agencies_fav_table = matches %>% 
  group_by(., Agencies_fav) %>% 
  summarise(., count_of_agencies_fav= n()) %>% 
mutate(total_games_played=22434,Percent_of_total_games_played_af= count_of_agencies_fav/total_games_played) %>%
mutate(Type = 'Agencies Favorite', Value=Percent_of_total_games_played_af)

Agencies_fav_results= matches %>% 
  group_by(Agencies_fav) %>% 
  summarise(match_count = n(), fav_win = sum(AgenciesVsgame_winner=='yes'),successrate = fav_win/match_count) %>%
  mutate(Value=successrate ,Type = 'Agencies Favorite won')

agencies_fav_success_rate = matches %>% group_by(Agencies_fav) %>% 
summarise(total_games = n(),success = sum(AgenciesVsgame_winner=='yes'))


favorite_table= matches %>% 
  group_by(Agencies_fav_level) %>% 
  summarise(count1=n(), 
            count2=sum(AgenciesVsgame_winner=='yes'), 
            success_rate= count2/count1)

  
drow_table= matches %>% group_by(Agencies_fav_level,Agencies_fav,game_winner) %>% 
  summarise(games_count= n(), fav_won_count=sum(AgenciesVsgame_winner=='yes')) %>% 
  filter(.,game_winner=='drow')


drow_table_favorite_table = drow_table %>% 
  group_by(Agencies_fav_level) %>% 
  summarise(game_count=sum(games_count))


favorite_table= matches %>% 
  group_by(Agencies_fav_level) %>% 
  summarise(count1=n(), 
            count2=sum(AgenciesVsgame_winner=='yes'), 
            success_rate= count2/count1)


league_analysis = matches %>% 
  group_by(name, Agencies_fav_level, Agencies_fav) %>% 
  summarise(game_count = n(), 
            count_of_won = sum(AgenciesVsgame_winner=='yes'))

league_analysis = mutate(league_analysis, success_rate= count_of_won /game_count)


europe_map=leaflet() %>% addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=4.4699, lat=50.5039, popup="Belgium Jupiler League",label='Avg. Success Rate - 52.8%') %>% 
  addMarkers(lng=1.1743, lat=52.3555, popup="England Premier League",label='Avg. Success Rate - 53.1%') %>%
  addMarkers(lng=2.2137, lat=46.2276, popup="France Ligue 1",label='Avg. Success Rate - 50.4%') %>%
  addMarkers(lng=10.4515, lat=51.1657, popup="Germany 1. Bundesliga",label='Avg. Success Rate - 51.4%') %>%
  addMarkers(lng=12.5674, lat=41.8719, popup="Italy Serie A",label='Avg. Success Rate - 53.3%') %>%
  addMarkers(lng=5.2913, lat=52.1326, popup="Netherlands Eredivisie",label='Avg. Success Rate - 55.5%') %>%
  addMarkers(lng=8.2245, lat=39.3999, popup="Portugal Liga ZON Sagres", label='Avg. Success Rate - 54.5%') %>%
  addMarkers(lng=4.2518, lat=55.8333, popup="Scotland Premier League", label= 'Avg. Success Rate - 50.7%') %>%
  addMarkers(lng=3.7492, lat=40.4637, popup="Spain LIGA BBVA", label= 'Avg. Success Rate - 56.2%')



europe_map_max=leaflet() %>% addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=4.4699, lat=50.5039, popup="Belgium Jupiler League",label='Home Team/High Favored - 63.7%') %>% 
  addMarkers(lng=1.1743, lat=52.3555, popup="England Premier League",label='Home Team/High Favored - 65.6%') %>%
  addMarkers(lng=2.2137, lat=46.2276, popup="France Ligue 1",label='Away Team/High Favored - 60.8%') %>%
  addMarkers(lng=10.4515, lat=51.1657, popup="Germany 1. Bundesliga",label='Home Team/High Favored - 62.8%') %>%
  addMarkers(lng=12.5674, lat=41.8719, popup="Italy Serie A",label='Away Team/High Favored - 63.9%') %>%
  addMarkers(lng=5.2913, lat=52.1326, popup="Netherlands Eredivisie",label='Home Team/High Favored - 67.6%') %>%
  addMarkers(lng=8.2245, lat=39.3999, popup="Portugal Liga ZON Sagres", label='Home Team/High Favored - 67.57%') %>%
  addMarkers(lng=4.2518, lat=55.8333, popup="Scotland Premier League", label= 'Away Team/High Favored - 66.8%') %>%
  addMarkers(lng=3.7492, lat=40.4637, popup="Spain LIGA BBVA", label= 'Away Team/High Favored - 68.2%')


high_favored_analysis = matches %>% 
  filter(AgenciesVsgame_winner=="no" & Agencies_fav_level=='A high favorite' & Agencies_fav != 'drow') %>% 
  group_by(Agencies_fav, Agencies_fav_level,game_winner) %>% 
  summarise(count_of_games = n())


high_favored_analysis= high_favored_analysis %>% 
  mutate(total_games = ifelse(Agencies_fav=='away team', 970,3005)) %>% 
  mutate(rates = count_of_games/ total_games)








mid_odds = matches %>% mutate(mid_odd = apply(matches[,c(36,37,38)],1, median))
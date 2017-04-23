install.packages('RSQLite')

library(shinydashboard)
library(shiny)
library(RSQLite)
library(dplyr)
library(ggplot2)

con <- dbConnect(SQLite(), dbname="~/Downloads/database.sqlite")

dbListTables(con)

Match <- tbl_df(dbGetQuery(con,"SELECT * FROM Match"))
Team  <- tbl_df(dbGetQuery(con,"SELECT * FROM Team"))
Country  <- tbl_df(dbGetQuery(con,"SELECT * FROM Country"))
League   <- tbl_df(dbGetQuery(con,"SELECT * FROM League"))

#select relevant columns  #22,979 rows left

matches = select(Match, id , country_id , league_id , season , stage, date , 
	match_api_id , home_team_api_id, away_team_api_id, home_team_goal, away_team_goal, 
	contains('BW'), contains('IW'), contains('LB'), contains('WH'), contains('VC'))

# filter out rows with missing values 22,434 left

matches <- (filter(matches,
                    !is.na(BWH) & !is.na(BWD) & !is.na(BWA) & 
                    !is.na(IWH) & !is.na(IWD) & !is.na(IWA) & 
                    !is.na(LBH) & !is.na(LBD) & !is.na(LBA) &
                    !is.na(WHH) & !is.na(WHD) & !is.na(WHA) &
                    !is.na(VCH) & !is.na(VCD) & !is.na(VCA)))

# exctract the date from the date column 

library(stringr)
matches = mutate(matches, dates = str_split_fixed(matches$date, " ", 2)[ ,1])
matches$dates=as.Date(strptime(match_dates2,format = '%Y-%m-%d'))[1:22434]

# from the date column, exctract the month.
matches$match_month= as.numeric(format(matches$dates, "%m"))

# create a result column based on the games result

matches = mutate(matches, game_winner = ifelse(home_team_goal>away_team_goal,'home team',
	ifelse(home_team_goal==away_team_goal,'drow','away team')))


# - create FAVORITE column FOR each betting AGENCY

matches$BWF = ifelse(matches$BWH > matches$BWA & matches$BWD > matches$BWA, 'away team',
ifelse(matches$BWA > matches$BWH & matches$BWD > matches$BWH, 'home team',
ifelse(matches$BWA > matches$BWD & matches$BWH > matches$BWD, 'drow', 'not a clear favorite')))

matches$IWF = ifelse(matches$IWH > matches$IWA & matches$BWD > matches$IWA, 'away team',
ifelse(matches$IWA > matches$IWH & matches$IWD > matches$IWH, 'home team',
ifelse(matches$IWA > matches$IWD & matches$IWH > matches$IWD, 'drow', 'not a clear favorite')))

matches$LBF = ifelse(matches$LBH > matches$LBA & matches$LBD > matches$LBA, 'away team',
ifelse(matches$LBA > matches$LBH & matches$LBD > matches$LBH, 'home team',
ifelse(matches$LBA > matches$LBD & matches$LBH > matches$LBD, 'drow', 'not a clear favorite')))

matches$WHF = ifelse(matches$WHH > matches$WHA & matches$WHD > matches$WHA, 'away team',
ifelse(matches$WHA > matches$WHH & matches$WHD > matches$WHH, 'home team',
ifelse(matches$WHA > matches$WHD & matches$WHH > matches$WHD, 'drow', 'not a clear favorite')))

matches$VCF = ifelse(matches$VCH > matches$VCA & matches$VCD > matches$VCA, 'away team',
ifelse(matches$VCA > matches$VCH & matches$VCD > matches$VCH, 'home team',
ifelse(matches$VCA > matches$VCD & matches$VCH > matches$VCD, 'drow', 'not a clear favorite')))	


# - create mean home team victory odd
matches$HT_ODD = apply(matches[,c(12,15,18,21,24)],1, mean)
# - create mean drow  odd
matches$D_ODD = apply(matches[,c(13,16,19,22,25)],1, mean)
# - create mean away team victory odd
matches$AT_ODD = apply(matches[,c(14,17,20,23,26)],1, mean)
# - create a betting agencies favorite column
matches$Agencies_fav = ifelse(matches$HT_ODD > matches$AT_ODD & matches$D_ODD > matches$AT_ODD, 'away team',
ifelse(matches$AT_ODD > matches$HT_ODD & matches$D_ODD > matches$HT_ODD, 'home team',
ifelse(matches$AT_ODD > matches$D_ODD & matches$HT_ODD > matches$D_ODD, 'drow', 'not a clear favorite')))	

# - create a column for the difference in the odds for the results - max - min > 2  ״A high favorite"
																#  - max - min < 1  -  "A low favorite"
																#  - 1 < max - min < 2 - "A moderate favorite"

mean_cal = function(x) {
  if (max(x)-min(x)>2) {
    'A high favorite'
  } else {
    if (max(x)-min(x)<1) {
      'A low favorite'
    } else {
      'A moderate favorite'
    }
    
  }
}

matches$Agencies_fav_level = apply(matches[,c(35,36,37)],1, mean_cal)


# create a "yes/no" column for if the agencies were correct
matches$AgenciesVsgame_winner = ifelse(matches$Agencies_fav == matches$game_winner,"yes","no")

# add league name from the league table

matches = left_join(matches , League, by = 'country_id')


# Vizualisation

# relationship between the max and min of the odds
install.packages('hexbin')
library(hexbin)

min_max_odds = matches %>% mutate(., min_odd= (apply(matches[,c(36,37,38)],1, min),
max_odd = apply(matches[,c(36,37,38)],1, max))) 

ggplot(min_max_odds, aes(x=max_odd,y=min_odd)) + geom_point(size = 0.005) + 
scale_x_continuous(limits = c(1,12)) + ylim(1,3) + stat_binhex() + 
ggtitle("Scatter Plot Of Min and Max Odds Of Observations")

# agancy success rate over time

Agencies_success_rate = matches %>% select(., season, AgenciesVsgame_winner, Agencies_fav_level) %>% 
+ group_by(., season) %>% summarize (., Agencies_success = sum(AgenciesVsgame_winner=='yes'), 
count_of_games = n() ,Agencies_success_rate= Agencies_success / count_of_games)


ggplot(Agencies_success_rate, aes(x = season , y= Agencies_success_rate)) + 
geom_bar(stat="identity") + ggtitle("Agencies Success Rate over time")

# Agency favorite level breakdown

Agencies_success_rate =matches %>% select(., season, AgenciesVsgame_winner, Agencies_fav_level) %>% 
group_by(., season,Agencies_fav_level) %>% summarize (., Agencies_success = sum(AgenciesVsgame_winner=='yes'), 
count_of_games = n() ,Agencies_success_rate= Agencies_success / count_of_games)

ggplot(Agencies_success_rate, aes(x = season , y= Agencies_success_rate)) + 
geom_bar(aes(fill=Agencies_fav_level ),stat="identity") + 
ggtitle("Agencies Success Rate over time")


ggplot(Agencies_success_rate, aes(x = season , y= Agencies_success_rate)) + 
geom_bar(aes(fill=Agencies_fav_level ),stat="identity", position = 'dodge') + 
ggtitle("Agencies Success Rate over time")


# agency success rate per favorate level


match_host_rates=matches %>% select(., season, AgenciesVsgame_winner, Agencies_fav_level, game_winner) %>% 
group_by(., season,Agencies_fav_level,game_winner) %>% 
summarize (., Agencies_success = sum(AgenciesVsgame_winner=='yes'), 
count_of_games = n() ,Agencies_success_rate= Agencies_success / count_of_games)

# show the actual game winner by host ### interactive

game_winner_host_Agency_fav = matches %>% select(., season, AgenciesVsgame_winner, Agencies_fav_level, game_winner) %>% 
group_by(., season,Agencies_fav_level,game_winner) %>% summarize (., Agencies_success = sum(AgenciesVsgame_winner=='yes'), 
count_of_games = n() ,Agencies_success_rate= Agencies_success / count_of_games) %>% filter(., game_winner =='drow')

ggplot(game_winner_host_Agency_fav, aes(x= game_winner, y=Agencies_success_rate)) + geom_bar(aes(fill=Agencies_fav_level),stat = "identity", position = 'dodge')


### count of game winner by host vs. agencies fav by host

# count of game winner by host

game_winner_table = matches %>% group_by(., game_winner) %>% summarize(., count_of_game_winner = n())
game_winner_table = mutate(game_winner_table, total_games_played= sum(count_of_game_winner)) 
game_winner_table=mutate(game_winner_table, Percent_of_total_games_played= count_of_game_winner/total_games_played)

ggplot(game_winner_table, aes(x= reorder(game_winner,-Percent_of_total_games_played) , y= Percent_of_total_games_played, 
label = paste(round(Percent_of_total_games_played*100, digits= 2),"%")))+ geom_bar(stat = 'identity')+
geom_text(size = 4, position = position_stack(vjust = 0.5))

# agencies fav % of total games

agencies_fav_table = matches %>% group_by(., Agencies_fav) %>% summarise(., count_of_agencies_fav= n()) %>% 
mutate(total_games_played=22434,Percent_of_total_games_played_af= count_of_agencies_fav/total_games_played)

agencies_fav_table= agencies_fav_table %>% mutate(., total_games_played= sum(count_of_agencies_fav)) %>% 
mutate(., Percent_of_total_games_played_af= count_of_agencies_fav/total_games_played)

ggplot(agencies_fav_table, aes(x= reorder(Agencies_fav,-Percent_of_total_games_played_af), y= Percent_of_total_games_played_af, 
label = paste(round(Percent_of_total_games_played_af*100, digits= 2),"%")))+ geom_bar(stat = 'identity') + 
geom_text(size = 4, position = position_stack(vjust = 0.5))

# x axis - agencies favorite / y axis - success rate 

ggplot(match_host_rates,aes(x=reorder(Agencies_fav_level,Agencies_success_rate),y=Agencies_success_rate)) + 
geom_bar(aes(fill=game_winner),stat = 'identity',position ='dodge')



# agencies total win rate - for the dashboard

(matches %>% summarise(count_games = n(), success_ = sum(AgenciesVsgame_winner=="yes"), 
	s_rate = success_/count_games))[,3] 


# table show the success rate breakdown - Agencies favorate & favorite level & season

rates_table = matches %>% group_by(season,Agencies_fav, Agencies_fav_level) %>% summarise(count_games = n(), success_ = sum(AgenciesVsgame_winner=="yes"), s_rate = success_/count_games) %>% 
filter(.,Agencies_fav_level == 'A high favorite' & Agencies_fav == 'away team')



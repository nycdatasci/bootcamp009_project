library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

load("teamdf.rda")

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
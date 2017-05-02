library(plyr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)

load('teamdf.rda')

##Lists

fltrs <- list('Field Goals Made'= 'fgm','Field Goals Attempted'='fga','Field Goal %' = 'fg_pct',
              '3-Pointers Made'='fg3m','3-Point Attempts'='fg3a',
              'Free Throws Made' = 'ftm','Free Throws Attempted' ='fta','Free Throw Percentage' =' ft_pct',
              'Offensive Rebounds'='oreb',
              'Defensive Rebounds'='dreb',
              'Total Rebounds' = 'reb',
              'Assists'='ast',
              'Steals'='stl',
              'Blocks'='blk',
              'Turnovers'='tov',
              'Points'='pts',
              'Personal Fouls'='pf',
              'Plus Minus' = 'plus_minus')


##Tables


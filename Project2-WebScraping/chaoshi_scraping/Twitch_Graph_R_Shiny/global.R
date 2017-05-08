##############################################
# Twitch Graph -- 
# Scraping Project @ NYC Data Science Academy
# 
#
# Chao Shi
# chao.shi.datasci@gmail.com
# 5/7/2017
##############################################
library(shiny)
library(networkD3)
library(dplyr)
library(htmltools)
library(markdown)
library(DT)

source('./helpers.R')

data(MisLinks)
data(MisNodes)

# read files in -- these are processed files using Python
cinfo = read.csv('./data_safe/channelsinfo_clean.csv')
ginfo = read.csv('./data_safe/teamsinfo_clean.csv')
c2g   = read.csv('./data_safe/testc2g.csv')
g2c   = read.csv('./data_safe/testg2c.csv')


# ===== input slicing method 4.2 -- search with channel name using c2g ===
# g_name_ls = c("SoloMid","Riot Games","Cloud9","Tempo Storm")
subset = ginfo %>% 
  arrange(desc(team_view_per_day)) %>% 
  top_n(3)

g_name_ls = subset$team_name

ind_g = which(ginfo$team_name %in% g_name_ls)
c2g_n = c2g[c2g[,3] %in% (ind_g-1),]
n = dim(c2g_n)[1]


links = get_links(c2g_n)

Nodes_cu  = get_Nodes_cu() # nodes from channels
Nodes_gu  = get_Nodes_gu() # nodes from teams / groups

Nodes_gcu = rbind.data.frame(Nodes_gu,Nodes_cu)

rownames(Nodes_gcu) <- 1:dim(Nodes_gcu)[1]-1

# need to remap indecies here -- pointers now need to point to the subset of data
links$g = match(links$g, Nodes_gu$link) - 1   # remapping, -1 is package specific
links$c = match(links$c, Nodes_cu$link) + dim(Nodes_gu)[1] - 1  # cu comes after gu
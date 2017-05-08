##############################################
# Twitch Graph -- 
# Scraping Project @ NYC Data Science Academy
# 
#
# Chao Shi
# chao.shi.datasci@gmail.com
# 5/7/2017
##############################################

get_links <- function(c2g_n){
  
  links      = data.frame(c2g_n)
  links$X    = NULL
  links$wid  = rep_len(5,n)
  links
  
}

get_Nodes_cu <- function(){
  
  Nodes_c      = data.frame(links$c,cinfo$display_name[links$c+1])
  Nodes_c$size = sqrt(cinfo$view_per_day[links$c+1])   
  
  Nodes_cu = unique.data.frame(Nodes_c)
  nc       = dim(Nodes_cu)[1]
  
  Nodes_cu$group = rep_len(1,nc)
  Nodes_cu$group = cinfo$last_game[Nodes_cu$link]
  
  Nodes_cu        = Nodes_cu[,c(1,2,4,3)]
  names(Nodes_cu) = c('link','name','group','size')
  
  Nodes_cu
  
}

get_Nodes_gu <- function(){
  
  Nodes_g = data.frame(links$g,ginfo$team_name[links$g+1])
  Nodes_gu = unique.data.frame(Nodes_g)
  
  ng = dim(Nodes_gu)[1]
  
  Nodes_gu$group = rep_len('TEAMS',ng)
  Nodes_gu$size  = sqrt(ginfo$team_view_per_day[Nodes_gu$link+1])
  
  names(Nodes_gu) = c('link','name','group','size')
  Nodes_gu
  
}



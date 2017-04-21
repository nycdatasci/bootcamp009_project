library(data.table)
library(dplyr)
library(googleVis)
library(plotly)
library(akima)
library(shinydashboard)

setwd('~/Desktop/nycdsa/shiny_comet/comet_app/')

#small_body_dt <- fread(file = "./small_body_dt.dt")

small_body_join <- fread(file = "./small_body_join.dt")

sentry_dt <- fread(file = "./sentry_dt.dt")

meteor_descriptions <- fread(file = "./meteor_descriptions")

class_temp <- unique(small_body_join$class)
col_temp <- heat.colors(length(class_temp), alpha=NULL)
class_col = c(class_temp=col_temp)

#r <- 1
#theta <- seq(0, 2*pi, length.out = 100)
#phi <- seq(0, 2*pi, length.out = 100)
#x1 <- r*outer(cos(theta), sin(phi))
#y1 <- r*outer(sin(theta), sin(phi))
#z1 <- r*outer(seq(1,1,length.out=100), cos(phi))
#df <- data.frame(split(x1, 1), split(y1, 1), split(z1, 1))
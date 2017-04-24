library(maps)
library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(data.table)
library(shinydashboard)
library(DT)
library(googleVis)
library(lazyeval)
# data <- fread("Final_data.csv")
data <- readRDS('data.rds')

# create variable with colnames as choice
choice <- colnames(data)[-1]
choice_1 <- colnames(data)[c(2,3,6,7)]
choice_2 <- colnames(data)[c(5,8,9,12,16,45)]
choice_4 <-sort(unique(data$year))
na.zero <- function (x) {
  x[is.na(x)] <- 0
  return(x)
}
states = map_data("state")

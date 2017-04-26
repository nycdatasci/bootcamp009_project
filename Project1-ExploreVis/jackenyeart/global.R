# global.R
library(shiny)
library(shinydashboard)
library(ggvis)
library(DT)
library(dplyr)
library(ggplot2)
library(tidyr)
library(plotly)

topshooters = read.csv("topshooters.csv", stringsAsFactors = FALSE)[,2:6]
trimmed1 = read.csv("trimmed1.csv", stringsAsFactors = FALSE)
items = c("SHOT_DIST","CLOSE_DEF_DIST","SHOOTER_height")
items2 = names(topshooters)


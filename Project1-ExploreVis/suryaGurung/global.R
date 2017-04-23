library(shiny)
library(shinydashboard)
library(plotly)
library(ggplot2)
library(dplyr)

fundamentals <- read.csv('~/git_proj/shiny_proj/ptcFundamentals.csv', na.strings = c(' ', 'NA'))

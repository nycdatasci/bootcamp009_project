# @author Scott Dobbins
# @version 0.6.1
# @date 2017-04-22 17:35

### import useful packages ###
# shiny
library(shiny)

# import data analytic extensions
library(data.table) # helps with data input
library(dplyr)      # helps with data cleaning
library(tidyr)      # helps with data tidying

refresh_data = TRUE
full_write = TRUE

if(refresh_data) {
  # refresh the data from scratch
  source(file = 'cleaner.R')
} else {
  # just read the pre-saved data
  load('saves/Shiny_2017-04-22.RData')
}

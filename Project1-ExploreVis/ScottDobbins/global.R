# @author Scott Dobbins
# @version 0.8
# @date 2017-04-23 01:30

### import useful packages ###
library(shiny)      # app formation
# library(data.table) # data input
# library(dplyr)      # data cleaning
# library(tidyr)      # data tidying


### toggles for app behavior ###

has_data = TRUE
refresh_data = FALSE
full_write = FALSE


### global static variables ###

WW1_string = "World War I (1914-1918)"
WW2_string = "World War II (1939-1945)"
Korea_string = "Korean War (1950-1953)"
Vietnam_string = "Vietnam War (1955-1975)"


### get data ###

if(!has_data) {
  if(refresh_data) {
    # refresh the data from scratch
    source(file = 'cleaner.R')
  } else {
    # just read the pre-saved data
    load('saves/Shiny_2017-04-22.RData')
  }
}

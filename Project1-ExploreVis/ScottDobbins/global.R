# @author Scott Dobbins
# @version 0.7
# @date 2017-04-22 20:50

### import useful packages ###
library(shiny)      # app formation
# library(data.table) # data input
# library(dplyr)      # data cleaning
# library(tidyr)      # data tidying


###

has_data = TRUE
refresh_data = FALSE
full_write = FALSE

if(!has_data) {
  if(refresh_data) {
    # refresh the data from scratch
    source(file = 'cleaner.R')
  } else {
    # just read the pre-saved data
    load('saves/Shiny_2017-04-22.RData')
  }
}

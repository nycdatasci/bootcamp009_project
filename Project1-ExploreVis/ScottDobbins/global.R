# @author Scott Dobbins
# @version 0.6
# @date 2017-04-21 23:58

### import useful packages ###
# shiny
library(shiny)

# import data analytic extensions
library(data.table) # helps with data input
library(dplyr)      # helps with data cleaning
library(tidyr)      # helps with data tidying

refresh_data = TRUE
full_write = FALSE

if(refresh_data) {
  # refresh the data from scratch
  source(file = 'cleaner.R')
} else {
  # just read the pre-saved data
  WW1_sample <- fread(file = 'WW1_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
  WW2_sample <- fread(file = 'WW2_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
  Korea_sample <- fread(file = 'Korea_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
  Vietnam_sample <- fread(file = 'Vietnam_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
}

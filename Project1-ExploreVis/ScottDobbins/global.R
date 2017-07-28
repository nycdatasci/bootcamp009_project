# @author Scott Dobbins
# @version 0.9.7
# @date 2017-07-28 17:30


### Import Packages ---------------------------------------------------------

library(shiny)          # app formation
library(shinydashboard) # web display
library(leaflet)        # map source
library(leaflet.extras) # map extras
library(ggplot2)        # plots and graphs
library(data.table)     # data processing
library(dplyr)          # data processing
# library(plotly)         # pretty interactive graphs
# library(maps)           # also helps with maps
# library(htmltools)      # helps with tooltips
library(DT)             # web tables
# library(rgdal)          # map reading


### Global Values -----------------------------------------------------------

# app behavior parameters
source('parameters.R')

# file locations
source('filepaths.R')

# labels for drop-down menus
source('labels.R')


### Global Functions --------------------------------------------------------

calculate_opacity <- function(sample_number, map_zoom) {
  return(0.1 * max(1, 
                   min(10, 
                       -2 + map_zoom + ifelse(sample_number > 1024, 
                                              1, # min opacity
                                              ifelse(sample_number < 2, 
                                                     10, # max opacity
                                                     11 - log2(sample_number)))))) # intermediate opacities
}

has_bombs_data <- function() {
  return(exists("WW1_bombs") &
           exists("WW2_bombs") &
           exists("Korea_bombs2") &
           exists("Vietnam_bombs"))
}

has_clean_data <- function() {
  return(exists("WW1_clean") &
           exists("WW2_clean") &
           exists("Korea_clean2") &
           exists("Vietnam_clean"))
}


### Parallel ----------------------------------------------------------------

if(use_parallel) {
  library(parallel)
  cores <- detectCores(logical = TRUE)
  setDTthreads(cores)
}


### Get Data ----------------------------------------------------------------

if(!has_clean_data()) {
  # enable JIT compiler
  if(use_compiler) {
    library(compiler)
    enableJIT(3)
  }
  
  if(refresh_data) {
    source('reader.R')
    source('cleaner.R')
    source('processor.R')
    # } else {
    #   if(!has_clean_data()) {
    #     if(!has_bombs_data()) {
    #       source('reader.R')# except make sure it reads clean data instead
    #     }
    #     source('processor.R')
    #   }
  } else {
    load(most_recent_save_filepath)
    source('helper.R')
  }
  
  if(full_write) {
    source('saver.R')
  }
  
  # reset JIT compiler
  if(use_compiler) {
    enableJIT(0)
  }
}


### Set Keys ----------------------------------------------------------------

setkey(WW1_clean, Mission_Date, Unit_Country, Aircraft_Type, Weapon_Type)
setkey(WW2_clean, Mission_Date, Unit_Country, Aircraft_Type, Weapon_Type)
setkey(Korea_clean2, Mission_Date, Unit_Country, Aircraft_Type, Weapon_Type)
setkey(Vietnam_clean, Mission_Date, Unit_Country, Aircraft_Type, Weapon_Type)


### Create Samples ----------------------------------------------------------

if(debug_mode_on) {
  WW1_sample <- sample_n(WW1_clean, debug_sample_size)
  WW2_sample <- sample_n(WW2_clean, debug_sample_size)
  Korea_sample1 <- sample_n(Korea_clean1, debug_sample_size)
  Korea_sample2 <- sample_n(Korea_clean2, debug_sample_size)
  Vietnam_sample <- sample_n(Vietnam_clean, debug_sample_size)
}

# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


### Import Packages ---------------------------------------------------------

library(shiny)          # app formation
library(shinydashboard) # web display
library(leaflet)        # map source
library(leaflet.extras) # map extras
library(ggplot2)        # plots and graphs
library(assertthat)     # assertions for errors
library(memoise)        # caching
library(dplyr)          # data processing
library(purrr)          # data processing
library(lubridate)      # time processing
library(data.table)     # data processing
# library(plotly)         # pretty interactive graphs
# library(maps)           # also helps with maps
# library(htmltools)      # helps with tooltips
library(DT)             # web tables
# library(rgdal)          # map reading


### Global Values -----------------------------------------------------------

# app behavior parameters
source('parameters.R')
if (debug_mode_on) {
  library(testthat)     # unit testing
  library(beepr)        # sound alert
}

# file locations
source('filepaths.R')

# labels for drop-down menus
source('labels.R')


### Global Functions --------------------------------------------------------

# standard personal functions
source('utils.R')

# specific helper functions
source('helper.R')

# for plotting points on overview map
calculate_opacity <- function(sample_number, map_zoom) {
  if (sample_number > 1024) {
    return (bounded(0.1 * (map_zoom - 1), 1, 10))
  } else if (sample_number < 2) {
    return (bounded(0.1 * (map_zoom + 8), 1, 10))
  } else {
    return (bounded(0.1 * (map_zoom + 9 - log2(sample_number)), 1, 10))
  }
}

# for stat summaries on graphs
quartile_points <- function(x) {
  quantile(x, probs = c(0.25, 0.50, 0.75))
}

# for necessity of loading or generating app data
has_bombs_data <- function() {
  return (exists("WW1_bombs") &&
            exists("WW2_bombs") &&
            exists("Korea_bombs2") &&
            exists("Vietnam_bombs"))
}
has_clean_data <- function() {
  return (exists("WW1_clean") &&
            exists("WW2_clean") &&
            exists("Korea_clean2") &&
            exists("Vietnam_clean"))
}


### Parallel ----------------------------------------------------------------

if (use_parallel) {
  library(parallel)
  all_cores <- detectCores(logical = TRUE)
  real_cores_only <- detectCores(logical = FALSE)
  cores <- real_cores_only
} else {
  cores <- 1L
}
setDTthreads(cores)


### Get Data ----------------------------------------------------------------

if (!has_clean_data()) {
  if (use_compiler) {
    library(compiler)
    enableJIT(3)
  }
  
  if (refresh_data) {
    started.at <- proc.time()
    source('reader.R')
    debug_message(paste0("Read in ", timetaken(started.at)))
    started.at <- proc.time()
    source('cleaner.R')
    debug_message(paste0("Cleaned in ", timetaken(started.at)))
    if (debug_mode_on) {
      started.at <- proc.time()
      source('cleaner_test.R')
      debug_message(paste0("Tested cleaned data in ", timetaken(started.at)))
    }
    started.at <- proc.time()
    source('processor.R')
    debug_message(paste0("Processed in ", timetaken(started.at)))
    if (debug_mode_on) {
      started.at <- proc.time()
      source('processor_test.R')
      debug_message(paste0("Tested processed data in ", timetaken(started.at)))
    }
    
    if (full_write) {
      started.at <- proc.time()
      source('saver.R')
      debug_message(paste0("Saved data in ", timetaken(started.at)))
    }
  } else {
    started.at <- proc.time()
    load(most_recent_save_filepath)
    debug_message(paste0("Loaded in ", timetaken(started.at)))
  }
  
  if (use_compiler) {
    enableJIT(0)
  }
  if (debug_mode_on) beep()
}


### Set Keys ----------------------------------------------------------------

keys <- c("Mission_Date", "Unit_Country", "Aircraft_Type", "Weapon_Type")
walk(list(WW1_clean, WW2_clean, Korea_clean1, Korea_clean2, Vietnam_clean), 
     ~setkeyv(., cols = keys))


### Create Samples ----------------------------------------------------------

if (debug_mode_on) {
  WW1_sample <-     sample_n(WW1_clean,     debug_sample_size)
  WW2_sample <-     sample_n(WW2_clean,     debug_sample_size)
  Korea_sample1 <-  sample_n(Korea_clean1,  debug_sample_size)
  Korea_sample2 <-  sample_n(Korea_clean2,  debug_sample_size)
  Vietnam_sample <- sample_n(Vietnam_clean, debug_sample_size)
}


### More Globals ------------------------------------------------------------

# for iteration
war_data <- list(WW1_clean, WW2_clean, Korea_clean2, Vietnam_clean)

# DataTable
war_color <- list(WW1_color, WW2_color, Korea_color, Vietnam_color)
war_background <- list(WW1_background, WW2_background, Korea_background, Vietnam_background)
war_datatable_columns <- list(WW1_datatable_columns, WW2_datatable_columns, Korea_datatable_columns, Vietnam_datatable_columns)
war_datatable_colnames <- list(WW1_datatable_colnames, WW2_datatable_colnames, Korea_datatable_colnames, Vietnam_datatable_colnames)

# war data
war_init_bins <- list(WW1_init_bins, WW2_init_bins, Korea_init_bins, Vietnam_init_bins)
war_min_bins <- list(WW1_min_bins, WW2_min_bins, Korea_min_bins, Vietnam_min_bins)
war_max_bins <- list(WW1_max_bins, WW2_max_bins, Korea_max_bins, Vietnam_max_bins)

# set names
walk(list(war_data, 
          war_color, 
          war_background, 
          war_datatable_columns, 
          war_datatable_colnames, 
          war_init_bins, 
          war_min_bins, 
          war_max_bins), 
     ~setattr(., "names", war_tags))

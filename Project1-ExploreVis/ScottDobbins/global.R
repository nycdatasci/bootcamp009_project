# @author Scott Dobbins
# @version 0.9
# @date 2017-04-23 23:45

### import useful packages ###
library(shiny)      # app formation
library(rgdal)      # map reading
# library(data.table) # data input
# library(dplyr)      # data cleaning
# library(tidyr)      # data tidying


### toggles for app behavior ###

# data refresh
has_data = TRUE
refresh_data = FALSE
full_write = FALSE

# debug control
debug_mode_on = FALSE

# default plotting complexity
sample_num <- 1000


### global static variables ###

# war labels
WW1_string = "World War I (1914-1918)"
WW2_string = "World War II (1939-1945)"
Korea_string = "Korean War (1950-1953)"
Vietnam_string = "Vietnam War (1955-1975)"

# lists and such

WW2_categorical_choices = c("Theater of Operations", 
                         "Military Regiment", 
                         "Country of Origin", 
                         "Target Country", 
                         "Target City", 
                         "Target Type", 
                         "Target Industry", 
                         "Aircraft Model", 
                         "Target Priority", 
                         "High Explosive Bomb Type", 
                         "Incendiary Bomb Type", 
                         "Fragmentation Bomb Type", 
                         "Takeoff Country", 
                         "Takeoff City", 
                         "Sighting Method")

WW2_continuous_choices = c("Number of Attacking Aircraft", 
                           "Altitude at Bomb Drop", 
                           "Number of High Explosive Bombs", 
                           "Pounds of High Explosive Weaponry", 
                           "Number of Incendiary Bombs", 
                           "Pounds of Incendiary Weaponry", 
                           "Number of Fragmentation Bombs", 
                           "Pounds of Fragmentation Weaponry", 
                           "Total Weight of Weaponry", 
                           "Number of Aircraft Lost/Destroyed", 
                           "Number of Aircraft Damaged", 
                           "Number of Aircraft Aborted due to Weather", 
                           "Number of Aircraft Aborted due to Mechanical Issues", 
                           "Number of Aircraft Aborted for Other Reasons")

WW2_all_choices <- c(WW2_category_choices, WW2_continuous_choices)

WW2_categorical = list("Theater of Operations" = "Mission.Theater", 
                       "Military Regiment" = "Unit.Service", 
                       "Country of Origin" = "Unit.Country", 
                       "Target Country" = "Target.Country", 
                       "Target City" = "Target.City", 
                       "Target Type" = "Target.Type", 
                       "Target Industry" = "Target.Industry", 
                       "Aircraft Model" = "Aircraft.Name", 
                       "Target Priority" = "Target.Priority.Explanation", 
                       "High Explosive Bomb Type" = "Bomb.HE.Type", 
                       "Incendiary Bomb Type" = "Bomb.IC.Type", 
                       "Fragmentation Bomb Type" = "Bomb.Frag.Type", 
                       "Takeoff Country" = "Takeoff.Country", 
                       "Takeoff City" = "Takeoff.City", 
                       "Sighting Method" = "Sighting.Method.Explanation")

WW2_continuous = list("Number of Attacking Aircraft" = "Aircraft.Attacking.Num", 
                      "Altitude at Bomb Drop" = "Bomb.Altitude.Feet", 
                      "Number of High Explosive Bombs" = "Bomb.HE.Num", 
                      "Pounds of High Explosive Weaponry" = "Bomb.HE.Pounds", 
                      "Number of Incendiary Bombs" = "Bomb.IC.Num", 
                      "Pounds of Incendiary Weaponry" = "Bomb.IC.Pounds", 
                      "Number of Fragmentation Bombs" = "Bomb.Frag.Num", 
                      "Pounds of Fragmentation Weaponry" = "Bomb.Frag.Pounds", 
                      "Total Weight of Weaponry" = "Bomb.Total.Pounds", 
                      "Number of Aircraft Lost/Destroyed" = "Aircraft.Lost.Num", 
                      "Number of Aircraft Damaged" = "Aircraft.Damaged.Num", 
                      "Number of Aircraft Aborted due to Weather" = "Aircraft.Fail.WX.Num", 
                      "Number of Aircraft Aborted due to Mechanical Issues" = "Aircraft.Fail.Mech.Num", 
                      "Number of Aircraft Aborted for Other Reasons" = "Aircraft.Fail.Misc.Num")


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


# ### world map stuff ###
# # based on blog post by Kristoffer Magnusson
# # http://rpsychologist.com/working-with-shapefiles-projections-and-world-maps-in-ggplot
# 
# world_map <- readOGR(dsn="countries")
# world_map_df <- fortify(world_map)
# 
# theme_opts <- list(theme(panel.grid.minor = element_blank(),
#                          panel.grid.major = element_blank(),
#                          panel.background = element_blank(),
#                          plot.background = element_rect(fill="#e6e8ed"),
#                          panel.border = element_blank(),
#                          axis.line = element_blank(),
#                          axis.text.x = element_blank(),
#                          axis.text.y = element_blank(),
#                          axis.ticks = element_blank(),
#                          axis.title.x = element_blank(),
#                          axis.title.y = element_blank(),
#                          plot.title = element_text(size=22)))

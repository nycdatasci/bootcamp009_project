# @author Scott Dobbins
# @version 0.9.3
# @date 2017-05-01 01:30

### import useful packages ###
library(shiny)      # app formation
library(rgdal)      # map reading
# library(data.table) # data input
# library(dplyr)      # data cleaning
# library(tidyr)      # data tidying


### toggles for app behavior ###

# data refresh
if(exists("WW1_clean") & exists("WW2_clean") & exists("Korea_clean2") & exists("Vietnam_clean")) {
  has_data <- TRUE
} else {
  has_data <- FALSE
}
refresh_data <- FALSE
full_write <- FALSE

# debug control
debug_mode_on <- TRUE

# default plotting complexity
sample_num <- 1024


### global static variables ###

# war labels
WW1_string = "World War I (1914-1918)"
WW2_string = "World War II (1939-1945)"
Korea_string = "Korean War (1950-1953)"
Vietnam_string = "Vietnam War (1955-1975)"

### WW1 labels ###

WW1_categorical_choices = c("Operation Supported", 
                            "Military Regiment", 
                            "Country of Origin", 
                            "Target Country", 
                            "Target City", 
                            "Target Type", 
                            "Aircraft Model", 
                            "Bomb Type", 
                            "Takeoff Time of Day", 
                            "Takeoff Base", 
                            "Weather")

WW1_continuous_choices = c("Number of Attacking Aircraft", 
                           "Altitude at Bomb Drop", 
                           "Number of Bombs Dropped", 
                           "Weight of Bombs Dropped", 
                           "Bombload (weight of bombs per plane)", 
                           "Number of Aircraft Lost")

WW1_all_choices <- c(WW1_categorical_choices, WW1_continuous_choices)

WW1_categorical = list("Operation Supported" = "Operation", 
                       "Military Regiment" = "Unit.Service", 
                       "Country of Origin" = "Unit.Country", 
                       "Target Country" = "Target.Country", 
                       "Target City" = "Target.City", 
                       "Target Type" = "Target.Type", 
                       "Aircraft Model" = "Aircraft.Type", 
                       "Bomb Type" = "Weapons.Type", 
                       "Takeoff Time of Day" = "Takeoff.Day.Period", 
                       "Takeoff Base" = "Takeoff.Base", 
                       "Weather" = "Target.Weather")

WW1_continuous = list("Number of Attacking Aircraft" = "Aircraft.Attacking.Num", 
                      "Altitude at Bomb Drop" = "Bomb.Altitude", 
                      "Number of Bombs Dropped" = "Weapons.Expended", 
                      "Weight of Bombs Dropped" = "Weapons.Weight", 
                      "Bombload (weight of bombs per plane)" = "Aircraft.Bombload", 
                      "Number of Aircraft Lost" = "Casualties.Friendly")


### WW2 labels ###

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

WW2_all_choices <- c(WW2_categorical_choices, WW2_continuous_choices)

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


### Korea labels ###

Korea_categorical_choices = c("Military Division", 
                               "Mission Type", 
                               "Target City", 
                               "Target Type", 
                               "Aircraft Model", 
                               "Bomb Type", 
                               "Sighting Method", 
                               "Nose Fuze", 
                               "Tail Fuze")

Korea_continuous_choices = c("Number of Attacking Aircraft", 
                              "Altitude at Bomb Drop", 
                              "Number of Bombs Dropped", 
                              "Bombload (weight of bombs per plane)", 
                              "Number of Aircraft Lost", 
                              "Number of Aircraft Aborted")

Korea_all_choices <- c(Korea_categorical_choices, Korea_continuous_choices)

Korea_categorical = list("Military Division" = "Unit.Order", 
                          "Mission Type" = "Mission.Type", 
                          "Target City" = "Target.Name", 
                          "Target Type" = "Target.Type", 
                          "Aircraft Model" = "Aircraft.Type", 
                          "Bomb Type" = "Weapons.Type", 
                          "Sighting Method" = "Bomb.Sighting.Method", 
                          "Nose Fuze" = "Nose.Fuze", 
                          "Tail Fuze" = "Tail.Fuze")

Korea_continuous = list("Number of Attacking Aircraft" = "Aircraft.Attacking.Num", 
                         "Altitude at Bomb Drop" = "Bomb.Altitude.Feet.Low", 
                         "Number of Bombs Dropped" = "Weapons.Num", 
                         "Bombload (weight of bombs per plane)" = "Aircraft.Bombload.Calculated.Pounds", 
                         "Number of Aircraft Lost" = "Aircraft.Lost.Num", 
                         "Number of Aircraft Aborted" = "Aircraft.Aborted.Num")


### Vietnam labels ###

Vietnam_categorical_choices = c("Operation Supported", 
                                "Military Regiment", 
                                "Country of Origin", 
                                "Target Country", 
                                "Target Type", 
                                "Aircraft Model", 
                                "Bomb Type", 
                                "Bomb Class", 
                                "Takeoff City", 
                                "Takeoff Time of Day", 
                                "Target Control", 
                                "Target Weather", 
                                "Target Cloudcover", 
                                "Geozone")

Vietnam_continuous_choices = c("Number of Attacking Aircraft", 
                               "Altitude at Bomb Drop", 
                               "Speed at Bomb Drop", 
                               "Number of Bombs Dropped", 
                               "Number of Bombs Jettisoned", 
                               "Number of Bombs Returned", 
                               "Flight Hours")

Vietnam_all_choices <- c(Vietnam_categorical_choices, Vietnam_continuous_choices)

Vietnam_categorical = list("Operation Supported" = "Operation.Supported", 
                           "Military Regiment" = "Unit.Service", 
                           "Country of Origin" = "Unit.Country", 
                           "Target Country" = "Target.Country", 
                           "Target Type" = "Target.Type", 
                           "Aircraft Model" = "Aircraft.Root.Valid", 
                           "Bomb Type" = "Weapon.Type", 
                           "Bomb Class" = "Weapon.Type.Class", 
                           "Takeoff City" = "Takeoff.Location", 
                           "Takeoff Time of Day" = "Mission.Day.Period", 
                           "Target Control" = "Target.Control", 
                           "Target Weather" = "Target.Weather", 
                           "Target Cloudcover" = "Target.CloudCover", 
                           "Geozone" = "Target.Geozone")

Vietnam_continuous = list("Number of Attacking Aircraft" = "Aircraft.Num", 
                          "Altitude at Bomb Drop" = "Bomb.Altitude", 
                          "Speed at Bomb Drop" = "Bomb.Speed", 
                          "Number of Bombs Dropped" = "Weapons.Delivered.Num", 
                          "Number of Bombs Jettisoned" = "Weapons.Jettisoned.Num", 
                          "Number of Bombs Returned" = "Weapons.Returned.Num", 
                          "Flight Hours" = "Flight.Hours")


### get data ###

if(!has_data) {
  if(refresh_data) {
    # refresh the data from scratch
    source(file = 'cleaner.R')
  } else {
    # just read the pre-saved data
    load('saves/Shiny_2017-04-30.RData')
  }
}

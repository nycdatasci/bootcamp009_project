# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


### Overview Tab ------------------------------------------------------------

# war tags
WW1 <- "WW1"
WW2 <- "WW2"
Korea <- "Korea"
Vietnam <- "Vietnam"
war_tags <- c(WW1, WW2, Korea, Vietnam)

# war labels
WW1_label = "World War I (1914-1918)"
WW2_label = "World War II (1939-1945)"
Korea_label = "Korean War (1950-1953)"
Vietnam_label = "Vietnam War (1955-1975)"
war_labels <- c(WW1_label, WW2_label, Korea_label, Vietnam_label)

# war data tags
war_data_tags <- c("WW1", "WW2", "Korea1", "Korea2", "Vietnam")


### Data Tab ----------------------------------------------------------------

# columns
WW1_datatable_columns <-     c("Mission_Date", "Unit_Country", "Target_Country", "Target_City", "Target_Type", "Aircraft_Type", "Aircraft_Attacking_Num", "Weapon_Type", "Weapon_Expended_Num", "Weapon_Weight_Pounds")
WW2_datatable_columns <-     c("Mission_Date", "Unit_Country", "Target_Country", "Target_City", "Target_Type", "Aircraft_Type", "Aircraft_Attacking_Num", "Weapon_Type", "Weapon_Expended_Num", "Weapon_Weight_Pounds")
Korea_datatable_columns <-   c("Mission_Date", "Unit_Country",                   "Target_City", "Target_Type", "Aircraft_Type", "Aircraft_Attacking_Num", "Weapon_Type", "Weapon_Expended_Num", "Weapon_Weight_Pounds")
Vietnam_datatable_columns <- c("Mission_Date", "Unit_Country", "Target_Country",                "Target_Type", "Aircraft_Type", "Aircraft_Attacking_Num", "Weapon_Type", "Weapon_Expended_Num", "Weapon_Weight_Pounds")

# column names
WW1_datatable_colnames <-     c("Date", "Airforce", "Target Country", "Target City", "Target", "Aircraft", "# of Aircraft", "Weapon", "# of Weapons", "Explosives (lbs)")
WW2_datatable_colnames <-     c("Date", "Airforce", "Target Country", "Target City", "Target", "Aircraft", "# of Aircraft", "Weapon", "# of Weapons", "Explosives (lbs)")
Korea_datatable_colnames <-   c("Date", "Airforce",                   "Target City", "Target", "Aircraft", "# of Aircraft", "Weapon", "# of Weapons", "Explosives (lbs)")
Vietnam_datatable_colnames <- c("Date", "Airforce", "Target Country",                "Target", "Aircraft", "# of Aircraft", "Weapon", "# of Weapons", "Explosives (lbs)")


### WW1 ---------------------------------------------------------------------

WW1_categorical = list("Operation Supported" = "Operation", 
                       "Military Regiment" = "Unit_Service", 
                       "Country of Origin" = "Unit_Country", 
                       "Target Country" = "Target_Country", 
                       "Target City" = "Target_City", 
                       "Target Type" = "Target_Category", 
                       "Aircraft Model" = "Aircraft_Type", 
                       "Bomb Type" = "Weapon_Type", 
                       "Takeoff Time of Day" = "Takeoff_Day_Period", 
                       "Takeoff Base" = "Takeoff_Base", 
                       "Visibility" = "Target_Visibility", 
                       "Year" = "Year", 
                       "Month" = "Month_name")
WW1_categorical_choices = names(WW1_categorical)

WW1_continuous = list("Number of Attacking Aircraft" = "Aircraft_Attacking_Num", 
                      "Altitude at Bomb Drop" = "Bomb_Altitude_Feet", 
                      "Number of Bombs Dropped" = "Weapon_Expended_Num", 
                      "Weight of Bombs Dropped" = "Weapon_Weight_Pounds", 
                      "Bombload (weight of bombs per plane)" = "Aircraft_Bombload_Pounds", 
                      "Number of Aircraft Lost/Destroyed" = "Casualties_Friendly")
WW1_continuous_choices = names(WW1_continuous)

WW1_all_choices <- c(WW1_categorical_choices, WW1_continuous_choices)


### WW2 ---------------------------------------------------------------------

WW2_categorical = list("Theater of Operations" = "Mission_Theater", 
                       "Military Regiment" = "Unit_Service", 
                       "Country of Origin" = "Unit_Country", 
                       "Target Country" = "Target_Country", 
                       "Target City" = "Target_City", 
                       "Target Type" = "Target_Category", 
                       "Target Industry" = "Target_Industry", 
                       "Aircraft Model" = "Aircraft_Type", 
                       "Target Priority" = "Target_Priority", 
                       "Bomb Type" = "Weapon_Type", 
                       "Bomb Class" = "Weapon_Class", 
                       "Takeoff Country" = "Takeoff_Country", 
                       "Takeoff Base" = "Takeoff_Base", 
                       "Sighting Method" = "Sighting_Method", 
                       "Year" = "Year", 
                       "Month" = "Month_name")
WW2_categorical_choices = names(WW2_categorical)

WW2_continuous = list("Number of Attacking Aircraft" = "Aircraft_Attacking_Num", 
                      "Altitude at Bomb Drop" = "Bomb_Altitude_Feet", 
                      "Number of Bombs Dropped" = "Weapon_Expended_Num", 
                      "Weight of Bombs Dropped" = "Weapon_Weight_Pounds", 
                      "Number of Aircraft Lost/Destroyed" = "Aircraft_Lost_Num", 
                      "Number of Aircraft Damaged" = "Aircraft_Damaged_Num")
WW2_continuous_choices = names(WW2_continuous)

WW2_all_choices <- c(WW2_categorical_choices, WW2_continuous_choices)


### Korea -------------------------------------------------------------------

Korea_categorical = list("Military Division" = "Unit_Squadron", 
                         "Mission Type" = "Mission_Type", 
                         "Target City" = "Target_City", 
                         "Target Type" = "Target_Category", 
                         "Aircraft Model" = "Aircraft_Type", 
                         "Bomb Type" = "Weapon_Type", 
                         "Sighting Method" = "Bomb_Sighting_Method", 
                         "Nose Fuze" = "Nose_Fuze", 
                         "Tail Fuze" = "Tail_Fuze", 
                         "Year" = "Year", 
                         "Month" = "Month_name")
Korea_categorical_choices = names(Korea_categorical)

Korea_continuous = list("Number of Attacking Aircraft" = "Aircraft_Attacking_Num", 
                        "Altitude at Bomb Drop" = "Bomb_Altitude_Feet", 
                        "Number of Bombs Dropped" = "Weapon_Num", 
                        "Weight of Bombs Dropped" = "Weapon_Weight_Pounds", 
                        "Bombload (weight of bombs per plane)" = "Aircraft_Bombload_Calculated_Pounds", 
                        "Number of Aircraft Lost" = "Aircraft_Lost_Num", 
                        "Number of Aircraft Aborted" = "Aircraft_Aborted_Num")
Korea_continuous_choices = names(Korea_continuous)

Korea_all_choices <- c(Korea_categorical_choices, Korea_continuous_choices)


### Vietnam -----------------------------------------------------------------

Vietnam_categorical = list("Operation Supported" = "Operation", 
                           "Military Regiment" = "Unit_Service", 
                           "Country of Origin" = "Unit_Country", 
                           "Target Country" = "Target_Country", 
                           "Target Type" = "Target_Category", 
                           "Aircraft Model" = "Aircraft_Type", 
                           "Bomb Type" = "Weapon_Type", 
                           "Bomb Class" = "Weapon_Class", 
                           "Takeoff City" = "Takeoff_Location", 
                           "Takeoff Time of Day" = "Mission_Day_Period", 
                           "Target Control" = "Target_Control", 
                           "Target Visibility" = "Target_Visibility", 
                           "Year" = "Year", 
                           "Month" = "Month_name")
Vietnam_categorical_choices = names(Vietnam_categorical)

Vietnam_continuous = list("Number of Attacking Aircraft" = "Aircraft_Attacking_Num", 
                          "Altitude at Bomb Drop" = "Bomb_Altitude", 
                          "Number of Bombs Dropped" = "Weapon_Expended_Num", 
                          "Number of Bombs Jettisoned" = "Weapon_Jettisoned_Num", 
                          "Number of Bombs Returned" = "Weapon_Returned_Num", 
                          "Flight Hours" = "Flight_Hours")
Vietnam_continuous_choices = names(Vietnam_continuous)

Vietnam_all_choices <- c(Vietnam_categorical_choices, Vietnam_continuous_choices)


### Lookup Tables -----------------------------------------------------------

war_categorical <- list(WW1_categorical, WW2_categorical, Korea_categorical, Vietnam_categorical)
war_categorical_choices <- list(WW1_categorical_choices, WW2_categorical_choices, Korea_categorical_choices, Vietnam_categorical_choices)
war_continuous <- list(WW1_continuous, WW2_continuous, Korea_continuous, Vietnam_continuous)
war_continuous_choices <- list(WW1_continuous_choices, WW2_continuous_choices, Korea_continuous_choices, Vietnam_continuous_choices)
war_all_choices <- list(WW1_all_choices, WW2_all_choices, Korea_all_choices, Vietnam_all_choices)


### Graph Titles ------------------------------------------------------------

WW1_histogram_title <- "World War One Histogram"
WW2_histogram_title <- "World War Two Histogram"
Korea_histogram_title <- "Korean War Histogram"
Vietnam_histogram_title <- "Vietnam War Histogram"
war_histogram_title <- list(WW1_histogram_title, WW2_histogram_title, Korea_histogram_title, Vietnam_histogram_title)

WW1_sandbox_title <- "World War One Sandbox"
WW2_sandbox_title <- "World War Two Sandbox"
Korea_sandbox_title <- "Korean War Sandbox"
Vietnam_sandbox_title <- "Vietnam War Sandbox"
war_sandbox_title <- list(WW1_sandbox_title, WW2_sandbox_title, Korea_sandbox_title, Vietnam_sandbox_title)


### Map Layers --------------------------------------------------------------

WW1_overview <- "WW1_overview"
WW2_overview <- "WW2_overview"
Korea_overview <- "Korea_overview"
Vietnam_overview <- "Vietnam_overview"
war_overview <- list(WW1_overview, WW2_overview, Korea_overview, Vietnam_overview)

WW1_civilian <- "WW1_civilian"
WW2_civilian <- "WW2_civilian"
Korea_civilian <- "Korea_civilian"
Vietnam_civilian <- "Vietnam_civilian"
war_civilian <- list(WW1_civilian, WW2_civilian, Korea_civilian, Vietnam_civilian)


### Set Names ---------------------------------------------------------------

walk(list(war_categorical, 
          war_categorical_choices, 
          war_continuous, 
          war_continuous_choices, 
          war_all_choices, 
          war_histogram_title, 
          war_sandbox_title, 
          war_overview, 
          war_civilian), 
     ~setattr(., "names", war_tags))


### Dropdowns ---------------------------------------------------------------

dropdowns <- list(country = "Unit_Country", aircraft = "Aircraft_Type", weapon = "Weapon_Type")

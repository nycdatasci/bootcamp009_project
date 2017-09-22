# @author Scott Dobbins
# @version 0.9.8.2
# @date 2017-08-15 22:30


### WW1 ---------------------------------------------------------------------

debug_message("processing WW1")

# filter
WW1_clean <- WW1_bombs[!is.na(Mission_Date) & !is.na(Target_Latitude) & !is.na(Target_Longitude), ]

# delete useless columns
WW1_clean[, `:=`(ID = NULL, 
                 Mission_Num = NULL, 
                 Bomb_Damage_Assessment = NULL, 
                 Enemy_Action = NULL, 
                 Route_Details = NULL, 
                 Intel_Collected = NULL, 
                 Casualties_Friendly_Verbose = NULL)]

# add useful columns

# format columns
cols <- colnames(keep(WW1_clean, is.factor))
WW1_clean[, (cols) := lapply(.SD, refactor_and_order, empty_text), .SDcols = cols]


### WW2 ---------------------------------------------------------------------

debug_message("processing WW2")

# filter
WW2_clean <- WW2_bombs[!is.na(Mission_Date) & !is.na(Target_Latitude) & !is.na(Target_Longitude), ]

# delete useless columns
WW2_clean[, `:=`(ID = NULL, 
                 Index_Number = NULL, 
                 Target_Country_Code = NULL, 
                 Target_Code = NULL, 
                 Target_Industry_Code = NULL, 
                 Target_Latitude_Nonconverted = NULL, 
                 Target_Longitude_Nonconverted = NULL, 
                 Aircraft_Model = NULL, 
                 Mission_Type = NULL, 
                 Target_Priority_Code = NULL, 
                 Bomb_Altitude = NULL, 
                 Sighting_Method_Code = NULL, 
                 Bomb_Damage_Assessment = NULL, 
                 Ammo_Rounds = NULL, 
                 Target_Comment = NULL, 
                 Mission_Comments = NULL, 
                 Reference_Source = NULL, 
                 Database_Edit_Comments = NULL)]

# add useful columns
WW2_clean[, Unit_Service_Title := factor(if_else(Unit_Country == "USA", 
                                                 paste(Unit_Country, Unit_Service), 
                                                 as.character(Unit_Service)))]
WW2_clean[, Aircraft_Num_Total := if_else(!is.na(Aircraft_Attacking_Num), 
                                          Aircraft_Attacking_Num, 
                                  if_else(!is.na(Aircraft_Dropping_Num), 
                                          Aircraft_Dropping_Num, 
                                  if_else(!is.na(Aircraft_Airborne_Num), 
                                          Aircraft_Airborne_Num, 
                                          NA_integer_)))]
WW2_clean[, Weapon_Expended_Num := sum(Weapon_Expl_Num, Weapon_Incd_Num, Weapon_Frag_Num, na.rm = TRUE), by = seq_len(nrow(WW2_clean))]
WW2_clean[, Weapon_Expended_Num := if_else(Weapon_Expended_Num == 0L, NA_integer_, Weapon_Expended_Num)]
WW2_clean[, Weapon_Type := factor(if_else(Weapon_Expl_Type != empty_text, 
                                          as.character(Weapon_Expl_Type), 
                                  if_else(Weapon_Incd_Type != empty_text, 
                                          as.character(Weapon_Incd_Type), 
                                  if_else(Weapon_Frag_Type != empty_text, 
                                          as.character(Weapon_Frag_Type), 
                                          empty_text))))]

# reformat columns
cols <- colnames(keep(WW2_clean, is.factor))
WW2_clean[, (cols) := lapply(.SD, refactor_and_order, empty_text), .SDcols = cols]


### Korea 1 -----------------------------------------------------------------

debug_message("processing Korea 1")

# filter
Korea_clean1 <- Korea_bombs1[!is.na(Mission_Date), ]

# delete useless columns
Korea_clean1[, `:=`(ID = NULL, 
                    Unit_ID = NULL, 
                    Unit_ID2 = NULL, 
                    Unit_ID_Long = NULL, 
                    Takeoff_Latitude = NULL, 
                    Takeoff_Longitude = NULL)]

# add useful columns
Korea_clean1[, Unit_Country := factor("USA")]
Korea_clean1[, Weapon_Type := factor(empty_text)]

# format columns
cols <- colnames(keep(Korea_clean1, is.factor))
Korea_clean1[, (cols) := lapply(.SD, refactor_and_order, empty_text), .SDcols = cols]


### Korea 2 -----------------------------------------------------------------

debug_message("processing Korea 2")

# filter
Korea_clean2 <- Korea_bombs2[!is.na(Mission_Date) & !is.na(Target_Latitude) & !is.na(Target_Longitude), ]

# delete useless columns
Korea_clean2[, `:=`(Row_Number = NULL, 
                    Mission_Number = NULL, 
                    Target_JapanB = NULL, 
                    Target_UTM = NULL, 
                    Target_MGRS = NULL, 
                    Target_Latitude_Source = NULL, 
                    Target_Longitude_Source = NULL, 
                    Bomb_Altitude_Feet_Range = NULL, 
                    Aircraft_Bombload_Pounds = NULL, 
                    Aircraft_Total_Weight = NULL, 
                    Callsign = NULL, 
                    Bomb_Damage_Assessment = NULL, 
                    Reference_Source = NULL)]

# add useful columns
Korea_clean2[, Unit_Country := factor("USA")]
Korea_clean2[, Bomb_Altitude_Feet := if_else(is.na(Bomb_Altitude_Feet_High), 
                                             Bomb_Altitude_Feet_Low, 
                                             round_to_int((Bomb_Altitude_Feet_Low + Bomb_Altitude_Feet_High) / 2))]

# format columns
cols <- colnames(keep(Korea_clean2, is.factor))
Korea_clean2[, (cols) := lapply(.SD, refactor_and_order, empty_text), .SDcols = cols]


### Vietnam -----------------------------------------------------------------

debug_message("processing Vietnam")

# filter
Vietnam_clean <- Vietnam_bombs[!is.na(Mission_Date) & !is.na(Target_Latitude) & !is.na(Target_Longitude), ]

# delete useless columns
Vietnam_clean[, `:=`(Reference_Source_ID = NULL, 
                     Reference_Source_Record = NULL, 
                     Weapon_Class2 = NULL, 
                     Aircraft_Original = NULL, 
                     Aircraft_Root = NULL, 
                     Unit_Group = NULL, 
                     Unit_Squadron = NULL, 
                     Mission_Function_Code = NULL, 
                     Unit = NULL, 
                     Target_ID = NULL, 
                     Target_Origin_Coordinates = NULL, 
                     Target_Origin_Coordinates_Format = NULL, 
                     Additional_Info = NULL, 
                     ID2 = NULL, 
                     Bomb_Speed = NULL, 
                     Bomb_Damage_Assessment = NULL)]

# format columns
cols <- colnames(keep(Vietnam_clean, is.factor))
Vietnam_clean[, (cols) := lapply(.SD, refactor_and_order, empty_text), .SDcols = cols]


### prepare tooltip rows ###

debug_message("preparing tooltips WW1")
WW1_clean[, `:=`(tooltip_datetime       = date_period_time_string(date_string(Month_name, Day, Year), Takeoff_Day_Period, Takeoff_Time, empty_text), 
                 tooltip_aircraft       = aircraft_string_vectorized(aircraft_numtype_string_vectorized(Aircraft_Attacking_Num, Aircraft_Type, empty_text), Unit_Squadron, empty_text), 
                 tooltip_bombload       = bomb_string_vectorized(Weapon_Weight_Pounds, Weapon_Type, empty_text), 
                 tooltip_targetType     = target_type_string_vectorized(as.character(Target_Type, empty_text)), 
                 tooltip_targetLocation = target_location_string_vectorized(Target_City, Target_Country, empty_text))]

debug_message("preparing tooltips WW2")
WW2_clean[, `:=`(tooltip_datetime       = date_time_string(date_string(Month_name, Day, Year), Bomb_Time, empty_text), 
                 tooltip_aircraft       = aircraft_string_vectorized(aircraft_numtype_string_vectorized(Aircraft_Num_Total, Aircraft_Type, empty_text), Unit_Squadron, empty_text), 
                 tooltip_bombload       = bomb_string_vectorized(Weapon_Weight_Pounds, Weapon_Type, empty_text), 
                 tooltip_targetType     = target_type_string_vectorized(as.character(Target_Type, empty_text)), 
                 tooltip_targetLocation = target_location_string_vectorized(Target_City, Target_Country, empty_text))]

debug_message("preparing tooltips Korea")
Korea_clean2[, `:=`(tooltip_datetime       = date_string(Month_name, Day, Year), 
                    tooltip_aircraft       = aircraft_string_vectorized(aircraft_numtype_string_vectorized(Aircraft_Attacking_Num, Aircraft_Type, empty_text), Unit_Squadron, empty_text), 
                    tooltip_bombload       = bomb_string_vectorized(Weapon_Weight_Pounds, Weapon_Type, empty_text), 
                    tooltip_targetType     = target_type_string_vectorized(as.character(Target_Type, empty_text)), 
                    tooltip_targetLocation = target_area_string_vectorized(Target_Name, empty_text))]

debug_message("preparing tooltips Vietnam")
Vietnam_clean[, `:=`(tooltip_datetime       = date_period_time_string(date_string(Month_name, Day, Year), Mission_Day_Period, Bomb_Time_Start, empty_text), 
                     tooltip_aircraft       = paste0(aircraft_numtype_string_vectorized(Aircraft_Attacking_Num, Aircraft_Type, empty_text), " dropped"), 
                     tooltip_bombload       = bomb_string_vectorized(Weapon_Weight_Pounds, Weapon_Type, empty_text), 
                     tooltip_targetType     = target_type_string_vectorized(as.character(Target_Type, empty_text)), 
                     tooltip_targetLocation = target_area_string_vectorized(Target_Country, empty_text))]


### create tooltips ###

debug_message("tooltips WW1")
WW1_clean[, tooltip := paste(tooltip_datetime, 
                             tooltip_aircraft, 
                             tooltip_bombload, 
                             tooltip_targetType, 
                             tooltip_targetLocation, 
                             sep = "<br>")]

debug_message("tooltips WW2")
WW2_clean[, tooltip := paste(tooltip_datetime, 
                             tooltip_aircraft, 
                             tooltip_bombload, 
                             tooltip_targetType, 
                             tooltip_targetLocation, 
                             sep = "<br>")]

debug_message("tooltips Korea2")
Korea_clean2[, tooltip := paste(tooltip_datetime, 
                                tooltip_aircraft, 
                                tooltip_bombload, 
                                tooltip_targetType, 
                                tooltip_targetLocation, 
                                sep = "<br>")]

debug_message("tooltips Vietnam")
Vietnam_clean[, tooltip := paste(tooltip_datetime, 
                                 tooltip_aircraft, 
                                 tooltip_bombload, 
                                 tooltip_targetType, 
                                 tooltip_targetLocation, 
                                 sep = "<br>")]


### Unique Target Locations -------------------------------------------------

debug_message("unique WW1")
WW1_unique <- unique(WW1_clean, by = c("Target_Latitude", "Target_Longitude"))
debug_message("unique WW2")
WW2_unique <- unique(WW2_clean, by = c("Target_Latitude", "Target_Longitude"))
debug_message("unique Korea1")
Korea_unique1 <- copy(Korea_clean1)
debug_message("unique Korea2")
Korea_unique2 <- unique(Korea_clean2, by = c("Target_Latitude", "Target_Longitude"))
debug_message("unique Vietnam")
Vietnam_unique <- unique(Vietnam_clean, by = c("Target_Latitude", "Target_Longitude"))


### Combine Data ------------------------------------------------------------

#plyr::rbind.fill() to combine data frames that don't have the same (or same number of) columns

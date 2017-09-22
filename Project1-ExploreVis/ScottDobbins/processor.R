# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


### WW1 ---------------------------------------------------------------------

debug_message("processing WW1")

# filter
WW1_clean <- copy(WW1_bombs[!is.na(Mission_Date) & !is.na(Target_Latitude) & !is.na(Target_Longitude), ])

# delete useless columns
WW1_clean[, `:=`(ID = NULL, 
                 Mission_Num = NULL, 
                 Callsign = NULL, 
                 Bomb_Damage_Assessment = NULL, 
                 Enemy_Action = NULL, 
                 Route_Details = NULL, 
                 Target_Weather = NULL, 
                 Intel_Collected = NULL, 
                 Aircraft_Lost_Verbose = NULL)]


### WW2 ---------------------------------------------------------------------

debug_message("processing WW2")

# filter
WW2_clean <- copy(WW2_bombs[!is.na(Mission_Date) & !is.na(Target_Latitude) & !is.na(Target_Longitude), ])

# delete useless columns
WW2_clean[, `:=`(ID = NULL, 
                 Index_Number = NULL, 
                 Target_Country_Code = NULL, 
                 Target_City_Code = NULL, 
                 Target_Industry_Code = NULL, 
                 Target_Latitude_Nonconverted = NULL, 
                 Target_Longitude_Nonconverted = NULL, 
                 Aircraft_Model = NULL, 
                 Mission_Type = NULL, 
                 Callsign = NULL, 
                 Target_Priority_Code = NULL, 
                 Bomb_Altitude = NULL, 
                 Aircraft_Spares_Num = NULL, 
                 Aircraft_Fail_WX_Num = NULL, 
                 Aircraft_Fail_Mech_Num = NULL, 
                 Aircraft_Fail_Misc_Num = NULL, 
                 Sighting_Method_Code = NULL, 
                 Bomb_Damage_Assessment = NULL, 
                 Ammo_Rounds = NULL, 
                 Target_Comment = NULL, 
                 Mission_Comments = NULL, 
                 Reference_Source = NULL, 
                 Database_Edit_Comments = NULL)]

# add useful columns
WW2_clean[, Weapon_Expended_Num := sum(Weapon_Expl_Num, Weapon_Incd_Num, Weapon_Frag_Num, na.rm = TRUE), by = seq_len(nrow(WW2_clean))]
WW2_clean[, Weapon_Expended_Num := if_else(Weapon_Expended_Num == 0L, NA_integer_, Weapon_Expended_Num)]

WW2_clean[, Aircraft_Struck_Num := sum(Aircraft_Lost_Num, Aircraft_Damaged_Num, na.rm = TRUE), by = seq_len(nrow(WW2_clean))]

WW2_clean[, `:=`(Weapon_Type = "", 
                 Weapon_Class = "")]
WW2_clean[Weapon_Expl_Type != "", 
          `:=`(Weapon_Type = as.character(Weapon_Expl_Type), 
               Weapon_Class = "explosive")]
WW2_clean[Weapon_Type == "" & 
            Weapon_Incd_Type != "", 
          `:=`(Weapon_Type = as.character(Weapon_Incd_Type), 
               Weapon_Class = "incendiary")]
WW2_clean[Weapon_Type == "" & 
            Weapon_Frag_Type != "", 
          `:=`(Weapon_Type = as.character(Weapon_Frag_Type), 
               Weapon_Class = "fragmentary")]
cols <- c("Weapon_Type", "Weapon_Class")
WW2_clean[, (cols) := lapply(.SD, factor), .SDcols = cols]


### Korea 1 -----------------------------------------------------------------

debug_message("processing Korea 1")

# filter
Korea_clean1 <- copy(Korea_bombs1[!is.na(Mission_Date), ])

# delete useless columns
Korea_clean1[, `:=`(ID = NULL, 
                    Unit_ID = NULL, 
                    Unit_ID2 = NULL, 
                    Unit_ID_Long = NULL, 
                    Takeoff_Latitude = NULL, 
                    Takeoff_Longitude = NULL)]

# add useful columns
Korea_clean1[, Aircraft_Lost_Num := sum(Aircraft_Lost_Enemy_Air_Num, Aircraft_Lost_Enemy_Ground_Num, Aircraft_Lost_Enemy_Unknown_Num, Aircraft_Lost_Other_Num, na.rm = TRUE), by = seq_len(nrow(Korea_clean1))]
Korea_clean1[, Aircraft_Struck_Num := sum(Aircraft_Lost_Num, Aircraft_Damaged_Num, na.rm = TRUE), by = seq_len(nrow(Korea_clean1))]


### Korea 2 -----------------------------------------------------------------

debug_message("processing Korea 2")

# filter
Korea_clean2 <- copy(Korea_bombs2[!is.na(Mission_Date) & !is.na(Target_Latitude) & !is.na(Target_Longitude), ])

# delete useless columns
Korea_clean2[, `:=`(Row_Number = NULL, 
                    Mission_Number = NULL, 
                    Sortie_Duplicates = NULL, 
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
Korea_clean2[, Bomb_Altitude_Feet := if_else(is.na(Bomb_Altitude_Feet_High), 
                                             Bomb_Altitude_Feet_Low, 
                                             round_to_int((Bomb_Altitude_Feet_Low + Bomb_Altitude_Feet_High) / 2))]


### Vietnam -----------------------------------------------------------------

debug_message("processing Vietnam")

# filter
Vietnam_clean <- copy(Vietnam_bombs[!is.na(Mission_Date) & !is.na(Target_Latitude) & !is.na(Target_Longitude), ])

# delete useless columns
Vietnam_clean[, `:=`(ID = NULL, 
                     Reference_Source_ID = NULL, 
                     Reference_Source_Record = NULL, 
                     Weapon_Class2 = NULL, 
                     Aircraft_Original = NULL, 
                     Aircraft_Root = NULL, 
                     Unit_Group = NULL, 
                     Mission_Function_Code = NULL, 
                     Mission_ID = NULL, 
                     Unit = NULL, 
                     Target_ID = NULL, 
                     Target_Origin_Coordinates = NULL, 
                     Target_Origin_Coordinates_Format = NULL, 
                     Target_CloudCover = NULL, 
                     Target_Weather = NULL, 
                     Weapon_Weight_Loaded = NULL, 
                     Additional_Info = NULL, 
                     ID2 = NULL, 
                     Callsign = NULL, 
                     Bomb_Speed = NULL, 
                     Bomb_Damage_Assessment = NULL)]


### Refactor ----------------------------------------------------------------

clean_data <- list(WW1_clean, 
                   WW2_clean, 
                   Korea_clean1, 
                   Korea_clean2, 
                   Vietnam_clean)
setattr(clean_data, "names", war_data_tags)

walk(clean_data, 
     function(dt) {
       cols <- dt %>% keep(is.factor) %>% discard(is.ordered) %>% colnames
       dt[, (cols) := lapply(.SD, refactor_and_order, empty_text), .SDcols = cols]})


### prepare tooltip rows ###

debug_message("preparing tooltips")
WW1_clean[, `:=`(tooltip_datetime       = date_period_time_string(date_string(Month_name, Day, Year), Takeoff_Day_Period, Takeoff_Time, empty_text), 
                 tooltip_targetLocation = target_location_string_vectorized(Target_City, Target_Country, empty_text))]

WW2_clean[, `:=`(tooltip_datetime       = date_time_string(date_string(Month_name, Day, Year), Bomb_Time, empty_text), 
                 tooltip_targetLocation = target_location_string_vectorized(Target_City, Target_Country, empty_text))]

Korea_clean2[, `:=`(tooltip_datetime       = date_string(Month_name, Day, Year), 
                    tooltip_targetLocation = target_area_string_vectorized(Target_City, empty_text))]

Vietnam_clean[, `:=`(tooltip_datetime       = date_period_time_string(date_string(Month_name, Day, Year), Mission_Day_Period, Bomb_Time_Start, empty_text), 
                     tooltip_targetLocation = target_area_string_vectorized(Target_Country, empty_text))]

walk(clean_data[c(1,2,4,5)], 
     function(dt) dt[, `:=`(tooltip_aircraft   = aircraft_string_vectorized(aircraft_numtype_string_vectorized(Aircraft_Attacking_Num, Aircraft_Type, empty_text), Unit_Title, empty_text), 
                            tooltip_bombload   = bomb_string_vectorized(Weapon_Weight_Pounds, Weapon_Type, empty_text), 
                            tooltip_targetType = target_type_string_vectorized(Target_Type, empty_text))])


### create tooltips ###

debug_message("stitching tooltips")
walk(clean_data[c(1,2,4,5)], 
     function(dt) dt[, tooltip := paste(tooltip_datetime, 
                                        tooltip_aircraft, 
                                        tooltip_bombload, 
                                        tooltip_targetType, 
                                        tooltip_targetLocation, 
                                        sep = "<br>")])


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

unique_data <- list(WW1_unique, 
                    WW2_unique, 
                    Korea_unique1, 
                    Korea_unique2, 
                    Vietnam_unique)
setattr(unique_data, "names", war_data_tags)


### Combine Data ------------------------------------------------------------

#plyr::rbind.fill() to combine data frames that don't have the same (or same number of) columns

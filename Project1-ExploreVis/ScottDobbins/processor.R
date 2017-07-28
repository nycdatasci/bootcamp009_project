# @author Scott Dobbins
# @version 0.9.7
# @date 2017-07-28 17:30


### WW1 ---------------------------------------------------------------------

if(debug_mode_on) print("cleaning WW1")

# filter
WW1_clean <- WW1_bombs[!is.na(Mission_Date)
                       & Target_Latitude <= 90 & Target_Latitude >= -90 
                       & Target_Longitude <= 180 & Target_Longitude >= -180 
                       & !(Target_Latitude == 0 & Target_Longitude == 0)
                       & (Bomb_Altitude_Feet < 100000 | is.na(Bomb_Altitude_Feet)), ]

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
WW1_clean[, (cols) := mclapply(.SD, ordered_empty_at_end, empty_string_text, mc.cores = cores), .SDcols = cols]


### WW2 ---------------------------------------------------------------------

if(debug_mode_on) print("cleaning WW2")

# filter
WW2_clean <- WW2_bombs[!is.na(Mission_Date)
                       & Target_Latitude <= 90 & Target_Latitude >= -90 
                       & Target_Longitude <= 180 & Target_Longitude >= -180 
                       & !(Target_Latitude == 0 & Target_Longitude == 0)
                       & (Bomb_Altitude_Feet < 100000 | is.na(Bomb_Altitude_Feet)), ]

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
WW2_clean[, Unit_Service_Title := factor(ifelse(Unit_Country == "USA", 
                                                paste(Unit_Country, Unit_Service), 
                                                as.character(Unit_Service)))]
WW2_clean[, Aircraft_Num_Total := ifelse(!is.na(Aircraft_Attacking_Num), 
                                         Aircraft_Attacking_Num, 
                                  ifelse(!is.na(Aircraft_Dropping_Num), 
                                         Aircraft_Dropping_Num, 
                                  ifelse(!is.na(Aircraft_Airborne_Num), 
                                         Aircraft_Airborne_Num, 
                                         NA_integer_)))]
WW2_clean[, Weapon_Expended_Num := ifelse(is.na(Weapon_Expl_Num), 0, Weapon_Expl_Num) + 
                                   ifelse(is.na(Weapon_Incd_Num), 0, Weapon_Incd_Num) + 
                                   ifelse(is.na(Weapon_Frag_Num), 0, Weapon_Frag_Num)]
WW2_clean[, Weapon_Expended_Num := ifelse(Weapon_Expended_Num == 0, NA_integer_, Weapon_Expended_Num)]
WW2_clean[, Weapon_Type := factor(ifelse(Weapon_Expl_Type != "unspecified", 
                                         as.character(Weapon_Expl_Type), 
                                  ifelse(Weapon_Incd_Type != "unspecified", 
                                         as.character(Weapon_Incd_Type), 
                                  ifelse(Weapon_Frag_Type != "unspecified", 
                                         as.character(Weapon_Frag_Type), 
                                         empty_string_text))))]

# reformat columns
cols <- colnames(keep(WW2_clean, is.factor))
WW2_clean[, (cols) := mclapply(.SD, ordered_empty_at_end, empty_string_text, mc.cores = cores), .SDcols = cols]


### Korea 1 -----------------------------------------------------------------

if(debug_mode_on) print("cleaning Korea 1")

# filter
Korea_clean1 <- Korea_bombs1[!is.na(Mission_Date), ]

# delete useless columns
Korea_clean1[, `:=`(ID = NULL, 
                    Unit_ID = NULL, 
                    Unit_ID2 = NULL, 
                    Unit_ID_Long = NULL)]

# add useful columns
Korea_clean1[, Unit_Country := factor("USA")]
Korea_bombs1[, Weapon_Weight_Pounds := as.integer(round(Weapon_Weight_Tons * 2000))]

# format columns
cols <- colnames(keep(Korea_clean1, is.factor))
Korea_clean1[, (cols) := mclapply(.SD, ordered_empty_at_end, empty_string_text, mc.cores = cores), .SDcols = cols]


### Korea 2 -----------------------------------------------------------------

if(debug_mode_on) print("cleaning Korea 2")

# filter
Korea_clean2 <- Korea_bombs2[!is.na(Mission_Date)
                             & Target_Latitude <= 90 & Target_Latitude >= -90 
                             & Target_Longitude <= 180 & Target_Longitude >= -180 
                             & !(Target_Latitude == 0 & Target_Longitude == 0)
                             & (Bomb_Altitude_Feet_Low < 100000 | is.na(Bomb_Altitude_Feet_Low)), ]

# delete useless columns
Korea_clean2[, `:=`(Row_Number = NULL, 
                    Mission_Number = NULL, 
                    Target_JapanB = NULL, 
                    Target_UTM = NULL, 
                    Target_MGRS = NULL, 
                    Target_Latitude_Source = NULL, 
                    Target_Longitude_Source = NULL, 
                    Aircraft_Bombload_Pounds = NULL, 
                    Aircraft_Total_Weight = NULL, 
                    Callsign = NULL, 
                    Bomb_Damage_Assessment = NULL, 
                    Reference_Source = NULL)]

# add useful columns
Korea_clean2[, Unit_Country := factor("USA")]
Korea_clean2[, Weapon_Weight_Pounds := Aircraft_Attacking_Num * Aircraft_Bombload_Calculated_Pounds]

# format columns
cols <- colnames(keep(Korea_clean2, is.factor))
Korea_clean2[, (cols) := mclapply(.SD, ordered_empty_at_end, empty_string_text, mc.cores = cores), .SDcols = cols]


### Vietnam -----------------------------------------------------------------

if(debug_mode_on) print("cleaning Vietnam")

# filter
Vietnam_clean <- Vietnam_bombs[!is.na(Mission_Date)
                               & Target_Latitude <= 90 & Target_Latitude >= -90 
                               & Target_Longitude <= 180 & Target_Longitude >= -180 
                               & !(Target_Latitude == 0 & Target_Longitude == 0)
                               & (Bomb_Altitude < 100000 | is.na(Bomb_Altitude)), ]

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

# add useful columns
Vietnam_clean[, Weapon_Weight_Pounds := Weapon_Expended_Num * Weapon_Unit_Weight]

# format columns
cols <- colnames(keep(Vietnam_clean, is.factor))
Vietnam_clean[, (cols) := mclapply(.SD, ordered_empty_at_end, empty_string_text, mc.cores = cores), .SDcols = cols]


### prepare tooltip rows ###

if(debug_mode_on) print("preparing tooltips WW1")
WW1_clean[, `:=`(tooltip_datetime = date_period_time_string(date_string(Month_name, Day, Year), Takeoff_Day_Period, Takeoff_Time), 
                 tooltip_aircraft = aircraft_string_vectorized(aircraft_numtype_string_vectorized(Aircraft_Attacking_Num, Aircraft_Type), Unit_Squadron), 
                 tooltip_bombload = bomb_weight_string_vectorized(Weapon_Weight_Pounds), 
                 tooltip_targetType = target_type_string_vectorized(as.character(Target_Type)), 
                 tooltip_targetLocation = target_location_string_vectorized(Target_City, Target_Country))]

if(debug_mode_on) print("preparing tooltips WW2")
WW2_clean[, `:=`(tooltip_datetime = date_string(Month_name, Day, Year), 
                 tooltip_aircraft = aircraft_string_vectorized(aircraft_numtype_string_vectorized(Aircraft_Num_Total, Aircraft_Type), Unit_Squadron), 
                 tooltip_bombload = bomb_weight_string_vectorized(Weapon_Weight_Pounds), 
                 tooltip_targetType = target_type_string_vectorized(as.character(Target_Type)), 
                 tooltip_targetLocation = target_location_string_vectorized(Target_City, Target_Country))]

if(debug_mode_on) print("preparing tooltips Korea")
Korea_clean2[, `:=`(tooltip_datetime = date_string(Month_name, Day, Year), 
                    tooltip_aircraft = aircraft_string_vectorized(aircraft_numtype_string_vectorized(Aircraft_Attacking_Num, Aircraft_Type), Unit_Squadron), 
                    tooltip_bombload = bomb_weight_string_vectorized(Weapon_Weight_Pounds), 
                    tooltip_targetType = target_type_string_vectorized(as.character(Target_Type)), 
                    tooltip_targetLocation = target_area_string_vectorized(Target_Name))]

if(debug_mode_on) print("preparing tooltips Vietnam")
Vietnam_clean[, `:=`(tooltip_datetime = date_string(Month_name, Day, Year), 
                     tooltip_aircraft = paste0(aircraft_numtype_string_vectorized(Aircraft_Attacking_Num, Aircraft_Type), " dropped"), 
                     tooltip_bombload = bomb_weight_string_vectorized(Weapon_Weight_Pounds), 
                     tooltip_targetType = target_type_string_vectorized(as.character(Target_Type)), 
                     tooltip_targetLocation = target_area_string_vectorized(Target_Country))]


### create tooltips ###

if(debug_mode_on) print("tooltips WW1")
WW1_clean[, tooltip := paste(tooltip_datetime, 
                             tooltip_aircraft, 
                             tooltip_bombload, 
                             tooltip_targetType, 
                             tooltip_targetLocation, 
                             sep = "<br>")]

if(debug_mode_on) print("tooltips WW2")
WW2_clean[, tooltip := paste(tooltip_datetime, 
                             tooltip_aircraft, 
                             tooltip_bombload, 
                             tooltip_targetType, 
                             tooltip_targetLocation, 
                             sep = "<br>")]

if(debug_mode_on) print("tooltips Korea2")
Korea_clean2[, tooltip := paste(tooltip_datetime, 
                                tooltip_aircraft, 
                                tooltip_bombload, 
                                tooltip_targetType, 
                                tooltip_targetLocation, 
                                sep = "<br>")]

if(debug_mode_on) print("tooltips Vietnam")
Vietnam_clean[, tooltip := paste(tooltip_datetime, 
                                 tooltip_aircraft, 
                                 tooltip_bombload, 
                                 tooltip_targetType, 
                                 tooltip_targetLocation, 
                                 sep = "<br>")]


### Unique Target Locations -------------------------------------------------

if(debug_mode_on) print("unique WW1")
WW1_unique <- unique(WW1_clean, by = c("Target_Latitude", "Target_Longitude"))
if(debug_mode_on) print("unique WW2")
WW2_unique <- unique(WW2_clean, by = c("Target_Latitude", "Target_Longitude"))
if(debug_mode_on) print("unique Korea1")
Korea_unique1 <- copy(Korea_clean1)
if(debug_mode_on) print("unique Korea2")
Korea_unique2 <- unique(Korea_clean2, by = c("Target_Latitude", "Target_Longitude"))
if(debug_mode_on) print("unique Vietnam")
Vietnam_unique <- unique(Vietnam_clean, by = c("Target_Latitude", "Target_Longitude"))

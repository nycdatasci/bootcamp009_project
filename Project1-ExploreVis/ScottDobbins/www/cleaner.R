# @author Scott Dobbins
# @version 0.9.8.2
# @date 2017-08-15 22:30


### Fix Dates ---------------------------------------------------------------

debug_message("cleaning date columns")

WW1_bombs[,     c("Year", "Month", "Day") := tstrsplit(Mission_Date, "-", fixed = TRUE, keep = 1:3)]
WW2_bombs[,     c("Month", "Day", "Year") := tstrsplit(Mission_Date, "/", fixed = TRUE, keep = 1:3)]
Korea_bombs1[,  c("Month", "Day", "Year") := tstrsplit(Mission_Date, "/", fixed = TRUE, keep = 1:3)]
Korea_bombs2[,  c("Month", "Day", "Year") := tstrsplit(Mission_Date, "/", fixed = TRUE, keep = 1:3)]
Vietnam_bombs[, c("Year", "Month", "Day") := tstrsplit(Mission_Date, "-", fixed = TRUE, keep = 1:3)]

Vietnam_bombs[is.na(Month), 
              `:=`(Day = substr(Year, 7, 8),
                   Month = substr(Year, 5, 6), 
                   Year = substr(Year, 1, 4))]

Vietnam_bombs[is.na(Mission_Date), 
              `:=`(Mission_Date = paste(Year, Month, Day, sep = "-"))]

cols <- c("Year", "Month", "Day")
WW1_bombs[, (cols) := lapply(.SD, factor), .SDcols = cols]
WW2_bombs[, (cols) := lapply(.SD, factor), .SDcols = cols]
Korea_bombs1[, (cols) := lapply(.SD, factor), .SDcols = cols]
Korea_bombs2[, (cols) := lapply(.SD, factor), .SDcols = cols]
Vietnam_bombs[, (cols) := lapply(.SD, factor), .SDcols = cols]

Korea_bombs1[["Year"]] %>% 
  format_levels(function(x) paste0("19", x))
Korea_bombs2[["Year"]] %>% 
  format_levels(function(x) paste0("19", x))

WW1_bombs[,     Month_name := Month]
WW2_bombs[,     Month_name := Month]
Korea_bombs1[,  Month_name := Month]
Korea_bombs2[,  Month_name := Month]
Vietnam_bombs[, Month_name := Month]

WW1_bombs[["Month_name"]] %>% 
  format_levels(month_num_padded_to_name)
WW2_bombs[["Month_name"]] %>% 
  format_levels(month_num_to_name)
Korea_bombs1[["Month_name"]] %>% 
  format_levels(month_num_to_name)
Korea_bombs2[["Month_name"]] %>% 
  format_levels(month_num_to_name)
Vietnam_bombs[["Month_name"]] %>% 
  format_levels(month_num_padded_to_name)

WW1_bombs[,     Mission_Date := ymd(Mission_Date)]
WW2_bombs[,     Mission_Date := mdy(Mission_Date)]
Korea_bombs1[,  Mission_Date := mdy(Mission_Date) - years(100)]
Korea_bombs2[,  Mission_Date := mdy(Mission_Date) - years(100)]
Vietnam_bombs[, Mission_Date := ymd(Mission_Date)]


### Set Keys ----------------------------------------------------------------

debug_message("setting keys")

walk(list(WW1_bombs, WW2_bombs, Korea_bombs1, Korea_bombs2, Vietnam_bombs), 
     ~setkeyv(., "Mission_Date"))


### WW1 Edits ---------------------------------------------------------------

debug_message("cleaning WW1")

# temporary type fixes
cols <- c("ID", 
          "Mission_Num", 
          "Aircraft_Attacking_Num", 
          "Weapon_Expended_Num", 
          "Casualties_Friendly", 
          "Bomb_Altitude_Feet")
WW1_bombs[, (cols) := lapply(.SD, as.integer), .SDcols = cols]

# general fixes, numerics
cols <- c("Aircraft_Bombload_Pounds", 
          "Weapon_Weight_Pounds")
WW1_bombs[, (cols) := lapply(.SD, round_to_int), .SDcols = cols]

# specific fixes, numerics
WW1_bombs[Aircraft_Attacking_Num == 0L | Aircraft_Attacking_Num >= 99L, 
          `:=`(Aircraft_Attacking_Num = NA_integer_)]

WW1_bombs[Weapon_Expended_Num == 0L, 
          `:=`(Weapon_Expended_Num = NA_integer_)]

WW1_bombs[Weapon_Weight_Pounds == 0L, 
          `:=`(Weapon_Weight_Pounds = NA_integer_)]

WW1_bombs[Bomb_Altitude_Feet == 0L, 
          `:=`(Bomb_Altitude_Feet = NA_integer_)]
WW1_bombs[Bomb_Altitude_Feet > WW1_altitude_max_feet, 
          `:=`(Bomb_Altitude_Feet = WW1_altitude_max_feet)]

WW1_bombs[Target_Latitude %!between% c(-90, 90), 
          `:=`(Target_Latitude = NA_real_)]

WW1_bombs[Target_Longitude %!between% c(-180, 180), 
          `:=`(Target_Latitude = NA_real_)]

WW1_bombs[Target_Latitude == 0 & Target_Longitude == 0, 
          `:=`(Target_Latitude = NA_real_, 
               Target_Longitude = NA_real_)]

# general fixes, times
WW1_bombs[, Takeoff_Time := substr(Takeoff_Time, 12, 16)]

# standard formatting
WW1_bombs %>% keep(is.factor) %>% 
  format_levels_by_col(remove_bad_formatting)

# editing string levels
WW1_bombs[["Unit_Squadron"]] %>% 
  recode_similar_levels(exact = TRUE, 
                        changes = c("GROUP" = "GRP", 
                                    "SQUADRON" = "SQDN"))

WW1_bombs[["Weapon_Type"]] %>% 
  recode_similar_levels(exact = TRUE, 
                        changes = c(" KG" = " KILO"))

WW1_bombs[["Target_City"]] %>% 
  recode_similar_levels(exact = TRUE, 
                        changes = c(" OF " = "; ")) %>% 
  drop_levels(drop = "OTHER")

WW1_bombs[["Operation"]] %>% 
  drop_levels(drop = "WW I")

WW1_bombs[["Target_Type"]] %>% 
  drop_similar_levels(exact = TRUE, 
                      drop = "UNKNOWN") %>% 
  format_levels(remove_parentheticals %,% cleanup_targets %,% tolower)

WW1_bombs[["Route_Details"]] %>% 
  drop_levels(drop = "NONE")

WW1_bombs %>% select("Takeoff_Day_Period", 
                     "Weapon_Type", 
                     "Target_Weather") %>% 
  format_levels_by_col(tolower)

WW1_bombs[["Target_Country"]] %>% 
  format_levels(capitalize_from_caps)

WW1_bombs %>% select("Operation", 
                     "Unit_Squadron", 
                     "Route_Details", 
                     "Target_City", 
                     "Takeoff_Base") %>% 
  format_levels_by_col(proper_noun_phrase_vectorized)

WW1_bombs %>% select("Unit_Country", 
                     "Unit_Service") %>% 
  format_levels_by_col(proper_noun_from_caps_vectorized)

WW1_bombs[["Aircraft_Type"]] %>% 
  format_levels(format_aircraft_types %,% proper_noun_phrase_aircraft_vectorized)


### WW2 Edits ---------------------------------------------------------------

debug_message("cleaning WW2")

# temporary type fixes
cols <- c("Aircraft_Attacking_Num", 
          "Bomb_Altitude_Feet", 
          "Weapon_Expl_Num", 
          "Weapon_Incd_Num", 
          "Weapon_Frag_Num", 
          "Weapon_Expl_Pounds", 
          "Weapon_Incd_Pounds", 
          "Weapon_Frag_Pounds", 
          "Weapon_Weight_Pounds", 
          "Aircraft_Lost_Num", 
          "Aircraft_Damaged_Num", 
          "Aircraft_Dropping_Num", 
          "Aircraft_Spares_Num", 
          "Aircraft_Fail_WX_Num", 
          "Aircraft_Fail_Mech_Num", 
          "Aircraft_Fail_Misc_Num")
WW2_bombs[, (cols) := lapply(.SD, as.integer), .SDcols = cols]

# quick fixes
WW2_bombs %>% 
  drop_levels_by_col(drop = "0", 
                     cols = c("Weapon_Expl_Type", 
                              "Weapon_Incd_Type", 
                              "Weapon_Frag_Type"))

# new columns
WW2_bombs[, Weapon_Expl_Unit_Weight := grem(pattern = "[^0-9][ -~]*", Weapon_Expl_Type)]
WW2_bombs[, Weapon_Expl_Unit_Weight := as.integer(if_else(Weapon_Expl_Unit_Weight %like% "[0-9]+", 
                                                          Weapon_Expl_Unit_Weight, 
                                                          NA_character_))]

WW2_bombs[, Weapon_Incd_Unit_Weight := grem(pattern = "[^0-9][ -~]*", Weapon_Incd_Type)]
WW2_bombs[, Weapon_Incd_Unit_Weight := as.integer(if_else(Weapon_Incd_Unit_Weight %like% "[0-9]+", 
                                                          Weapon_Incd_Unit_Weight, 
                                                          NA_character_))]

WW2_bombs[, Weapon_Frag_Unit_Weight := grem(pattern = "[^0-9][ -~]*", Weapon_Frag_Type)]
WW2_bombs[, Weapon_Frag_Unit_Weight := as.integer(if_else(Weapon_Frag_Unit_Weight %like% "[0-9]+", 
                                                          Weapon_Frag_Unit_Weight, 
                                                          NA_character_))]

# column error fixes
WW2_bombs[grepl(pattern = ":", Unit_Squadron), 
          `:=`(Bomb_Time = Unit_Squadron, 
               Unit_Squadron = "")]
WW2_bombs[["Unit_Squadron"]] %>% 
  drop_similar_levels(drop = ":", exact = TRUE)

WW2_bombs[Sighting_Method_Code == "PFF", 
          `:=`(Sighting_Method_Code = "", 
               Sighting_Method_Explanation = "PFF")]
WW2_bombs[Sighting_Method_Code == "VISUAL", 
          `:=`(Sighting_Method_Code = "1", 
               Sighting_Method_Explanation = "VISUAL")]
WW2_bombs[Sighting_Method_Code == "" & 
            Sighting_Method_Explanation == "VISUAL", 
          `:=`(Sighting_Method_Code = "1")]
WW2_bombs[["Sighting_Method_Code"]] %>% 
  drop_levels(drop = c("0", "9", "PFF", "VISUAL")) %>% 
  recode_levels(changes = c("FFF" = "F.F.F."))

WW2_bombs[(!near(Bomb_Altitude * 100, Bomb_Altitude_Feet) | (is.na(Bomb_Altitude) & !is.na(Bomb_Altitude_Feet))) & 
            is.na(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Num = Bomb_Altitude_Feet, 
               Bomb_Altitude_Feet = NA_integer_)]
WW2_bombs[!near(Bomb_Altitude * 100, Bomb_Altitude_Feet) & 
            Weapon_Expl_Num == 0L, 
          `:=`(Bomb_Altitude = Bomb_Altitude_Feet / 100)]
WW2_bombs[!near(Bomb_Altitude * 100, Bomb_Altitude_Feet) & 
            !is.na(Weapon_Expl_Num) & 
            Weapon_Expl_Num != 0L, 
          `:=`(Bomb_Altitude_Feet = as.integer(Bomb_Altitude * 100))]
WW2_bombs[Bomb_Altitude > 0 & 
            Bomb_Altitude < 1, 
          `:=`(Bomb_Altitude = Bomb_Altitude * 100, 
               Bomb_Altitude_Feet = Bomb_Altitude_Feet * 100L)]
WW2_bombs[Bomb_Altitude == 1, 
          `:=`(Bomb_Altitude = 10, 
               Bomb_Altitude_Feet = 1000L)]
WW2_bombs[Bomb_Altitude >= 1000, 
          `:=`(Bomb_Altitude = Bomb_Altitude / 100, 
               Bomb_Altitude_Feet = as.integer(Bomb_Altitude))]
WW2_bombs[Bomb_Altitude >= 350, 
          `:=`(Bomb_Altitude = Bomb_Altitude / 10, 
               Bomb_Altitude_Feet = as.integer(Bomb_Altitude * 10))]
WW2_bombs[!is.na(Bomb_Altitude) & 
            is.na(Bomb_Altitude_Feet), 
          `:=`(Bomb_Altitude_Feet = as.integer(Bomb_Altitude * 100))]
WW2_bombs[is.na(Bomb_Altitude) & 
            !is.na(Bomb_Altitude_Feet), 
          `:=`(Bomb_Altitude = Bomb_Altitude_Feet / 100)]

# specific fixes, numerics
WW2_bombs[Aircraft_Attacking_Num == 0L | Aircraft_Attacking_Num >= 99L, 
          `:=`(Aircraft_Attacking_Num = NA_integer_)]
WW2_bombs[!near(Aircraft_Airborne_Num, as.integer(Aircraft_Airborne_Num)), 
          `:=`(Aircraft_Airborne_Num = 2 * Aircraft_Airborne_Num)]
WW2_bombs[Aircraft_Airborne_Num == 0, 
          `:=`(Aircraft_Airborne_Num = NA_real_)]
WW2_bombs[, Aircraft_Airborne_Num := as.integer(Aircraft_Airborne_Num)] # gets forced to double somehow

WW2_bombs[, Target_Priority_Code := grem(pattern = "[A-Z]*", Target_Priority_Code)]
WW2_bombs[, Target_Priority_Code := as.integer(if_else(Target_Priority_Code == "", 
                                                       NA_character_, 
                                                       Target_Priority_Code))] # gets forced to character somehow

WW2_bombs[Target_Latitude %!between% c(-90, 90), 
          `:=`(Target_Latitude = NA_real_)]
WW2_bombs[Target_Longitude %!between% c(-180, 180), 
          `:=`(Target_Latitude = NA_real_)]
WW2_bombs[Target_Latitude == 0 & Target_Longitude == 0, 
          `:=`(Target_Latitude = NA_real_, 
               Target_Longitude = NA_real_)]

# general fixes, numerics
WW2_bombs[Bomb_Altitude_Feet == 0L, 
          `:=`(Bomb_Altitude_Feet = NA_integer_)]
WW2_bombs[Bomb_Altitude_Feet > WW2_altitude_max_feet, 
          `:=`(Bomb_Altitude_Feet = WW2_altitude_max_feet)]

WW2_bombs[Weapon_Incd_Type == "10 LB INCENDIARY", 
          `:=`(Weapon_Incd_Tons = Weapon_Incd_Tons * 2.5, 
               Weapon_Incd_Pounds = round_to_int(Weapon_Incd_Pounds * 2.5))]

WW2_bombs[Weapon_Incd_Type == "100 LB WP (WHITE PHOSPHROUS)" & 
            is.na(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Tons = 1)]

WW2_bombs[Weapon_Expl_Unit_Weight %exactlylike% " KG", 
          `:=`(Weapon_Expl_Unit_Weight = round_to_int(Weapon_Expl_Unit_Weight * 2.2))]
WW2_bombs[Weapon_Incd_Unit_Weight %exactlylike% " KG", 
          `:=`(Weapon_Incd_Unit_Weight = round_to_int(Weapon_Incd_Unit_Weight * 2.2))]
WW2_bombs[Weapon_Frag_Unit_Weight %exactlylike% " KG", 
          `:=`(Weapon_Frag_Unit_Weight = round_to_int(Weapon_Frag_Unit_Weight * 2.2))]

# general fixes, times #*** fix the below two using levels
WW2_bombs[, Bomb_Time := format_military_times(Bomb_Time)]

# specific fixes, times
WW2_bombs[Bomb_Time %like% " ?[AaPp][Mm]", 
          `:=`(Bomb_Time = ampm_to_24_hour(Bomb_Time))]

# standard formatting
WW2_bombs %>% keep(is.factor) %>% 
  format_levels_by_col(remove_bad_formatting)

# editing string levels
WW2_bombs[["Unit_Squadron"]] %>% 
  drop_levels(drop = "0.458333333") %>% 
  recode_similar_levels(changes = c(" SQUADRON" = " (SQ?)\\b")) %>% 
  recode_similar_levels(exact = TRUE, 
                        changes = c("SQUADRON" = "SQDN", 
                                    "INDIA AIR TASK FORCE" = "IATF", 
                                    "CHINA AIR TASK FORCE" = "CATF", 
                                    "SERVICE FLYING TRAINING SCHOOL" = "SFTS", 
                                    "FLIGHT GROUP" = "FG", 
                                    "FLIGHT SQUADRON" = "FS", 
                                    "BOMBARDMENT GROUP" = "BG", 
                                    "BOMBARDMENT SQUADRON" = "BS"))

WW2_bombs[["Unit_Service"]] %>% 
  recode_levels(changes = c("RAAF" = "RAAF/NEI"))

WW2_bombs[["Unit_Country"]] %>% 
  recode_levels(changes = c("UK" = "GREAT BRITAIN"))

WW2_bombs[["Aircraft_Type"]] %>% 
  recode_levels(changes = c("A-31 Vengeance" = "VENGEANCE (A31)", 
                            "A-31 Vengeance" = "VENGEANCE(A-31)")) %>% 
  format_levels(format_aircraft_types %,% proper_noun_phrase_aircraft_vectorized)

WW2_bombs[["Weapon_Expl_Type"]] %>% 
  recode_similar_levels(exact = TRUE, 
                        changes = c("0 LB GP" = "0 GP")) %>% 
  recode_levels(changes = c("TORPEDO" = "TORPEDOES", 
                            "TORPEDO" = "TORPEDOES MISC", 
                            "40 LB EXPLOSIVE" = "UNK CODE 20 110 LB EXPLOSIVE", 
                            "250 LB BAP" = "250 BAP"))

WW2_bombs[["Weapon_Incd_Type"]] %>% 
  drop_levels(drop = "X")

WW2_bombs[["Weapon_Frag_Type"]] %>% 
  recode_levels(changes = c("138 LB FRAG (6X23 CLUSTERS)" = "23 LB FRAG CLUSTERS (6 X23 PER CLUSTER)", 
                            "23 LB PARA FRAG" = "23 LB PARAFRAG")) %>% 
  drop_levels(drop = "UNK CODE 15")

WW2_bombs[["Target_Type"]] %>% 
  drop_similar_levels(drop = "\\b(UNID|UNDENT)") %>% 
  format_levels(cleanup_targets %,% tolower)

WW2_bombs[["Target_City"]] %>% 
  drop_levels_formula(expr = (grem(., pattern = "[ NSEW]+") %like% "^[0-9.]+$"))

WW2_bombs[["Target_Country"]] %>% 
  drop_similar_levels(drop = "UNKNOWN", exact = TRUE)

WW2_bombs[["Target_City"]] %>% 
  drop_levels(drop = c("UNKNOWN", "UNIDENTIFIED"))

WW2_bombs[["Target_Industry"]] %>% 
  drop_levels(drop = "UNIDENTIFIED TARGETS")

WW2_bombs %>% select("Target_Priority_Explanation", 
                     "Sighting_Method_Explanation", 
                     "Target_Industry") %>% 
  format_levels_by_col(tolower)

WW2_bombs %>% select("Unit_Country", 
                     "Takeoff_Country", 
                     "Takeoff_Base", 
                     "Target_Country", 
                     "Unit_Squadron", 
                     "Target_City") %>% 
  format_levels_by_col(proper_noun_phrase_vectorized)

# long weapons types and numbers cleaning script
source('WW2_weapon_cleaning.R')


### Korea 1 Edits -------------------------------------------------------------

debug_message("cleaning Korea1")

# temporary type fixes
cols <- c("Aircraft_Dispatched_Num", 
          "Aircraft_Attacking_Num", 
          "Aircraft_Aborted_Num", 
          "Aircraft_Lost_Enemy_Air_Num", 
          "Aircraft_Lost_Enemy_Ground_Num", 
          "Aircraft_Lost_Enemy_Unknown_Num", 
          "Aircraft_Lost_Other_Num", 
          "Aircraft_Damaged_Num", 
          "KIA", 
          "WIA", 
          "MIA", 
          "Enemy_Aircraft_Destroyed_Confirmed", 
          "Enemy_Aircraft_Destroyed_Probable", 
          "Rocket_Num", 
          "Bullet_Rounds")
Korea_bombs1[, (cols) := lapply(.SD, as.integer), .SDcols = cols]

# new columns
Korea_bombs1[, Weapon_Weight_Pounds := round_to_int(Weapon_Weight_Tons * 2000)]

# specific fixes, numerics
Korea_bombs1[Aircraft_Attacking_Num == 0L | Aircraft_Attacking_Num >= 99L, 
             `:=`(Aircraft_Attacking_Num = NA_integer_)]

# standard formatting
Korea_bombs1 %>% keep(is.factor) %>% 
  format_levels_by_col(remove_bad_formatting)

# editing string levels
Korea_bombs1[["Unit_ID"]] %>% 
  recode_levels(changes = c("GAF" = "G AF")) %>% 
  drop_levels(drop = c("NONE", "N0NE", "NONE0", "NONE6", "NQNE"))

Korea_bombs1[["Aircraft_Type"]] %>% 
  recode_levels(changes = c("C-54" = "O54", 
                            "L-05" = "LO5", 
                            "RB-29" = "R829", 
                            "T-06" = "TO6", 
                            "T-06" = "TQ6")) %>% 
  format_levels(format_aircraft_types)


### Korea 2 Edits -----------------------------------------------------------

debug_message("cleaning Korea2")

# temporary type fixes
cols <- c("Aircraft_Attacking_Num", 
          "Sortie_Duplicates", 
          "Aircraft_Aborted_Num", 
          "Aircraft_Bombload_Calculated_Pounds")
Korea_bombs2[, (cols) := lapply(.SD, as.integer), .SDcols = cols]

# column error fixes
Korea_bombs2[Bomb_Altitude_Feet_Range != "" & !(Bomb_Altitude_Feet_Range %like% "[0-9]+ ?- ?[0-9]*"), 
             `:=`(Bomb_Damage_Assessment = Bomb_Altitude_Feet_Range, 
                  Bomb_Altitude_Feet_Range = "")]
Korea_bombs2[Bomb_Altitude_Feet_Range == "" & 
               Bomb_Damage_Assessment %like% "^[0-9]+$", 
             `:=`(Bomb_Altitude_Feet_Range = Bomb_Damage_Assessment, 
                  Bomb_Damage_Assessment = "")]
Korea_bombs2[Target_Name %like% "ission|ccomplished|erformed|B[CO][APR]", 
             `:=`(Bomb_Damage_Assessment = Target_Name, 
                  Target_Name = "")]
Korea_bombs2[["Target_Name"]] %>% 
  drop_similar_levels(drop = c("ission|ccomplished|erformed|B[CO][APR]"))

Korea_bombs2[Target_Type %exactlylike% "ccomplished|erformed", 
             `:=`(Bomb_Damage_Assessment = Target_Type, 
                  Target_Type = "")]
Korea_bombs2[["Target_Type"]] %>% 
  drop_similar_levels(drop = "ccomplished|erformed|UN[A-Z]*OWN") %>% 
  format_levels(toupper %,% cleanup_targets %,% tolower)

# new columns
cols <- c("Bomb_Altitude_Feet_Low", 
          "Bomb_Altitude_Feet_High")
Korea_bombs2[, (cols) := tstrsplit(Bomb_Altitude_Feet_Range, " ?- ?", keep = 1:2)]
Korea_bombs2[, (cols) := lapply(.SD, as.integer), .SDcols = cols]

Korea_bombs2[, Weapon_Unit_Weight := grem(pattern = "[^0-9][ -~]*", Weapon_Type)]
Korea_bombs2[, Weapon_Unit_Weight := as.integer(if_else(Weapon_Unit_Weight %like% "[0-9]+", 
                                                        Weapon_Unit_Weight, 
                                                        NA_character_))]
Korea_bombs2[, Weapon_Weight_Pounds := Aircraft_Attacking_Num * Aircraft_Bombload_Calculated_Pounds]

# general fixes, numerics
Korea_bombs2[, Target_Latitude  := grem(pattern = "[^0-9.]*", Target_Latitude)]
Korea_bombs2[, Target_Latitude  := as.numeric(if_else(Target_Latitude == "", 
                                                      NA_character_, 
                                                      Target_Latitude))]
Korea_bombs2[, Target_Longitude := grem(pattern = "[^0-9.]*", Target_Longitude)]
Korea_bombs2[, Target_Longitude := as.numeric(if_else(Target_Longitude == "", 
                                                      NA_character_, 
                                                      Target_Longitude))]

# specific fixes, numerics
Korea_bombs2[Aircraft_Attacking_Num == 0L | Aircraft_Attacking_Num >= 99L, 
             `:=`(Aircraft_Attacking_Num = NA_integer_)]

Korea_bombs2[Bomb_Altitude_Feet_High == 0L, 
             `:=`(Bomb_Altitude_Feet_High = NA_integer_)]
Korea_bombs2[Bomb_Altitude_Feet_High > Korea_altitude_max_feet & 
               Bomb_Altitude_Feet_High / 10 < Bomb_Altitude_Feet_Low, 
             `:=`(Bomb_Altitude_Feet_High = as.integer(Bomb_Altitude_Feet_High / 10))]
Korea_bombs2[Bomb_Altitude_Feet_High > Korea_altitude_max_feet, 
             `:=`(Bomb_Altitude_Feet_High = Korea_altitude_max_feet)]

Korea_bombs2[, Row_Number := as.integer(grem(pattern = "\r\r", fixed = TRUE, Row_Number))] # gets forced to character somehow
Korea_bombs2[Weapon_Expended_Num == "" | 
               Weapon_Expended_Num == "Unknown", 
             `:=`(Weapon_Expended_Num = NA_character_)]
Korea_bombs2[, Weapon_Expended_Num := as.integer(Weapon_Expended_Num)] # gets forced to character somehow
Korea_bombs2[Weapon_Expended_Num == 0L, 
             `:=`(Weapon_Expended_Num = NA_integer_)]
Korea_bombs2[, Mission_Number := as.integer(grem(pattern = " ?L", Mission_Number))] # gets forced to character somehow
Korea_bombs2[Aircraft_Lost_Num == "", 
             `:=`(Aircraft_Lost_Num = NA_character_)]
Korea_bombs2[!(Aircraft_Lost_Num == "1" | Aircraft_Lost_Num == "2" | Aircraft_Lost_Num == "3"), 
             `:=`(Aircraft_Lost_Num = NA_character_, 
                  Bomb_Damage_Assessment = Aircraft_Lost_Num)]
Korea_bombs2[, Aircraft_Lost_Num := as.integer(Aircraft_Lost_Num)] # cleaning data type due to bad data

Korea_bombs2[Target_Latitude %!between% c(-90, 90), 
             `:=`(Target_Latitude = NA_real_)]
Korea_bombs2[Target_Longitude %!between% c(-180, 180), 
             `:=`(Target_Latitude = NA_real_)]
Korea_bombs2[Target_Latitude == 0 & Target_Longitude == 0, 
             `:=`(Target_Latitude = NA_real_, 
                  Target_Longitude = NA_real_)]

# type fixes
Korea_bombs2[, Bomb_Damage_Assessment := factor(Bomb_Damage_Assessment)]

# standard formatting
Korea_bombs2 %>% keep(is.factor) %>% 
  format_levels_by_col(remove_bad_formatting)

# editing string levels
Korea_bombs2[["Weapon_Type"]] %>% 
  recode_similar_levels(changes = c(" LB GP" = " GP\\b")) %>% 
  drop_levels(drop = "UNKNOWN")

Korea_bombs2[["Unit_Squadron"]] %>% 
  recode_similar_levels(changes = c(" SQUADRON" = " SQ\\b"))

Korea_bombs2[["Aircraft_Type"]] %>% 
  recode_levels(changes = c("RB-45" = "RB 45")) %>% 
  format_levels(proper_noun_phrase_aircraft_vectorized)

Korea_bombs2[["Mission_Type"]] %>% 
  recode_similar_levels(changes = c("Interdiction" = "Interd[a-z]*n"))

Korea_bombs2[["Nose_Fuze"]] %>% 
  recode_levels(changes = c("Instantaneous" = "instantaneous")) %>% 
  drop_levels(drop = "Unknown to poor results.")

Korea_bombs2[["Bomb_Sighting_Method"]] %>% 
  format_levels(tolower)


### Vietnam Edits -----------------------------------------------------------

debug_message("cleaning Vietnam")

# temporary type fixes
cols <- c("ID", 
          "Weapon_Expended_Num", 
          "Weapon_Unit_Weight", 
          "Aircraft_Attacking_Num", 
          "Weapon_Jettisoned_Num", 
          "Weapon_Returned_Num", 
          "Weapon_Weight_Loaded")
Vietnam_bombs[, (cols) := lapply(.SD, as.integer), .SDcols = cols]

# specific fixes, numerics
Vietnam_bombs[Aircraft_Attacking_Num == 0L | Aircraft_Attacking_Num >= 99L, 
             `:=`(Aircraft_Attacking_Num = NA_integer_)]
Vietnam_bombs[Weapon_Expended_Num == 0L, 
              `:=`(Weapon_Expended_Num = NA_integer_)]
Vietnam_bombs[Weapon_Unit_Weight == 0L, 
              `:=`(Weapon_Unit_Weight = NA_integer_)]
Vietnam_bombs[Weapon_Jettisoned_Num == -1L, 
              `:=`(Weapon_Jettisoned_Num = NA_integer_)]
Vietnam_bombs[Weapon_Returned_Num == -1L, 
              `:=`(Weapon_Returned_Num = NA_integer_)]
Vietnam_bombs[Weapon_Weight_Loaded < 1L, 
              `:=`(Weapon_Weight_Loaded = NA_integer_)]
Vietnam_bombs[is_NA_or_0L(Weapon_Expended_Num) & 
                is_NA_or_0L(Weapon_Jettisoned_Num) & 
                is_NA_or_0L(Weapon_Returned_Num), 
              `:=`(Weapon_Expended_Num = NA_integer_, 
                   Weapon_Jettisoned_Num = NA_integer_, 
                   Weapon_Returned_Num = NA_integer_)]

Vietnam_bombs[Target_Latitude %!between% c(-90, 90), 
              `:=`(Target_Latitude = NA_real_)]
Vietnam_bombs[Target_Longitude %!between% c(-180, 180), 
              `:=`(Target_Latitude = NA_real_)]
Vietnam_bombs[Target_Latitude == 0 & Target_Longitude == 0, 
              `:=`(Target_Latitude = NA_real_, 
                   Target_Longitude = NA_real_)]

# new columns
Vietnam_bombs[, Weapon_Weight_Pounds := Weapon_Expended_Num * Weapon_Unit_Weight]
Vietnam_bombs[, Bomb_Altitude_Feet := as.integer(Bomb_Altitude * 1000)] # assumed factor of 1000 here (in ft)--otherwise makes no sense

# more specific fixes, numerics
Vietnam_bombs[Bomb_Altitude_Feet == 0L, 
              `:=`(Bomb_Altitude_Feet = NA_integer_)]
Vietnam_bombs[Bomb_Altitude_Feet > Vietnam_altitude_max_feet, 
              `:=`(Bomb_Altitude_Feet = round_to_int(Bomb_Altitude_Feet / 10))]

# general fixes, times
cols <- c("Bomb_Time_Start", 
          "Bomb_Time_Finish")
Vietnam_bombs %>% select(cols) %>% 
  recode_similar_levels_by_col(exact = TRUE, 
                               changes = ".0") %>% 
  drop_levels_by_col(drop = "0") %>% 
  format_levels_by_col(format_military_times)

# standard formatting
Vietnam_bombs %>% keep(is.factor) %>% 
  format_levels_by_col(remove_bad_formatting)

# editing string levels
Vietnam_bombs[["Aircraft_Type"]] %>% 
  recode_similar_levels(changes = c("\\1-\\2" = "([A-Za-z]+)[ ./]?(\\d+[A-Za-z]*)( ?/.*)?")) %>% 
  drop_levels(drop = "NOT CODED") %>% 
  format_levels(format_aircraft_types)

Vietnam_bombs[["Target_Type"]] %>% 
  recode_similar_levels(exact = TRUE, 
                        changes = c("/" = "\\", 
                                    "/ANY"))

Vietnam_bombs[["Operation"]] %>% 
  recode_similar_levels(changes = c("^([- \"/]+)|(IN COUNTRY[- \"/]*)", 
                                    "ROLLING THUNDER" = "ROLLING THUN((D)|( - ROLLING THUN))?")) %>% 
  format_levels(capitalize_phrase_vectorized)

Vietnam_bombs[["Weapon_Type"]] %>% 
  recode_similar_levels(exact = TRUE, 
                        changes = c(" (100 rounds each)" = " (HNDRDS)")) %>% 
  drop_levels(drop = c("UNK", "UNKNOWN"))

Vietnam_bombs[["Unit_Country"]] %>% 
  recode_levels(changes = c("South Korea" = "KOREA (SOUTH)", 
                            "USA" = "UNITED STATES OF AMERICA", 
                            "South Vietnam" = "VIETNAM (SOUTH)"))

Vietnam_bombs[["Target_Type"]] %>% 
  recode_similar_levels(changes = c("TROOPS" = "TROOPS? UNK.*")) %>% 
  drop_levels(drop = c("NO TARGET ACQUIRED", "UNKNOWN/UNIDENTIFIED", "UNK/UND")) %>% 
  format_levels(cleanup_targets %,% tolower)

Vietnam_bombs[["Target_Country"]] %>% 
  recode_levels(changes = c("PHILIPPINES" = "PHILLIPINES", 
                            "WEST PACIFIC WATERS" = "WESTPAC WATERS")) %>% 
  drop_levels(drop = "UNKNOWN")

Vietnam_bombs[["Mission_Day_Period"]] %>% 
  keep_levels(keep = c("D", "N", "M", "E")) %>% 
  format_levels(format_day_periods)

Vietnam_bombs[["Unit_Service"]] %>% 
  drop_levels(drop = "OTHER")

Vietnam_bombs[["Mission_Function_Code"]] %>% 
  drop_similar_levels(drop = "\\d[A-Z]")

Vietnam_bombs[["Target_CloudCover"]] %>% 
  drop_levels(drop = "NOT OBS")

Vietnam_bombs[["Target_Control"]] %>% 
  drop_levels(drop = "UNKNOWN")

Vietnam_bombs %>% select("Mission_Function_Description", 
                         "Target_CloudCover", 
                         "Weapon_Class") %>% 
  format_levels_by_col(tolower)

Vietnam_bombs %>% select("Unit_Country", 
                         "Takeoff_Location", 
                         "Target_Country") %>% 
  format_levels_by_col(proper_noun_phrase_vectorized)

# type fixes
Vietnam_bombs[, Mission_Function_Code := as.integer(if_else(Mission_Function_Code == "", 
                                                            NA_character_, 
                                                            as.character(Mission_Function_Code)))]

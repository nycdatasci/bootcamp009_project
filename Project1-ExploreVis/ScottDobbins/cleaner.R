# @author Scott Dobbins
# @version 0.9.7
# @date 2017-07-28 17:30


### Import Packages ---------------------------------------------------------

# import data analytic extensions
library(tidyr)
library(purrr)
library(forcats)
#library(chron)
library(lubridate)

# helper functions
source('helper.R')


### Fix Dates ---------------------------------------------------------------

if(debug_mode_on) print("fixing date columns")
WW1_bombs[, c("Year", "Month", "Day") := tstrsplit(Mission_Date, '-', fixed = TRUE)]
WW1_bombs[, Month_name := month_num_padded_to_name(Month)]
WW2_bombs[, c("Month", "Day", "Year") := tstrsplit(Mission_Date, '/', fixed = TRUE)]
WW2_bombs[, Month_name := month_num_to_name(Month)]
Korea_bombs1[, c("Month", "Day", "Year") := tstrsplit(Mission_Date, '/', fixed = TRUE)]
Korea_bombs1[, Year := paste0("19", Year)]
Korea_bombs1[, Month_name := month_num_to_name(Month)]
Korea_bombs2[, c("Month", "Day", "Year") := tstrsplit(Mission_Date, '/', fixed = TRUE)]
Korea_bombs2[, Year := paste0("19", Year)]
Korea_bombs2[, Month_name := month_num_to_name(Month)]
Vietnam_bombs[, c("Year", "Month", "Day") := tstrsplit(Mission_Date, '-', fixed = TRUE)]
Vietnam_bombs[nchar(Year) == 8, 
              `:=`(Day = substr(Year, 7, 8),
                   Month = substr(Year, 5, 6), 
                   Year = substr(Year, 1, 4))]
Vietnam_bombs[is.na(Mission_Date), 
              `:=`(Mission_Date = paste(Year, Month, Day, sep = '-'))]
Vietnam_bombs[, Month_name := month_num_padded_to_name(Month)]

WW1_bombs[, Mission_Date := ymd(Mission_Date)]
WW2_bombs[, Mission_Date := mdy(Mission_Date)]
Korea_bombs1[, Mission_Date := mdy(Mission_Date) - years(100)]
Korea_bombs2[, Mission_Date := mdy(Mission_Date) - years(100)]
Vietnam_bombs[, Mission_Date := ymd(Mission_Date)]


### Set Keys ----------------------------------------------------------------

if(debug_mode_on) print("setting keys")
setkey(WW1_bombs, Mission_Date)
setkey(WW2_bombs, Mission_Date)
setkey(Korea_bombs1, Mission_Date)
setkey(Korea_bombs2, Mission_Date)
setkey(Vietnam_bombs, Mission_Date)


### WW1 Edits ---------------------------------------------------------------

if(debug_mode_on) print("fixing WW1")

# general fixes, numerics
WW1_bombs[, ID := as.integer(ID)]
WW1_bombs[, Mission_Num := as.integer(Mission_Num)]
WW1_bombs[, Weapon_Expended_Num := as.integer(Weapon_Expended_Num)]
WW1_bombs[, Aircraft_Bombload_Pounds := as.integer(round(Aircraft_Bombload_Pounds))]
WW1_bombs[, Weapon_Weight_Pounds := as.integer(round(Weapon_Weight_Pounds))]

# specific fixes, strings
WW1_bombs[, Operation := fct_other(Operation, drop = c("WW I"), other_level = "")]
WW1_bombs[, Target_City := fct_other(Target_City, drop = c("OTHER"), other_level = "")]
WW1_bombs[, Target_Type := fct_other(Target_Type, drop = c("UNKNOWN", "UNKNOWN (ABORTED RAID)"), other_level = "")]
WW1_bombs[, Route_Details := fct_other(Route_Details, drop = c("NONE"), other_level = "")]

WW1_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = "GRP", replacement = "GROUP", fixed = TRUE, levels(.)))
WW1_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = "SQDN", replacement = "SQUADRON", fixed = TRUE, levels(.)))
WW1_bombs$Weapon_Type %>% setattr("levels", gsub(pattern = " KILO", replacement = " KG", fixed = TRUE, levels(.)))
WW1_bombs$Target_City %>% setattr("levels", gsub(pattern = "; ", replacement = " OF ", fixed = TRUE, levels(.)))

# general fixes, strings
WW1_bombs$Operation %>% setattr("levels", proper_noun_phrase_vectorized(levels(.)))
WW1_bombs$Unit_Country %>% setattr("levels", proper_noun_from_caps_vectorized(levels(.)))
WW1_bombs$Unit_Service %>% setattr("levels", proper_noun_from_caps_vectorized(levels(.)))
WW1_bombs$Unit_Squadron %>% setattr("levels", proper_noun_phrase_vectorized(levels(.)))
WW1_bombs$Aircraft_Type %>% setattr("levels", proper_noun_phrase_aircraft_vectorized(format_aircraft_types(levels(.))))
WW1_bombs$Takeoff_Day_Period %>% setattr("levels", tolower(levels(.)))
WW1_bombs$Weapon_Type %>% setattr("levels", tolower(levels(.)))
WW1_bombs$Target_City %>% setattr("levels", proper_noun_phrase_vectorized(remove_nonASCII_chars(levels(.))))
WW1_bombs$Target_Country %>% setattr("levels", capitalize_from_caps(levels(.)))
WW1_bombs$Target_Type %>% setattr("levels", tolower(cleanup_targets(remove_parentheticals(levels(.)))))
WW1_bombs$Takeoff_Base %>% setattr("levels", proper_noun_phrase_vectorized(remove_nonASCII_chars(levels(.))))
WW1_bombs$Route_Details %>% setattr("levels", proper_noun_phrase_vectorized(levels(.)))
WW1_bombs$Target_Weather %>% setattr("levels", tolower(levels(.)))


### WW2 Edits ---------------------------------------------------------------

if(debug_mode_on) print("fixing WW2")

# new columns
WW2_bombs[, Weapon_Expl_Unit_Weight := as.integer(gsub(pattern = " [ -~]*", replacement = '', Weapon_Expl_Type))]
WW2_bombs[, Weapon_Incd_Unit_Weight := as.integer(gsub(pattern = " [ -~]*", replacement = '', Weapon_Incd_Type))]
WW2_bombs[, Weapon_Frag_Unit_Weight := as.integer(gsub(pattern = " [ -~]*", replacement = '', Weapon_Frag_Type))]

# column error fixes
WW2_bombs[regexpr(pattern = ':', Unit_Squadron) > 0, 
          `:=`(Bomb_Time = Unit_Squadron, 
               Unit_Squadron = "")]

WW2_bombs[Sighting_Method_Code == "PFF", 
          `:=`(Sighting_Method_Code = "", 
               Sighting_Method_Explanation = "PFF")]
WW2_bombs[Sighting_Method_Code == "VISUAL", 
          `:=`(Sighting_Method_Code = "1", 
               Sighting_Method_Explanation = "VISUAL")]
WW2_bombs[Sighting_Method_Code == "" & 
            Sighting_Method_Explanation == "VISUAL", 
          `:=`(Sighting_Method_Code = "1")]
WW2_bombs[Sighting_Method_Code == "0" | 
            Sighting_Method_Code == "7" | 
            Sighting_Method_Code == "9", 
          `:=`(Sighting_Method_Explanation = "", 
               Sighting_Method_Code = "")]

WW2_bombs[(!near(Bomb_Altitude * 100, Bomb_Altitude_Feet) | (is.na(Bomb_Altitude) & !is.na(Bomb_Altitude_Feet))) & 
            is.na(Weapon_Expl_Num) & 
            !is.na(Weapon_Expl_Tons), 
          `:=`(Weapon_Expl_Num = Bomb_Altitude_Feet, 
               Bomb_Altitude_Feet = NA)]

# specific fixes, numerics
WW2_bombs[!near(Bomb_Altitude * 100, Bomb_Altitude_Feet) & 
            Weapon_Expl_Num == 0, 
          `:=`(Bomb_Altitude = Bomb_Altitude_Feet / 100)]
WW2_bombs[!near(Bomb_Altitude * 100, Bomb_Altitude_Feet) & 
            !is.na(Weapon_Expl_Num) & 
            Weapon_Expl_Num != 0, 
          `:=`(Bomb_Altitude_Feet = Bomb_Altitude * 100)]
WW2_bombs[Bomb_Altitude > 0 & 
            Bomb_Altitude < 1, 
          `:=`(Bomb_Altitude = Bomb_Altitude * 100, 
               Bomb_Altitude_Feet = Bomb_Altitude_Feet * 100)]
WW2_bombs[Bomb_Altitude == 1, 
          `:=`(Bomb_Altitude = 10, 
               Bomb_Altitude_Feet = 1000)]
WW2_bombs[Bomb_Altitude >= 1000, 
          `:=`(Bomb_Altitude = Bomb_Altitude / 100, 
               Bomb_Altitude_Feet = Bomb_Altitude)]
WW2_bombs[Bomb_Altitude >= 350, 
          `:=`(Bomb_Altitude = Bomb_Altitude / 10, 
               Bomb_Altitude_Feet = Bomb_Altitude * 10)]
WW2_bombs[!is.na(Bomb_Altitude) & 
            is.na(Bomb_Altitude_Feet), 
          `:=`(Bomb_Altitude_Feet = Bomb_Altitude * 100)]
WW2_bombs[is.na(Bomb_Altitude) & 
            !is.na(Bomb_Altitude_Feet), 
          `:=`(Bomb_Altitude = Bomb_Altitude_Feet / 100)]

WW2_bombs[Weapon_Incd_Type == "10 LB INCENDIARY", 
          `:=`(Weapon_Incd_Tons = Weapon_Incd_Tons * 2.5, 
               Weapon_Incd_Pounds = Weapon_Incd_Pounds * 2.5)]

WW2_bombs[Weapon_Incd_Type == "100 LB WP (WHITE PHOSPHROUS)" & 
            is.na(Weapon_Incd_Tons), 
          `:=`(Weapon_Incd_Tons = 1)]

WW2_bombs[regexpr(pattern = ' KG', Weapon_Expl_Unit_Weight) > 0, 
          `:=`(Weapon_Expl_Unit_Weight = Weapon_Expl_Unit_Weight * 2.2)]
WW2_bombs[regexpr(pattern = ' KG', Weapon_Incd_Unit_Weight) > 0, 
          `:=`(Weapon_Incd_Unit_Weight = Weapon_Incd_Unit_Weight * 2.2)]
WW2_bombs[regexpr(pattern = ' KG', Weapon_Frag_Unit_Weight) > 0, 
          `:=`(Weapon_Frag_Unit_Weight = Weapon_Frag_Unit_Weight * 2.2)]

# general fixes, numerics
WW2_bombs[, Aircraft_Airborne_Num := as.integer(Aircraft_Airborne_Num)] # gets forced to double somehow
WW2_bombs[, Weapon_Expl_Num := as.integer(round(Weapon_Expl_Num))]
WW2_bombs[, Weapon_Incd_Num := as.integer(round(Weapon_Incd_Num))]
WW2_bombs[, Weapon_Frag_Num := as.integer(round(Weapon_Frag_Num))]
WW2_bombs[, Weapon_Weight_Pounds := as.integer(round(Weapon_Weight_Pounds))]
WW2_bombs[, Weapon_Expl_Pounds := as.integer(round(Weapon_Expl_Pounds))]
WW2_bombs[, Weapon_Incd_Pounds := as.integer(round(Weapon_Incd_Pounds))]
WW2_bombs[, Weapon_Frag_Pounds := as.integer(round(Weapon_Frag_Pounds))]

# general fixes, times
WW2_bombs[, Bomb_Time := format_military_times(Bomb_Time)]

# specific fixes, strings
WW2_bombs[regexpr(pattern = 'UNID', Target_Type) > 0, 
          `:=`(Target_Type = "")]

WW2_bombs[, Unit_Service := fct_recode(Unit_Service, `RAAF` = "RAAF/NEI")]
WW2_bombs[, Unit_Country := fct_recode(Unit_Country, `UK` = "GREAT BRITAIN")]
WW2_bombs[, Target_Country := fct_other(Target_Country, drop = c("UNKNOWN", "UNKNOWN OR NOT INDICATED"), other_level = "")]
WW2_bombs[, Target_City := fct_other(Target_City, drop = c("UNKNOWN", "UNIDENTIFIED"), other_level = "")]
WW2_bombs[, Target_Type := fct_other(Target_Type, drop = c("UNIDENTIFIED", "UNIDENTIFIED TARGET"), other_level = "")]

WW2_bombs[!is.na(as.integer(gsub(pattern = "[ NSEW]+", replacement = "", Target_City))), 
          `:=`(Target_City = "")]

WW2_bombs[, Target_Industry := fct_other(Target_Industry, drop = c("UNIDENTIFIED TARGETS"), other_level = "")]
WW2_bombs[, Unit_Squadron := fct_other(Unit_Squadron, drop = c("0.458333333"), other_level = "")]
WW2_bombs[, Aircraft_Type := fct_recode(Aircraft_Type, `A-31 Vengeance` = "VENGEANCE (A31)", `A-31 Vengeance` = "VENGEANCE(A-31)")]
WW2_bombs[, Weapon_Expl_Type := fct_other(Weapon_Expl_Type, drop = c("0"), other_level = "")]
WW2_bombs[, Weapon_Expl_Type := fct_recode(Weapon_Expl_Type, TORPEDO = "TORPEDOES", TORPEDO = "TORPEDOES MISC", `40 LB EXPLOSIVE` = "UNK CODE 20 110 LB EXPLOSIVE", `250 LB BAP` = "250 BAP")]
WW2_bombs[, Weapon_Incd_Type := fct_other(Weapon_Incd_Type, drop = c("X"), other_level = "")]
WW2_bombs[, Weapon_Incd_Type := fct_recode(Weapon_Incd_Type, `110 LB INCENDIARY` = "110 LB  INCENDIARY")]
WW2_bombs[, Weapon_Frag_Type := fct_other(Weapon_Frag_Type, drop = c("0", "UNK CODE 15"), other_level = "")]
WW2_bombs[, Weapon_Frag_Type := fct_recode(Weapon_Frag_Type, `138 LB FRAG (6X23 CLUSTERS)` = "23 LB FRAG CLUSTERS (6 X23 PER CLUSTER)", `23 LB PARA FRAG` = "23 LB PARAFRAG")]

WW2_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = "SQDN", replacement = 'SQUADRON', fixed = TRUE, levels(.)))
WW2_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = " (SQ?)\\b", replacement = " SQUADRON", levels(.)))
WW2_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = "IATF", replacement = "INDIA AIR TASK FORCE", fixed = TRUE, levels(.)))
WW2_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = "CATF", replacement = "CHINA AIR TASK FORCE", fixed = TRUE, levels(.)))
WW2_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = "SFTS", replacement = "SERVICE FLYING TRAINING SCHOOL", fixed = TRUE, levels(.)))
WW2_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = "FG", replacement = "FLIGHT GROUP", fixed = TRUE, levels(.)))
WW2_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = "FS", replacement = "FLIGHT SQUADRON", fixed = TRUE, levels(.)))
WW2_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = "BG", replacement = "BOMBARDMENT GROUP", fixed = TRUE, levels(.)))
WW2_bombs$Unit_Squadron %>% setattr("levels", gsub(pattern = "BS", replacement = "BOMBARDMENT SQUADRON", fixed = TRUE, levels(.)))
WW2_bombs$Weapon_Expl_Type %>% setattr("levels", gsub(pattern = "0 GP", replacement = "0 LB GP", fixed = TRUE, levels(.)))

# general fixes, strings
WW2_bombs$Unit_Country %>% setattr("levels", proper_noun_phrase_vectorized(levels(.)))
WW2_bombs$Target_Country %>% setattr("levels", proper_noun_phrase_vectorized(remove_quotes(levels(.))))
WW2_bombs$Target_City %>% setattr("levels", proper_noun_phrase_vectorized(remove_nonASCII_chars(remove_quotes(levels(.)))))
WW2_bombs$Target_Type %>% setattr("levels", tolower(cleanup_targets(levels(.))))
WW2_bombs$Target_Industry %>% setattr("levels", tolower(remove_quotes(levels(.))))
WW2_bombs$Unit_Squadron %>% setattr("levels", proper_noun_phrase_vectorized(remove_quotes(levels(.))))
WW2_bombs$Aircraft_Type %>% setattr("levels", proper_noun_phrase_aircraft_vectorized(format_aircraft_types(levels(.))))
WW2_bombs$Target_Priority_Explanation %>% setattr("levels", tolower(levels(.)))
WW2_bombs$Takeoff_Base %>% setattr("levels", proper_noun_phrase_vectorized(levels(.)))
WW2_bombs$Takeoff_Country %>% setattr("levels", proper_noun_phrase_vectorized(levels(.)))
WW2_bombs$Sighting_Method_Explanation %>% setattr("levels", tolower(levels(.)))
WW2_bombs$Bomb_Damage_Assessment %>% setattr("levels", remove_quotes(levels(.)))
WW2_bombs$Target_Comment %>% setattr("levels", remove_quotes(levels(.)))
WW2_bombs$Database_Edit_Comments %>% setattr("levels", remove_quotes(levels(.)))

# type fixes
WW2_bombs[, Target_Priority_Code := as.integer(Target_Priority_Code)] # gets forced to character somehow
WW2_bombs[, Sighting_Method_Code := as.integer(Sighting_Method_Code)] # fixing data type due to bad data

# long weapons types and numbers cleaning script
source('WW2_weapon_cleaning.R')


### Korea 1 Edits -------------------------------------------------------------

if(debug_mode_on) print("fixing Korea1")

# specific fixes, strings
Korea_bombs1[, Unit_ID := fct_recode(Unit_ID, GAF = "G AF")]
Korea_bombs1[, Unit_ID := fct_other(Unit_ID, drop = c("NONE", "N0NE", "NONE0", "NONE6", "NQNE"), other_level = "")]
Korea_bombs1[, Aircraft_Type := fct_recode(Aircraft_Type, `C-54` = "O54")]
Korea_bombs1[, Aircraft_Type := fct_recode(Aircraft_Type, `L-05` = "LO5")]
Korea_bombs1[, Aircraft_Type := fct_recode(Aircraft_Type, `RB-29` = "R829")]
Korea_bombs1[, Aircraft_Type := fct_recode(Aircraft_Type, `T-06` = "TO6", `T-06` = "TQ6")]

# general fixes, strings
Korea_bombs1$Aircraft_Type %>% setattr("levels", format_aircraft_types(levels(.)))


### Korea 2 Edits -----------------------------------------------------------

if(debug_mode_on) print("fixing Korea2")

# new columns
Korea_bombs2 <- separate(data = Korea_bombs2, # maybe change this to a tstrsplit in data.table form
                         col = Bomb_Altitude_Feet_Range,
                         into = c("Bomb_Altitude_Feet_Low", "Bomb_Altitude_Feet_High"),
                         sep = '-',
                         extra = 'merge',
                         fill = 'right')

# general fixes, numerics
Korea_bombs2[, Target_Latitude := as.numeric(substr(Target_Latitude, 1, nchar(Target_Latitude)-1))]
Korea_bombs2[, Target_Longitude := as.numeric(substr(Target_Longitude, 1, nchar(Target_Longitude)-1))]
Korea_bombs2[, Bomb_Altitude_Feet_Low := as.integer(Bomb_Altitude_Feet_Low)]
Korea_bombs2[, Bomb_Altitude_Feet_High := as.integer(Bomb_Altitude_Feet_High)]

# specific fixes, strings
#KB-29 technically exists, and is modified B-29 available in 1948, so theoretically possible, but it's just a refueling aircraft--probably an OCR error for RB-29, but I'm not sure
Korea_bombs2[regexpr(pattern = 'UNKNK?OWN', Target_Type) > 0, 
          `:=`(Target_Type = "")]

Korea_bombs2[, Unit_Squadron := gsub(pattern = "Sq\\b", replacement = "Squadron", Unit_Squadron)]

Korea_bombs2[, Aircraft_Type := fct_recode(Aircraft_Type, `RB-45` = "RB 45")]
Korea_bombs2[, Aircraft_Lost_Num := fct_other(Aircraft_Lost_Num, keep = c("1", "2", "3"), other_level = "")]
Korea_bombs2[, Weapon_Type := fct_other(Weapon_Type, drop = c("UNKNOWN"), other_level = "")]
Korea_bombs2[, Mission_Type := fct_recode(Mission_Type, Interdiction = "Interdcition", Interdiction = "Interdiciton", Interdiction = "Interdicton", Interdiction = "Interduction")]
Korea_bombs2[, Nose_Fuze := fct_recode(Nose_Fuze, Instantaneous = "instantaneous")]
Korea_bombs2[, Nose_Fuze := fct_other(Nose_Fuze, drop = c("Unknown to poor results."), other_level = "")]

Korea_bombs2$Weapon_Type %>% setattr("levels", gsub(pattern = " GP\\b", replacement = " LB GP", levels(.)))
Korea_bombs2$Unit_Squadron %>% setattr("levels", gsub(pattern = " SQ\\b", replacement = " SQUADRON", levels(.)))

# general fixes, strings
Korea_bombs2$Aircraft_Type %>% setattr("levels", proper_noun_phrase_aircraft_vectorized(levels(.)))
Korea_bombs2$Target_Type %>% setattr("levels", tolower(cleanup_targets(toupper(levels(.)))))
Korea_bombs2$Target_Name %>% setattr("levels", remove_quotes(levels(.)))
Korea_bombs2$Bomb_Sighting_Method %>% setattr("levels", tolower(levels(.)))
Korea_bombs2$Bomb_Damage_Assessment %>% setattr("levels", remove_quotes(levels(.)))
Korea_bombs2$Nose_Fuze %>% setattr("levels", remove_quotes(levels(.)))
Korea_bombs2$Tail_Fuze %>% setattr("levels", remove_quotes(levels(.)))

# type fixes
Korea_bombs2[, Row_Number := as.integer(Row_Number)] # gets forced to character somehow
Korea_bombs2[, Mission_Number := as.integer(Mission_Number)] # gets forced to character somehow
Korea_bombs2[, Aircraft_Lost_Num := as.integer(Aircraft_Lost_Num)] # fixing data type due to bad data
Korea_bombs2[, Weapon_Expended_Num := as.integer(Weapon_Expended_Num)] # gets forced to character somehow


### Vietnam Edits -----------------------------------------------------------

if(debug_mode_on) print("fixing Vietnam")

# specific fixes, numerics
Vietnam_bombs[Weapon_Jettisoned_Num == -1, 
              `:=`(Weapon_Jettisoned_Num = NA_integer_)]
Vietnam_bombs[Weapon_Returned_Num == -1, 
              `:=`(Weapon_Returned_Num = NA_integer_)]
Vietnam_bombs[Weapon_Weight_Loaded == -1, 
              `:=`(Weapon_Weight_Loaded = NA_integer_)]

# general fixes, numerics
Vietnam_bombs[, Bomb_Altitude_Feet := as.integer(Bomb_Altitude * 1000)] # assumed factor of 1000 here (in ft)--otherwise makes no sense

# general fixes, times
Vietnam_bombs[, Bomb_Time := format_military_times(Bomb_Time)]
Vietnam_bombs[, Target_Time_Off := format_military_times(Target_Time_Off)]

# specific fixes, strings
Vietnam_bombs$Aircraft_Type %>% setattr("levels", gsub(pattern = "([A-Za-z]+)[ ./]?(\\d+[A-Za-z]*)( ?/.*)?", replacement = "\\1-\\2", levels(.)))
Vietnam_bombs$Target_Type %>% setattr("levels", gsub(pattern = "/ANY", replacement = '', fixed = TRUE, 
                                                     gsub(pattern = "\\", replacement = '/', fixed = TRUE, levels(.))))
Vietnam_bombs$Operation %>% setattr("levels", gsub(pattern = "^([- \"/]+)|(IN COUNTRY[- \"/]*)", replacement = '', levels(.)))
Vietnam_bombs$Operation %>% setattr("levels", gsub(pattern = "ROLLING THUN((D)|( - ROLLING THUN))?", replacement = "ROLLING THUNDER", levels(.)))

Vietnam_bombs[, Unit_Country := fct_recode(Unit_Country, `South Korea` = "KOREA (SOUTH)", `USA` = "UNITED STATES OF AMERICA", `South Vietnam` = "VIETNAM (SOUTH)")]
Vietnam_bombs[, Unit_Service := fct_other(Unit_Service, drop = c("OTHER"), other_level = "")]
Vietnam_bombs[, Aircraft_Type := fct_other(Aircraft_Type, drop = c("NOT CODED"), other_level = "")]
Vietnam_bombs[, Target_Type := fct_other(Target_Type, drop = c("NO TARGET ACQUIRED", "UNKNOWN/UNIDENTIFIED", "UNK/UND"), other_level = "")]
Vietnam_bombs[, Target_Type := fct_recode(Target_Type, TROOPS = "TROOP UNK", TROOPS = "TROOP UNK #")]
Vietnam_bombs[, Weapon_Type := fct_other(Weapon_Type, drop = c("UNK", "UNKNOWN"), other_level = "")]
Vietnam_bombs[, Mission_Function_Code := fct_other(Mission_Function_Code, drop = c("1B", "1S", "1T", "1U", "2I", "2N", "2O", "3C", "3F", "3K", "3S", "3T", "3U", "4N", "5J", "6L", "6S"), other_level = "")]
Vietnam_bombs[, Mission_Day_Period := fct_other(Mission_Day_Period, keep = c("D", "N", "M", "E"), other_level = "")]
Vietnam_bombs[, Target_CloudCover := fct_other(Target_CloudCover, drop = c("NOT OBS"), other_level = "")]
Vietnam_bombs[, Target_Control := fct_other(Target_Control, drop = c("UNKNOWN"), other_level = "")]
Vietnam_bombs[, Target_Country := fct_other(Target_Country, drop = c("UNKNOWN"), other_level = "")]
Vietnam_bombs[, Target_Country := fct_recode(Target_Country, PHILIPPINES = "PHILLIPINES", `WEST PACIFIC WATERS` = "WESTPAC WATERS")]


# general fixes, strings
Vietnam_bombs$Unit_Country %>% setattr("levels", proper_noun_phrase_vectorized(levels(.)))
Vietnam_bombs$Aircraft_Type %>% setattr("levels", format_aircraft_types(levels(.)))
Vietnam_bombs$Target_Type %>% setattr("levels", tolower(cleanup_targets(levels(.))))
Vietnam_bombs$Takeoff_Location %>% setattr("levels", proper_noun_phrase_vectorized(levels(.)))
Vietnam_bombs$Mission_Function_Description %>% setattr("levels", tolower(levels(.)))
Vietnam_bombs$Operation %>% setattr("levels", capitalize_phrase_vectorized(levels(.)))
Vietnam_bombs$Mission_Day_Period %>% setattr("levels", ifelse(levels(.) == "D", "day", ifelse(levels(.) == "N", "night", ifelse(levels(.) == "M", "morning", ifelse(levels(.) == "E", "evening", "")))))
Vietnam_bombs$Target_CloudCover %>% setattr("levels", tolower(levels(.)))
Vietnam_bombs$Target_Country %>% setattr("levels", proper_noun_phrase_vectorized(levels(.)))
Vietnam_bombs$Weapon_Class %>% setattr("levels", tolower(levels(.)))

# type fixes
Vietnam_bombs[, Mission_Function_Code := as.integer(Mission_Function_Code)]

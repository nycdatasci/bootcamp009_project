# @author Scott Dobbins
# @version 0.8
# @date 2017-04-23 01:30

### import useful packages ###

# import data analytic extensions
library(data.table) # helps with data input
library(dplyr)      # helps with data cleaning
library(tidyr)      # helps with data tidying
library(lubridate)  # helps with dates

# source helper functions
source(file = 'helper.R')


### debug control ###
debug_mode_on = TRUE

### file path setup

# conflict directories
WW1_directory <- './THOR/WW1/'
WW2_directory <- './THOR/WW2/'
Korea_directory <- './THOR/Korea/'
Vietnam_directory <- './THOR/Vietnam/'

# directory structure
data_infix <- 'data/'
glossary_infix <- 'glossary/'

# standard file names
aircraft_glossary_name <- 'aircraft.csv'
weapons_glossary_name <- 'weapons.csv'

# specific file names
WW1_bombs_filename <- 'WW1_bombs.csv'
WW2_bombs_filename <- 'WW2_bombs.csv'
Korea_bombs1_filename <- 'Korea_bombs1.csv'
Korea_bombs2_filename <- 'Korea_bombs2.csv'
Vietnam_bombs_filename <- 'Vietnam_bombs.csv'

# total file paths
WW1_bombs_filepath <- paste0(WW1_directory, data_infix, WW1_bombs_filename)
WW2_bombs_filepath <- paste0(WW2_directory, data_infix, WW2_bombs_filename)
Korea_bombs1_filepath <- paste0(Korea_directory, data_infix, Korea_bombs1_filename)
Korea_bombs2_filepath <- paste0(Korea_directory, data_infix, Korea_bombs2_filename)
Vietnam_bombs_filepath <- paste0(Vietnam_directory, data_infix, Vietnam_bombs_filename)

WW1_aircraft_glossary_filepath <- paste0(WW1_directory, glossary_infix, aircraft_glossary_name)
WW1_weapons_glossary_filepath <- paste0(WW1_directory, glossary_infix, weapons_glossary_name)
WW2_aircraft_glossary_filepath <- paste0(WW2_directory, glossary_infix, aircraft_glossary_name)
WW2_weapons_glossary_filepath <- paste0(WW2_directory, glossary_infix, weapons_glossary_name)
Korea_aircraft_glossary_filepath <- paste0(Korea_directory, glossary_infix, aircraft_glossary_name)
#Korea weapons glossary doesn't exist#
Vietnam_aircraft_glossary_filepath <- paste0(Vietnam_directory, glossary_infix, aircraft_glossary_name)
Vietnam_weapons_glossary_filepath <- paste0(Vietnam_directory, glossary_infix, weapons_glossary_name)


### set column names ###

WW1_col_names <- c("ID",                           # integer
                   "Mission.Date",                 # character
                   "Operation",                    # character
                   "Unit.Country",                 # character
                   "Unit.Service",                 # character
                   "Unit.Aircraft.Unit",           # character
                   "Aircraft.Type",                # character
                   "Mission.Num",                  # integer
                   "Takeoff.Day.Period",           # character
                   "Takeoff.Time",                 # character
                   "Aircraft.Attacking.Num",       # integer
                   "Callsign",                     # character
                   "Weapons.Expended",             # integer
                   "Weapons.Type",                 # character
                   "Weapons.Weight",               # double
                   "Aircraft.Bombload",            # double
                   "Target.Latitude",              # double
                   "Target.Longitude",             # double
                   "Target.City",                  # character
                   "Target.Country",               # character
                   "Target.Type",                  # character
                   "Takeoff.Base",                 # character
                   "Takeoff.Latitude",             # double
                   "Takeoff.Longitude",            # double
                   "Bomb.Damage.Assessment",       # character
                   "Enemy.Action",                 # character
                   "Route.Details",                # character
                   "Intel.Collected",              # character
                   "Casualties.Friendly",          # integer
                   "Casualties.Friendly.Verbose",  # character
                   "Target.Weather",               # character
                   "Bomb.Altitude")                # integer

WW2_col_names <- c("ID",                             # integer
                   "Index.Number",                   # integer
                   "Mission.Date",                   # character
                   "Mission.Theater",                # character
                   "Unit.Service",                   # character
                   "Unit.Country",                   # character
                   "Target.Country.Code",            # integer
                   "Target.Country",                 # character
                   "Target.City",                    # character
                   "Target.Type",                    # character
                   "Target.Code",                    # integer
                   "Target.Industry.Code",           # integer
                   "Target.Industry",                # character
                   #"Target.Latitude.Nonconverted",  # character   # dropped while reading
                   #"Target.Longitude.Nonconverted", # character   # dropped while reading
                   "Target.Latitude",                # double
                   "Target.Longitude",               # double
                   "Unit.ID",                        # character
                   "Aircraft.Model",                 # character
                   "Aircraft.Name",                  # character
                   "Mission.Type",                   # integer
                   "Target.Priority.Code",           # integer
                   "Target.Priority.Explanation",    # character
                   "Aircraft.Attacking.Num",         # integer
                   "Bomb.Altitude",                  # integer
                   "Bomb.Altitude.Feet",             # integer
                   "Bomb.HE.Num",                    # integer
                   "Bomb.HE.Type",                   # character
                   "Bomb.HE.Pounds",                 # integer
                   "Bomb.HE.Tons",                   # double
                   "Bomb.IC.Num",                    # integer
                   "Bomb.IC.Type",                   # character
                   "Bomb.IC.Pounds",                 # integer
                   "Bomb.IC.Tons",                   # double
                   "Bomb.Frag.Num",                  # integer
                   "Bomb.Frag.Type",                 # character
                   "Bomb.Frag.Pounds",               # integer
                   "Bomb.Frag.Tons",                 # double                
                   "Bomb.Total.Pounds",              # integer
                   "Bomb.Total.Tons",                # double
                   "Takeoff.Base",                   # character
                   "Takeoff.Country",                # character
                   "Takeoff.Latitude",               # double
                   "Takeoff.Longitude",              # double
                   "Aircraft.Lost.Num",              # integer
                   "Aircraft.Damaged.Num",           # integer
                   "Aircraft.Airborne.Num",          # integer
                   "Aircraft.Dropping.Num",          # integer
                   "Bomb.Time",                      # character
                   "Sighting.Method.Code",           # integer
                   "Sighting.Method.Explanation",    # character
                   "Bomb.Damage.Assessment",         # character
                   "Callsign",                       # character
                   "Ammo.Rounds",                    # integer
                   "Aircraft.Spares.Num",            # integer
                   "Aircraft.Fail.WX.Num",           # integer
                   "Aircraft.Fail.Mech.Num",         # integer
                   "Aircraft.Fail.Misc.Num",         # integer
                   "Target.Comment",                 # character
                   "Mission.Comments",               # character
                   "Reference.Source",               # character
                   "Database.Edit.Comments")         # character

Korea_col_names1 <- c("ID",#                                  # integer
                      "Mission.Date",#                        # character
                      "Unit.ID",#                             # character
                      "Unit.ID2",#                            # character
                      "Unit.ID.Long",#                        # character
                      "Group.Unit.ID",#                       # character
                      "Squadron.ID",#                         # character
                      "Airfield.ID",#                         # character
                      "Takeoff.Base",#                        # character
                      "Takeoff.Country",#                     # character
                      "Takeoff.Latitude",#                    # double
                      "Takeoff.Longitude",#                   # double
                      "Aircraft.Type",#                       # character
                      "Aircraft.Dispatched.Num",#             # integer
                      "Aircraft.Attacking.Num",#              # integer
                      "Aircraft.Aborted.Num",#                # integer
                      "Aircraft.Lost.Enemy.Air.Num",#         # integer
                      "Aircraft.Lost.Enemy.Ground.Num",#      # integer
                      "Aircraft.Lost.Enemy.Unknown.Num",#     # integer
                      "Aircraft.Lost.Other.Num",#             # integer
                      "Aircraft.Damaged.Num",#                # integer
                      "KIA",#                                 # integer
                      "WIA",#                                 # integer
                      "MIA",#                                 # integer
                      "Enemy.Aircraft.Destroyed.Confirmed",#  # integer
                      "Enemy.Aircraft.Destroyed.Probable",#   # integer
                      "Bomb.Total.Tons",#                     # double
                      "Rockets.Num",#                         # integer
                      "Bullets.Rounds")#                      # integer

Korea_col_names2 <- c("Row.Number",                          # integer
                      "Mission.Number",                      # integer
                      "Unit.Order",                          # character
                      "Unit.Group",                          # character
                      "Mission.Date",                        # character
                      "Aircraft.Type",                       # character
                      "Aircraft.Attacking.Num",              # integer
                      "Sortie.Duplicates",                   # integer
                      "Aircraft.Aborted.Num",                # integer
                      "Aircraft.Lost.Num",                   # integer
                      "Target.Name",                         # character
                      "Target.Type",                         # character
                      #"Target.JapanB",                      # character   # dropped while reading
                      #"Target.UTM",                         # character   # dropped while reading
                      #"Target.MGRS",                        # character   # dropped while reading
                      "Target.Latitude",                     # character
                      "Target.Longitude",                    # character
                      #"Target.Latitude.Source",             # character   # dropped while reading
                      #"Target.Longitude.Source",            # character   # dropped while reading
                      "Weapons.Num",                         # integer
                      "Weapons.Type",                        # character
                      "Bomb.Sighting.Method",                # character
                      "Aircraft.Bombload.Pounds",            # integer
                      #"Aircraft.Total.Weight",              # character   # dropped while reading
                      "Mission.Type",                        # character
                      "Bomb.Altitude.Feet.Range",            # character
                      "Callsign",                            # character
                      "Bomb.Damage.Assessment",              # character
                      "Nose.Fuze",                           # character
                      "Tail.Fuze",                           # character
                      "Aircraft.Bombload.Calculated.Pounds", # integer
                      "Reference.Source")                    # character

Vietnam_col_names <- c("ID",                               # integer
                       "Unit.Country",                     # character
                       "Unit.Service",                     # character
                       "Mission.Date",                     # character
                       "Reference.Source.ID",              # integer
                       "Reference.Source.Record",          # character
                       "Aircraft.Root.Valid",              # character
                       "Takeoff.Location",                 # character
                       "Target.Latitude",                  # double
                       "Target.Longitude",                 # double
                       "Target.Type",                      # character
                       "Weapons.Delivered.Num",            # integer
                       "Bomb.Time",                        # character
                       "Weapon.Type",                      # character
                       "Weapon.Type.Class",                # character
                       "Weapon.Type.Weight",               # integer
                       "Aircraft.Original",                # character
                       "Aircraft.Root",                    # character
                       "Unit.Group",                       # character
                       "Unit.Squadron",                    # character
                       "Callsign",                         # character
                       "Flight.Hours",                     # integer
                       "Mission.Function.Code",            # integer
                       "Mission.Function.Description",     # character
                       "Mission.ID",                       # character
                       "Aircraft.Num",                     # integer
                       "Operation.Supported",              # character
                       "Mission.Day.Period",               # character
                       "Unit",                             # character
                       "Target.CloudCover",                # character
                       "Target.Control",                   # character
                       "Target.Country",                   # character
                       "Target.ID",                        # character
                       #"Target.Origin.Coordinates",       # character   # dropped while reading
                       #"Target.Origin.Coordinates.Format",# character   # dropped while reading
                       "Target.Weather",                   # character
                       "Additional.Info",                  # character
                       "Target.Geozone",                   # character
                       "ID2",                              # integer
                       "Weapons.Class",                    # character
                       "Weapons.Jettisoned.Num",           # integer
                       "Weapons.Returned.Num",             # integer
                       "Bomb.Altitude",                    # integer
                       "Bomb.Speed",                       # integer
                       "Bomb.Damage.Assessment",           # character
                       "Target.Time.Off",                  # integer
                       "Weapons.Weight.Loaded")            # integer


### set data column classes ###

WW1_col_classes <- list(integer = c("WWI_ID", "MISSIONNUM", "NUMBEROFPLANESATTACKING", "WEAPONSEXPENDED", "FRIENDLYCASUALTIES", "ALTITUDE"), 
                        double = c("WEAPONWEIGHT", "BOMBLOAD", "LATITUDE", "LONGITUDE", "TAKEOFFLATITUDE", "TAKEOFFLONGITUDE"), 
                        character = c("MSNDATE", "OPERATION", "COUNTRY", "SERVICE", "UNIT", "MDS", "DEPARTURE", "TAKEOFFTIME", "CALLSIGN", "WEAPONTYPE", "TGTLOCATION", "TGTCOUNTRY", "TGTTYPE", "TAKEOFFBASE", "BDA", "ENEMYACTION", "ROUTEDETAILS", "ISRCOLLECTED", "FRIENDLYCASUALTIES_VERBOSE", "WEATHER"))

WW2_col_classes <- list(integer = c("WWII_ID", "MASTER_INDEX_NUMBER", "TGT_COUNTRY_CODE", "TGT_ID", "TGT_INDUSTRY_CODE", "MSN_TYPE", "TGT_PRIORITY", "AC_ATTACKING", "ALTITUDE", "ALTITUDE_FEET", "NUMBER_OF_HE", "LBS_HE", "NUMBER_OF_IC", "LBS_IC", "NUMBER_OF_FRAG", "LBS_FRAG", "TOTAL_LBS", "AC_LOST", "AC_DAMAGED", "AC_AIRBORNE", "AC_DROPPING", "SIGHTING_METHOD_CODE", "ROUNDS_AMMO", "SPARES_RETURN_AC", "WX_FAIL_AC", "MECH_FAIL_AC", "MISC_FAIL_AC"), 
                        double = c("LATITUDE", "LONGITUDE", "TONS_OF_HE", "TONS_OF_IC", "TONS_OF_FRAG", "TOTAL_TONS", "TAKEOFF_LATITUDE", "TAKEOFF_LONGITUDE"), 
                        character = c("MSNDATE", "THEATER", "NAF", "COUNTRY_FLYING_MISSION", "TGT_COUNTRY", "TGT_LOCATION", "TGT_TYPE", "TGT_INDUSTRY", "UNIT_ID", "MDS", "AIRCRAFT_NAME", "TGT_PRIORITY_EXPLANATION", "TYPE_OF_HE", "TYPE_OF_IC", "TYPE_OF_FRAG", "TAKEOFF_BASE", "TAKEOFF_COUNTRY", "TIME_OVER_TARGET", "SIGHTING_EXPLANATION", "BDA", "CALLSIGN", "TARGET_COMMENT", "MISSION_COMMENTS", "SOURCE", "DATABASE_EDIT_COMMENTS"), 
                        NULL = c("SOURCE_LATITUDE", "SOURCE_LONGITUDE"))

Korea_col_classes1 <- list(integer = c("KOREAN_ID", "AC_DISPATCHED", "AC_EFFECTIVE", "AC_ABORT", "AC_LOST_TO_EAC", "AC_LOST_TO_AAA", "AC_LOST_TO_UNKNOWN_EA", "AC_LOST_TO_OTHER", "AC_DAMAGED", "KIA", "WIA", "MIA", "EAC_CONFIRMED_DESTROYED", "EAC_PROB_DESTROYED", "ROCKETS", "BULLETS"), 
                           double = c("LAUNCH_LAT", "LAUNCH_LONG", "TOTAL_TONS"), 
                           character = c("MSN_DATE", "UNIT_ID", "UNIT_ID_2", "UNIT_ID_CODE", "GROUP_OR_HIGHER_UNIT_ID", "SQUADRON_ID", "AIRFIELD_ID", "LAUNCH_BASE", "LAUNCH_COUNTRY", "AC_TYPE"))

Korea_col_classes2 <- list(integer = c("ROW_NUMBER", "MISSION_NUMBER", "NBR_ATTACK_EFFEC_AIRCRAFT", "SORTIE_DUPE", "NBR_ABORT_AIRCRAFT", "NBR_LOST_AIRCRAFT", "NBR_OF_WEAPONS", "TOTAL_BOMBLOAD_IN_LBS", "CALCULATED_BOMBLOAD_LBS"), 
                           character = c("OP_ORDER", "UNIT", "MISSION_DATE", "AIRCRAFT_TYPE_MDS", "TARGET_NAME", "TGT_TYPE", "TGT_LATITUDE_WGS84", "TGT_LONGITUDE_WGS84", "WEAPONS_TYPE", "BOMB_SIGHTING_METHOD", "MISSION_TYPE", "ALTITUDE_FT", "CALLSIGN", "BDA", "NOSE_FUZE", "TAIL_FUZE", "RECORD_SOURCE"), 
                           NULL = c("SOURCE_UTM_JAPAN_B", "SOURCE_TGT_UTM", "TGT_MGRS", "SOURCE_TGT_LAT", "SOURCE_TGT_LONG", "TOT"))

Vietnam_col_classes <- list(integer = c("THOR_DATA_VIET_ID", "SOURCEID", "NUMWEAPONSDELIVERED", "WEAPONTYPEWEIGHT", "FLTHOURS", "MFUNC", "NUMOFACFT", "ID", "NUMWEAPONSJETTISONED", "NUMWEAPONSRETURNED", "RELEASEALTITUDE", "RELEASEFLTSPEED", "TIMEOFFTARGET", "WEAPONSLOADEDWEIGHT"), 
                            double = c("TGTLATDD_DDD_WGS84", "TGTLONDDD_DDD_WGS84"), 
                            character = c("COUNTRYFLYINGMISSION", "MILSERVICE", "MSNDATE", "SOURCERECORD", "VALID_AIRCRAFT_ROOT", "TAKEOFFLOCATION", "TGTTYPE", "TIMEONTARGET", "WEAPONTYPE", "WEAPONTYPECLASS", "AIRCRAFT_ORIGINAL", "AIRCRAFT_ROOT", "AIRFORCEGROUP", "AIRFORCESQDN", "CALLSIGN", "MFUNC_DESC", "MISSIONID", "OPERATIONSUPPORTED", "PERIODOFDAY", "UNIT", "TGTCLOUDCOVER", "TGTCONTROL", "TGTCOUNTRY", "TGTID", "TGTWEATHER", "ADDITIONALINFO", "GEOZONE", "MFUNC_DESC_CLASS", "RESULTSBDA"), 
                            NULL = c("TGTORIGCOORDS", "TGTORIGCOORDSFORMAT"))


### read raw data ###

if(debug_mode_on) print("reading WW1")
WW1_bombs <- fread(file =  WW1_bombs_filepath, 
                   sep = ',', 
                   sep2 = '\n', 
                   header = TRUE, 
                   stringsAsFactors = FALSE, 
                   blank.lines.skip = TRUE, 
                   colClasses = WW1_col_classes, 
                   col.names = WW1_col_names)

if(debug_mode_on) print("reading WW2")
WW2_bombs <- fread(file =  WW2_bombs_filepath, 
                   sep = ',', 
                   sep2 = '\n', 
                   header = TRUE, 
                   stringsAsFactors = FALSE, 
                   blank.lines.skip = TRUE, 
                   colClasses = WW2_col_classes, 
                   col.names = WW2_col_names)

if(debug_mode_on) print("reading Korea1")
Korea_bombs1 <- fread(file =  Korea_bombs1_filepath, 
                      sep = ',',
                      sep2 = '\n', 
                      header = TRUE, 
                      stringsAsFactors = FALSE, 
                      blank.lines.skip = TRUE, 
                      colClasses = Korea_col_classes1, 
                      col.names = Korea_col_names1)

if(debug_mode_on) print("reading Korea2")
Korea_bombs2 <- fread(file =  Korea_bombs2_filepath, 
                      sep = ',',
                      sep2 = '\n', 
                      header = TRUE, 
                      stringsAsFactors = FALSE, 
                      blank.lines.skip = TRUE, 
                      colClasses = Korea_col_classes2, 
                      col.names = Korea_col_names2)

if(debug_mode_on) print("reading Vietnam")
Vietnam_bombs <- fread(file =  Vietnam_bombs_filepath, 
                       sep = ',', 
                       sep2 = '\n', 
                       header = TRUE, 
                       stringsAsFactors = FALSE, 
                       blank.lines.skip = TRUE, 
                       colClasses = Vietnam_col_classes, 
                       col.names = Vietnam_col_names)


### fix dates and set keys ###

# fix mission date columns
if(debug_mode_on) print("fixing date columns")
WW1_bombs[, Mission.Date := .(ymd(Mission.Date))]
WW2_bombs[, Mission.Date := .(mdy(Mission.Date))]
Korea_bombs1[, Mission.Date := .(mdy(Mission.Date) - years(100))]
Korea_bombs2[, Mission.Date := .(mdy(Mission.Date) - years(100))]
Vietnam_bombs[, Mission.Date := .(ymd(Mission.Date))] # 50000 dates are missing

# sort by mission date for efficient searching
if(debug_mode_on) print("setting keys")
setkey(WW1_bombs, Mission.Date)
setkey(WW2_bombs, Mission.Date)
setkey(Korea_bombs1, Mission.Date)
setkey(Korea_bombs2, Mission.Date)
setkey(Vietnam_bombs, Mission.Date)

### fix actual data where necessary ###

# WW1
if(debug_mode_on) print("fixing WW1")
WW1_bombs[, ID := .(as.integer(ID))] # gets forced to character somehow
if(debug_mode_on) print("1")
WW1_bombs[Operation == "WW I", c("Operation")] <- ""
if(debug_mode_on) print("2")
WW1_bombs[, Unit.Country := sapply(Unit.Country, proper_noun_phrase)]
if(debug_mode_on) print("3")
WW1_bombs[, Unit.Aircraft.Unit := sapply(Unit.Aircraft.Unit, proper_noun_phrase)]
if(debug_mode_on) print("4")
WW1_bombs[, Mission.Num := .(as.integer(Mission.Num))] # gets forced to character somehow
if(debug_mode_on) print("5")
WW1_bombs[, Takeoff.Day.Period := .(tolower(Takeoff.Day.Period))]
if(debug_mode_on) print("6")
WW1_bombs[, Takeoff.Time := .(format(strptime(Takeoff.Time, format = "%Y-%m-%d %H:%M:%S"), format = "%H:%M"))]
if(debug_mode_on) print("7")
WW1_bombs[, Weapons.Expended := .(as.integer(Weapons.Expended))] # gets forced to character somehow
if(debug_mode_on) print("8")
WW1_bombs[, Weapons.Type := .(tolower(Weapons.Type))]
if(debug_mode_on) print("9")
WW1_bombs[, Weapons.Weight := .(round(Weapons.Weight))] # round away needless precision
if(debug_mode_on) print("10")
WW1_bombs[, Aircraft.Bombload := .(as.integer(round(Aircraft.Bombload)))] # round away needless precision
if(debug_mode_on) print("11")
WW1_bombs[, Target.City := sapply(remove_nonASCII_chars(Target.City), proper_noun_phrase)]
if(debug_mode_on) print("12")
WW1_bombs[, Target.Country := .(capitalize_from_caps(Target.Country))]
if(debug_mode_on) print("13")
WW1_bombs[, Target.Type := .(tolower(Target.Type))]
if(debug_mode_on) print("14")
WW1_bombs[, Takeoff.Base := sapply(remove_nonASCII_chars(Takeoff.Base), proper_noun_phrase)]
if(debug_mode_on) print("15")
WW1_bombs[, Route.Details := sapply(Route.Details, proper_noun_phrase)]
if(debug_mode_on) print("16")
WW1_bombs[, Target.Weather := .(tolower(Target.Weather))]
if(debug_mode_on) print("17")

# WW2
if(debug_mode_on) print("fixing WW2")
WW2_bombs[, Unit.Country := sapply(Unit.Country, proper_noun_phrase)]
if(debug_mode_on) print("1")
WW2_bombs[, Target.Country := sapply(Target.Country, proper_noun_phrase)]
if(debug_mode_on) print("2")
WW2_bombs[, Target.City := .(sapply(remove_nonASCII_chars(remove_quotes(Target.City)), proper_noun_phrase))]
if(debug_mode_on) print("3")
WW2_bombs[!is.na(as.integer(substring(Target.City, 1, 1))), c("Target.City")] <- ""
if(debug_mode_on) print("4")
WW2_bombs[, Target.Type := .(tolower(Target.Type))]
if(debug_mode_on) print("5")
WW2_bombs[, Target.Industry := .(tolower(remove_quotes(Target.Industry)))]
if(debug_mode_on) print("6")
WW2_bombs[, Target.Priority.Code := .(as.integer(Target.Priority.Code))] # gets forced to character somehow
if(debug_mode_on) print("7")
WW2_bombs[, Bomb.Altitude.Feet := .(as.integer(round(Bomb.Altitude*100)))]
if(debug_mode_on) print("8")
WW2_bombs[, Bomb.Altitude := NULL]
if(debug_mode_on) print("9")

WW2_bombs[, Bomb.HE.Num := .(as.integer(Bomb.HE.Num))] # gets forced to double somehow
if(debug_mode_on) print("10")
WW2_bombs[, Bomb.Frag.Num := .(as.integer(Bomb.Frag.Num))] # gets forced to double somehow
if(debug_mode_on) print("11")

WW2_bombs[, Bomb.Total.Tons := Bomb.HE.Tons + Bomb.IC.Tons + Bomb.Frag.Tons]
if(debug_mode_on) print("12")
WW2_bombs[, Bomb.Total.Pounds := .(as.integer(Bomb.Total.Tons*2000))]
if(debug_mode_on) print("13")

WW2_bombs[is.na(Bomb.HE.Tons), c("Bomb.HE.Tons")] <- 0
if(debug_mode_on) print("14")
WW2_bombs[, Bomb.HE.Pounds := .(as.integer(Bomb.HE.Tons*2000))]
if(debug_mode_on) print("15")

WW2_bombs[is.na(Bomb.IC.Tons), c("Bomb.IC.Tons")] <- 0
if(debug_mode_on) print("16")
WW2_bombs[, Bomb.IC.Pounds := .(as.integer(Bomb.IC.Tons*2000))]
if(debug_mode_on) print("17")

WW2_bombs[is.na(Bomb.Frag.Tons), c("Bomb.Frag.Tons")] <- 0
if(debug_mode_on) print("18")
WW2_bombs[, Bomb.Frag.Pounds := .(as.integer(Bomb.Frag.Tons*2000))]
if(debug_mode_on) print("19")

WW2_bombs[, Takeoff.Base := sapply(Takeoff.Base, proper_noun_phrase)]
if(debug_mode_on) print("20")
WW2_bombs[, Takeoff.Country := sapply(Takeoff.Country, proper_noun_phrase)]
if(debug_mode_on) print("21")
WW2_bombs[, Aircraft.Airborne.Num := .(as.integer(Aircraft.Airborne.Num))] # gets forced to double somehow
if(debug_mode_on) print("22")
WW2_bombs[, Bomb.Time := .(format(strptime(Bomb.Time, format = "%H%M"), format = "%H:%M"))]
if(debug_mode_on) print("23")
WW2_bombs[, Sighting.Method.Code := .(as.integer(Sighting.Method.Code))] # gets forced to character somehow
if(debug_mode_on) print("24")
WW2_bombs[, Sighting.Method.Explanation := .(tolower(Sighting.Method.Explanation))]
if(debug_mode_on) print("25")

# Korea
if(debug_mode_on) print("fixing Korea2")
Korea_bombs2[, Row.Number := .(as.integer(Row.Number))] # gets forced to character somehow
if(debug_mode_on) print("1")
Korea_bombs2[, Mission.Number := .(as.integer(Mission.Number))] # gets forced to character somehow
if(debug_mode_on) print("2")
Korea_bombs2[, Aircraft.Lost.Num := .(as.integer(Aircraft.Lost.Num))] # gets forced to character somehow
if(debug_mode_on) print("3")
Korea_bombs2[, Target.Latitude := .(as.numeric(substr(Target.Latitude, 1, nchar(Target.Latitude)-1)))]
if(debug_mode_on) print("4")
Korea_bombs2[, Target.Longitude := .(as.numeric(substr(Target.Longitude, 1, nchar(Target.Longitude)-1)))]
if(debug_mode_on) print("5")
Korea_bombs2[, Weapons.Num := .(as.integer(Weapons.Num))] # gets forced to character somehow
if(debug_mode_on) print("6")
Korea_bombs2 <- separate(data = Korea_bombs2,
                         col = Bomb.Altitude.Feet.Range,
                         into = c("Bomb.Altitude.Feet.Low", "Bomb.Altitude.Feet.High"),
                         sep = '-',
                         extra = 'merge',
                         fill = 'right')
if(debug_mode_on) print("7")
Korea_bombs2[, Bomb.Altitude.Feet.Low := .(as.integer(Bomb.Altitude.Feet.Low))]
if(debug_mode_on) print("8")
Korea_bombs2[, Bomb.Altitude.Feet.High := .(as.integer(Bomb.Altitude.Feet.High))]
if(debug_mode_on) print("9")

# Vietnam
if(debug_mode_on) print("fixing Vietnam")
Vietnam_bombs[, Unit.Country := sapply(Unit.Country, proper_noun_phrase)]         # this takes way too long
if(debug_mode_on) print("1")
Vietnam_bombs[, Takeoff.Location := sapply(Takeoff.Location, proper_noun_phrase)] # this takes way too long
if(debug_mode_on) print("2")
Vietnam_bombs[, Target.Type := .(tolower(gsub(pattern = '\\\\', replacement = '/', Target.Type)))]
if(debug_mode_on) print("3")
Vietnam_bombs[, Bomb.Time := .(format(strptime(Bomb.Time, format = "%H%M"), format = "%H:%M"))]
if(debug_mode_on) print("4")
Vietnam_bombs[, Mission.Function.Code := .(as.integer(Mission.Function.Code))] # gets forced to character somehow
if(debug_mode_on) print("5")
Vietnam_bombs[, Mission.Function.Description := .(tolower(Mission.Function.Description))]
if(debug_mode_on) print("6")
Vietnam_bombs[, Operation.Supported := .(tolower(Operation.Supported))]
if(debug_mode_on) print("7")
Vietnam_bombs[, Mission.Day.Period := .(ifelse(Mission.Day.Period == "D", "day", ifelse(Mission.Day.Period == "N", "night", "")))]
if(debug_mode_on) print("8")
Vietnam_bombs[, Target.CloudCover := .(tolower(Target.CloudCover))]
if(debug_mode_on) print("9")
Vietnam_bombs[, Target.Control := .(tolower(Target.Control))]
if(debug_mode_on) print("10")
Vietnam_bombs[, Target.Country := sapply(Target.Country, proper_noun_phrase)]     # this takes way too long
if(debug_mode_on) print("11")
Vietnam_bombs[, Weapons.Class := .(tolower(Weapons.Class))]
if(debug_mode_on) print("12")
Vietnam_bombs[Weapons.Jettisoned.Num == -1, c("Weapons.Jettisoned.Num")] <- NA
if(debug_mode_on) print("13")
Vietnam_bombs[Weapons.Returned.Num == -1, c("Weapons.Returned.Num")] <- NA
if(debug_mode_on) print("14")
Vietnam_bombs[Weapons.Weight.Loaded == -1, c("Weapons.Weight.Loaded")] <- NA
if(debug_mode_on) print("15")
Vietnam_bombs[, Bomb.Altitude := .(as.integer(Bomb.Altitude*1000))] # assumed factor of 1000 here (in ft)--otherwise makes no sense
if(debug_mode_on) print("16")
Vietnam_bombs[, Bomb.Time := .(format(strptime(Target.Time.Off, format = "%H%M"), format = "%H:%M"))]
if(debug_mode_on) print("17")

### add useful columns ###

if(debug_mode_on) print("adding to WW1")
WW2_bombs[, Unit.Service.Title := .(ifelse(Unit.Country == "USA", paste(Unit.Country, Unit.Service), Unit.Service))]
WW2_bombs[, Aircraft.Total := .(ifelse(!is.na(Aircraft.Attacking.Num), Aircraft.Attacking.Num,
                                       ifelse(!is.na(Aircraft.Dropping.Num), Aircraft.Dropping.Num,
                                              ifelse(!is.na(Aircraft.Airborne.Num), Aircraft.Airborne.Num, "some"))))]


### clean out obviously wrong values ###

if(debug_mode_on) print("cleaning WW1")
WW1_clean <- WW1_bombs[Target.Latitude <= 90 & Target.Latitude >= -90
                       & Target.Longitude <= 180 & Target.Longitude >= -180,]

if(debug_mode_on) print("cleaning WW2")
WW2_clean <- WW2_bombs[Target.Latitude <= 90 & Target.Latitude >= -90
                       & Target.Longitude <= 180 & Target.Longitude >= -180,]

if(debug_mode_on) print("cleaning Korea2")
Korea_clean2 <- Korea_bombs2[Target.Latitude <= 90 & Target.Latitude >= -90
                             & Target.Longitude <= 180 & Target.Longitude >= -180,]

if(debug_mode_on) print("cleaning Vietnam")
Vietnam_clean <- Vietnam_bombs[Target.Latitude <= 90 & Target.Latitude >= -90
                               & Target.Longitude <= 180 & Target.Longitude >= -180,]


### add tooltips ###

if(debug_mode_on) print("tooltips WW1")
WW1_clean[, tooltip := .(paste0("On ", Mission.Date, " during the ", Takeoff.Time, ",<br>",
                                Aircraft.Attacking.Num, " ", Unit.Service, " ", Aircraft.Type, "s dropped <br>",
                                Aircraft.Bombload, " lbs of bombs on <br>",
                                Target.Type, "<br>",
                                "in ", Target.City, ', ', Target.Country))]

if(debug_mode_on) print("tooltips WW2")
WW2_clean[, tooltip := .(paste0("On ", Mission.Date, ",<br>",
                                Aircraft.Total, " ", Unit.Service, " ", Aircraft.Name, "s dropped <br>",
                                Bomb.Total.Tons, " tons of bombs on <br>",
                                Target.Type, "<br>",
                                "in ", Target.City, ", ", Target.Country))]

if(debug_mode_on) print("tooltips Korea2")
Korea_clean2[, tooltip := .(paste0("On ", Mission.Date, ",<br>",
                                   Aircraft.Attacking.Num, " ", Unit.Group, " ", Aircraft.Type, "s dropped <br>",
                                   Aircraft.Bombload.Calculated.Pounds, " pounds of bombs on <br>",
                                   Target.Type, "<br>",
                                   "in ", Target.Name))]

if(debug_mode_on) print("tooltips Vietnam")
Vietnam_clean[, tooltip := .(paste0("On ", Mission.Date, ",<br>",
                                    Aircraft.Num, " ", Unit.Service, " ", Aircraft.Root.Valid, "s dropped bombs on <br>",
                                    Target.Type, "<br>",
                                    "in ", Target.Country))]


### find unique targets etc ###
if(debug_mode_on) print("unique WW1")
WW1_unique_target <- unique(WW1_clean, by = c("Target.Latitude", "Target.Longitude"))
if(debug_mode_on) print("unique WW2")
WW2_unique_target <- unique(WW2_clean, by = c("Target.Latitude", "Target.Longitude"))
#if(debug_mode_on) print("unique Korea1")
#Korea_unique_target1 <- unique(Korea_clean1, by = c("Target.Latitude", "Target.Longitude"))
if(debug_mode_on) print("unique Korea2")
Korea_unique_target2 <- unique(Korea_clean2, by = c("Target.Latitude", "Target.Longitude"))
if(debug_mode_on) print("unique Vietnam")
Vietnam_unique_target <- unique(Vietnam_clean, by = c("Target.Latitude", "Target.Longitude"))

### sample ###
if(debug_mode_on) print("sampling WW1")
WW1_sample <- WW1_unique_target
if(debug_mode_on) print("sampling WW2")
WW2_sample <- sample_n(WW2_unique_target, size = 1000)
if(debug_mode_on) print("sampling Korea2")
Korea_sample <- sample_n(Korea_unique_target2, size = 1000)
if(debug_mode_on) print("sampling Vietnam")
Vietnam_sample <- sample_n(Vietnam_unique_target, size = 1000)

### can write samples for quick tests ###
if(debug_mode_on) print("writing WW1")
write.csv(x = data.frame(WW1_sample), file = 'saves/WW1_sample.csv', quote = TRUE)
if(full_write) write.csv(x = data.frame(WW1_clean), file = 'saves/WW1_clean.csv', quote = TRUE)
if(full_write) save(WW1_bombs, file = 'saves/WW1_bombs.Rda')
if(debug_mode_on) print("writing WW2")
write.csv(x = data.frame(WW2_sample), file = 'saves/WW2_sample.csv', quote = TRUE)
if(full_write) write.csv(x = data.frame(WW2_clean), file = 'saves/WW2_clean.csv', quote = TRUE)
if(full_write) save(WW2_bombs, file = 'saves/WW2_bombs.Rda')
if(debug_mode_on) print("writing Korea")
write.csv(x = data.frame(Korea_sample), file = 'saves/Korea_sample.csv', quote = TRUE)
if(full_write) write.csv(x = data.frame(Korea_clean2), file = 'saves/Korea_clean.csv', quote = TRUE)
if(full_write) save(Korea_bombs2, file = 'saves/Korea_bombs2.Rda')
if(debug_mode_on) print("writing Vietnam")
write.csv(x = data.frame(Vietnam_sample), file = 'saves/Vietnam_sample.csv', quote = TRUE)
if(full_write) write.csv(x = data.frame(Vietnam_clean), file = 'saves/Vietnam_clean.csv', quote = TRUE)
if(full_write) save(Vietnam_bombs, file = 'saves/Vietnam_bombs.Rda')
if(full_write) save.image(file = 'saves/Shiny_2017-04-22.RData')

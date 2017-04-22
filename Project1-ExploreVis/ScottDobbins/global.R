# @author Scott Dobbins
# @version 0.5
# @date 2017-04-21 18:53

### import useful packages ###
# shiny
library(shiny)

# import data analytic extensions
library(data.table) # helps with data input
library(dplyr)      # helps with data cleaning
library(tidyr)      # helps with data tidying

# refresh_data = TRUE
# 
# if(refresh_data) {
#   # source helper functions
#   source(file = 'helper.R')
#   source(file = 'cleaner.R')
# } else {
#   WW1_sample <- fread(file = 'WW1_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
#   WW2_sample <- fread(file = 'WW2_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
#   Korea_sample <- fread(file = 'Korea_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
#   Vietnam_sample <- fread(file = 'Vietnam_sample.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)
# }


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


### read raw data ###

# set desired classes of columns
WW1_col_classes <- c("numeric", rep("character", 6), "numeric", rep("character", 2), "numeric", "character", "numeric", "character", rep("numeric", 4), rep("character", 4), rep("numeric", 2), rep("character", 4), "numeric", rep("character", 2), "numeric")
WW2_col_classes <- c(rep("numeric", 2), rep("character", 4), "numeric", rep("character", 3), rep("numeric", 2), "character", rep("numeric", 5), rep("character", 2), rep("numeric", 2), "character", rep("numeric", 4), "character", rep("numeric", 3), "character", rep("numeric", 3), "character", rep("numeric", 4), rep("character", 2), rep("numeric", 6), "character", "numeric", rep("character", 3), rep("numeric", 5), rep("character", 4))
Korea_col_classes1 <- c(rep("character", 4), "numeric", rep("character", 5), rep("numeric", 2), "character", rep("numeric", 16))
Korea_col_classes2 <- c(rep("numeric", 2), rep("character", 4), rep("numeric", 4), rep("character", 9), "numeric", rep("character", 2), rep("numeric", 2), rep("character", 6), "numeric", "character")
Vietnam_col_classes <- c("numeric", rep("character", 3), "numeric", rep("character", 3), rep("numeric", 2), "character", "numeric", rep("character", 3), "numeric", rep("character", 5), "numeric", rep("character", 3), "numeric", rep("character", 6), "numeric", rep("character", 7), rep("numeric", 4), rep("character", 2), "numeric")

# read files
if(debug_mode_on) print("reading WW1")
WW1_bombs <- fread(file =  WW1_bombs_filepath, 
                   sep = ',', 
                   sep2 = '\n', 
                   header = TRUE, 
                   stringsAsFactors = FALSE, 
                   blank.lines.skip = TRUE, 
                   #drop = c(), 
                   colClasses = WW1_col_classes
                   )

if(debug_mode_on) print("reading WW2")
WW2_bombs <- fread(file =  WW2_bombs_filepath, 
                   sep = ',', 
                   sep2 = '\n', 
                   header = TRUE, 
                   stringsAsFactors = FALSE, 
                   blank.lines.skip = TRUE, 
                   colClasses = WW2_col_classes, 
                   drop = c("SOURCE_LATITUDE", 
                            "SOURCE_LONGITUDE")
                   )

if(debug_mode_on) print("reading Korea1")
Korea_bombs1 <- fread(file =  Korea_bombs1_filepath, 
                      sep = ',',
                      sep2 = '\n', 
                      header = TRUE, 
                      stringsAsFactors = FALSE, 
                      blank.lines.skip = TRUE, 
                      #drop = , 
                      colClasses = Korea_col_classes1
                      )

if(debug_mode_on) print("reading Korea2")
Korea_bombs2 <- fread(file =  Korea_bombs2_filepath, 
                      sep = ',',
                      sep2 = '\n', 
                      header = TRUE, 
                      stringsAsFactors = FALSE, 
                      blank.lines.skip = TRUE, 
                      colClasses = Korea_col_classes2, 
                      drop = c("SOURCE_UTM_JAPAN_B", 
                               "SOURCE_TGT_UTM", 
                               "TGT_MGRS", 
                               "SOURCE_TGT_LAT", 
                               "SOURCE_TGT_LONG")
                      )

if(debug_mode_on) print("reading Vietnam")
Vietnam_bombs <- fread(file =  Vietnam_bombs_filepath, 
                       sep = ',', 
                       sep2 = '\n', 
                       header = TRUE, 
                       stringsAsFactors = FALSE, 
                       blank.lines.skip = TRUE, 
                       colClasses = Vietnam_col_classes, 
                       drop = c("TGTORIGCOORDS", 
                                "TGTORIGCOORDSFORMAT")
                       )

### change column names ###

WW1_col_names <- c("ID",
                   "Mission.Date",
                   "Operation",
                   "Unit.Country",
                   "Unit.Service",
                   "Unit.Aircraft.Unit",
                   "Aircraft.Model",
                   "Mission.Num",
                   "Takeoff.Day.Period",
                   "Takeoff.Time",
                   "Aircraft.Attacking.Num",
                   "Callsign",
                   "Weapons.Expended",
                   "Weapons.Type",
                   "Weapons.Weight",
                   "Aircraft.Bombload",
                   "Target.Latitude",
                   "Target.Longitude",
                   "Target.City",
                   "Target.Country",
                   "Target.Type",
                   "Takeoff.Base",
                   "Takeoff.Latitude",
                   "Takeoff.Longitude",
                   "Bomb.Damage.Assessment",
                   "Enemy.Action",
                   "Route.Details",
                   "Intel.Collected",
                   "Casualties.Friendly",
                   "Casualties.Friendly.Verbose",
                   "Target.Weather",
                   "Bomb.Altitude")

WW2_col_names <- c("ID",
                   "Index.Number",
                   "Mission.Date",
                   "Mission.Theater",
                   "Unit.Service",
                   "Unit.Country",
                   "Target.Country.Code",
                   "Target.Country",
                   "Target.Location",
                   "Target.Type",
                   "Target.ID",
                   "Target.Industry.Code",
                   "Target.Industry",
                   #"Target.Latitude.Nonconverted",
                   #"Target.Longitude.Nonconverted",
                   "Target.Latitude",
                   "Target.Longitude",
                   "Unit.ID",
                   "Aircraft.Model",
                   "Aircraft.Name",
                   "Mission.Type",
                   "Target.Priority",
                   "Target.Priority.Explanation",
                   "Aircraft.Attacking.Num",
                   "Bomb.Altitude",
                   "Bomb.Altitude.Feet",
                   "Bomb.HE.Num",
                   "Bomb.HE.Type",
                   "Bomb.HE.Pounds",
                   "Bomb.HE.Tons",
                   "Bomb.IC.Num",
                   "Bomb.IC.Type",
                   "Bomb.IC.Pounds",
                   "Bomb.IC.Tons",
                   "Bomb.Frag.Num",
                   "Bomb.Frag.Type",
                   "Bomb.Frag.Pounds",
                   "Bomb.Frag.Tons",
                   "Bomb.Total.Pounds",
                   "Bomb.Total.Tons",
                   "Takeoff.Base",
                   "Takeoff.Country",
                   "Takeoff.Latitude",
                   "Takeoff.Longitude",
                   "Aircraft.Lost.Num",
                   "Aircraft.Damaged.Num",
                   "Aircraft.Airborne.Num",
                   "Aircraft.Dropping.Num",
                   "Bomb.Time",
                   "Sighting.Method.Code",
                   "Sighting.Method.Explanation",
                   "Bomb.Damage.Assessment",
                   "Callsign",
                   "Ammo.Rounds",
                   "Aircraft.Spares.Num",
                   "Aircraft.Fail.WX.Num",
                   "Aircraft.Fail.Mech.Num",
                   "Aircraft.Fail.Misc.Num",
                   "Target.Comment",
                   "Mission.Comments",
                   "Reference.Source",
                   "Database.Edit.Comments")

Korea_col_names1 <- c("ID",
                      "Mission.Date",
                      "Unit.ID",
                      "Unit.ID2",
                      "Unit.ID.Code",
                      "Group.Unit.ID",
                      "Squadron.ID",
                      "Airfield.ID",
                      "Takeoff.Base",
                      "Takeoff.Country",
                      "Takeoff.Latitude",
                      "Takeoff.Longitude",
                      "Aircraft.Type",
                      "Aircraft.Dispatched",
                      "Aircraft.Attacking",
                      "Aircraft.Aborted",
                      "Aircraft.Lost.Enemy.Air.Num",
                      "Aircraft.Lost.Enemy.Ground.Num",
                      "Aircraft.Lost.Enemy.Unknown.Num",
                      "Aircraft.Lost.Other.Num",
                      "Aircraft.Damaged.Num",
                      "KIA",
                      "WIA",
                      "MIA",
                      "Enemy.Aircraft.Destroyed.Confirmed",
                      "Enemy.Aircraft.Destroyed.Probable",
                      "Bomb.Total.Tons",
                      "Rockets.Num",
                      "Bullets.Rounds")

Korea_col_names2 <- c("Row.Number",
                      "Mission.Number",
                      "Unit.Order",
                      "Unit.Group",
                      "Mission.Date",
                      "Aircraft.Type",
                      "Aircraft.Attacking.Num",
                      "Sortie.Duplicates",
                      "Aircraft.Aborted.Num",
                      "Aircraft.Lost.Num",
                      "Target.Name",
                      "Target.Type",
                      #"Target.JapanB",           # dropped while reading
                      #"Target.UTM",              # dropped while reading
                      #"Target.MGRS",             # dropped while reading
                      "Target.Latitude",
                      "Target.Longitude",
                      #"Target.Latitude.Source",  # dropped while reading
                      #"Target.Longitude.Source", # dropped while reading
                      "Weapons.Num",
                      "Weapons.Type",
                      "Bomb.Sighting.Method",
                      "Aircraft.Bombload.Pounds",
                      "Aircraft.Total.Weight?",
                      "Mission.Type",
                      "Bomb.Altitude.Feet.Range",
                      "Callsign",
                      "Bomb.Damage.Assessment",
                      "Nose.Fuze",
                      "Tail.Fuze",
                      "Aircraft.Bombload.Calculated.Pounds",
                      "Reference.Source")

Vietnam_col_names <- c("ID",
                       "Unit.Country",
                       "Unit.Service",
                       "Mission.Date",
                       "Reference.Source.ID",
                       "Reference.Source.Record",
                       "Aircraft.Root.Valid",
                       "Takeoff.Location",
                       "Target.Latitude",
                       "Target.Longitude",
                       "Target.Type",
                       "Weapons.Delivered.Num",
                       "Bomb.Time",
                       "Weapon.Type",
                       "Weapon.Type.Class",
                       "Weapon.Type.Weight",
                       "Aircraft.Original",
                       "Aircraft.Root",
                       "Unit.Group",
                       "Unit.Squadron",
                       "Callsign",
                       "Flight.Hours",
                       "Mission.Function",
                       "Mission.Function.Description",
                       "Mission.ID",
                       "Aircraft.Num",
                       "Operation.Supported",
                       "Mission.Day.Period",
                       "Unit",
                       "Target.CloudCover",
                       "Target.Control",
                       "Target.Country",
                       "Target.ID",
                       #"Target.Origin.Coordinates",          # dropped while reading
                       #"Target.Origin.Coordinates.Format",   # dropped while reading
                       "Target.Weather",
                       "Additional.Info",
                       "Target.Geozone",
                       "ID2",
                       "Weapons.Class",
                       "Weapons.Jettisoned.Num",
                       "Weapons.Returned.Num",
                       "Bomb.Altitude",
                       "Bomb.Speed",
                       "Bomb.Damage.Assessment",
                       "Target.Time.Off",
                       "Weapons.Weight.Loaded")

colnames(WW1_bombs) <- WW1_col_names
colnames(WW2_bombs) <- WW2_col_names
colnames(Korea_bombs1) <- Korea_col_names1
colnames(Korea_bombs2) <- Korea_col_names2
colnames(Vietnam_bombs) <- Vietnam_col_names


### fix data types ###

# fix date columns
if(debug_mode_on) print("fixing date columns")
WW1_bombs[, Mission.Date := .(as.Date(Mission.Date, format = "%Y-%m-%d"))]
WW2_bombs[, Mission.Date := .(as.Date(Mission.Date, format = "%m/%d/%Y"))]
Korea_bombs1[, Mission.Date := .(as.Date(Mission.Date, format = "%m/%d/%y"))]
Korea_bombs2[, Mission.Date := .(as.Date(Mission.Date, format = "%m/%d/%y"))]
Vietnam_bombs[, Mission.Date := .(as.Date(Mission.Date, format = "%Y-%m-%d"))]

# sort by mission date for efficient searching
if(debug_mode_on) print("setting keys")
setkey(WW1_bombs, Mission.Date)
setkey(WW2_bombs, Mission.Date)
setkey(Korea_bombs1, Mission.Date)
setkey(Korea_bombs2, Mission.Date)
setkey(Vietnam_bombs, Mission.Date)

### fix actual data where necessary ###

if(debug_mode_on) print("fixing WW1")
WW1_bombs[, Takeoff.Time := .(tolower(Takeoff.Time))]
print("1")
WW1_bombs[, Aircraft.Bombload := .(as.integer(round(Aircraft.Bombload)))]
print("2")
WW1_bombs[, Target.City := lapply(remove_nonASCII_chars(Target.City), proper_noun_phrase)]
print("3")
WW1_bombs[, Target.Country := .(capitalize_from_caps(Target.Country))]
print("4")
WW1_bombs[, Target.Type := .(tolower(Target.Type))]
print("5")
WW1_bombs[, Takeoff.Base := lapply(remove_nonASCII_chars(Takeoff.Base), proper_noun_phrase)]
print("6")

if(debug_mode_on) print("fixing WW2")
WW2_bombs[, Unit.Country := lapply(Unit.Country, proper_noun_phrase)]
print("1")
WW2_bombs[, Target.Country := lapply(Target.Country, proper_noun_phrase)]
print("2")
WW2_bombs[, Target.Location := lapply(remove_nonASCII_chars(remove_quotes(Target.Location)), proper_noun_phrase)]
print("3")
WW2_bombs[, Target.Type := .(tolower(Target.Type))]
print("4")
WW2_bombs[, Target.Industry := lapply(remove_quotes(Target.Industry), proper_noun_phrase)]
print("5")

if(debug_mode_on) print("fixing Korea2")
Korea_bombs2[, Target.Latitude := .(as.numeric(substr(Target.Latitude, 1, nchar(Target.Latitude)-1)))]
print("1")
Korea_bombs2[, Target.Longitude := .(as.numeric(substr(Target.Longitude, 1, nchar(Target.Longitude)-1)))]
print("2")
Korea_bombs2 <- separate(data = Korea_bombs2, 
                         col = Bomb.Altitude.Feet.Range, 
                         into = c("Bomb.Altitude.Feet.Low", "Bomb.Altitude.Feet.High"), 
                         sep = '-', 
                         extra = 'merge', 
                         fill = 'right')
print("3")

if(debug_mode_on) print("fixing Vietnam")
#Vietnam_bombs[, Unit.Country := lapply(Unit.Country, proper_noun_phrase)]         # this takes way too long
print("1")
#Vietnam_bombs[, Takeoff.Location := lapply(Takeoff.Location, proper_noun_phrase)] # this takes way too long
print("2")
Vietnam_bombs[, Target.Type := .(tolower(gsub(pattern = '\\\\', replacement = '/', Target.Type)))]
print("3")
Vietnam_bombs[, Mission.Function.Description := .(tolower(Mission.Function.Description))]
print("4")
Vietnam_bombs[, Operation.Supported := .(tolower(Operation.Supported))]
print("5")
Vietnam_bombs[, Target.CloudCover := .(tolower(Target.CloudCover))]
print("6")
#Vietnam_bombs[, Target.Country := lapply(Target.Country, proper_noun_phrase)]     # this takes way too long
print("7")
Vietnam_bombs[, Weapons.Class := .(tolower(Weapons.Class))]
print("8")
Vietnam_bombs[Weapons.Weight.Loaded == -1, c("Weapons.Weight.Loaded")] <- NA


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
                                "in ", Target.Location, ', ', Target.Country))]

if(debug_mode_on) print("tooltips WW2")
WW2_clean[, tooltip := .(paste0("On ", Mission.Date, ",<br>", 
                                Aircraft.Total, " ", Unit.Service, " ", Aircraft.Series, "s dropped <br>", 
                                Aircraft.Total.Tons, " tons of bombs on <br>", 
                                Target.Type, "<br>", 
                                "in ", Target.City, ", ", Target.Country))]

if(debug_mode_on) print("tooltips Korea2")
Korea_clean2[, tooltip := .(paste0("On ", Mission.Date, ",<br>", 
                                   Aircraft.Attacking.Num, " ", Unit, " ", Aircraft.Type, "s dropped <br>", 
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
WW1_sample <- WW1_unique_target#[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(WW1_unique_target), 1-1000/nrow(WW1_unique_target))),]
if(debug_mode_on) print("sampling WW2")
WW2_sample <- sample_n(WW2_unique_target, size = 1000)#[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(WW2_unique_target), 1-1000/nrow(WW2_unique_target))),]
if(debug_mode_on) print("sampling Korea2")
Korea_sample <- sample_n(Korea_unique_target2, size = 1000)#[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(Korea_unique_target2), 1-1000/nrow(Korea_unique_target2))),]
if(debug_mode_on) print("sampling Vietnam")
Vietnam_sample <- sample_n(Vietnam_unique_target, size = 1000)#[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(Vietnam_unique_target), 1-1000/nrow(Vietnam_unique_target))),]

### can write samples for quick tests ###
write.csv(x = WW1_sample, file = 'WW1_sample.csv', quote = TRUE, sep = ',')
write.csv(x = WW2_sample, file = 'WW2_sample.csv', quote = TRUE, sep = ',')
write.csv(x = Korea_sample, file = 'Korea_sample.csv', quote = TRUE, sep = ',')
write.csv(x = Vietnam_sample, file = 'Vietnam_sample.csv', quote = TRUE, sep = ',')

# @author Scott Dobbins
# @version 0.4
# @date 2017-04-20 23:51

### import useful packages ###
# shiny
library(shiny)

# import data analytic extensions
library(data.table) # helps with data input
library(dplyr)      # helps with data cleaning

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
WW1_bombs <- 'WW1_bombs.csv'
WW2_bombs <- 'WW2_bombs.csv'
Korea_bombs1 <- 'Korea_bombs1.csv'
Korea_bombs2 <- 'Korea_bombs2.csv'
Vietnam_bombs <- 'Vietnam_bombs.csv'

# total file paths
WW1_bombs_filepath <- paste0(WW1_directory, data_infix, WW1_bombs)
WW2_bombs_filepath <- paste0(WW2_directory, data_infix, WW2_bombs)
Korea_bombs1_filepath <- paste0(Korea_directory, data_infix, Korea_bombs1)
Korea_bombs2_filepath <- paste0(Korea_directory, data_infix, Korea_bombs2)
Vietnam_bombs_filepath <- paste0(Vietnam_directory, data_infix, Vietnam_bombs)

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
Korea_col_classes2 <- c(rep("numeric", 2), rep("character", 4), rep("numeric", 4), rep("character", 9), "numeric", rep("character", 2), rep("numeric", 2), "character", "numeric", rep("character", 4), "numeric", "character")
Vietnam_col_classes <- c("numeric", rep("character", 3), "numeric", rep("character", 3), rep("numeric", 2), "character", "numeric", rep("character", 3), "numeric", rep("character", 5), "numeric", rep("character", 3), "numeric", rep("character", 6), "numeric", rep("character", 7), rep("numeric", 4), rep("character", 2), "numeric")

# read files
WW1_raw <- fread(file =  WW1_bombs_filepath, 
                 sep = ',', 
                 sep2 = '\n', 
                 header = TRUE, 
                 stringsAsFactors = FALSE, 
                 blank.lines.skip = TRUE, 
                 #drop = , 
                 colClasses = WW1_col_classes
                 )

WW2_raw <- fread(file =  WW2_bombs_filepath, 
                 sep = ',', 
                 sep2 = '\n', 
                 header = TRUE, 
                 stringsAsFactors = FALSE, 
                 blank.lines.skip = TRUE, 
                 #drop = , 
                 colClasses = WW2_col_classes
                 )

Korea_raw1 <- fread(file =  Korea_bombs1_filepath, 
                    sep = ',',
                    sep2 = '\n', 
                    header = TRUE, 
                    stringsAsFactors = FALSE, 
                    blank.lines.skip = TRUE, 
                    #drop = , 
                    colClasses = Korea_col_classes1
                    )

Korea_raw2 <- fread(file =  Korea_bombs2_filepath, 
                    sep = ',',
                    sep2 = '\n', 
                    header = TRUE, 
                    stringsAsFactors = FALSE, 
                    blank.lines.skip = TRUE, 
                    #drop = , 
                    colClasses = Korea_col_classes2
                    )

Vietnam_raw <- fread(file =  Vietnam_bombs_filepath, 
                     sep = ',', 
                     sep2 = '\n', 
                     header = TRUE, 
                     stringsAsFactors = FALSE, 
                     blank.lines.skip = TRUE, 
                     #drop = , 
                     colClasses = Vietnam_col_classes
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
                   "Source.Latitude",
                   "Source.Longitude",
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
                      "Unit.?",
                      "Mission.Date",
                      "Aircraft.Type",
                      "Aircraft.Attacking.Num",
                      "Sortie.Duplicates",
                      "Aircraft.Aborted.Num",
                      "Aircraft.Lost.Num",
                      "Target.Name",
                      "Target.Type",
                      "Something.JapanB",
                      "Something.UTM.Target?",
                      "Target.MGRS",
                      "Target.Latitude",
                      "Target.Longitude",
                      "Target.Latitude.Source",
                      "Target.Longitude.Source",
                      "Weapons.Num",
                      "Weapons.Type",
                      "Bomb.Sighting.Method",
                      "Aircraft.Bombload.Pounds",
                      "Aircraft.Total.Weight?",
                      "Mission.Type",
                      "Bomb.Altitude.Feet",
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
                       "Target.Origin.Coordinates",
                       "Target.Origin.Coordinates.Format",
                       "Target.Weather",
                       "Additional.Info",
                       "Target.Geozone",
                       "ID2",
                       "Mission.Function.Description.Class",
                       "Weapons.Jettisoned.Num",
                       "Weapons.Returned.Num",
                       "Bomb.Altitude",
                       "Bomb.Speed",
                       "Bomb.Damage.Assessment",
                       "Target.Time.Off",
                       "Weapons.Weight.Loaded")

colnames(WW1_raw) <- WW1_col_names
colnames(WW2_raw) <- WW2_col_names
colnames(Korea_raw1) <- Korea_col_names1
colnames(Korea_raw2) <- Korea_col_names2
colnames(Vietnam_raw) <- Vietnam_col_names


### fix data types ###

# fix date columns
WW1_raw$Mission.Date <- as.Date(WW1_raw$Mission.Date, format = "%Y-%m-%d")
WW2_raw$Mission.Date <- as.Date(WW2_raw$Mission.Date, format = "%m/%d/%Y")
Korea_raw1$Mission.Date <- as.Date(Korea_raw1$Mission.Date, format = "%m/%d/%y")
Korea_raw2$Mission.Date <- as.Date(Korea_raw2$Mission.Date, format = "%m/%d/%y")
Vietnam_raw$Mission.Date <- as.Date(Vietnam_raw$Mission.Date, format = "%Y-%m-%d")


### fix actual data where necessary ###

WW1_raw$Takeoff.Time <- tolower(WW1_raw$Takeoff.Time)
WW1_raw$Aircraft.Bombload <- as.integer(round(WW1_raw$Aircraft.Bombload))
WW1_raw$Target.Location <- paste0(substring(WW1_raw$Target.Location, 1, 1), 
                                    tolower(substring(WW1_raw$Target.Location, 2)))
WW1_raw$Target.Country <- paste0(substring(WW1_raw$Target.Country, 1, 1), 
                                   tolower(substring(WW1_raw$Target.Country, 2)))
WW1_raw$Target.Type <- tolower(WW1_raw$Target.Type)

Korea_raw2 <- mutate(Korea_raw2, 
                    Target.Latitude = as.numeric(substr(Target.Latitude, 1, nchar(Target.Latitude)-1)), 
                    Target.Longitude = as.numeric(substr(Target.Longitude, 1, nchar(Target.Longitude)-1)))

Vietnam_raw$Target.Type <- tolower(Vietnam_raw$Target.Type)

### clean out obviously wrong values ###

WW1_clean <- data.table(filter(WW1_raw, 
                               Target.Latitude <= 90 & Target.Latitude >= -90 
                               & Target.Longitude <= 180 & Target.Longitude >= -180))

WW2_clean <- data.table(filter(WW2_raw, 
                               Target.Latitude <= 90 & Target.Latitude >= -90 
                               & Target.Longitude <= 180 & Target.Longitude >= -180))

Korea_clean2 <- data.table(filter(Korea_raw2, 
                                  Target.Latitude <= 90 & Target.Latitude >= -90 
                                  & Target.Longitude <= 180 & Target.Longitude >= -180))

Vietnam_clean <- data.table(filter(Vietnam_raw, 
                                   Target.Latitude <= 90 & Target.Latitude >= -90 
                                   & Target.Longitude <= 180 & Target.Longitude >= -180))


### add useful columns ###

WW2_clean$Service <- ifelse(WW2_clean$Country == "USA", 
                            paste(WW2_clean$Country, WW2_clean$Air.Force), 
                            WW2_clean$Air.Force)
WW2_clean$Target.City <- paste0(substring(WW2_clean$Target.City, 1, 1), 
                                tolower(substring(WW2_clean$Target.City, 2)))
WW2_clean$Target.Country <- paste0(substring(WW2_clean$Target.Country, 1, 1), 
                                   tolower(substring(WW2_clean$Target.Country, 2)))
WW2_clean$Target.Type <- tolower(WW2_clean$Target.Type)
WW2_clean$Target.Industry <- tolower(WW2_clean$Target.Industry)
WW2_clean$Aircraft.Total <- ifelse(!is.na(WW2_clean$Bombing.Aircraft), 
                                   WW2_clean$Bombing.Aircraft, 
                                   ifelse(!is.na(WW2_clean$Attacking.Aircraft), 
                                          WW2_clean$Attacking.Aircraft, 
                                          ifelse(!is.na(WW2_clean$Airborne.Aircraft), 
                                                 WW2_clean$Airborne.Aircraft, "some")))

### add tooltips ###

WW1_clean$tooltip <- paste0("On ", WW1_clean$Mission.Date, " during the ", WW1_clean$Takeoff.Time, ",<br>", 
                            WW1_clean$Aircraft.Attacking.Num, " ", WW1_clean$Unit.Service, " ", WW1_clean$Aircraft.Type, "s dropped <br>", 
                            WW1_clean$Aircraft.Bombload, " lbs of bombs on <br>", 
                            WW1_clean$Target.Type, "<br>", 
                            "in ", WW1_clean$Target.Location, ', ', WW1_clean$Target.Country)

WW2_clean$tooltip <- paste0("On ", WW2_clean$Mission.Date, ",<br>", 
                            WW2_clean$Aircraft.Total, " ", WW2_clean$Unit.Service, " ", WW2_clean$Aircraft.Series, "s dropped <br>", 
                            WW2_clean$Aircraft.Total.Tons, " tons of bombs on <br>", 
                            WW2_clean$Target.Type, "<br>", 
                            "in ", WW2_clean$Target.City, ", ", WW2_clean$Target.Country)

Korea_clean2$tooltip <- paste0("On ", Korea_clean2$Mission.Date, ",<br>", 
                               Korea_clean2$Aircraft.Attacking.Num, " ", Korea_clean2$Unit, " ", Korea_clean2$Aircraft.Type, "s dropped <br>", 
                               Korea_clean2$Aircraft.Bombload.Calculated.Pounds, " pounds of bombs on <br>", 
                               Korea_clean2$Target.Type, "<br>", 
                               "in ", Korea_clean2$Target.Name)

Vietnam_clean$tooltip <- paste0("On ", Vietnam_clean$Mission.Date, ",<br>", 
                                Vietnam_clean$Aircraft.Num, " ", Vietnam_clean$Unit.Service, " ", Vietnam_clean$Aircraft.Root.Valid, "s dropped bombs on <br>", 
                                Vietnam_clean$Target.Type, "<br>", 
                                "in ", Vietnam_clean$Target.Country)

### find unique targets etc ###

WW1_unique_target <- unique(WW1_clean, by = c("Target.Latitude", "Target.Longitude"))
WW2_unique_target <- unique(WW2_clean, by = c("Target.Latitude", "Target.Longitude"))
#Korea_unique_target1 <- unique(Korea_clean1, by = c("Target.Latitude", "Target.Longitude"))
Korea_unique_target2 <- unique(Korea_clean2, by = c("Target.Latitude", "Target.Longitude"))
Vietnam_unique_target <- unique(Vietnam_clean, by = c("Target.Latitude", "Target.Longitude"))

### sample ###

WW1_sample <- WW1_unique_target#[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(WW1_unique_target), 1-1000/nrow(WW1_unique_target))),]
WW2_sample <- sample_n(WW2_unique_target, size = 1000)#[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(WW2_unique_target), 1-1000/nrow(WW2_unique_target))),]
Korea_sample <- sample_n(Korea_unique_target2, size = 1000)#[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(Korea_unique_target2), 1-1000/nrow(Korea_unique_target2))),]
Vietnam_sample <- sample_n(Vietnam_unique_target, size = 1000)#[sample(x = c(TRUE, FALSE), replace = TRUE, prob = c(1000/nrow(Vietnam_unique_target), 1-1000/nrow(Vietnam_unique_target))),]

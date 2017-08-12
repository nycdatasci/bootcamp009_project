# @author Scott Dobbins
# @version 0.9.8
# @date 2017-08-11 23:30


### Files -------------------------------------------------------------------

save_name <- "Shiny_"
save_name_downsampled <- "Shiny_downsampled_"
save_extension <- ".RData"
most_recent_save_date <- "2017-08-07"


### Filepath Parameters -----------------------------------------------------

# project directory
local_directory <- "/Users/scottdobbins/Developer/RStudio/NYCDSA/ScottDobbins_Shiny/"

# data directories
WW1_directory_infix     <- "THOR/WW1/"
WW2_directory_infix     <- "THOR/WW2/"
Korea_directory_infix   <- "THOR/Korea/"
Vietnam_directory_infix <- "THOR/Vietnam/"

# directory structure
data_infix <- "data/"
glossary_infix <- "glossary/"

# standard file names
aircraft_glossary_name <- "aircraft.csv"
weapons_glossary_name <- "weapons.csv"

# missions file names
WW1_missions_filename     <- "WW1_missions.csv"
WW2_missions_filename     <- "WW2_missions.csv"
Korea_missions1_filename  <- "Korea_missions1.csv"
Korea_missions2_filename  <- "Korea_missions2.csv"
Vietnam_missions_filename <- "Vietnam_missions.csv"

# bombs file names
WW1_bombs_filename     <- "WW1_bombs.csv"
WW2_bombs_filename     <- "WW2_bombs.csv"
Korea_bombs1_filename  <- "Korea_bombs1.csv"
Korea_bombs2_filename  <- "Korea_bombs2.csv"
Vietnam_bombs_filename <- "Vietnam_bombs.csv"

# clean file names
WW1_clean_filename     <- "WW1_clean.csv"
WW2_clean_filename     <- "WW2_clean.csv"
Korea_clean1_filename  <- "Korea_clean1.csv"
Korea_clean2_filename  <- "Korea_clean2.csv"
Vietnam_clean_filename <- "Vietnam_clean.csv"

# unique target file names
WW1_unique_filename     <- "WW1_unique.csv"
WW2_unique_filename     <- "WW2_unique.csv"
Korea_unique1_filename  <- "Korea_unique1.csv"
Korea_unique2_filename  <- "Korea_unique2.csv"
Vietnam_unique_filename <- "Vietnam_unique.csv"

# save directories
local_save_infix <- "saves/"
external_save_directory <- "/Volumes/My Passport/projects temp/Shiny/"


### Others ------------------------------------------------------------------

source('busywork.R')

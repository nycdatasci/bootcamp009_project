# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


### Save Filepaths ----------------------------------------------------------

# previous saves
local_save_directory <- paste0(local_directory, local_save_infix)
most_recent_save_file <- paste0(save_name_downsampled, most_recent_save_date, save_extension)
most_recent_save_filepath <- paste0(local_save_directory, most_recent_save_file)

# next saves
save_path <- paste0(external_save_directory, save_name)
save_path_downsampled <- paste0(external_save_directory, save_name_downsampled)


### Original Data Filepaths -------------------------------------------------

# directories
WW1_directory     <- paste0(local_directory, WW1_directory_infix)
WW2_directory     <- paste0(local_directory, WW2_directory_infix)
Korea_directory   <- paste0(local_directory, Korea_directory_infix)
Vietnam_directory <- paste0(local_directory, Vietnam_directory_infix)

# bomb data for loading
WW1_missions_filepath     <- paste0(WW1_directory,     data_infix, WW1_missions_filename)
WW2_missions_filepath     <- paste0(WW2_directory,     data_infix, WW2_missions_filename)
Korea_missions1_filepath  <- paste0(Korea_directory,   data_infix, Korea_missions1_filename)
Korea_missions2_filepath  <- paste0(Korea_directory,   data_infix, Korea_missions2_filename)
Vietnam_missions_filepath <- paste0(Vietnam_directory, data_infix, Vietnam_missions_filename)

# aircraft data for loading
WW1_aircraft_glossary_filepath     <- paste0(WW1_directory,     glossary_infix, aircraft_glossary_name)
WW2_aircraft_glossary_filepath     <- paste0(WW2_directory,     glossary_infix, aircraft_glossary_name)
Korea_aircraft_glossary_filepath   <- paste0(Korea_directory,   glossary_infix, aircraft_glossary_name)
Vietnam_aircraft_glossary_filepath <- paste0(Vietnam_directory, glossary_infix, aircraft_glossary_name)

# weapons data for loading
WW1_weapons_glossary_filepath     <- paste0(WW1_directory,     glossary_infix, weapons_glossary_name)
WW2_weapons_glossary_filepath     <- paste0(WW2_directory,     glossary_infix, weapons_glossary_name)
#Korea weapons glossary doesn't exist#
Vietnam_weapons_glossary_filepath <- paste0(Vietnam_directory, glossary_infix, weapons_glossary_name)


### Saved Data Filepaths ----------------------------------------------------

# processed bomb data
WW1_bombs_filepath     <- paste0(local_save_directory, WW1_bombs_filename)
WW2_bombs_filepath     <- paste0(local_save_directory, WW2_bombs_filename)
Korea_bombs1_filepath  <- paste0(local_save_directory, Korea_bombs1_filename)
Korea_bombs2_filepath  <- paste0(local_save_directory, Korea_bombs2_filename)
Vietnam_bombs_filepath <- paste0(local_save_directory, Vietnam_bombs_filename)
war_bombs_filepath <- list(WW1_bombs_filepath, 
                           WW2_bombs_filepath, 
                           Korea_bombs1_filepath, 
                           Korea_bombs2_filepath, 
                           Vietnam_bombs_filepath)

# filtered bomb data
WW1_clean_filepath     <- paste0(local_save_directory, WW1_clean_filename)
WW2_clean_filepath     <- paste0(local_save_directory, WW2_clean_filename)
Korea_clean1_filepath  <- paste0(local_save_directory, Korea_clean1_filename)
Korea_clean2_filepath  <- paste0(local_save_directory, Korea_clean2_filename)
Vietnam_clean_filepath <- paste0(local_save_directory, Vietnam_clean_filename)
war_clean_filepath <- list(WW1_clean_filepath, 
                           WW2_clean_filepath, 
                           Korea_clean1_filepath, 
                           Korea_clean2_filepath, 
                           Vietnam_clean_filepath)

# unique target bomb data
WW1_unique_filepath     <- paste0(local_save_directory, WW1_unique_filename)
WW2_unique_filepath     <- paste0(local_save_directory, WW2_unique_filename)
Korea_unique1_filepath  <- paste0(local_save_directory, Korea_unique1_filename)
Korea_unique2_filepath  <- paste0(local_save_directory, Korea_unique2_filename)
Vietnam_unique_filepath <- paste0(local_save_directory, Vietnam_unique_filename)
war_unique_filepath <- list(WW1_unique_filepath, 
                            WW2_unique_filepath, 
                            Korea_unique1_filepath, 
                            Korea_unique2_filepath, 
                            Vietnam_unique_filepath)

# setting names
walk(list(war_bombs_filepath, war_clean_filepath, war_unique_filepath), 
     ~setattr(., "names", c("WW1", "WW2", "Korea1", "Korea2", "Vietnam")))

# @author Scott Dobbins
# @version 0.9.7
# @date 2017-07-28 17:30


### WW1 Column Names --------------------------------------------------------

WW1_col_names <- c("ID",                                     # integer        # dropped post-processing
                   "Mission_Date",                           # character
                   "Operation",                              # character
                   "Unit_Country",                           # character
                   "Unit_Service",                           # character
                   "Unit_Squadron",                          # character
                   "Aircraft_Type",                          # character
                   "Mission_Num",                            # integer
                   "Takeoff_Day_Period",                     # character
                   "Takeoff_Time",                           # character
                   "Aircraft_Attacking_Num",                 # integer
                   "Callsign",                               # character
                   "Weapon_Expended_Num",                    # integer
                   "Weapon_Type",                            # character
                   "Aircraft_Bombload_Pounds",               # double
                   "Weapon_Weight_Pounds",                   # double
                   "Target_Latitude",                        # double
                   "Target_Longitude",                       # double
                   "Target_City",                            # character
                   "Target_Country",                         # character
                   "Target_Type",                            # character
                   "Takeoff_Base",                           # character
                   "Takeoff_Latitude",                       # double
                   "Takeoff_Longitude",                      # double
                   "Bomb_Damage_Assessment",                 # character
                   "Enemy_Action",                           # character
                   "Route_Details",                          # character
                   "Intel_Collected",                        # character
                   "Casualties_Friendly",                    # integer
                   "Casualties_Friendly_Verbose",            # character
                   "Target_Weather",                         # character
                   "Bomb_Altitude_Feet")                     # integer


### WW2 Column Names --------------------------------------------------------

WW2_col_names <- c("ID",                                     # integer
                   "Index_Number",                           # integer
                   "Mission_Date",                           # character
                   "Mission_Theater",                        # character
                   "Unit_Service",                           # character
                   "Unit_Country",                           # character
                   "Target_Country_Code",                    # integer
                   "Target_Country",                         # character
                   "Target_City",                            # character
                   "Target_Type",                            # character
                   "Target_Code",                            # integer
                   "Target_Industry_Code",                   # integer
                   "Target_Industry",                        # character
                   "Target_Latitude_Nonconverted",          # character   # drop while reading
                   "Target_Longitude_Nonconverted",         # character   # drop while reading
                   "Target_Latitude",                        # double
                   "Target_Longitude",                       # double
                   "Unit_Squadron",                          # character
                   "Aircraft_Model",                        # character   # drop while reading
                   "Aircraft_Type",                          # character
                   "Mission_Type",                           # integer
                   "Target_Priority_Code",                   # integer     # read as character per data.table's insistence
                   "Target_Priority_Explanation",            # character
                   "Aircraft_Attacking_Num",                 # integer
                   "Bomb_Altitude",                          # integer
                   "Bomb_Altitude_Feet",                     # integer
                   "Weapon_Expl_Num",                        # integer
                   "Weapon_Expl_Type",                       # character
                   "Weapon_Expl_Pounds",                     # integer
                   "Weapon_Expl_Tons",                       # double
                   "Weapon_Incd_Num",                        # integer
                   "Weapon_Incd_Type",                       # character
                   "Weapon_Incd_Pounds",                     # integer
                   "Weapon_Incd_Tons",                       # double
                   "Weapon_Frag_Num",                        # integer
                   "Weapon_Frag_Type",                       # character
                   "Weapon_Frag_Pounds",                     # integer
                   "Weapon_Frag_Tons",                       # double                
                   "Weapon_Weight_Pounds",                   # integer
                   "Weapon_Weight_Tons",                     # double
                   "Takeoff_Base",                           # character
                   "Takeoff_Country",                        # character
                   "Takeoff_Latitude",                       # double
                   "Takeoff_Longitude",                      # double
                   "Aircraft_Lost_Num",                      # integer
                   "Aircraft_Damaged_Num",                   # integer
                   "Aircraft_Airborne_Num",                  # integer
                   "Aircraft_Dropping_Num",                  # integer
                   "Bomb_Time",                              # character
                   "Sighting_Method_Code",                   # integer     # needs to be read as character due to bad data (leakage from next column)
                   "Sighting_Method_Explanation",            # character
                   "Bomb_Damage_Assessment",                 # character
                   "Callsign",                               # character
                   "Ammo_Rounds",                           # integer     # drop while reading
                   "Aircraft_Spares_Num",                    # integer
                   "Aircraft_Fail_WX_Num",                   # integer
                   "Aircraft_Fail_Mech_Num",                 # integer
                   "Aircraft_Fail_Misc_Num",                 # integer
                   "Target_Comment",                         # character
                   "Mission_Comments",                       # character
                   "Reference_Source",                       # character
                   "Database_Edit_Comments")                 # character


### Korea 1 Column Names ----------------------------------------------------

Korea_col_names1 <- c("ID",                                  # integer
                      "Mission_Date",                        # character
                      "Unit_ID",                             # character
                      "Unit_ID2",                            # character
                      "Unit_ID_Long",                        # character
                      "Unit_Group",                          # character
                      "Unit_Squadron",                       # character
                      "Airfield_ID",                         # character
                      "Takeoff_Base",                        # character
                      "Takeoff_Country",                     # character
                      "Takeoff_Latitude",                    # double
                      "Takeoff_Longitude",                   # double
                      "Aircraft_Type",                       # character
                      "Aircraft_Dispatched_Num",             # integer
                      "Aircraft_Attacking_Num",              # integer
                      "Aircraft_Aborted_Num",                # integer
                      "Aircraft_Lost_Enemy_Air_Num",         # integer
                      "Aircraft_Lost_Enemy_Ground_Num",      # integer
                      "Aircraft_Lost_Enemy_Unknown_Num",     # integer
                      "Aircraft_Lost_Other_Num",             # integer
                      "Aircraft_Damaged_Num",                # integer
                      "KIA",                                 # integer
                      "WIA",                                 # integer
                      "MIA",                                 # integer
                      "Enemy_Aircraft_Destroyed_Confirmed",  # integer
                      "Enemy_Aircraft_Destroyed_Probable",   # integer
                      "Weapon_Weight_Tons",                  # double
                      "Rocket_Num",                          # integer
                      "Bullet_Rounds")                       # integer


### Korea 2 Column Names ----------------------------------------------------

Korea_col_names2 <- c("Row_Number",                          # integer     # read as character per data.table's insistence
                      "Mission_Number",                      # integer
                      "Unit_Order",                          # character
                      "Unit_Squadron",                       # character
                      "Mission_Date",                        # character
                      "Aircraft_Type",                       # character
                      "Aircraft_Attacking_Num",              # integer
                      "Sortie_Duplicates",                   # integer
                      "Aircraft_Aborted_Num",                # integer
                      "Aircraft_Lost_Num",                   # integer     # needs to be read as character due to bad data
                      "Target_Name",                         # character
                      "Target_Type",                         # character
                      "Target_JapanB",                      # character   # drop while reading
                      "Target_UTM",                         # character   # drop while reading
                      "Target_MGRS",                        # character   # drop while reading
                      "Target_Latitude",                     # character
                      "Target_Longitude",                    # character
                      "Target_Latitude_Source",             # character   # drop while reading
                      "Target_Longitude_Source",            # character   # drop while reading
                      "Weapon_Expended_Num",                 # integer    # read as character per data.table's insistence
                      "Weapon_Type",                         # character
                      "Bomb_Sighting_Method",                # character
                      "Aircraft_Bombload_Pounds",           # integer     # drop while reading because it's empty
                      "Aircraft_Total_Weight",              # character   # drop while reading because it's mostly empty and useless
                      "Mission_Type",                        # character
                      "Bomb_Altitude_Feet_Range",            # character
                      "Callsign",                           # character   # drop while reading because it's empty
                      "Bomb_Damage_Assessment",              # character
                      "Nose_Fuze",                           # character
                      "Tail_Fuze",                           # character
                      "Aircraft_Bombload_Calculated_Pounds", # integer
                      "Reference_Source")                    # character


### Vietnam Column Names ----------------------------------------------------

Vietnam_col_names <- c("ID",                                 # integer
                       "Unit_Country",                       # character
                       "Unit_Service",                       # character
                       "Mission_Date",                       # character
                       "Reference_Source_ID",                # integer
                       "Reference_Source_Record",            # character
                       "Aircraft_Type",                      # character
                       "Takeoff_Location",                   # character
                       "Target_Latitude",                    # double
                       "Target_Longitude",                   # double
                       "Target_Type",                        # character
                       "Weapon_Expended_Num",                # integer
                       "Bomb_Time",                          # character
                       "Weapon_Type",                        # character
                       "Weapon_Class2",                     # character   # drop while reading
                       "Weapon_Unit_Weight",                 # integer
                       "Aircraft_Original",                  # character
                       "Aircraft_Root",                      # character
                       "Unit_Group",                        # character   # drop while reading
                       "Unit_Squadron",                     # character   # drop while reading
                       "Callsign",                           # character
                       "Flight_Hours",                       # integer
                       "Mission_Function_Code",              # integer     # needs to be read as character due to bad data
                       "Mission_Function_Description",       # character
                       "Mission_ID",                         # character
                       "Aircraft_Attacking_Num",             # integer
                       "Operation",                          # character
                       "Mission_Day_Period",                 # character
                       "Unit",                               # character
                       "Target_CloudCover",                  # character
                       "Target_Control",                     # character
                       "Target_Country",                     # character
                       "Target_ID",                          # character
                       "Target_Origin_Coordinates",         # character   # drop while reading
                       "Target_Origin_Coordinates_Format",  # character   # drop while reading
                       "Target_Weather",                     # character
                       "Additional_Info",                    # character
                       "Target_Geozone",                     # character
                       "ID2",                                # integer
                       "Weapon_Class",                       # character
                       "Weapon_Jettisoned_Num",              # integer
                       "Weapon_Returned_Num",                # integer
                       "Bomb_Altitude",                      # integer
                       "Bomb_Speed",                        # integer     # drop while reading
                       "Bomb_Damage_Assessment",             # character
                       "Target_Time_Off",                    # integer
                       "Weapon_Weight_Loaded")               # integer


### WW1 Column Classes ------------------------------------------------------

WW1_col_classes <- list(numeric = c("WWI_ID",
                                    "MISSIONNUM",
                                    "NUMBEROFPLANESATTACKING",
                                    "WEAPONSEXPENDED",
                                    "FRIENDLYCASUALTIES",
                                    "ALTITUDE"), #*** for now: once int32 colClasses issue is fixed in data.table 1.10.5 dev update, switch to integer

                        double = c("WEAPONWEIGHT",
                                   "BOMBLOAD",
                                   "LATITUDE",
                                   "LONGITUDE",
                                   "TAKEOFFLATITUDE",
                                   "TAKEOFFLONGITUDE"),

                        character = c("MSNDATE",
                                      "TAKEOFFTIME"), 
                        
                        factor = c("OPERATION",
                                   "COUNTRY",
                                   "SERVICE",
                                   "UNIT",
                                   "MDS",
                                   "DEPARTURE",
                                   "CALLSIGN",
                                   "WEAPONTYPE",
                                   "TGTLOCATION",
                                   "TGTCOUNTRY",
                                   "TGTTYPE",
                                   "TAKEOFFBASE",
                                   "BDA",
                                   "ENEMYACTION",
                                   "ROUTEDETAILS",
                                   "ISRCOLLECTED",
                                   "FRIENDLYCASUALTIES_VERBOSE",
                                   "WEATHER"))


### WW2 Column Classes ------------------------------------------------------

WW2_col_classes <- list(numeric = c("WWII_ID",
                                    "MASTER_INDEX_NUMBER",
                                    "TGT_COUNTRY_CODE",
                                    "TGT_ID",
                                    "TGT_INDUSTRY_CODE",
                                    "MSN_TYPE",
                                    "AC_ATTACKING",
                                    "ALTITUDE",
                                    "ALTITUDE_FEET",
                                    "NUMBER_OF_HE",
                                    "LBS_HE",
                                    "NUMBER_OF_IC",
                                    "LBS_IC",
                                    "NUMBER_OF_FRAG",
                                    "LBS_FRAG",
                                    "TOTAL_LBS",
                                    "AC_LOST",
                                    "AC_DAMAGED",
                                    "AC_AIRBORNE",
                                    "AC_DROPPING",
                                    "SPARES_RETURN_AC",
                                    "WX_FAIL_AC",
                                    "MECH_FAIL_AC",
                                    "MISC_FAIL_AC"), #*** for now: once int32 colClasses issue is fixed in data.table 1.10.5 dev update, switch to integer

                        double = c("LATITUDE",
                                   "LONGITUDE",
                                   "TONS_OF_HE",
                                   "TONS_OF_IC",
                                   "TONS_OF_FRAG",
                                   "TOTAL_TONS",
                                   "TAKEOFF_LATITUDE",
                                   "TAKEOFF_LONGITUDE"),

                        character = c("MSNDATE",
                                      "TGT_PRIORITY",
                                      "TIME_OVER_TARGET",
                                      "SIGHTING_METHOD_CODE"),
                        
                        factor = c("THEATER",
                                   "NAF",
                                   "COUNTRY_FLYING_MISSION",
                                   "TGT_COUNTRY",
                                   "TGT_LOCATION",
                                   "TGT_TYPE",
                                   "TGT_INDUSTRY",
                                   "UNIT_ID",
                                   "AIRCRAFT_NAME",
                                   "TGT_PRIORITY_EXPLANATION",
                                   "TYPE_OF_HE",
                                   "TYPE_OF_IC",
                                   "TYPE_OF_FRAG",
                                   "TAKEOFF_BASE",
                                   "TAKEOFF_COUNTRY",
                                   "SIGHTING_EXPLANATION",
                                   "BDA",
                                   "CALLSIGN",
                                   "TARGET_COMMENT",
                                   "MISSION_COMMENTS",
                                   "SOURCE",
                                   "DATABASE_EDIT_COMMENTS"),

                        NULL = c("SOURCE_LATITUDE",
                                 "SOURCE_LONGITUDE",
                                 "MDS",
                                 "ROUNDS_AMMO"))#*** doesn't work (successfully drop columns by not reading them) in current data.table 1.10.5 dev version


### Korea 1 Column Classes --------------------------------------------------

Korea_col_classes1 <- list(numeric = c("KOREAN_ID",
                                       "AC_DISPATCHED",
                                       "AC_EFFECTIVE",
                                       "AC_ABORT",
                                       "AC_LOST_TO_EAC",
                                       "AC_LOST_TO_AAA",
                                       "AC_LOST_TO_UNKNOWN_EA",
                                       "AC_LOST_TO_OTHER",
                                       "AC_DAMAGED",
                                       "KIA",
                                       "WIA",
                                       "MIA",
                                       "EAC_CONFIRMED_DESTROYED",
                                       "EAC_PROB_DESTROYED",
                                       "ROCKETS",
                                       "BULLETS"), #*** for now: once int32 colClasses issue is fixed in data.table 1.10.5 dev update, switch to integer

                           double = c("LAUNCH_LAT",
                                      "LAUNCH_LONG",
                                      "TOTAL_TONS"),

                           character = c("MSN_DATE"), 
                           
                           factor = c("UNIT_ID",
                                      "UNIT_ID_2",
                                      "UNIT_ID_CODE",
                                      "GROUP_OR_HIGHER_UNIT_ID",
                                      "SQUADRON_ID",
                                      "AIRFIELD_ID",
                                      "LAUNCH_BASE",
                                      "LAUNCH_COUNTRY",
                                      "AC_TYPE"))


### Korea 2 Column Classes --------------------------------------------------

Korea_col_classes2 <- list(numeric = c("NBR_ATTACK_EFFEC_AIRCRAFT",
                                       "SORTIE_DUPE",
                                       "NBR_ABORT_AIRCRAFT",
                                       "TOTAL_BOMBLOAD_IN_LBS",
                                       "CALCULATED_BOMBLOAD_LBS"), #*** for now: once int32 colClasses issue is fixed in data.table 1.10.5 dev update, switch to integer

                           character = c("ROW_NUMBER",
                                         "MISSION_NUMBER",
                                         "MISSION_DATE",
                                         "NBR_LOST_AIRCRAFT",
                                         "TGT_LATITUDE_WGS84",
                                         "TGT_LONGITUDE_WGS84",
                                         "NBR_OF_WEAPONS", 
                                         "ALTITUDE_FT"), 
                           
                           factor = c("OP_ORDER",
                                      "UNIT",
                                      "AIRCRAFT_TYPE_MDS",
                                      "TARGET_NAME",
                                      "TGT_TYPE",
                                      "WEAPONS_TYPE",
                                      "BOMB_SIGHTING_METHOD",
                                      "MISSION_TYPE",
                                      "BDA",
                                      "NOSE_FUZE",
                                      "TAIL_FUZE",
                                      "RECORD_SOURCE"), 

                           NULL = c("SOURCE_UTM_JAPAN_B",
                                    "SOURCE_TGT_UTM",
                                    "TGT_MGRS",
                                    "SOURCE_TGT_LAT",
                                    "SOURCE_TGT_LONG",
                                    "TOT",
                                    "CALLSIGN"))#*** doesn't work (successfully drop columns by not reading them) in current data.table 1.10.5 dev version


### Vietnam Column Classes --------------------------------------------------

Vietnam_col_classes <- list(numeric = c("THOR_DATA_VIET_ID",
                                        "SOURCEID",
                                        "NUMWEAPONSDELIVERED",
                                        "WEAPONTYPEWEIGHT",
                                        "FLTHOURS",
                                        "NUMOFACFT",
                                        "ID",
                                        "NUMWEAPONSJETTISONED",
                                        "NUMWEAPONSRETURNED",
                                        "RELEASEALTITUDE",
                                        "TIMEOFFTARGET",
                                        "WEAPONSLOADEDWEIGHT"), #*** for now: once int32 colClasses issue is fixed in data.table 1.10.5 dev update, switch to integer

                            double = c("TGTLATDD_DDD_WGS84",
                                       "TGTLONDDD_DDD_WGS84"),

                            character = c("MSNDATE",
                                          "TIMEONTARGET",
                                          "MFUNC"), 
                            
                            factor = c("COUNTRYFLYINGMISSION",
                                       "MILSERVICE",
                                       "SOURCERECORD",
                                       "VALID_AIRCRAFT_ROOT",
                                       "TAKEOFFLOCATION",
                                       "TGTTYPE",
                                       "WEAPONTYPE",
                                       "AIRCRAFT_ORIGINAL",
                                       "AIRCRAFT_ROOT",
                                       "CALLSIGN",
                                       "MISSIONID",
                                       "MFUNC_DESC",
                                       "OPERATIONSUPPORTED",
                                       "PERIODOFDAY",
                                       "UNIT",
                                       "TGTCLOUDCOVER",
                                       "TGTCONTROL",
                                       "TGTCOUNTRY",
                                       "TGTID",
                                       "TGTWEATHER",
                                       "ADDITIONALINFO",
                                       "GEOZONE",
                                       "MFUNC_DESC_CLASS",
                                       "RESULTSBDA"), 

                            NULL = c("AIRFORCEGROUP",
                                     "AIRFORCESQDN",
                                     "WEAPONTYPECLASS",
                                     "TGTORIGCOORDS",
                                     "TGTORIGCOORDSFORMAT",
                                     "RELEASEFLTSPEED"))#*** doesn't work (successfully drop columns by not reading them) in current data.table 1.10.5 dev version


### Read Data ---------------------------------------------------------------

if(debug_mode_on) print("reading WW1")
WW1_bombs <- fread(file =  WW1_missions_filepath, 
                   col.names = WW1_col_names, 
                   colClasses = WW1_col_classes)

if(debug_mode_on) print("reading WW2")
WW2_bombs <- fread(file =  WW2_missions_filepath, 
                   col.names = WW2_col_names, 
                   colClasses = WW2_col_classes)

if(debug_mode_on) print("reading Korea1")
Korea_bombs1 <- fread(file =  Korea_missions1_filepath, 
                      col.names = Korea_col_names1, 
                      colClasses = Korea_col_classes1)

if(debug_mode_on) print("reading Korea2")
Korea_bombs2 <- fread(file =  Korea_missions2_filepath, 
                      col.names = Korea_col_names2, 
                      colClasses = Korea_col_classes2)

if(debug_mode_on) print("reading Vietnam")
Vietnam_bombs <- fread(file =  Vietnam_missions_filepath, 
                       col.names = Vietnam_col_names, 
                       colClasses = Vietnam_col_classes)

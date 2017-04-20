# @author Scott Dobbins
# @version 0.3.2
# @date 2017-04-20 18:51

### import useful packages ###
# shiny
library(shiny)

# import data analytic extensions
library(data.table) # helps with data input
library(dplyr)      # helps with data cleaning

### import and clean data ###
# WW1
# data source: data.mil
# data origin URL: https://insight.livestories.com/s/v2/world-war-i/5be11be2-83c7-4d20-b5bc-05b3dc325d7e/

WW1_raw <- fread('WW1_bombing_operations.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)

colnames(WW1_raw)[colnames(WW1_raw) %in% c("LATITUDE","LONGITUDE")] <- c("Target.Latitude","Target.Longitude")

WW1_clean <- data.table(filter(WW1_raw, 
                               Target.Latitude <= 90 & Target.Latitude >= -90 
                               & Target.Longitude <= 180 & Target.Longitude >= -180))

WW1_unique_target <- unique(WW1_clean, by = c("Target.Latitude","Target.Longitude"))[1:1000,]#***take this out, and also move to after the cleaning step maybe?

WW1_unique_target$TAKEOFFTIME <- tolower(WW1_unique_target$TAKEOFFTIME)
WW1_unique_target$BOMBLOAD <- as.integer(round(WW1_unique_target$BOMBLOAD))
WW1_unique_target$TGTLOCATION <- paste0(substring(WW1_unique_target$TGTLOCATION, 1, 1), 
                                        tolower(substring(WW1_unique_target$TGTLOCATION, 2)))
WW1_unique_target$TGTCOUNTRY <- paste0(substring(WW1_unique_target$TGTCOUNTRY, 1, 1), 
                                       tolower(substring(WW1_unique_target$TGTCOUNTRY, 2)))
WW1_unique_target$TGTTYPE <- tolower(WW1_unique_target$TGTTYPE)

WW1_unique_target$tooltip <- paste0("On ", WW1_unique_target$MSNDATE, " during the ", WW1_unique_target$TAKEOFFTIME, ",<br>", 
                                    WW1_unique_target$NUMBEROFPLANESATTACKING, " ", WW1_unique_target$SERVICE, " ", WW1_unique_target$MDS, "s dropped <br>", 
                                    WW1_unique_target$BOMBLOAD, " lbs of bombs on <br>", 
                                    WW1_unique_target$TGTTYPE, "<br>", 
                                    "in ", WW1_unique_target$TGTLOCATION, ', ', WW1_unique_target$TGTCOUNTRY)


# WW2
# data source: data.mil
# data origin URL: https://insight.livestories.com/s/v2/world-war-ii/3262351e-df74-437c-8624-0c3b623064b5/
# pre-cleaned data source URL: https://www.kaggle.com/usaf/world-war-ii

WW2_raw <- fread('WW2_bombing_operations.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)

colnames(WW2_raw) <- gsub("[()]", "", colnames(WW2_raw))
colnames(WW2_raw) <- gsub(" ", ".", colnames(WW2_raw))

WW2_clean <- data.table(filter(WW2_raw, 
                               Target.Latitude <= 90 & Target.Latitude >= -90 
                               & Target.Longitude <= 180 & Target.Longitude >= -180))

WW2_unique_target <- unique(WW2_clean, by = c("Target.Latitude","Target.Longitude"))[1:1000,]#***take this out, and also move to after the cleaning step maybe?

WW2_unique_target$Service <- ifelse(WW2_unique_target$Country == "USA", 
                                    paste(WW2_unique_target$Country, WW2_unique_target$Air.Force), 
                                    WW2_unique_target$Air.Force)
WW2_unique_target$Target.City <- paste0(substring(WW2_unique_target$Target.City, 1, 1), 
                                        tolower(substring(WW2_unique_target$Target.City, 2)))
WW2_unique_target$Target.Country <- paste0(substring(WW2_unique_target$Target.Country, 1, 1), 
                                           tolower(substring(WW2_unique_target$Target.Country, 2)))
WW2_unique_target$Target.Type <- tolower(WW2_unique_target$Target.Type)
WW2_unique_target$Target.Industry <- tolower(WW2_unique_target$Target.Industry)
WW2_unique_target$Aircraft.Total <- ifelse(!is.na(WW2_unique_target$Bombing.Aircraft), 
                                           WW2_unique_target$Bombing.Aircraft, 
                                           ifelse(!is.na(WW2_unique_target$Attacking.Aircraft), 
                                                  WW2_unique_target$Attacking.Aircraft, 
                                                  ifelse(!is.na(WW2_unique_target$Airborne.Aircraft), 
                                                         WW2_unique_target$Airborne.Aircraft, "some")))

WW2_unique_target$tooltip <- paste0("On ", WW2_unique_target$Mission.Date, ",<br>", 
                                    WW2_unique_target$Aircraft.Total, " ", WW2_unique_target$Service, " ", WW2_unique_target$Aircraft.Series, "s dropped <br>", 
                                    WW2_unique_target$Total.Weight.Tons, " tons of bombs on <br>", 
                                    WW2_unique_target$Target.Type, "<br>", 
                                    "in ", WW2_unique_target$Target.City, ", ", WW2_unique_target$Target.Country)


# Korea
# data source: data.mil
# data origin URL: https://insight.livestories.com/s/v2/korea/ff390af4-7ee7-4742-a404-2c3490f6ed96/

Korea_raw <- fread('Korea_bombing_operations2.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)

Korea_clean <- mutate(Korea_raw, 
                      Target.Latitude = as.numeric(substr(TGT_LATITUDE_WGS84, 1, nchar(TGT_LATITUDE_WGS84)-1)), 
                      Target.Longitude = as.numeric(substr(TGT_LONGITUDE_WGS84, 1, nchar(TGT_LONGITUDE_WGS84)-1)))

Korea_clean <- data.table(filter(Korea_clean, 
                                 Target.Latitude <= 90 & Target.Latitude >= -90 
                                 & Target.Longitude <= 180 & Target.Longitude >= -180))

Korea_unique_target <- unique(Korea_clean, by = c("Target.Latitude","Target.Longitude"))[1:1000,]#***take this out, and also move to after the cleaning step maybe?

Korea_unique_target <- select(Korea_unique_target, -ROW_NUMBER)

Korea_unique_target$tooltip <- paste0("On ", Korea_unique_target$MISSION_DATE, ",<br>", 
                                      Korea_unique_target$NBR_ATTACK_EFFEC_AIRCRAFT, " ", Korea_unique_target$UNIT, " ", Korea_unique_target$AIRCRAFT_TYPE_MDS, "s dropped <br>", 
                                      Korea_unique_target$CALCULATED_BOMBLOAD_LBS, " pounds of bombs on <br>", 
                                      Korea_unique_target$TGT_TYPE, "<br>", 
                                      "in ", Korea_unique_target$TARGET_NAME)


# Vietnam ***actually a small sample of Vietnam data, which is currently too large to effectively use
# data source: data.mil
# data origin URL: https://insight.livestories.com/s/v2/vietnam/48973b96-8add-4898-9b33-af2a676b10bb/

Vietnam_raw <- fread('./datamil-vietnam-war-thor-data/VietNam_1965.csv', sep = ',', sep2 = '\n', header = TRUE, stringsAsFactors = FALSE)

colnames(Vietnam_raw)[colnames(Vietnam_raw) %in% c("TGTLATDD_DDD_WGS84","TGTLONDDD_DDD_WGS84")] <- c("Target.Latitude","Target.Longitude")

Vietnam_clean <- data.table(filter(Vietnam_raw, 
                                   Target.Latitude <= 90 & Target.Latitude >= -90 
                                   & Target.Longitude <= 180 & Target.Longitude >= -180))

Vietnam_unique_target <- unique(Vietnam_clean, by = c("Target.Latitude","Target.Longitude"))[1:1000,]#***take this out, and also move to after the cleaning step maybe?

Vietnam_unique_target$TGTTYPE <- tolower(Vietnam_unique_target$TGTTYPE)

Vietnam_unique_target$tooltip <- paste0("On ", Vietnam_unique_target$MSNDATE, ",<br>", 
                                        Vietnam_unique_target$NUMOFACFT, " ", Vietnam_unique_target$MILSERVICE, " ", Vietnam_unique_target$VALID_AIRCRAFT_ROOT, "s dropped bombs on <br>", 
                                        Vietnam_unique_target$TGTTYPE, "<br>", 
                                        "in ", Vietnam_unique_target$TGTCOUNTRY)

library(data.table)
library(lubridate)
library(fasttime)
library(dplyr)
library(ggplot2)
library(ggvis)

stations_data = fread("stations_M_L_Line.csv")
stations_l = fread("stations_L_Line.csv")
stations_m = fread("stations_M_Line.csv")
DT = fread("turnstile_data_M00516_0517v2.csv")

impacted_stations = c("Middle Village - Metropolitan Av", "Fresh Pond Rd", "Forest Av", "Seneca Av", "Myrtle - Wyckoff Avs", "Knickerbocker Av", "Central Av", "Myrtle Av", "Dekalb Av")                
impacted_stations_df = stations_data[`Stop Name` %in% impacted_stations]

## Converty DATE/TIME strings to DATETIME type
DT[, "DATE.TIME" := fastPOSIXct(DT$DATE.TIME)]

# Turnstiles per Station
DT[,.N, by = .(STATION, UNIT, SCP)]

View(DT[STATION == "METROPOLITAN AV", .(max(ENTRIES) - min(ENTRIES), max(EXITS) - min(EXITS)), by = .(STATION, UNIT, SCP, DATE)])



DT %>%  
  group_by(DATE, STATION, UNIT, SCP) %>% 
  summarise(TOTAL.ENTRIES = sum(as.numeric(ENTRIES)), TOTAL.EXITS = sum(as.numeric(EXITS))) %>% 
  ggplot(aes(
    x = DATE,
    y = TOTAL.ENTRIES,
    color = STATION)) +
  geom_violin()

DT %>% 
  ggplot(aes(
    x = DAY.OF.WEEK,
    y = ENTRIES.FINAL
    )) +
  geom_bar(stat = "identity") +
  facet_wrap(~STATION)

DT %>%
  ggplot(aes(
    x = DATE,
    y = ENTRIES.FINAL,
    color = STATION)) +
  geom_smooth()
DT %>% 
  ggplot(aes(
    x = DAY.OF.WEEK,
    y = ENTRIES.FINAL,
    col = DAY.OF.WEEK)) +
  geom_boxplot() +
  facet_wrap(~STATION)
# 
# DT %>% 
#   ggplot(aes(
#     x = TIME,
#     y = ENTRIES.FINAL)) +
#   geom_freqpoly(stat = "identity") +
#   facet_wrap(~STATION)
# 
# 
# DT %>% 
#   ggplot(aes(
#     x = DAY.OF.WEEK,
#     y = ENTRIES.FINAL,
#     col = STATION)) +
#     geom_bar(stat = "identity")



# Average Entries per 4 hour time increment per station
# DT[, .(Average.Entries = mean(ENTRIES.FINAL), Average.Exits = mean(EXITS.FINAL)), by=.(STATION)]
# 
# DT[,.(unique(DATE))]
#    
   
   
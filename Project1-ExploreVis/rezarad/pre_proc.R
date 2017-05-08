# import turnstile and fares data files into two SQL databases
library(DBI)
library(dplyr)
library(dbplyr)
library(chron)

dbname = "./data/mta.db"
conn <- dbConnect(RSQLite::SQLite(), dbname)

fares_dir = "./data/fares_new"
fares_files = rev(paste(fares_dir, list.files(fares_dir), sep="/")) # list of fares data files

for(file in fares_files) {
  temp_data = read.csv(file,skip = 2, stringsAsFactors = FALSE)
  temp_data = data.frame(temp_data, DATE_RANGE = read.csv(file, nrows = 1, stringsAsFactors = FALSE)[[2]]) # append date of data file to the merged data
  dbWriteTable(conn = conn,
               name = "fares_data",
               value = temp_data,
               append = TRUE)
  rm(temp_data)
}

turnstile_dir = "./data/turnstile_new"
turnstile_files = rev(paste(turnstile_dir, list.files(turnstile_dir), sep="/")) # list of turnstile data files

for(file in turnstile_files) {
  dbWriteTable(conn = conn,
               name = "turnstile_data",
               value = file,
               append = TRUE,
               headers = TRUE,
               sep = ",")
}

ts_count = read.csv("./data/turnstile_count.csv")

# Read turnstile DB file and convert to df
dbname = "./data/mta.db"
conn <- DBI::dbConnect(SQLite(), dbname)

turnstile_data = tbl(conn, "cleaned_turnstile_data")
turnstile_data = collect(turnstile_data)

# Convert Date/Times to respective class
turnstile_data = turnstile_data %>% 
  mutate(DATE = as.Date(DATE,format="%m/%d/%Y"), 
         TIME = chron(times. = TIME))

turnstile_totals = turnstile_data %>% 
  group_by(LINENAME, STATION, SCP, DATE) %>% 
  summarise(ENTRIES.T = max(ENTRIES)-min(ENTRIES), 
            EXITS.T = max(EXITS)-min(EXITS))
# station names
stations = turnstile_data %>% distinct(STATION)

for(i in 1244531:length(turnstile_data$ENTRIES)) {
  if(turnstile_data$SCP[[i-1]] == turnstile_data$SCP[[i]]) {
    turnstile_data$ENTRIES.NEW[[i]] = turnstile_data$ENTRIES[[i]] - turnstile_data$ENTRIES[[i-1]]
    turnstile_data$EXITS.NEW[[i]] = turnstile_data$EXITS[[i]] - turnstile_data$EXITS[[i-1]]
  }
  else
  {
    i = i+2
  }
  print(paste(turnstile_data$STATION[[i]],turnstile_data$SCP[[i]]))
}

dbWriteTable(conn,"turnstile_data_v4", turnstile_data)


## Number of Turnstiles per Station
ts_count = getTurnstileData("turnstile_data") %>%
  group_by(STATION) %>%
  summarise(`Number of Turnstiles` = n_distinct(SCP))
ts_count = collect(ts_count)

stations_data = getStationData("./data/Stations.csv")
ts_station_matcher = read.csv(file = "./data/stations_lookup_table.csv")
ts_station_matcher = ts_station_matcher %>%
  rename(`Stop Name` = csv_station_name) %>%
  inner_join(stations_data)

ts_station_matcher = ts_station_matcher %>%
  rename(STATION = ts_station_name) %>%
  inner_join(ts_count)

write.csv(ts_station_matcher,"./data/turnstile_count.csv")


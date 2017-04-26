    # import turnstila and fares data files into two SQL databases
library(RSQLite)
library(DBI)

source("./helpers.R")

# make sure your working directory is the directory of the project
dbname = "db.mta"
conn <- dbConnect(SQLite(), dbname)

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

### Number of Turnstiles per Station
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


stations_data = stations_data %>% 
  mutate(`Turnstile Station Name` = toupper(`Turnstile Station Name`))
stations_data = stations_data %>% left_join(ts_count, by = c("Turnstile Station Name" = "STATION"))



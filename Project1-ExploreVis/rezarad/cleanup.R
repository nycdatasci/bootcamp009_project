library(dplyr)
library(dbplyr)
library(chron)
library(data.table)

ts_count = fread("./data/turnstile_count.csv",sep=",")

conn <- DBI::dbConnect(RSQLite::SQLite(), dbname)
dbname = "./data/mta.db"

# Read turnstile DB file and convert to df
turnstile_data = tbl(conn,"turnstile_data")
turnstile_data = collect(turnstile_data)

# Convert Date/Times to respective class
turnstile_data = turnstile_data %>% 
  mutate(DATE = as.Date(DATE,format="%m/%d/%Y"), 
         TIME = chron(times. = TIME)) %>% 
  arrange(LINENAME, DIVISION, STATION, SCP, UNIT, DATE, TIME) 

# station names
stations = turnstile_data %>% distinct(STATION)
entries_diff = c()
exits_diff = c()
for(station in stations$STATION) {
  print(station)
  scps = turnstile_data %>%
    filter(STATION == station) %>%
    distinct(SCP)
  for(scp in scps$SCP) {
    print(scp)
    entries = turnstile_data %>%
        filter(SCP == scp & STATION == station) %>%
        select(ENTRIES)
    entries = entries$ENTRIES
    entries_vec = entries[c(-1)] - entries
    entries_vec = c(0,entries_vec[c(-length(entries_vec))])
    entries_diff = append(entries_diff,entries_vec)
    exits = turnstile_data %>%
      filter(SCP == scp & STATION == station) %>%
      select(EXITS)
    exits = exits$EXITS
    exits_vec = exits[c(-1)] - exits
    exits_vec = c(0,exits_vec[c(-length(exits_vec))])
    exits_diff = append(exits_diff,exits_vec)
  }
}

cleanup["New Entries"] = entries_diff
cleanup["New Exits"] = exits_diff  

for(i in 2:length(cleanup$ENTRIES)) {
  if(cleanup$SCP[[i-1]] == cleanup$SCP[[i]]) {
    cleanup$ENTRIES.NEW[[i]] = cleanup$ENTRIES[[i]] - cleanup$ENTRIES[[i-1]]
    cleanup$EXITS.NEW[[i]] = cleanup$EXITS[[i]] - cleanup$EXITS[[i-1]]
  }
  else
  {
    i = i+2
  }
  print(paste(cleanup$STATION[[i]],cleanup$SCP[[i]]))
}

turnstile_data = turnstile_data %>%
  filter(ENTRIES.NEW > -1 && EXITS.NEW > -1) %>% 
  


dbWriteTable(conn,"cleaned_turnstile_data", turnstile_data)

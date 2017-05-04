library(dbplyr)
library(dplyr)
library(ggplot2)

dbname = "./data/mta.db"
conn = DBI::dbConnect(RSQLite::SQLite(), dbname)

turnstile_data = tbl(conn, "cleaned_turnstile_data")
fares_data = tbl(conn, "fares_data")
stations_data = data.table::fread("./data/Updated_Stations.csv",sep = ",")
ts_data = read.csv("./data/turnstile_count.csv")

## Summary of Data
summary(collect(filter(turnstile_data, `New Entries`)))

## Filter for outliers
test = collect(turnstile_data %>% 
          filter(`New Entries` < 0 & STATION == "50 ST"))
          
### Old Code
# entries_diff = append(entries_diff,entries_vec)

# entries_exits = turnstile_data %>%
#   filter(SCP == scp & STATION == station) %>%
#   select(ENTRIES, EXITS)
# 
# entries = entries_exits$ENTRIES
# exits = entries_exits$EXITS

# entries_vec = entries[c(-1)] - entries
# entries_vec = c(0,entries_vec[c(-length(entries_vec))])
# exits_vec = exits[c(-1)] - exits
# exits_vec = c(0,exits_vec[c(-length(exits_vec))])

# for(i in 1:length(entries_vec)) {
#   print(entries_vec[i])
#   turnstile_data$`New Entries`[[i]] = entries_vec[i]
#   turnstile_data$`New Exits`[[i]] = exits_vec[i]
# }
# import turnstila and fares data files into two SQL databases
library(RSQLite)
library(DBI)

# make sure your working directory is the directory of the project
conn <- dbConnect(SQLite(), dbname)
data_dir = paste(getwd(),"data", sep = "/")

fares_dir = paste(data_dir, "fares", sep='/') # Directory of fares data
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

turnstile_dir = paste(data_dir, "turnstile", sep='/') # Directory of turnstile data
turnstile_files = rev(paste(turnstile_dir, list.files(turnstile_dir), sep="/")) # list of turnstile data files

for(file in turnstile_files) {
  dbWriteTable(conn = conn,
               name = "turnstile_data",
               value = file,
               append = TRUE,
               headers = TRUE,
               sep = ",")
}


## list tables
dbListTables(conn)
## disconnect
dbDisconnect(conn)
library(leaflet) 
library(shiny)
library(ggplot2)

source("./helpers.R")

dbname = "db.mta"
conn = DBI::dbConnect(RSQLite::SQLite(), dbname)

stations_data = getStationData("./data/Updated_Stations.csv")
ts_data = read.csv("./data/turnstile_count.csv")

# list of mta lines including hex code for color
mta_lines = list("1" = "#EE352E","2" = "#EE352E","3" = "#EE352E",
                 "4" = "#00933C","5" = "#00933C","6" = "#00933C","7" = "#B933AD",
                 "A" = "#0039A6","C" = "#0039A6","E" = "#0039A6",
                 "B" = "#FF6319","D" = "#FF6319", "F" = "#FF6319","M" = "#FF6319",
                 "G" = "#6CBE45", "J" = "#996633", "Z" = "#996633","L" = "#A7A9AC",
                 "S" = "#808183", "N" = "#FCCC0A","Q" = "#FCCC0A","R" = "#FCCC0A",
                 "W" = "#FCCC0A")

hour = c("00:00:00","01:00:00","02:00:00","03:00:00","04:00:00","05:00:00",
         "06:00:00","07:00:00","08:00:00","09:00:00","10:00:00","11:00:00",
         "12:00:00","13:00:00","14:00:00","15:00:00","16:00:00","17:00:00",
         "18:00:00","19:00:00","20:00:00","21:00:00","22:00:00","23:00:00")


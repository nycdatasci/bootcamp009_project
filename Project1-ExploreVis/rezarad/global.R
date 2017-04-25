setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(leaflet) 
library(shiny)

source("./helpers.R")

dbname = "db.sqlite"
conn = DBI::dbConnect(RSQLite::SQLite(), dbname)


# list of mta lines including hex code for color
mta_lines = list("1" = "#EE352E","2" = "#EE352E","3" = "#EE352E",
                 "4" = "#00933C","5" = "#00933C","6" = "#00933C","7" = "#B933AD",
                 "A" = "#0039A6","C" = "#0039A6","E" = "#0039A6",
                 "B" = "#FF6319","D" = "#FF6319", "F" = "#FF6319","M" = "#FF6319",
                 "G" = "#6CBE45", "J" = "#996633", "Z" = "#996633","L" = "#A7A9AC",
                 "S" = "#808183", "N" = "#FCCC0A","Q" = "#FCCC0A","R" = "#FCCC0A",
                 "W" = "#FCCC0A")

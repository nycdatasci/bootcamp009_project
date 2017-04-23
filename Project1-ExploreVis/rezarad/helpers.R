## Miscaellaneous Functions
capwords <- function(s, strict = FALSE) {
  cap <- function(s) paste(toupper(substring(s, 1, 1)),
                           {s <- substring(s, 2); if(strict) tolower(s) else s},
                           sep = "", collapse = " " )
  sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
}



getFaresData = function() {
require(dplyr)
require(dbplyr)
require(tidyr)

dbname = "db.sqlite"
conn = DBI::dbConnect(RSQLite::SQLite(), dbname)

fares_tbl = tbl(conn,"fares_data")

fares_by_date = fares_tbl %>%
  select(Remote = REMOTE,
         `Date Range` = DATE_RANGE,
         Station = STATION,
         `Full Fare` = FF,
         `Senior Citizen/Disabled` = SEN.DIS,
         `7 Day Unlimited AFAS (ADA FARECARD ACCESS SYSTEM)` = X7.D.AFAS.UNL,
         `30 Day Unlimited AFAS (ADA FARECARD ACCESS SYSTEM)` =  X30.D.AFAS.RMF.UNL,
         `Joint Rail Road Ticket` = JOINT.RR.TKT,
         `7 Day Unlimited` = X7.D.UNL,
         `30 Day Unlimited` = X30.D.UNL,
         `14 Day Unlimited (Reduced Fare Media)` = X14.D.RFM.UNL,
         `1 Day Unlimited/Funpass` = X1.D.UNL,
         `14 Day Unlimited` = X14.D.UNL, 
         `7 Day Express Bus` = X7D.XBUS.PASS,
         `Transit Check Metro Card` = TCMC,
         `Reduced Fare 2 Trip` = RF.2.TRIP,
         `Rail Road Unlimited (No Trade?)` = RR.UNL.NO.TRADE,
         `Transit Check Metro Card (Annual)` = TCMC.ANNUAL.MC,
         `Mail and Ride Easy Pay (Express)` = MR.EZPAY.EXP,
         `Mail and Ride Easy Pay (Unlimited)` = MR.EZPAY.UNL,
         `PATH 2 Trip` = PATH.2.T,
         `Airtrain Full Fare` = AIRTRAIN.FF,
         `Airtrain 30 Day` = AIRTRAIN.30.D,
         `Airtrain 10 Trip` = AIRTRAIN.10.T,
         `Airtrain Monthly` = AIRTRAIN.MTHLY,
         `Student Fare` = STUDENTS,
         `NICE (Nassau Inter-County Express) 2 Trip` = NICE.2.T,
         `CUNY Unlimited Commuter Card` = CUNY.120 
  ) %>% 
  group_by(Station)

# fares_by_date = fares_by_date %>% select(`CUNY Unlimited Commuter Card`) %>% arrange(`CUNY Unlimited Commuter Card`)
    
fares_by_date = collect(fares_by_date) %>%
  separate(`Date Range`, c("Start Date", "End Date"), sep="-", remove = TRUE) %>%
  mutate(`Week Of` = as.Date(`Start Date`,format = "%m/%d/%Y")) %>%
  arrange(`Full Fare`)

fares_by_date
} # returns a df of maximum fare card's sold per station per type

cleanTurnstileData = function() {
  require(dplyr)
  require(dbplyr)
  
  dbname = "db.sqlite"
  conn = DBI::dbConnect(RSQLite::SQLite(), dbname)
  
  # turnstile data for every 4 hours 
  turnstile_db = tbl(conn,"turnstile_data")
  stations = turnstile_db %>% 
    distinct(STATION, LINENAME)
    # mutate(strsplit(stations$LINENAME,split=""))
  
  collect(stations)
}


getBaseMap = function() {
require(leaflet)

map_style = "https://api.mapbox.com/styles/v1/rezarad77/cj1u20c5q000q2rqhg8zd822d/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoicmV6YXJhZDc3IiwiYSI6ImNqMXAyOHZvMzAwOWczNG1seHY4ZzJzdXcifQ.JwYon0JR4nbIAMC-fsaNyw"

map = leaflet() %>%
  addTiles(map_style) %>%
  setView(lng = -73.87, lat = 40.705, zoom = 12)

map
}

getStationData = function(filename) {
require(dplyr)

filename = data.table::fread(input = filename, sep = ",") %>%
  mutate(LatLong = paste(`GTFS Latitude`,`GTFS Longitude`, sep=":")) %>% 
  filter(`Daytime Routes` != "SIR")

filename
}

filteredLineData = function(line, station_info) {
require(dplyr)

latlong = station_info %>%  
  filter(grepl(line, `Daytime Routes`)) %>% 
  arrange(desc(`GTFS Stop ID`)) %>% 
  select(`Stop Name` , lng = `GTFS Longitude`, lat = `GTFS Latitude`, `Daytime Routes`) %>% 
  mutate(`Line` = line)

latlong
}

mapLineData = function(map, df, color = "blue") {
require(leaflet)

map = map %>% addPolylines(df$lng,
                           df$lat,
                           color = color,
                           weight = 4,
                           opacity = 0.6,
                           stroke = TRUE) %>% 
                addCircleMarkers(
                   df$lng,
                   df$lat,
                   # label = paste(df$`Stop Name`, paste("(",df$`Daytime Routes`,")",sep="")),
                   label  = df$`Stop Name`,
                   labelOptions = labelOptions(
                                    textsize = "12px",
                                    noHide = TRUE,
                                    textOnly = T,
                                    opacity = .8,
                                    direction = "left",
                                    style = NULL,
                                    clickable = TRUE
                                    ),
                    color = "black",
                    stroke = FALSE,
                    fillOpacity = .6,
                    radius = 4.5,
                    weight = 1.5)
map
}


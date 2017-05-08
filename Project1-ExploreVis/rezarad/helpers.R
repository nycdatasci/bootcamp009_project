## Functions for Building a Table
turnstileQuery = function(df, date = "03/01/2017", time = "11:00:00", station = "1 AV") {
  require(dplyr)
  
  daily_entries = df %>% 
    filter(DATE == date & TIME == time & STATION == station) %>% 
    group_by(STATION) %>% 
    summarise( `Entries` = max(ENTRIES) - min(ENTRIES), `Exits` = max(EXITS) - min(EXITS))
  
  daily_entries
}

getStationData = function(filename) {
require(dplyr)

filename = data.table::fread(input = filename, sep = ",") %>%
  mutate(LatLong = paste(`GTFS Latitude`,`GTFS Longitude`, sep=":")) %>% 
  filter(`Daytime Routes` != "SIR")

filename
}


## Functions for building and displaying map features
getBaseMap = function() {
  require(leaflet)
  
  map_style = "https://api.mapbox.com/styles/v1/rezarad77/cj1u20c5q000q2rqhg8zd822d/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoicmV6YXJhZDc3IiwiYSI6ImNqMXAyOHZvMzAwOWczNG1seHY4ZzJzdXcifQ.JwYon0JR4nbIAMC-fsaNyw"
  
  leaflet() %>%
    addTiles(map_style, 
             options = tileOptions(maxZoom = 17,
                                   minZoom = 11,
                                   detectRetina = TRUE,
                                   unloadInvisibleTiles = TRUE,
                                   reuseTiles = FALSE  
                                  )
    ) %>%
    setView(lng = -73.93, lat = 40.74, zoom = 13)
}

filteredLineData = function(line, station_df) {
require(dplyr)

latlong = station_df %>%  
  filter(grepl(line, `Daytime Routes`)) %>% 
  arrange(`Station ID`) %>% 
  select(`Stop Name` , lng = `GTFS Longitude`, lat = `GTFS Latitude`, `Daytime Routes`) %>% 
  mutate(`Line` = line)

latlong
}

mapLineData = function(map, df, color = "blue") {
require(leaflet)

map %>% addPolylines(df$lng,
             df$lat,
             color = color,
             weight = 3,
             opacity = 0.5,
             stroke = TRUE) %>% 
          addCircleMarkers(
             df$lng,
             df$lat,
             color = "black",
             stroke = FALSE,
             fillOpacity = 0.5,
             radius = 7,
             weight = 1.5,
             popupOptions = popupOptions(autoPan = T),
             # label = paste(df$`Stop Name`, paste("(",df$`Daytime Routes`,")",sep="")),
             label  = df$`Stop Name`,
             labelOptions = labelOptions(
                textsize = "12px",
                noHide = TRUE,
                textOnly = F,
                opacity = 0.4,
                direction = "auto",
                clickable = TRUE,
                className = "label_stations",
                zoomAnimation = TRUE
                )
             )
}

## Functions for Grabbing Data 
getFaresData = function(table) {
  require(dplyr)
  require(dbplyr)
  require(tidyr)
  
  fares_data = tbl(conn, table)
  
  fares_by_date = fares_data %>%
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
  
  fares_by_date = collect(fares_by_date) 
  
  fares_by_date %>%
    separate(`Date Range`, c("Start Date", "End Date"), sep="-", remove = TRUE) %>%
    mutate(`Week Of` = as.Date(`Start Date`,format = "%m/%d/%Y")) %>%
    arrange(`Full Fare`)
  
}

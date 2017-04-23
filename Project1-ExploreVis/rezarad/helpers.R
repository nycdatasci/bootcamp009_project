

getFaresData = function() {
  
  require(dplyr)
  require(dbplyr)
  require(tidyr)
  
  dbname = "db.sqlite"
  conn = DBI::dbConnect(RSQLite::SQLite(), dbname)
  
  turnstile_tbl = tbl(conn,"turnstile_data")
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

addMTAStations = function() {
  require(leaflet)
  require(dplyr)
  
  station_info = paste(getwd(),"data","Stations.csv",sep = "/")
  station_info = data.table::fread(input = station_info, sep = ",") %>%
    mutate(LatLong = paste(`GTFS Latitude`,`GTFS Longitude`, sep=":")) %>% 
    filter(`Daytime Routes` != "SIR")
  
  map_style = "https://api.mapbox.com/styles/v1/rezarad77/cj1u20c5q000q2rqhg8zd822d/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoicmV6YXJhZDc3IiwiYSI6ImNqMXAyOHZvMzAwOWczNG1seHY4ZzJzdXcifQ.JwYon0JR4nbIAMC-fsaNyw"
  
  nyc_map = leaflet() %>%
    addTiles(map_style) %>%
    setView(lng = -73.947, lat = 40.706, zoom = 11)
  
  # list of mta lines including hex code for color
  mta_lines = list("1" = "#EE352E","2" = "#EE352E","3" = "#EE352E",
                   "4" = "#00933C","5" = "#00933C","6" = "#00933C","7" = "#B933AD",
                   "A" = "#0039A6","C" = "#0039A6","E" = "#0039A6",
                   "B" = "#FF6319","D" = "#FF6319", "F" = "#FF6319","M" = "#FF6319",
                   "G" = "#6CBE45", "J" = "#996633", "Z" = "#996633","L" = "#A7A9AC",
                   "S" = "#808183", "N" = "#FCCC0A","Q" = "#FCCC0A","R" = "#FCCC0A",
                   "W" = "#FCCC0A")
  line_coordinates = as.data.frame(c())
  for(line in names(mta_lines)) {
    line_coordinates = station_info %>%  
      filter(grepl(line, `Daytime Routes`)) %>% 
      arrange(desc(`GTFS Stop ID`)) %>% 
      select(`Stop Name` , lng = `GTFS Longitude`, lat = `GTFS Latitude`) %>% 
      mutate(`Line` = line)
    
    nyc_map = nyc_map %>% addPolylines(lng = line_coordinates$lng,
                                       lat = line_coordinates$lat,
                                       color = mta_lines[line][[1]],
                                       weight = 2.5,
                                       fillOpacity = .8)
  }
  
  nyc_map = nyc_map %>% addCircleMarkers(lng = station_info$`GTFS Longitude`, 
                               lat = station_info$`GTFS Latitude`,
                               label = paste(station_info$`Stop Name`, paste("(",station_info$`Daytime Routes`,")",sep="")),
                               labelOptions = labelOptions(
                                 textsize = "14px",
                                 clickable = TRUE
                                  ),
                               color = "black",
                               stroke = FALSE,
                               fillOpacity = .6,
                               radius = 2,
                                weight = .5)
  
  nyc_map
}




messageData = data.frame(
  from = c("Subway Status", "Delays"),
  message = c(
    "trains on-time (%):",
    "Lines having delays:"
  ),
  stringsAsFactors = FALSE
)


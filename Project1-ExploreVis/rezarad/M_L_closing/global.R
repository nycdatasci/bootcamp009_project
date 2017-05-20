library(data.table)
library(leaflet)

stations_data = fread("stations_M_L_Line.csv")
stations_l = fread("stations_L_Line.csv")
stations_m = fread("stations_M_Line.csv")
turnstile = fread('turnstile_data_M_line_workv2.csv')



impacted_stations = c("Middle Village - Metropolitan Av", "Fresh Pond Rd", "Forest Av", "Seneca Av", "Myrtle - Wyckoff Avs", "Knickerbocker Av", "Central Av", "Myrtle Av", "Dekalb Av")                
impacted_stations_df = stations_data[`Stop Name` %in% impacted_stations]

map_style = "https://api.mapbox.com/styles/v1/rezarad77/cj1u20c5q000q2rqhg8zd822d/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoicmV6YXJhZDc3IiwiYSI6ImNqMXAyOHZvMzAwOWczNG1seHY4ZzJzdXcifQ.JwYon0JR4nbIAMC-fsaNyw"

map = leaflet() %>%
  addTiles(map_style, 
           options = tileOptions(maxZoom = 17,
                                 minZoom = 11,
                                 detectRetina = TRUE,
                                 unloadInvisibleTiles = TRUE,
                                 reuseTiles = FALSE  
           )) %>% 
  setView(lng = -73.91, lat = 40.705, zoom = 15) %>% 
  addPolylines(stations_l$`GTFS Longitude`,
               stations_l$`GTFS Latitude`,
               color = "#A7A9AC",
               weight = 6,
               opacity = 0.5,
               stroke = TRUE) %>% 
  addPolylines(stations_m$`GTFS Longitude`,
               stations_m$`GTFS Latitude`,
               color = "#FF6319",
               weight = 6,
               opacity = 0.5,
               stroke = TRUE) %>% 
  addCircleMarkers(
    impacted_stations_df$`GTFS Longitude`,
    impacted_stations_df$`GTFS Latitude`,
    color = "black",
    stroke = FALSE,
    fillOpacity = 0.5,
    radius = 7,
    weight = 3.5,
    popupOptions = popupOptions(autoPan = T),
    label  = impacted_stations_df$`Stop Name`,
    labelOptions = labelOptions(
      textsize = "14px",
      noHide = TRUE,
      textOnly = F,
      opacity = 0.4,
      direction = "auto",
      clickable = TRUE,
      className = "label_stations",
      zoomAnimation = TRUE
    )
  )


mta_lines = list("M" = "#FF6319","J" = "#996633", "Z" = "#996633","L" = "#A7A9AC")


hour = c("00:00:00","01:00:00","02:00:00","03:00:00","04:00:00","05:00:00",
         "06:00:00","07:00:00","08:00:00","09:00:00","10:00:00","11:00:00",
         "12:00:00","13:00:00","14:00:00","15:00:00","16:00:00","17:00:00",
         "18:00:00","19:00:00","20:00:00","21:00:00","22:00:00","23:00:00")


# colnames(DT)
# # Average Entries per Station per 4 hours
# avg_per_update = DT[, .(mean(ENTRIES.FINAL), mean(EXITS.FINAL)), by = STATION]
# # Total entries and exits since 4/20
# total_per_station = DT[, .(sum(ENTRIES.FINAL), sum(EXITS.FINAL)), by = STATION]


library(data.table)
library(lubridate)

# import turnstile data into a data.table and filter on stations being looked at
# use rbindlist to merge data from separate text files into one DT
turnstile_dir = "../data/turnstile/"
# list of turnstile data files to do rbindlist on
turnstile_files = rev(paste(turnstile_dir,
                      list.files(turnstile_dir), sep="/"))
DT = rbindlist(lapply(turnstile_files,fread, fill=TRUE))

# filter for M and L line 
DT_ml = DT[grepl("L|M|J", LINENAME)]
# remove other lines to free up memory
rm(DT)
# convert date and time columns to DATE TIME format
DT_ml = DT_ml[,DATE := as.Date(DATE,format = "%m/%d/%Y")][,TIME := chron(times. = TIME)]
# Station Names from turnstile data
ts_station_names = DT_ml[, uniqueN(STATION), by = STATION]
DT_ml[STATION == "MYRTLE AVE", STATION := "MYRTLE AV"]
DT_ml[STATION == "MORGAN AVE", STATION := "MORGAN AV"]
DT_ml[STATION == "FRESH POND ROAD", STATION := "FRESH POND RD"]
DT_ml[STATION == "DEKALB AVE", STATION := "DEKALB AV"]

# Add GRPS (long/lat) data to each station
stations = fread("../data/Updated_Stations_v2.csv")

# create a vector of station order to add to each station and order by stop
stations_m = stations[grepl("M", `Daytime Routes`)]
stop_order_m = c(seq(8,13), seq(1,7), 15, seq(20,16), 14, seq(36,21))
stations_m[,'Stop Number'] = stop_order_m
setkey(stations_m, 'Stop Number')
stations_l = stations[grepl("L", `Daytime Routes`)]
stations_l[,'Stop Number'] = seq(nrow(stations_l))
setkey(stations_l, 'Stop Number')

station_lm = rbind(stations_l, stations_m)
fwrite(station_lm, "stations_M_L_Line.csv")
fwrite(stations_l, "stations_L_Line.csv")
fwrite(stations_m, "stations_M_Line.csv")

m = stations_m[`Stop Number` %in% seq(1,8),`Turnstile Station Name`]
l = stations_l[`Stop Number` %in% seq(13,14),`Turnstile Station Name`]
j = c('KOSCIUSZKO ST', 'FLUSHING AV', 'MYRTLE AV')

DT = DT_ml[STATION %in% m | STATION %in% l | STATION %in% j]

# update order of rows 
setorder(DT, STATION, SCP,UNIT, DATE.TIME)

# slice data for 05/01/16-05/01/17
DT = DT[DATE >= as.Date("2016-05-01", format="%Y-%m-%d") & DATE <= as.Date("2017-05-01", format="%Y-%m-%d")]

# add date.time column and weekday column
DT[, "DATE.TIME" := as.POSIXct(paste(DT$DATE, DT$TIME), format="%Y-%m-%d %H:%M:%S", tz = "EST")]
DT[, "WEEKDAY" := wday(DT$DATE.TIME, label = TRUE)]

fwrite(DT, "turnstile_data_M00516_0517v2.csv")


# add column for entry/exit deltas for each observation 
DT[, c("ENTRIES.NEXT", "EXITS.NEXT") := NULL]

setkey(DT, DATE.TIME)

DT = DT[, .SD, by=.(STATION, UNIT, SCP)]

entries = data.table(ENTRIES.NEXT = c(DT[-1,ENTRIES],0))
exits = data.table(EXITS.NEXT = c(DT[-1,EXITS],0))

cbind(DT, entries, exits)

setkey(entries, DATE.TIME)
setkey(exits, DATE.TIME)

setkey(DT, DATE.TIME)

DT[entries, roll = T]


  
DT[, "ENTRIES.NEXT" := entries][,"EXITS.NEXT" := exits]

rm(entries)
rm(exits)

DT[,ENTRIES.FINAL := ENTRIES.NEXT-ENTRIES][,EXITS.FINAL := EXITS.NEXT-EXITS]
DT[,ENTRIES.FINAL := c(0,DT[-1,ENTRIES.FINAL])] 
DT[,EXITS.FINAL := c(0,DT[-1,EXITS.FINAL])] 


# DT[ENTRIES.FINAL > 0 & ENTRIES.FINAL < 5000, mean(ENTRIES.FINAL), by= .(STATION, SCP, `C/A`)]
DT = DT[EXITS.FINAL > 0 & EXITS.FINAL < 5000 & ENTRIES.FINAL > 0 & ENTRIES.FINAL < 5000]


fwrite(DT, "turnstile_data_M_line_workv3.csv")

nrow(DT[EXITS.FINAL < 0 | EXITS.FINAL > 5000])
nrow(DT[ENTRIES.FINAL < 0 | ENTRIES.FINAL > 5000])

  


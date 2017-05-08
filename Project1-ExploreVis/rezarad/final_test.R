library(dplyr)
library(dbplyr)
library(chron)
library(data.table)
library(ggplot2)

turnstile_dir = "./data/turnstile_new"
turnstile_files = rev(paste(turnstile_dir, list.files(turnstile_dir), sep="/")) # list of turnstile data files

turnstile_DT = rbindlist(lapply(turnstile_files,fread))

turnstile_DT[,DATE := as.Date(DATE,format="%m/%d/%Y")][,TIME := chron(times. = TIME)]
        
setkey(turnstile_DT, STATION, UNIT, SCP, DATE, TIME)

entries = c(turnstile_DT[-1,ENTRIES],0)
exits = c(turnstile_DT[-1,EXITS],0)

turnstile_DT[, "ENTRIES.NEXT" := entries][,"EXITS.NEXT" := exits]

rm(entries)
rm(exits)

turnstile_DT[,ENTRIES.FINAL := ENTRIES.NEXT-ENTRIES][,EXITS.FINAL := EXITS.NEXT-EXITS]
turnstile_DT[,ENTRIES.FINAL := c(0,turnstile_DT[-1,ENTRIES.FINAL])] 
turnstile_DT[,EXITS.FINAL := c(0,turnstile_DT[-1,EXITS.FINAL])] 

setkey(turnstile_DT, DATE, TIME)

turnstile_DT = turnstile_DT[DATE != as.Date("2016-12-31")][DATE != as.Date("2017-03-31")]
turnstile_DT = turnstile_DT[(abs(ENTRIES.FINAL - mean(ENTRIES.FINAL))/sd(ENTRIES.FINAL) < 2)]

station_details = turnstile_DT %>% 
  group_by(STATION) %>% 
  summarise(Total_Entries = sum(ENTRIES.FINAL),
            Total_Exits = sum(EXITS.FINAL)) %>% 
  arrange(Total_Entries) 

by_weekday = list("Monday" = turnstile_DT[day.of.week(month.day.year(DATE)$month,month.day.year(DATE)$day,month.day.year(DATE)$year) == 0,sum(ENTRIES.FINAL)],
                  "Tuesday" = turnstile_DT[day.of.week(month.day.year(DATE)$month,month.day.year(DATE)$day,month.day.year(DATE)$year) == 1,sum(ENTRIES.FINAL)],
                  "Wednesday" = turnstile_DT[day.of.week(month.day.year(DATE)$month,month.day.year(DATE)$day,month.day.year(DATE)$year) == 2,sum(ENTRIES.FINAL)],
                  "Thursday" = turnstile_DT[day.of.week(month.day.year(DATE)$month,month.day.year(DATE)$day,month.day.year(DATE)$year) == 3,sum(ENTRIES.FINAL)],
                  "Friday" = turnstile_DT[day.of.week(month.day.year(DATE)$month,month.day.year(DATE)$day,month.day.year(DATE)$year) == 4,sum(ENTRIES.FINAL)],
                  "Saturday" = turnstile_DT[day.of.week(month.day.year(DATE)$month,month.day.year(DATE)$day,month.day.year(DATE)$year) == 5,sum(ENTRIES.FINAL)],
                  "Sunday" = turnstile_DT[day.of.week(month.day.year(DATE)$month,month.day.year(DATE)$day,month.day.year(DATE)$year) == 6,sum(ENTRIES.FINAL)])

as.data.frame(by_weekday, row.names = c("Day of Week","Total Entries")) %>% ggplot(aes(x = , y =2)) + geom_bar()

turnstile_DT %>%
  ggplot(aes(x = DATE, y = ENTRIES.FINAL)) +
  geom_smooth()

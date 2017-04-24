library (dplyr)
library(data.table)
library (lubridate)
library(zipcode)

library(ggplot2)
library (ggthemes)

library(labeling)
library(chron)

library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(shinydashboard)

devtools::install_github("rstudio/leaflet")

setwd("C:/Users/Pradeep Krishnan/Desktop/New folder/visionzero/Main")


mvc_raw=fread("NYPD_Motor_Vehicle_Collisions.csv")
#1015999 observartions and 29 variables


mvc_raw[mvc_raw==""]<-NA
#to fill missing values uniformly with NA


names(mvc_raw)<-chartr(" ","_", names(mvc_raw))
#to rename variable names so that space is replace by underscore

mvc_raw[,DATE:=mdy(DATE)]
#changing the type of DATE column from character to date

mvc_raw[,MONTH:=month(DATE)]
mvc_raw[,YEAR:=year(DATE)]
mvc_raw[,DAY:=wday(DATE)]

#creating month and year columns

#Removing 2012 and 2017 from the observations because they do not have data for the full year
mvc_raw<-mvc_raw[YEAR %in% c(2013:2016)]

mvc_raw<- filter(mvc_raw, !is.na(BOROUGH))
mvc_raw<- filter(mvc_raw, !is.na(LOCATION))
mvc_raw<- filter(mvc_raw, !is.na(ZIP_CODE))
mvc_raw<- filter(mvc_raw, !is.na(CONTRIBUTING_FACTOR_VEHICLE_2))
mvc_raw<- filter(mvc_raw, !is.na(VEHICLE_TYPE_CODE_2))

#filtering out observations with empty borough, location, zipcode


mvc_raw=select(mvc_raw,-contains("STREET"))

mvc_raw=select(mvc_raw,-contains("CONTRIBUTING_FACTOR_VEHICLE_3"))
mvc_raw=select(mvc_raw,-contains("CONTRIBUTING_FACTOR_VEHICLE_4"))
mvc_raw=select(mvc_raw,-contains("CONTRIBUTING_FACTOR_VEHICLE_5"))
mvc_raw=select(mvc_raw,-contains("VEHICLE_TYPE_CODE_3"))
mvc_raw=select(mvc_raw,-contains("VEHICLE_TYPE_CODE_4"))
mvc_raw=select(mvc_raw,-contains("VEHICLE_TYPE_CODE_5"))
mvc_raw=select(mvc_raw,-contains("UNIQUE_KEY"))


mvc_raw<-mvc_raw[which(mvc_raw$NUMBER_OF_PERSONS_INJURED>0 | mvc_raw$NUMBER_OF_PERSONS_KILLED>0), ]

mvc_raw<-mvc_raw[which((mvc_raw$NUMBER_OF_PERSONS_INJURED) == (mvc_raw$NUMBER_OF_PEDESTRIANS_INJURED + mvc_raw$NUMBER_OF_CYCLIST_INJURED + mvc_raw$NUMBER_OF_MOTORIST_INJURED)),]

mvc_raw<-mvc_raw[which((mvc_raw$NUMBER_OF_PERSONS_KILLED) == (mvc_raw$NUMBER_OF_PEDESTRIANS_KILLED + mvc_raw$NUMBER_OF_CYCLIST_KILLED + mvc_raw$NUMBER_OF_MOTORIST_KILLED)),]



write.csv(mvc_raw, "NY_MotorVehicleCollisions_Cleaned.csv",row.names=FALSE)

mvc=fread("NY_MotorVehicleCollisions_Cleaned.csv")
#70821 observations of 22 variables


save(mvc,file="mvc.Rda")


mvc_grp=mvc %>% group_by(BOROUGH,YEAR)
Borough_by_year = mvc_grp %>% summarise(total_killed = sum(NUMBER_OF_PERSONS_KILLED))
Killed_by_years = ggplot(data = Borough_by_year, aes(x = YEAR, y = total_killed))
Killed_by_years + geom_bar(aes(fill = BOROUGH), stat = 'identity') + theme(legend.position = "right") + theme(legend.text=element_text(size=5)) + ggtitle('Fatalities') + ylab("Persons killed\n") + xlab("\nYEAR")  + theme(axis.text.x = element_text(vjust = 0.5, angle = 0, hjust = 0.5)) + theme(legend.position = "right") + theme(legend.text=element_text(size=10)) + theme(plot.title = element_text(hjust = 0.5))



# mvc=as.data.table(mvc)
# location_dt=mvc[,.N,by=LOCATION]
# location_sort=location_dt[order(-rank(N), LOCATION)]
# location_sort
#
# mvc_borough_ziploc=mvc[,c("BOROUGH","ZIP_CODE","LOCATION","LONGITUDE","LATITUDE")]
#
# mvc_uniq_columns=mvc_borough_ziploc[!duplicated(mvc_borough_ziploc[,LOCATION,])]
#
# major_intersections=merge(mvc_uniq_columns,location_sort, by="LOCATION")
#
# n<-.05
#
# top_intersections=head(major_intersections[order(major_intersections$N,decreasing=T),],n*nrow(major_intersections))


mvc_location_count = count(mvc,LOCATION)

mvc <- merge(mvc,mvc_location_count, by="LOCATION")
# finding the count of each location with give number of accident occurences at each location

mvc_by_total_number=mvc %>% group_by(LOCATION) %>% 
  summarize(total_fatalities=sum(NUMBER_OF_PERSONS_KILLED),
            total_injuries=sum(NUMBER_OF_PERSONS_INJURED),
            pedestrians_killed=sum(NUMBER_OF_PEDESTRIANS_KILLED),
            pedestrians_injured=sum(NUMBER_OF_PEDESTRIANS_INJURED),
            cyclists_killed=sum(NUMBER_OF_CYCLIST_KILLED),
            cyclists_injured=sum(NUMBER_OF_CYCLIST_INJURED),
            motorists_killed=sum(NUMBER_OF_MOTORIST_KILLED),
            motorists_injured=sum(NUMBER_OF_MOTORIST_INJURED))

#merging the sums of injuries and fatalities to the main dataset mvc


mvc_total_numbers=merge(mvc_by_total_number, mvc, by="LOCATION")

mvc_total_numbers=mvc_total_numbers[!duplicated(mvc_total_numbers$LOCATION),]

mvc_total_numbers=as.data.table(mvc_total_numbers)


mvc_total_numbers$color<- ifelse(mvc_total_numbers$n>20 | mvc_total_numbers$total_injuries>20, "red", ifelse(mvc_total_numbers$n<5 | mvc_total_numbers$total_injuries<5, "green", "orange"))


mvc_total_numbers$commute=ifelse(((mvc_total_numbers$cyclists_killed + mvc_total_numbers$cyclists_injured)> 
                       ((mvc_total_numbers$motorists_killed + mvc_total_numbers$motorists_injured + mvc_total_numbers$pedestrians_injured
                         + mvc_total_numbers$pedestrians_killed))), "CYCLE", 
                    ifelse(((mvc_total_numbers$pedestrians_killed + mvc_total_numbers$pedestrians_injured)>
                              (mvc_total_numbers$motorists_killed + mvc_total_numbers$motorists_injured 
                               + mvc_total_numbers$cyclists_killed + mvc_total_numbers$cyclists_injured)),"WALK","CAR"))






mvc_major=head(arrange(mvc_total_numbers, desc(n)),2500)


killed_by_borough<- group_by(mvc_major,YEAR,BOROUGH)%>%
  summarise( 
    injured = sum(NUMBER_OF_PERSONS_INJURED), 
    killed = sum(NUMBER_OF_PERSONS_KILLED),
    none = sum(NUMBER_OF_PERSONS_INJURED ==0 & 
                 NUMBER_OF_PERSONS_KILLED ==0),
    count = n()
  )




# 
# 
# 
# mvc_major$color<- ifelse(mvc_major$n>40 | mvc_major$total_injuries>60, "red", ifelse(mvc_major$n<20 | mvc_major$total_injuries<24, "green", "orange"))
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# mvc_major$commute=ifelse(((mvc_major$cyclists_killed + mvc_major$cyclists_injured)> 
#                            ((mvc_major$motorists_killed + mvc_major$motorists_injured + mvc_major$pedestrians_injured
#                              + mvc_major$pedestrians_killed))), "CYCLE", 
#                   ifelse(((mvc_major$pedestrians_killed + mvc_major$pedestrians_injured)>
#                             (mvc_major$motorists_killed + mvc_major$motorists_injured 
#                              + mvc_major$cyclists_killed + mvc_major$cyclists_injured)),"WALK","CAR"))
# 
# 
# 
# 
# 
# 
# Commute_killed = mvc_grp %>% dplyr::summarise(total_motorists_killed = sum(NUMBER_OF_MOTORIST_KILLED),
#                                                total_ped_killed = sum(NUMBER_OF_PEDESTRIANS_KILLED), 
#                                                total_cyclist_killed = sum(NUMBER_OF_CYCLIST_KILLED))
# 
# 
#                          
# Total_mot_killed_yearly = ggplot(data = Commute_killed, aes(x = YEAR, y = total_motorists_killed )) 
# Total_mot_killed_yearly + geom_bar(aes(fill = BOROUGH), stat = 'identity') + facet_wrap(~BOROUGH)   + theme_economist() +  theme(legend.position = "right") + theme(legend.text=element_text(size=5)) + ggtitle('Total number of Motorist Fatalities by Year') + ylab("Number of Fatalities\n") + xlab("\nYear")  + theme(axis.text.x = element_text(vjust = 0, angle = 0, hjust = 0.5)) + theme(legend.position = "right") + theme(legend.text=element_text(size=10)) + theme(plot.title = element_text(hjust = 0.5))
# 
# 
# Total_ped_killed_yearly = ggplot(data = Commute_killed, aes(x = YEAR, y = total_ped_killed)) 
# Total_ped_killed_yearly+ geom_bar(aes(fill = BOROUGH), stat = 'identity') + facet_wrap(~BOROUGH)   + theme_economist() +  theme(legend.position = "right") + theme(legend.text=element_text(size=5)) + ggtitle('Total number of Pedestrian Fatalities by Year') + ylab("Number of Fatalities\n") + xlab("\nYear")  + theme(axis.text.x = element_text(vjust = 0, angle = 0, hjust = 0.5)) + theme(legend.position = "right") + theme(legend.text=element_text(size=10)) + theme(plot.title = element_text(hjust = 0.5))
# #Brooklyn seems to be different from other boroughs where we see an increasing trend in number of pedestrian fatalities. This 
# 
# 
# Total_cycl_killed_yearly = ggplot(data = Commute_killed, aes(x = YEAR, y = total_cyclist_killed)) 
# Total_cycl_killed_yearly + geom_bar(aes(fill = BOROUGH), stat = 'identity') + facet_wrap(~BOROUGH)   + theme_economist()  + theme(legend.position = "right") + theme(legend.text=element_text(size=5)) + ggtitle('Total number of Cyclist Fatalities by Year') + ylab("Number of Fatalities\n") + xlab("\nYear")  + theme(axis.text.x = element_text(vjust = 0, angle = 0, hjust = 0.5)) + theme(legend.position = "right") + theme(legend.text=element_text(size=10)) + theme(plot.title = element_text(hjust = 0.5))
# 
# 







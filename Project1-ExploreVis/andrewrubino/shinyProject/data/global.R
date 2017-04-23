### global.R ###

library(dplyr)
library(data.table)
library(tidyr)
library(lubridate)
library(ggplot2)
library(maps)
library(plotly)
library(dygraphs)
library(xts) # as.Date is masked by zoo!!
library(reshape2)
library(googleVis)
library(leaflet)
library(DT)

claims <- read.table("tidy_claims.tsv", header = T, sep = " ") # space separated for some reason


type_df <- claims %>% group_by(Claim.Type) %>%
  summarise(n = n(),
            overall_ratio = n / nrow(claims))

type_dis <- claims %>% group_by(Claim.Type, Disposition) %>%
  summarise(n = n()) %>%
  spread(Disposition, n) %>%
  rename(Approved = `Approve in Full`)

joined_typedis <- left_join(type_dis, type_df, by = "Claim.Type") %>%
  mutate(approved_ratio = Approved / n,
         denied_ratio = Deny / n,
         settled_ratio = Settle / n) %>%
  select(- overall_ratio)


# Adding Total.Claims will make calculations easier
claims <- claims %>% mutate(Total.Claims  = Audio.Video +
                              Automobile.Parts.Accessories +
                              Baggage.Cases.Purses +
                              Books.Magazines.Other +
                              Cameras +
                              Clothing +
                              Computer.Accessories +
                              Cosmetics.Grooming +
                              Crafting.Hobby +
                              Currency +
                              Food.Drink +
                              Home.Decor +
                              Household.Items +
                              Hunting.Fishing.Items +
                              Jewelry.Watches +
                              Medical.Science +
                              Musical.Instruments.Accessories +
                              Office.Equipment.Supplies +
                              Other +
                              Outdoor.Items +
                              Personal.Accessories +
                              Personal.Electronics +
                              Personal.Navigation +
                              Sporting.Equipment.Supplies +
                              Tools.Home.Improvement.Supplies +
                              Toys.Games)

# How bout by month. Need to create a month column from the incident date
claims$Month_Yr <- format(as.Date(claims$Incident.Date), "%Y-%m")
claims$Year <- year(claims$Incident.Date)
claims$Month.Dot.Year <- gsub("-", ".", claims$Month_Yr)
claims$Month.Dot.Year <- as.numeric(claims$Month.Dot.Year)

by_date <- claims %>% filter(Claim.Type != "Compliment") %>%
  group_by(Month_Yr, Claim.Type) %>%
  summarise(n = n()) %>%
  arrange(Month_Yr)

by_date$Full.Date <- paste0(by_date$Month_Yr, "-01")
by_date$Full.Date <- as.Date(as.character(by_date$Full.Date))

x = by_date
x$Month_Yr <- NULL
x <- as.data.frame(x)

x <- dcast(x, Full.Date ~ Claim.Type, value.var = "n")


x_by_date <- xts(x, order.by = x$Full.Date)

# sort of hard to interpret, except that claims have been pretty steady for the past 
# few years. What if we do it by month only.
claims$Month <- month(claims$Incident.Date)

by_month <- claims %>% filter(Claim.Type != "Compliment") %>%
  group_by(Month, Claim.Type, Year) %>%
  filter(Claim.Type != "Compliment") %>%
  summarise(avg_claim_amount = mean(Total.Claims),
            median_claim_amount = median(Total.Claims))





# I want to see the counts of each item!! How many of what was lost by Airport
items_by_airport <- claims %>% filter(Airport.Code %in% c("ATL", "LAX", "ORD", "DFW", "JFK", 
                                     "DEN", "SFO", "CLT", "LAS", "PHX")) %>% 
  group_by(Airport.Code, Year, Disposition) %>% 
  summarise(audio_video = sum(Audio.Video),
                 automobile = sum(Automobile.Parts.Accessories),
                 baggage = sum(Baggage.Cases.Purses),
                 books = sum(Books.Magazines.Other),
                 cameras = sum(Cameras),
                 clothing = sum(Clothing),
                 computer = sum(Computer.Accessories),
                 cosmetics = sum(Cosmetics.Grooming),
                 crafting = sum(Crafting.Hobby),
                 currency = sum(Currency),
                 food = sum(Food.Drink),
                 home_decor = sum(Home.Decor),
                 household_items = sum(Household.Items),
                 hunting_items = sum(Hunting.Fishing.Items),
                 jewelry = sum(Jewelry.Watches),
                 medical = sum(Medical.Science),
                 music_instruments = sum(Musical.Instruments.Accessories),
                 office_supplies = sum(Office.Equipment.Supplies),
                 outdoor_items = sum(Outdoor.Items),
                 pers_accessories = sum(Personal.Accessories),
                 pers_electronics = sum(Personal.Electronics),
                 pers_navigation = sum(Personal.Navigation),
                 sport_supplies = sum(Sporting.Equipment.Supplies),
                 home_improve_supplies = sum(Tools.Home.Improvement.Supplies),
                 toys = sum(Toys.Games),
                 travel_accessories = sum(Travel.Accessories))




### by airline

items_by_airline <- claims %>% filter(Airline.Name %like% "^American Airlines" |
                                      Airline.Name %like% "Southwest Airlines" |
                                      Airline.Name %like% "Delta Air Lines" |
                                      Airline.Name %like% "UAL" |
                                      Airline.Name %like% "Jet Blue" |
                                      Airline.Name %like% "Alaska Airlines" |
                                      Airline.Name %like% "Spirit Airlines") %>% 
  group_by(Airline.Name, Year, Disposition) %>% 
  summarise(audio_video = sum(Audio.Video),
            automobile = sum(Automobile.Parts.Accessories),
            baggage = sum(Baggage.Cases.Purses),
            books = sum(Books.Magazines.Other),
            cameras = sum(Cameras),
            clothing = sum(Clothing),
            computer = sum(Computer.Accessories),
            cosmetics = sum(Cosmetics.Grooming),
            crafting = sum(Crafting.Hobby),
            currency = sum(Currency),
            food = sum(Food.Drink),
            home_decor = sum(Home.Decor),
            household_items = sum(Household.Items),
            hunting_items = sum(Hunting.Fishing.Items),
            jewelry = sum(Jewelry.Watches),
            medical = sum(Medical.Science),
            music_instruments = sum(Musical.Instruments.Accessories),
            office_supplies = sum(Office.Equipment.Supplies),
            outdoor_items = sum(Outdoor.Items),
            pers_accessories = sum(Personal.Accessories),
            pers_electronics = sum(Personal.Electronics),
            pers_navigation = sum(Personal.Navigation),
            sport_supplies = sum(Sporting.Equipment.Supplies),
            home_improve_supplies = sum(Tools.Home.Improvement.Supplies),
            toys = sum(Toys.Games),
            travel_accessories = sum(Travel.Accessories))

# create a heatmap with dataframe using plotly.


# Top 5 airline claims: Delta, Southwest, American, UAL, USAir. Now by Airport


# Let's join the lat lon from the other file with the airport codes in this file
latlon <- read.csv("Airport_Codes_mapped_to_Latitude_Longitude_in_the_United_States.csv", header = TRUE)

latlon <- latlon %>% rename(Airport.Code = locationID)

claims <- left_join(claims, latlon, by = "Airport.Code")

lltest <- claims %>% group_by(Latitude, Longitude) %>%
  summarise(n = n()) %>%
  arrange(desc(n))

ggplot(lltest, aes(x = Latitude, y = Longitude)) + geom_point()





######## compare top10 airports and airlines
top10airports <- read.csv("top10airports.csv", header = T)

# Let's do top10airlines first. Create a dataframe from claims that has total count of
# claims grouped by airline and year for 2015 only. We'll need to gather the data and tidy
# it (rename columns also)

top10airports <- top10airports %>% 
  rename("2015" = est_2015_flights, "2014" = est_2014_flights) %>%
  gather(key = "Year", value = "flights", 3:4)

top10airports$Year <- as.numeric(top10airports$Year)

top10ac <- claims %>% filter(Airport.Code %in% c('ATL','LAX','ORD','DFW',
                                                 'JFK','DEN','SFO',
                                                 'CLT','LAS','PHX') 
                             & (Year == 2014 | Year == 2015)) %>%
  group_by(Airport.Code, Year, Claim.Type) %>%
  summarise(total = sum(Total.Claims)) %>%
  arrange(Year)



top10ac <- left_join(top10ac, top10airports, by = c("Airport.Code", "Year"))

top10ac <- top10ac %>% mutate(Claim.Rate = total / flights)
top10ac$Year <- as.character(top10ac$Year)



## Now do airlines
# tidy
top10airlines <- read.csv("top10airlines.csv", header = T)
top10airlines <- top10airlines %>% rename("2015" = est_2015_flights, "2014" = est_2014_flights) %>%
  gather(key = "Year", value = "flights", 2:3)

# filter claims for top 10 airlines
top10al <- claims %>% filter((as.character(Airline.Name) %like% "^American Airlines" |
                                Airline.Name %like% "Southwest Airlines" |
                                Airline.Name %like% "Delta Air Lines" |
                                Airline.Name %like% "UAL" |
                                Airline.Name %like% "Jet Blue" |
                                Airline.Name %like% "Alaska Airlines" |
                                Airline.Name %like% "Spirit Airlines") & 
                               (Year == 2014 | Year == 2015)) %>%
  group_by(Airline.Name, Year, Claim.Type) %>%
  summarise(total_claims = sum(Total.Claims))

# join them, but first, trim the white space
for (i in 1:nrow(top10al)) {
  trimws(top10al$Airline.Name[i], c("both"))
}

top10al$Year <- as.character(top10al$Year)

jtl <- read.csv("jointop10al.csv", header = T) 
# i did this because whitespaces were causing problems with joining and i was too lazy
# to figure out how to fix.

top10al <- jtl
top10al$Year <- as.character(top10al$Year)

# add claim rate
top10al <- top10al %>% mutate(Claim.Rate = total_claims / Flights)
top10al <- top10al %>% select(- concat)


###### leaflet ########
leaf_data <- claims %>% group_by(Latitude, Longitude, Year, Airport.Code) %>%
  summarise(all_claims = sum(Total.Claims)) %>%
    filter(all_claims >= 25) %>%
    arrange(desc(all_claims))

leaf_data$Longitude <- paste0("-",leaf_data$Longitude)
leaf_data$Longitude <- as.numeric(leaf_data$Longitude)


##### renderTables #####
airport_table <- read.csv("airport_table.csv", header = TRUE)
airline_table <- read.csv("airline_table.csv", header = TRUE)









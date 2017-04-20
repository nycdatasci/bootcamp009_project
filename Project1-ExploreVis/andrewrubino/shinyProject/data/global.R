### global.R ###

library(dplyr)
library(data.table)
library(tidyr)
library(lubridate)
library(ggplot2)
library(maps)

claims <- read.table("tidy_claims.tsv", header = T, sep = " ") # space separated for some reason

# total claims by airport
claims %>% group_by(Airport.Code) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  top_n(20)

claims %>% group_by(Airline.Name) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  top_n(20)

# total close amount by airport
claims %>% group_by(Airport.Code) %>%
  summarise(total_claims = sum(Close.Amount)) %>%
  arrange(desc(total_claims)) %>%
  top_n(20)

# JFK leads by a whopping margin. Maybe we can make a group bar chart that lets us filter by
# airport code, showing the total claims, close amounts, and by month?

# How bout overall claim type?
table(claims$Claim.Type)
# property loss first, , followed by prop damange, then personal injury
# Let's group this, and find which were denied, settled, or approved

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

#60% is property loss, 38% is prop damange, less than 1% is personal injury, and the rest
# are very small.
# The highest approval rate is only 25%!!!, when property damage is involved. They also
# settle 14% of the time. Property loss is only accepted 18% of the time, and settled 7%.

# Out of curiosity, I want to see where people claimed injuries.
claims %>% group_by(Airline.Name, Airport.Code) %>%
  filter(Claim.Type == "Personal Injury" & Disposition != "Deny") %>%
  summarise(n = n()) %>%
  arrange(desc(n))

# well well well. what do we have here. How bout if we take out the disposition type.

claims %>% group_by(Airline.Name) %>%
  filter(Claim.Type == "Personal Injury") %>%
  summarise(n = n()) %>%
  arrange(desc(n))
# I'd rather leave out the disposition type for personal injury, on account of data being 
# small and if it seems serious enough to file a claim for injury, might as well leave it.

# Vegas baby. because they were hungover?? Fun fact, all of these were denied.
# Followed by Newark at 3, Denver, Honolulu, Houton, and Orlanda with 2 that were not denied. 
# View(claims[claims$Claim.Type == "Personal Injury", ])

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

by_date <- claims %>% group_by(Month_Yr, Claim.Type) %>%
  summarise(n = n()) %>%
  arrange(Month_Yr)

# sort of hard to interpret, except that claims have been pretty steady for the past 
# few years. What if we do it by month only.
claims$Month <- month(claims$Incident.Date)

by_month <- claims %>% group_by(Month, Claim.Type) %>%
  filter(Claim.Type != "Compliment") %>%
  summarise(avg_claim_amount = mean(Total.Claims),
            median_claim_amount = median(Total.Claims))

ggplot(by_month, aes(x = Month, y = avg_claim_amount)) + 
  geom_histogram(binwidth = 0.2, stat = "identity") + facet_wrap( ~ Claim.Type)
# Kind of surprising, I thought there'd be more during November-December, but the avg
# claims looks to be pretty even across the board. What if we look at the same plot, 
# but with Airlines and Airports? Maybe it'll be good to get the ratio of claims/flights\
# first.


claims %>% group_by(Airport.Code, Claim.Type) %>%
  summarise(n = n()) %>%
  arrange(Claim.Type)

################## GO BACK #############






# I want to see the counts of each item!! How many of what was lost
# View(claims %>% group_by(Airline.Name) %>%
#        summarise(audio_video = sum(Audio.Video),
#                  automobile = sum(Automobile.Parts.Accessories),
#                  baggage = sum(Baggage.Cases.Purses),
#                  books = sum(Books.Magazines.Other),
#                  cameras = sum(Cameras),
#                  clothing = sum(Clothing),
#                  computer = sum(Computer.Accessories),
#                  cosmetics = sum(Cosmetics.Grooming),
#                  crafting = sum(Crafting.Hobby),
#                  currency = sum(Currency),
#                  food = sum(Food.Drink),
#                  home_decor = sum(Home.Decor),
#                  household_items = sum(Household.Items),
#                  hunting_items = sum(Hunting.Fishing.Items),
#                  jewelry = sum(Jewelry.Watches),
#                  medical = sum(Medical.Science),
#                  music_instruments = sum(Musical.Instruments.Accessories),
#                  office_supplies = sum(Office.Equipment.Supplies),
#                  other = sum(Other),
#                  outdoor_items = sum(Outdoor.Items),
#                  pers_accessories = sum(Personal.Accessories),
#                  pers_electronics = sum(Personal.Electronics),
#                  pers_navigation = sum(Personal.Navigation),
#                  sport_supplies = sum(Sporting.Equipment.Supplies),
#                  home_improve_supplies = sum(Tools.Home.Improvement.Supplies),
#                  toys = sum(Toys.Games),
#                  travel_accessories = sum(Travel.Accessories),
#                  total_claims = sum(Total.Claims)))

# Top 5 airline claims: Delta, Southwest, American, UAL, USAir. Now by Airport

# View(claims %>% group_by(Airport.Code) %>%
#        summarise(audio_video = sum(Audio.Video),
#                  automobile = sum(Automobile.Parts.Accessories),
#                  baggage = sum(Baggage.Cases.Purses),
#                  books = sum(Books.Magazines.Other),
#                  cameras = sum(Cameras),
#                  clothing = sum(Clothing),
#                  computer = sum(Computer.Accessories),
#                  cosmetics = sum(Cosmetics.Grooming),
#                  crafting = sum(Crafting.Hobby),
#                  currency = sum(Currency),
#                  food = sum(Food.Drink),
#                  home_decor = sum(Home.Decor),
#                  household_items = sum(Household.Items),
#                  hunting_items = sum(Hunting.Fishing.Items),
#                  jewelry = sum(Jewelry.Watches),
#                  medical = sum(Medical.Science),
#                  music_instruments = sum(Musical.Instruments.Accessories),
#                  office_supplies = sum(Office.Equipment.Supplies),
#                  other = sum(Other),
#                  outdoor_items = sum(Outdoor.Items),
#                  pers_accessories = sum(Personal.Accessories),
#                  pers_electronics = sum(Personal.Electronics),
#                  pers_navigation = sum(Personal.Navigation),
#                  sport_supplies = sum(Sporting.Equipment.Supplies),
#                  home_improve_supplies = sum(Tools.Home.Improvement.Supplies),
#                  toys = sum(Toys.Games),
#                  travel_accessories = sum(Travel.Accessories),
#                  total_claims = sum(Total.Claims)))

# Note on above. We can plot this several ways. One way I was thinkg was if you want to 
# include this in a map, you'd have a filter for the Claim Type, and a RATIO (do calculations)
# will show up based on Airport.Name/Code.


# Let's join the lat lon from the other file with the airport codes in this file
latlon <- read.csv("Airport_Codes_mapped_to_Latitude_Longitude_in_the_United_States.csv", header = TRUE)

latlon <- latlon %>% rename(Airport.Code = locationID)

claims <- left_join(claims, latlon, by = "Airport.Code")

lltest <- claims %>% group_by(Latitude, Longitude) %>%
  summarise(n = n()) %>%
  arrange(desc(n))

ggplot(lltest, aes(x = Latitude, y = Longitude)) + geom_point()





######## compare top10 airports and airlines
top10airlines <- read.csv("top10airlines.csv", header = T)
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

top10ac %>% group_by(Airport.Code) %>%
  summarise(total_claims = sum(total),
            total_flights = sum(flights)) %>%
  mutate(claim_rate = total_claims / total_flights)


## Now do airlines
# tidy
top10airlines <- top10airlines %>% rename("2015" = est_2015_flights, "2014" = est_2014_flights) %>%
  gather(key = "Year", value = "flights", 2:3)

# filter claims for top 10 airlines
top10al <- claims %>% filter((as.character(Airline.Name) %like% "^American Airlines" |
                                Airline.Name %like% "Southwest Airlines" |
                                Airline.Name %like% "Delta Air Lines" |
                                Airline.Name %like% "UAL" |
                                Airline.Name %like% "Jet Blue" |
                                Airline.Name %like% "Alaska Airlines" |
                                Airline.Name %like% "Spirit Airlines" |
                                Airline.Name %like% "Republic Airways") & 
                               (Year == 2014 | Year == 2015)) %>%
  group_by(Airline.Name, Year, Claim.Type) %>%
  summarise(total_claims = sum(Total.Claims))

# join them, but first, trim the white space
for (i in 1:nrow(top10al)) {
  trimws(top10al$Airline.Name[i], c("both"))
}

jtl <- read.csv("jointop10al.csv", header = T) 
# i did this because whitespaces were causing problems with joining and i was too lazy
# to figure out how to fix.

top10al <- jtl

# add claim rate
top10al <- top10al %>% mutate(Claim.Rate = total_claims / Flights)
top10al <- top10al %>% select(- concat)

top10al %>% group_by(Airline.Name) %>%
  summarise(claims = sum(total_claims),
            total_flights = sum(Flights),
            claim_rate = claims/total_flights) %>%
  arrange(desc(claim_rate))


## write another table with added columns and shit, then add to global.



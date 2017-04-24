# Romibala Ningthoujam
# NYC DSA: Project - DataVizShiny

getwd()
setwd("~/Documents/NYCDSA_Bootcamp/Project/Shiny_Project")

library(lubridate)
library(dplyr)
library(shiny)
library(ggplot2)
library(plotly)
library(zipcode)
library(Hmisc)
library(leaflet)


hospitals <- read.csv("Complications - Hospital.csv", stringsAsFactors = FALSE)

# Check for rows with missing values
complete_cases <- complete.cases(hospitals)
length(complete_cases)

# Check column names
names(hospitals)

# Check the class of each column
summary(hospitals)

# Convert columns 'Denominator', 'Score', 'Lower.Estimate', 'Higher.Estimate' to numeric
hospitals$Denominator <- as.numeric(hospitals$Denominator)
hospitals$Score <- as.numeric(hospitals$Score)
hospitals$Lower.Estimate <- as.numeric(hospitals$Lower.Estimate)
hospitals$Higher.Estimate <- as.numeric(hospitals$Higher.Estimate)

# Check for rows with missing/NA 'Score'
sum(is.na(hospitals$Score))

# Remove rows with missing/NA Score
hospitals <- filter(hospitals, !(is.na(Score)))

# Format 'Phone.Number' column
hospitals$Phone.Number <- gsub("(^\\d{3})(\\d{3})(\\d{4}$)", "\\1-\\2-\\3", hospitals$Phone.Number)

# Format date columns
hospitals$Measure.Start.Date <- mdy(hospitals$Measure.Start.Date)
hospitals$Measure.End.Date <- mdy(hospitals$Measure.End.Date)


unique(hospitals$Measure.Name)
unique(hospitals$Measure.ID)

length(unique(hospitals$Hospital.Name))
length(unique(hospitals$State))
unique(hospitals$State)

summary(hospitals)




##########################################
## Geocoding hospital addresses with CRAN's 'zipcode' package

data("zipcode") # load the zipcode data from the 'zipcode' package
geo_zipcode <- zipcode
head(geo_zipcode)

# convert 'zip' column to numeric
geo_zipcode$zip <- as.numeric(geo_zipcode$zip)
class(geo_zipcode$zip)

hospitals_with_geocode <- left_join(hospitals, geo_zipcode, by = c("ZIP.Code" = "zip"))

# Dropping duplicate columns (after left_join)
hospitals_with_geocode <- subset(hospitals_with_geocode, select = -c(state, city))

# lower casing and capitalizing first letter for 'City' and 'County.Name'
hospitals_with_geocode$City <- capitalize(tolower(hospitals_with_geocode$City))
hospitals_with_geocode$County.Name <- capitalize(tolower(hospitals_with_geocode$County.Name))



### Geocoding using Google's geocode API; but this has a limit of 2500 per day for an IP address!
# hospital_address <- unique(hospitals %>% 
#                              select(Hospital.Name, 
#                                     Address, 
#                                     City, 
#                                     State, 
#                                     ZIP.Code, 
#                                     County.Name,
#                                     Phone.Number))
# 
# hospital_address[, c("long", "lat")] <- NA
# 
# for(i in 1:nrow(hospital_address)) { 
#   address <- paste(hospital_address[i, c("Address", "City", "State", "ZIP.Code")], collapse = ", ")
#   coord <- ggmap::geocode(address, override_limit = TRUE)
#   hospital_address[i, c("long", "lat")] <- coord
#   }

# hospitals_filtered <- hospitals %>%
#   filter(Measure.ID == measures$Measure.ID[1]) %>%
#   unite(Address_full, Address, City, State, ZIP.Code, sep = ", ")

#######################



# plot(gvisMap(data = few_hospital_address1, 
#              locationvar = "LatLong", 
#              tipvar = "Hospital.Name",
#              options = list(region = "US")))

# few_hospital_address1 <- head(hospital_address1, 100)
# 
# hospital_address1 <- unite(hospital_address, "LatLong", lat, lon, sep = ":")
# 
# 
# plot(gvisGeoChart(few_hospital_address1, 
#                   locationvar = "LatLong",
#                   options = list(region = "US",
#                                  showTip = TRUE,
#                                  #showLine = TRUE,
#                                  enableScrollWheel = TRUE
#                                  )))






 #######################

# To assign region; for reginal comparison
north_east <- c("CT", "ME", "MA", "NH", "RI", "VT", "NJ", "NY", "PA")
mid_west <- c("IL", "IN", "MI", "OH", "WI", "IA", "KS", "MN", "MI", "NE", "ND", "SD")
south <- c("DE", "FL", "GA", "MD", "NC", "SC", "VA", "DC", "WV", "AL", "KY", "MS", "TN", "AR", "LA", "OK", "TX")
west <- c("AZ", "CO", "ID", "MT", "NV", "NM", "UT", "WY", "AK", "CA", "HI", "OR", "WA")


hospitals_tr <- mutate(hospitals_with_geocode, Region = ifelse(State %in% north_east, "NORTHEAST",
                                                      ifelse(State %in% mid_west, "MIDWEST", 
                                                             ifelse(State %in% south, "SOUTH",
                                                                    ifelse(State %in% west, "WEST", NA)))))



write.csv(hospitals_tr, file = "hospitals_transformed.csv")

# Puerto Rico's data show up in bloxpot but don't show up in scatter plot (although they are present in the dataset)
# Region inserted as 'NA' for Puerto Rico

# > unique(hosp_by_measure$Region)
# [1] "SOUTH"     "WEST"      "NORTHEAST" "MIDWEST"   ""         
# > length(hosp_by_measure$Region == "")
# [1] 3192
# > length(hosp_by_measure$State == "PR")
# [1] 3192
# > unique(hospital_regions$Region)
# [1] "SOUTH"     "WEST"      "NORTHEAST" "MIDWEST"   ""         
# > length(hospital_regions$State == "PR")
# [1] 31076
# > length(hospital_regions$Region == "")
# [1] 31076

# Map plot: test geo map for a state & measure name
mapdata <- filter(hospitals_with_geocode, State == "NJ" & 
                    Measure.Name == "Accidental cuts and tears from medical treatment")


leaflet(data = mapdata) %>% addTiles() %>%
  addMarkers(~longitude, ~latitude, popup = ~paste0(Hospital.Name, '<br>', Address, ', ', City, ', ', State,
                                                    '<br>','Score: ', Score, '<br>', Compared.to.National))


hospitals %>%
  group_by(State, Measure.Name) %>%
  summarise(total = n(), max_score = max(Score), min_score = min(Score))


hospitals_by_state_measure <- hospitals %>% 
  group_by(State, Measure.Name) %>%
  summarise(hosp_count = n())

# for slection - State - Measure.Name
h_selected <- filter(hospitals, State == "AK" & Measure.Name == "Accidental cuts and tears from medical treatment")


# plot1 - For each measure, complication score by state
hosp_by_measure <- filter(hospitals_tr, Measure.Name == "Accidental cuts and tears from medical treatment")

ggplot(data = hosp_by_measure, aes(x = State, y = Score)) +
  geom_point(aes(color = Score)) +
  scale_color_gradientn(colours = terrain.colors(20)) +
  labs(title = "Complication Rates by State",
       x = "State",
       y = "Complication Rate (Score)") +
  theme_dark() +
  theme(axis.text.x = element_text(angle = 60))
  
              
## Plot2
# use "na.omit" to omit Puerto Rico's data (inserted Region as 'NA')
ggplot(data = na.omit(hosp_by_measure), aes(x = Region, y = Score, fill = Region)) +
  geom_boxplot() +
  labs(title = "Complication Score - Regional Comparison",
       x = "Region",
       y = "Complication Rate (Score)") +
  theme_bw()








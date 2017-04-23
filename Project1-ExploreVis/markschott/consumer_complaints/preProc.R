library(zipcode)
require(rgdal)
#require(leaflet)
require(dplyr)
#library(maps)
#require(geojsonio)
#require(htmltools)

setwd("~/data/consumer_complaints")

csvpath = "data/Consumer_Complaints.csv"
## read main complaints csv, match zip codes to lat and longitude, remove unneccessary columns,
## change some columns type, save as Rda file
complaints <- read.csv(csvpath, stringsAsFactors = F)

### I also need to extract the Consumer.complaint.narratives to make the word bubbles.
### It appears that Rda files do not save long strings of text

narratives = complaints %>% group_by(Company) %>% select(Company, Consumer.complaint.narrative) %>%
  filter(Consumer.complaint.narrative != "") %>% 
  summarise(text = paste0(Consumer.complaint.narrative,collapse='')) %>%
  # Make a new column with the number of characters
  mutate(chars = nchar(text)) %>%
  # Make another new column with the number of words total
  mutate(words = sapply(gregexpr("\\W+", text),length)) %>%
  arrange(desc(chars))

### There are over 3000 different companies and some don't have very many responses. 
### The user will probably want to select from a drop down menu or even search by
### an input text. First and foremost I would like to be able to plot a word bubble for 
### the selected company. Right now I will save all companies narratives but I also need
### to paste them all together

##save narratives as Rda for late
saveRDS(narratives, 'data/narratives.Rda')

### Now process complaints itself
complaints$ZIP.code = as.character(complaints$ZIP.code)
data(zipcode)
complaints = inner_join(complaints, zipcode, by = c('ZIP.code' = 'zip'))
### Now drop unwanted columns
complaints = complaints %>% select(-c(Tags,ZIP.code,Consumer.consent.provided.,state, 
                                      Consumer.complaint.narrative, Complaint.ID))
## convert Date.received and Date.sent.to.company from factors/characters to date
## Dates are in %m/%d/%Y format
complaints$Date.received = as.Date(complaints$Date.received, format = '%m/%d/%Y')
complaints$Date.sent.to.company = as.Date(complaints$Date.sent.to.company, format = '%m/%d/%Y')
saveRDS(complaints, 'data/complaints.Rda')

## Read in other csv's
pops = read.csv("data/state_populations.csv", stringsAsFactors = F)
abbrevs = read.csv("data/states.csv", stringsAsFactors = F)
colnames(abbrevs) = c('region','abbreviation')

## Merge abbreviations with the 2016 population estimates
pops = inner_join(abbrevs, pops, by = c('region'='State.or.territory')) %>% 
  select(c(region,abbreviation,Population.estimate.2016.07.01))
pops = select(pops, -X)
pops = rename(pops, population_2016 = Population.estimate.2016.07.01)
rm(abbrevs)

## Write out this csv for later convenience
write.csv(pops,'data/us_populations.csv', row.names = F)

## Get frequency counts by state
#freq_by_state = complaints %>% group_by(State) %>% summarize(count = n())

## Merge freq_by_state with abbrevs to get the state names which serves as the bridge to merge with
## the SPDF
#freq_by_state = inner_join(freq_by_state, abbrevs, by = c('State' = 'abbreviation'))

## normalize the count by the 2016 population estimate
#get population dataset and clean it up a bit
# pops_plain = pops %>% select(State.or.territory, Population.estimate.2016.07.01)
# colnames(pops_plain) = c('region','population')

# join pops_plain with freq_by_state by region to add in the population data
#freq_by_state = merge(freq_by_state, pops_plain, by = 'region')

# Write out freq_by_state
#saveRDS(freq_by_state,'data/freq_by_state.Rda')

## mutate to get normalized count
freq_by_state = freq_by_state %>% mutate(norm_count = (count/population))

## Read in the SpatialPolygonsDataFrame
states = readOGR('data/gz_2010_us_040_00_20m.json')

## Merge in default information to this SPDF such as complaint counts and normalized complaint counts.

## merge in default data using special SPDF syntax to access the data frame '@data'
## For some reason I need to use inner_join or else the information ends up getting misaligned
#states@data = merge(states@data, freq_by_state, by.x = 'NAME', by.y = 'region')
states@data = inner_join(states@data, freq_by_state, by = c('NAME' = 'region'))

## Drop unneccesary columns and upper case all column names
states@data = states@data %>% select(-c(State))
colnames(states@data) = toupper(colnames(states@data))

## Write default SPDF out
writeOGR(states,'data/states.json','states.json',driver = 'GeoJSON')

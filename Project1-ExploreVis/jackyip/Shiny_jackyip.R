#
# ============================================================================
#                           Data Definitions
# ============================================================================
# id      = Unique identifier of a Service Request (SR) in the open data set
# dtopen  = Date SR was created
# dtclose = Date SR was closed by responding agency
# agency  = Acronym of responding City Government Agency
# type    = This is the first level of a hierarchy identifying the topic of 
#           the incident or condition. Complaint Type may have a corresponding 
#           Descriptor (not in scope for this analysis) or may stand alone.
# zip     = Incident location zip code, provided by geo validation.
# boro    = Provided by the submitter and confirmed by geovalidation.
# year    = Year extracted from dtopen
# ============================================================================


# ============================================================================
#                          R Libaries Required
# ============================================================================
library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(googleVis)
library(leaflet)
library(rgdal)
# ============================================================================


# ============================================================================
# Part 0: Loading the Dataset
# ============================================================================

# load specific columns from .csv
rawdata <- fread('311_Service_Requests_from_2010_to_Present.csv', 
                 select = c('Unique Key',
                            'Created Date',
                            'Closed Date',
                            'Agency',
                            'Complaint Type',
                            'Incident Zip',
                            'Borough'
                            ))
# simplify column names
colnames(rawdata) <- c('id',
                       'dtopen',
                       'dtclose',
                       'agency',
                       'type',
                       'zip',
                       'boro')

# explore data structure
str(rawdata)
# Classes ‘data.table’ and 'data.frame':	14977319 obs. of  7 variables:
# $ id     : int  28302469 28302546 28302470 28302472 28302473 28302474 28302475 28302478 28302479 28302480 ...
# $ dtopen : chr  "06/20/2014 09:19:26 AM" "06/20/2014 06:23:00 PM" "06/20/2014 11:22:00 AM" "06/20/2014 12:56:53 PM" ...
# $ dtclose: chr  "06/20/2014 05:55:34 PM" "06/20/2014 06:23:00 PM" "06/20/2014 12:25:00 PM" "06/20/2014 12:57:36 PM" ...
# $ agency : chr  "NYPD" "DSNY" "DEP" "HRA" ...
# $ type   : chr  "Derelict Vehicle" "Derelict Vehicles" "Sewer" "Benefit Card Replacement" ...
# $ zip    : chr  "11206" "10475" "11101" "" ...
# $ boro   : chr  "BROOKLYN" "BRONX" "QUEENS" "Unspecified" ...

# ============================================================================
# Part 1: Cleaning the Dataset
# ============================================================================

# explore NA and missing values
colSums(is.na(rawdata))
# id  dtopen dtclose  agency    type     zip    boro 
# 0       0       0       0       0     215       0 

# remove 215 observations where zip codes are missing
rawdata <- rawdata[!is.na(zip), ]

# when observing the list of complaint categories, the following issues have been identified:

# issue 1: complaint types with the same spellings are treated as separate rows due 
#          due to character case differences
# solution: convert 'type' column to lower case
rawdata$type <- tolower(rawdata$type)

# issue 2: there are overlapping categories and/or categories should be grouped
# solution: a) consolidate heat and water related categories to existing category 'heat/hot water'
#           b) consolidate 'general construction', 'construction', and 'plumbing' to 
#              existing category 'general construction/plubming'
#           c) consolidate all noise types to existing category 'noise'
#           d) consolidate traffic and road categories to existing category 'street/road condition'
#           e) consolidate 'blocked driveway' to existing category 'illegal parking'
#           f) consolidate sanitary related categories to existing category
#              'unsanitary condition'
#           g) consolidate 'paint - plaster' into existing category 'paint/plaster'
#           h) consolidate 'electrical' into existing category 'electric'
#           i) consolidate tree related categories to new category 'tree condition'
#           j) consolidate 'broken parking meter' into existing category 'broken muni meter'
#           k) consolidate 'indoor air quality' into existing category 'air quality'
#           l) consolidate 'derelict vehicles' into existing category 'derelict vehicle'
#           m) consolidate 'for hire vehicle complaint' into existing category 'taxi complaint'
rawdata <- rawdata %>% mutate(type = replace(type, type == 'heating' |
                                               type == 'heat/hot water' |
                                               type == 'non-residential heat' |
                                               type == 'water system' |
                                               type == 'water leak',
                                             'heat/water system'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'general construction' |
                                               type == 'plumbing' |
                                               type == 'construction',
                                             'general construction/plumbing'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'noise - residential' |
                                               type == 'noise - street/sidewalk' |
                                               type == 'noise - commercial' |
                                               type == 'noise - vehicle' |
                                               type == 'noise - park' |
                                               type == 'noise survey' |
                                               type == 'noise - house of worship' |
                                               type == 'noise - helicopter' |
                                               type == 'collection truck noise',
                                             'noise'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'street light condition' |
                                               type == 'street condition' |
                                               type == 'street sign - damaged' |
                                               type == 'street sign - missing' |
                                               type == 'street sign - dangling' |
                                               type == 'broken muni meter' |
                                               type == 'broken parking meter' |
                                               type == 'traffic signal condition' |
                                               type == 'traffic' |
                                               type == 'traffic/illegal parking' |
                                               type == 'highway condition',
                                             'street/traffic condition'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'blocked driveway',
                                             'illegal parking'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'sewer' |
                                               type == 'dirty conditions' |
                                               type == 'sanitary condition' |
                                               type == 'sanitation condition' |
                                               type == 'unsanitary animal pvt property' |
                                               type == 'unsanitary pigeon condition' |
                                               type == 'unsanitary animal facility',
                                             'unsanitary condition'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'paint - plaster',
                                             'paint/plaster'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'electrical',
                                             'electric'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'damaged tree' |
                                               type == 'new tree request' |
                                               type == 'overgrown tree/branches' |
                                               type == 'dead tree' |
                                               type == 'illegal tree damage' |
                                               type == 'dead/dying tree',
                                             'tree condition'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'broken muni meter',
                                             'broken parking meter'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'indoor air quality',
                                             'air quality'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'derelict vehicles',
                                             'derelict vehicle'))
rawdata <- rawdata %>% mutate(type = replace(type, type == 'for hire vehicle complaint',
                                             'taxi complaint'))

# issue 3: complaint categories are too vague
# solution: remove from dataset
rawdata <- rawdata[!rawdata$type == 'general', ]
rawdata <- rawdata[!rawdata$type == 'nonconst', ]

# ================================================================================================
# Part 2: How do noise complaint counts compare with those of other 311 complaints since 2010?
# ================================================================================================

# identify top 20 complaint category counts since 2010
top20 <- rawdata %>% 
  group_by(type) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count)) %>% 
  top_n(20)

# visualize top 20 complaint category counts since 2010
ggplot(top20, aes(x = reorder(type, count), y = count)) +
  geom_bar(stat='identity') +
  scale_y_continuous(labels=function(x) x/1000) +
  xlab('Complaint Category') +
  ylab('Count (in thousands)') +
  ggtitle('Top 311 Service Request (2010-Present)') +
  coord_flip()

# ==================================================================================
# Part 3: Based on the observations from the top 20 complaint category counts,
# it appears that the counts of noise and street/traffic condition complaints are 
# both significantly high. Let's see how they correlate with each other by plotting 
# them onto a line chart by year.
# ==================================================================================

# extract year and hour from 'dtopen' into new columns 'year' and 'hour'
rawdata$year <- strptime(rawdata$dtopen, format = "%m/%d/%Y %I:%M:%S %p")$year + 1900
rawdata$hour <- strptime(rawdata[, 'dtopen'], format = "%m/%d/%Y %I:%M:%S %p")$hour

# break down noise and street/traffic complaint category counts by year (excluding 2017)
noisetrafficbyyr <- rawdata %>%
  filter(type %in% c('noise', 'street/traffic condition')) %>% 
  filter(year != '2017') %>% 
  group_by(year, type) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

# create a scatter plot to compare yearly noise complaints and yearly 
# street/traffic condition complaints
ggplot(noisetrafficbyyr, aes(x = year, y = count, color = type)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

# ==================================================================================
# Part 4: From the noise & street/traffic scatterplot, it does not appear that 
# there is a strong correlation between them. Let's create a line chart for the top 10
# complaint counts and see if any of those complaint types share similar trends
# with noise complaints.
# ==================================================================================

# break down top 10 complaint category counts by year
top10byyr <- rawdata %>%
  filter(type %in% top20$type[1:10]) %>% 
  group_by(year, type) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

# format top10byyr into "spread' format for googleVis line chart
top10byyr_spread <- spread(top10byyr, type, count)

# convert year column from integer to character
top10byyr_spread$year <- as.character(top10byyr_spread$year)

# create gvisLineChart with customizations (note that an internet connection
# is required to view)
top10byyr_line <- gvisLineChart(top10byyr_spread,
                      options=list(width = 1400,
                                   height = 800,
                                   title = '311 Service Requests (2010-2016)',
                                   titleTextStyle = "{ color: 'black',
                                                       fontSize: '24',
                                                       bold: 'TRUE' }",
                                   hAxis = "{ title: 'Year',
                                              ticks: [2010, 2011, 2012, 2013, 2014, 2015, 2016],
                                              format: ''}",
                                   vAxis = "{ title: 'Count',
                                              format: 'short'}",
                                   pointSize = '10',
                                   series="{
                                   0: { pointShape: 'circle' },
                                   1: { pointShape: 'triangle' },
                                   2: { pointShape: 'square' },
                                   3: { pointShape: 'diamond' },
                                   4: { pointShape: 'star' },
                                   5: { pointShape: 'polygon' },
                                   6: { pointShape: 'circle' },
                                   7: { pointShape: 'triangle' },
                                   8: { pointShape: 'square' },
                                   9: { pointShape: 'diamond' },
                                  10: { pointShape: 'star' }
                                   }"))

# show line chart
plot(top10byyr_line)

# by observation, there appears to be a correlation between the levels of noise
# complaints and the levels of illegal street parking. Let's draw their complaint
# counts against a scatterplot to examine their correlation.

# break down noise and street/traffic complaint category counts by year (excluding 2017)
noiseillegalparkbyyr <- rawdata %>%
  filter(type %in% c('noise', 'illegal parking')) %>% 
  filter(year != '2017') %>% 
  group_by(year, type) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))
  
# create a line chart to compare yearly noise complaints and yearly 
# illegal parking condition complaints
ggplot(noiseillegalparkbyyr, aes(x = year, y = count, color = type)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

# ===========================================================================
# Part 5: To dive deeper into this hypothesis, let's create a heat map for 
# these two complaint types, and see if these two complaint categories are 
# concentrated in the same areas on a map.
# ===========================================================================

# determine distinct zip codes and counts for noise and illegal parking complaints
noisyparkingzip <- rawdata %>% 
  filter(type %in% c('noise', 'illegal parking')) %>% 
  group_by(zip, type) %>% 
  summarize(count = n()) %>% 
  arrange(-count)

# remove from noisyparkingzip the two observations where zipcodes are empty
noisyparkingzip <- noisyparkingzip[noisyparkingzip$zip != '', ]

# we observe that the noisyparkingzip table contains 227 distinct zip codes
length(unique(noisyparkingzip$zip)) # returns 227

# to prepare zip code polygons on the map, we load US Census shape file from
# https://www.census.gov/geo/maps-data/data/cbf/cbf_zcta.html (2016)
rawzipshape <-readOGR(dsn = "cb_2016_us_zcta510_500k", layer="cb_2016_us_zcta510_500k")

# confirm that the 227 distinct zip codes are found in the US Census shape file
censuszip <- data.frame(as.character(rawzipshape$ZCTA5CE10))
colnames(censuszip) = 'zip'
nomatchzips <- anti_join(noisyparkingzip, censuszip, by = 'zip')

# We see that a number of zip codes are not found in the US Census shape file dataset,
# of which all but one (zip code 11249) has significant number of complaints associated 
# with it (i.e. 11,038 noise & 3,323 illegal parking). A web search on this zip codes 
# shows the area covering west Willamsburg up to the East River. When attempting to plot
# the other zip codes onto the Leaflet, we see that zip code 11211 covers the
# area aforementioned. With this assumption, we add the counts for zip code 11249
# to zip code 11211. As a note, all of the other nonmatching zipcodes represented counts
# that ranges from 1 to ~350, which is insignificant for the purpose of this analysis.
noisyparkingzip[noisyparkingzip$zip == '11211' & noisyparkingzip$type == 'noise', 'count'] =
  noisyparkingzip[noisyparkingzip$zip == '11211' & noisyparkingzip$type == 'noise', 'count'] + 11038
noisyparkingzip[noisyparkingzip$zip == '11211' & noisyparkingzip$type == 'illegal parking', 'count'] =
  noisyparkingzip[noisyparkingzip$zip == '11211' & noisyparkingzip$type == 'illegal parking', 'count'] + 3323

# After adjusting for the counts associated with zip code 11249, we remove the nonmatching
# zipcodes from the noisyparkingzip table.
noisyparkingzip <- noisyparkingzip[!noisyparkingzip$zip %in% nomatchzips$zip, ]

# we are left with 205 unique zip codes in our dataset
length(unique(noisyparkingzip$zip))

# subset the US Census shape file based on the 205 unique zip codes
zipshapefile <- rawzipshape[rawzipshape$GEOID10 %in% noisyparkingzip$zip, ]

# add neighborhood names to noisyparkingzip (we joined neighborhood names from
# https://www.health.ny.gov/statistics/cancer/registry/appendix/neighborhoods.htm)
neighborhoods <- read.csv('zipcityname.csv', colClasses = 'character')
neighborhoods <- gather(neighborhoods, key="Neighborhood", value="zip", 2:10)
neighborhoods <- neighborhoods[, -2]
noisyparkingzip <- left_join(noisyparkingzip, neighborhoods, by = 'zip')
noisyparkingzip$Neighborhood[is.na(noisyparkingzip$Neighborhood)] <- 'Unknown'

# remove US Census shape file from global (large file), censuszip (no longer needed),
# nomatchzips, and neighborhoods
rm(rawzipshape)
rm(censuszip)
rm(nomatchzips)
rm(neighborhoods)

# 'spread' noisyparkingzip to prepare it for leaflet
noisyparkingzip <- spread(noisyparkingzip, key = type, value = count)

# after spreading the dataset, we need to replace NA's with 0's to prepare for leaflet coloring
noisyparkingzip$`illegal parking`[is.na(noisyparkingzip$`illegal parking`)] <- 0
noisyparkingzip$noise[is.na(noisyparkingzip$noise)] <- 0

# reorder noisyparkingzip to match zipcode order in the shape file
noisyparkingzip <- noisyparkingzip[match(zipshapefile$ZCTA5CE10, noisyparkingzip$zip), ]

# prepare color palettes for leaflet map
pal_noise <- colorNumeric(
  palette = "Blues",
  domain = noisyparkingzip$noise)

pal_parking <- colorNumeric(
  palette = "Reds",
  domain = noisyparkingzip$noise)

# create leaflet noise
noise_leaflet <- leaflet(zipshapefile) %>% 
  addTiles() %>% 
  addPolygons(color = "#444444",
              fillColor = pal_noise(noisyparkingzip$noise),
              weight = 1.0,
              fillOpacity = 1.0,
              label = paste('City:', as.character(noisyparkingzip$Neighborhood), ', ',
                           'Noise Count:', as.character(noisyparkingzip$noise)),
              highlightOptions = highlightOptions(
                weight = 3,
                color = "red",
                fillOpacity = 1.0),
              group = 'Noise Complaints') %>% 
  addPolygons(color = "#444444",
              fillColor = pal_parking(noisyparkingzip$`illegal parking`),
              weight = 1.0,
              fillOpacity = 1.0,
              label = paste('City:', as.character(noisyparkingzip$Neighborhood), ', ',
                            'Noise Count:', as.character(noisyparkingzip$`illegal parking`)),
              highlightOptions = highlightOptions(
                weight = 3,
                color = "red",
                fillOpacity = 1.0),
              group = 'Illegal Parking Complaints') %>% 
  addPolygons(group = 'None',
              stroke = FALSE,
              fillOpacity = 0) %>% 
  addLayersControl(
    baseGroups = c('Noise Complaints', 'Illegal Parking Complaints', 'None'),
    options = layersControlOptions(collapsed = FALSE)
  )

# show leaflet (note that an internet connection is necessary to view map)
noise_leaflet

# from observing the heat maps for noise and illegal parking complaints, it appears that
# there isn't an apparent relationship between the areas where these two types of complaints
# occured. Specifically, for example, in Manhattan, there are various levels of
# noise complaints throughout the neighborhoods, but low levels of illegal parking complaints
# thoroughout. The same observation can be made for Central Brooklyn/Williamsburg/Greenpoint.
# We will further examine this relationship on a scatterplot in the next part.

# ===========================================================================
# Part 6: In part 5, we made the hypothesis that noise complaint counts are
# not correlated with illegal parking complaint counts. In this part, we will
# create a scatterplot to examine their relationship more closely.
# ===========================================================================

ggplot(noisyparkingzip, aes(x = `illegal parking`, y = noise)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)

cor.test(x = noisyparkingzip$`illegal parking`, 
         y = noisyparkingzip$noise, 
         alternative = 'two.sided')

## Pearson's product-moment correlation
## 
## data:  noisyparkingzip$`illegal parking` and noisyparkingzip$noise
## t = 5.6486, df = 203, p-value = 5.414e-08
## alternative hypothesis: true correlation is not equal to 0
## 95 percent confidence interval:
##  0.2438277 0.4812770
## sample estimates:
##       cor 
## 0.3685484

## Based on the correlation analysis above, there is a small correlation
## (i.e. cor = 0.3685) between noise and illegal parking complaints. From
## the scatter plot, there seems to be two groups of observations at hand,
## the areas where noise and illegal parking complaints tend to follow closely
## at the linear regression, and the other areas where noise levels are 
## significantly higher as a function of illegal parking. To further understand
## the drivers between these two groups, additional analysis will need to be done
## to reason other factors contributing to the behaviors of these two groups.

# ===========================================================================
# Part 7: Noise Complaints By Hour of Day
# ===========================================================================

rawdata$hour <- strptime(rawdata[, 'dtopen'], format = "%m/%d/%Y %I:%M:%S %p")$hour

noisebyhour <- rawdata %>%
  filter(type %in% c('noise')) %>% 
  filter(zip %in% noisyparkingzip$zip) %>% 
  group_by(zip, hour) %>% 
  summarize(count = n()) %>% 
  arrange(desc(count))

length(unique(noisebyhour$zip)) 
noisebyhour <- spread(noisebyhour, key = hour, value = count)

test <- right_join(noisebyhour, noisyparkingzip, by = 'zip')
test[, c('illegal parking', 'noise')] = NULL
colnames(test)
test <- test[, c(1, 26, 2:25)]
test[is.na(test)] <- 0
test <- test[match(zipshapefile$ZCTA5CE10, test$zip), ]

noisebyhour <- test
rm(test)

# ===========================================================================
# Part 8: Noise Hour of Day Line Graph
# ===========================================================================

skinnynoisebyhour <- as.data.frame(colSums(noisebyhour[ ,3:26]))
skinnynoisebyhour[,2] = c(0:23)
skinnynoisebyhour = skinnynoisebyhour[, c(2, 1)]
colnames(skinnynoisebyhour) <- c('hour', 'count')

ggplot(data = skinnynoisebyhour,aes(x = hour)) + geom_bar(aes(fill = count))
ggplot(skinnynoisebyhour, aes(x = hour)) + 
  geom_line(aes(y = count)) +
  scale_x_continuous(breaks = 0:23) +
  ggtitle("Noise Complaint by Hour of Day (2010 to Present)")
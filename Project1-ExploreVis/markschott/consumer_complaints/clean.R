require(dplyr)
require(ggplot2)
require(leaflet)
require(maps)
require(shiny)
require(jsonlite)
require(zipcode)

READIN = T

### Clean data and read in if haven't done already

if (READIN) {
    data = read.csv("data/Consumer_Complaints.csv", stringsAsFactors = F)
    data$ZIP.code = as.character(data$ZIP.code)
    data(zipcode)
    data = inner_join(data, zipcode, by = c('ZIP.code' = 'zip'))
    ### Now drop the ZIP.code and Tags columns
    data = data %>% select(-c(Tags,ZIP.code,Consumer.consent.provided.))
    
    
    pops = read.csv("data/state_populations.csv", stringsAsFactors = F)
    abbrevs = read.csv("data/states.csv", stringsAsFactors = F)
    colnames(abbrevs) = c('region','abbreviation')
    #abbrevs$region = tolower(abbrevs$region)
    zip2fps = fromJSON("zip2fips/zip2fips.json")
    
    class(data$Date.received)
    ## convert Date.received and Date.sent.to.company from factors/characters to date
    ## Dates are in %m/%d/%Y format
    data$Date.received = as.Date(data$Date.received, format = '%m/%d/%Y')
    data$Date.sent.to.company = as.Date(data$Date.sent.to.company, format = '%m/%d/%Y')
}

# It looks like Sub.issue, Consumer.complaint.narrative, and Company.public.response may all be empty columns
unique(data$Sub.issue) #not empty, 69 unique values
unique(data$Consumer.complaint.narrative) #not empty, 1000 unique values
unique(data$Company.public.response) #not empty, 11 unique values

## Tags is very sparse, how many values does it have filled in?
sum(data$Tags != '')
unique(data$Tags)
# 3 whole values! Will probably drop this column

# Consumer.consent.provided. also looks sparse
unique(data$Consumer.consent.provided)

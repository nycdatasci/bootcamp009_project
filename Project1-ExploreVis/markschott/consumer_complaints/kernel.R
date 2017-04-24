library(ggplot2)
library(dplyr)

data = readRDS('data/complaints.Rda')
## Read in other csv's
pops = read.csv("data/state_populations.csv", stringsAsFactors = F)
abbrevs = read.csv("data/states.csv", stringsAsFactors = F)
colnames(abbrevs) = c('region','abbreviation')
### Look by company the frequency of complaints (normalize by market cap?)
### Nice shiny visualization to be able to select the company
data %>% group_by(Company) %>% summarize(count = n()) %>% arrange(desc(count)) %>%
  top_n(20)

## Note: It would be nice to see the market cap for each of these companies

#########################
### Analyze frequency of complaints by state

# get count by state and then add column of verbose state
freq_by_state = data %>% group_by(State) %>% summarize(count = n()) %>% arrange(desc(count))
freq_by_state = inner_join(freq_by_state, abbrevs, by = c('State' = 'abbreviation'))

### normalize the count by the 2016 population estimate

# get population dataset and clean it up a bit
pops_plain = pops %>% select(State.or.territory, Population.estimate.2016.07.01)
pops_plain$State.or.territory = tolower(pops_plain$State.or.territory)
colnames(pops_plain) = c('region','population')

# join pops_plain with freq_by_state by region to add in the population data
freq_by_state = merge(freq_by_state, pops_plain, by = 'region')

# now mutate to add the normalized_count
freq_by_state = freq_by_state %>% mutate(count_normed = (count/population))

# now visualize (first the overall, then the normed)
states <- map_data("state")
tfmerged <- merge(states, freq_by_state, sort = FALSE, by = "region")
tfmerged <- tfmerged[order(tfmerged$order), ]
# overall
qplot(long, lat, data = tfmerged, group = group, fill = count,
      geom="polygon")
# normalized
qplot(long, lat, data = tfmerged, group = group, fill = count_normed,
      geom="polygon")

### Look at the states and zip code frequency of complaints (normalize by population? or atleast compare with population rank)
### I NEED A NICE WAY TO VISUALIZE THIS!!!!

######################################################################
#######################################3
#Analyze zip codes
# Lots of zipcodes end in XX or HH which indicates uncertainty in the specific zip code.
# The problem is that these seem to make up a lot of the dataset but just how much?
### plyr can't be loaded for this
# data$ZIP.code = as.numeric(data$ZIP.code)
# zipcodes = data %>% group_by(ZIP.code) %>% summarize(count = n()) %>% arrange(desc(count))  ### Why are there XX at the end of zip code?
# NA_zips = (zipcodes %>% filter(is.na(ZIP.code)))$count
# other_zips = sum((zipcodes %>% filter(!is.na(ZIP.code)))$count)
# NA_zips / (NA_zips + other_zips) # 22.5% of the dataset!
# ## 77.5% of the data is enough for me to plot it (... if I had my druthers .....)
# ## remove those NA's from the dataset
# data_cleanzips = data %>% filter(!is.na(ZIP.code))
# #join with zipcode dataset from library(zipcode)
# data_cleanzips$ZIP.code = as.character(data_cleanzips$ZIP.code)
# data_cleanzips = inner_join(data_cleanzips, zipcode, by = c('ZIP.code' = 'zip'))
# # Now need to map zipcodes to fips numbers with my json table from https://github.com/bgruber/zip2fips.git
# # I'll create a function to do this (takes so long to run)
# 
# zips2fips_funk = function(zips) {
#     fips = c(logical(length(zips)))
#     for (i in 1:length(zips)) {
#         fip = zip2fps[[zips[i]]]
#         if (!is.null(fip)) {
#             fips[i] = zip2fps[[zips[i]]]
#         }
#     }
#     fips
# }

######################################################################################

####I'll just create a heat map based on latitude longitude

#### OK now plot the mothafucka

#####

unique(data$Product) # 12 different values
unique(data$Sub.product)

### Look at the counts by product
prod_counts = data %>% group_by(Product, Sub.product) %>% summarize(count = n())
ggplot(prod_counts, aes(x=reorder(Product,count), y = count)) + geom_bar(stat = 'identity') + 
    theme(axis.text.x = element_text(angle = 90))

### Look at top counts and look at top sub products
ggplot(prod_counts, aes(x=reorder(Product,count), y = count)) + geom_bar(stat = 'identity', 
                                                                         aes(fill = Sub.product)) + 
    theme(axis.text.x = element_text(angle = 90))

### Look at counts by issue / sub issue
issue_counts = data %>% group_by(Issue,Sub.issue) %>% summarize(count = n()) %>% arrange(desc(count)) %>% top_n(5,count)
ggplot(issue_counts, aes(x=reorder(Issue,count), y = count)) + geom_bar(stat = 'identity') + 
    theme(axis.text.x = element_text(angle = 90))
ggplot(issue_counts, aes(x=reorder(Issue,count), y = count)) + geom_bar(stat = 'identity', 
                                                                       aes(fill = Sub.issue)) + 
    theme(axis.text.x = element_text(angle = 90))

### Look at counts of submitted via
submitted_counts = data %>% group_by(Submitted.via) %>% summarize(count = n()) %>% arrange(desc(count))
ggplot(submitted_counts, aes(x=Submitted.via, y= count)) + geom_bar(stat='identity')

### Look at company (would be awesome to normalize this by market cap)
company_counts = data %>% group_by(Company) %>% summarize(count = n()) %>% arrange(desc(count)) %>% top_n(20)
ggplot(company_counts, aes(x=reorder(Company,count), y= count)) + geom_bar(stat='identity', 
                                                            aes(fill = Company)) + 
    theme(axis.text.x = element_text(angle = 90))

## counts for Company.response.to.consumer
response_counts = data %>% group_by(Company.response.to.consumer) %>% summarize(count = n()) %>% arrange(desc(count))
ggplot(response_counts, aes(x=reorder(Company.response.to.consumer,count), y= count)) + geom_bar(stat='identity', 
                                                                           aes(fill = Company.response.to.consumer)) + 
    theme(axis.text.x = element_text(angle = 90))

## counts for Company.public.response

### How many are there?
unique(data$Company.public.response)
public_counts = data %>% group_by(Company.public.response) %>% summarize(count = n()) %>% arrange(desc(count))
ggplot(public_counts, aes(x=reorder(Company.public.response,count), y= count)) + geom_bar(stat='identity', 
                                                                                                 aes(fill = Company.public.response)) + 
    theme(axis.text.x = element_text(angle = 90))


### Mosaic plots
test = complaints %>% select(State, Consumer.disputed.,Submitted.via) %>% 
  filter((State %in% c('CA', 'NY', 'MI', 'FL', 'GA', 'DC', 'AL','CT')))
mosaicplot(table(test), shade=T, las = 2)

## gets busy quick. How many can I fit?
test = complaints %>% select(State, Consumer.disputed.) 
mosaicplot(table(test), shade=T, las = 2)

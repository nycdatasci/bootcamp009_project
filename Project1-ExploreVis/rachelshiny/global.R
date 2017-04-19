# convert matrix to dataframe
data <- read.csv('~/data10.csv')
# remove row names

# create variable with colnames as choice
choice <- c('4 year', 'less than 4 year')


#states

state_vector <- c('all', sort(as.character(unique(data$STATE))))

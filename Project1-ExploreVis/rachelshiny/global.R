# convert matrix to dataframe


data <- readRDS("data.Rds")

# remove row names

# create variable with colnames as choice
choice <- c('4 year', 'less than 4 year')

highest_degree <- c('All', 'Non-degree-granting', 'Certificate', 'Associate', 'Bachelors', 'Graduate')
highest_degree <- list('All'='.', 'Certificate'='1', 'Associate'='2', 'Bachelors'='3', 'Graduate'='4')


#states

state_vector <- c('all', sort(as.character(unique(data$STABBR))))
state_vector <- state_vector[!state_vector %in% c('HI', 'AK')]


region_vector <- c('all', as.character(unique(data$REGION_2)))

#scatter
y_vars <- c('MN_EARN_WNE_P7', 'GT_25K_P7', 'C150_4', 'C150_L4')
x_vars <- c('stem_pct', 'ADM_RATE', 'FAMINC', 'UGDS')
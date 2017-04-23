# convert matrix to dataframe
library(ggvis)

data <- readRDS("~/Student_Loans/data.Rds")

# remove row names

# create variable with colnames as choice
choice <- c('4 year', 'less than 4 year')

highest_degree <- c('All', 'Non-degree-granting', 'Certificate', 'Associate', 'Bachelors', 'Graduate')
highest_degree <- list('All'='.', 'Certificate'='1', 'Associate'='2', 'Bachelors'='3', 'Graduate'='4')

filts <- list('None'='.', 'Historically Black Colleges'='black', 'Women Only'='women',
              'Nursing Schools'='nurses', 'Technical Schools'='tech', 'Highest degree offered' = 'HIGHDEG')

#states

state_vector <- c('all', sort(as.character(unique(data$STABBR))))
state_vector <- state_vector[!state_vector %in% c('HI', 'AK')]


region_vector <- c('all', as.character(unique(data$REGION_2)))

#scatter
y_vars <- c('MN_EARN_WNE_P7', 'GT_25K_P7', 'C150_4', 'C150_L4')
x_vars <- c('stem_pct', 'ADM_RATE', 'FAMINC', 'UGDS', 'PCTPELL', 'INEXPFTE', 'TUITFTE')

data$nurses <- grepl(pattern='Nurs', x=data$INSTNM)
data$tech <- grepl(pattern='Tech', x=data$INSTNM)
data$women <- ifelse(data$WOMENONLY==1, TRUE, FALSE)
data$women <- ifelse(is.na(data$women), FALSE, data$women)


library(dplyr)
library(ggplot2)
library(gridExtra)
library(plotly)

Budget_df = read.csv('Budget.csv', stringsAsFactors = FALSE, encoding = 'latin1')
Int_df = read.csv('Int_Data.csv', stringsAsFactors = FALSE, encoding = 'latin1')

Budget_df$Title <- tolower(Budget_df$Title)
Int_df$Title <- tolower(Int_df$Title)

Int_df <- mutate(Int_df, Title = gsub(pattern = " :", replacement = ":",Title))
Int_df <- mutate(Int_df, Title = gsub(pattern = "&", replacement = "and",Title))
Budget_df <- mutate(Budget_df, Title = gsub(pattern = "&", replacement = "and",Title))
Int_df$Gross.As.Of. <- as.Date(Int_df$Gross.As.Of., format = '%m/%d/%y')


Movie = left_join(Int_df,Budget_df,by='Title')
Movie = mutate(Movie, Ratio = ifelse(F.D >= 0, 'For', 'Dom'))

Movie_Name = na.omit(Movie)
Movie_Name = Movie_Name %>% select(Ratio, Title, International, Domestic.x, Worldwide.x, 
                                   Gross.As.Of., X..Foreign, X..Domestic, F.D, Budget)
Movie_Name = Movie_Name %>% dplyr::rename(Foreign = International, Domestic = Domestic.x, 
                                          Worldwide = Worldwide.x, Date = Gross.As.Of., 
                                          Foreign_Per = X..Foreign, Domestic_Per = X..Domestic)
Movie_Name <- mutate(Movie_Name, Budget_Bins = ifelse(Movie_Name$Budget < 35, 'Small Budget', 
                                                      ifelse(Movie_Name$Budget > 90, 'Large Budget', 'Medium Budget' )))
Movie_Name <- mutate(Movie_Name, Profit = Worldwide - Budget)
Movie_Name <- mutate(Movie_Name, Worldwide_Bins = ifelse(Movie_Name$Worldwide < 131.4, 'Small Worldwide', 
                                                         ifelse(Movie_Name$Worldwide > 332.5, 'Large Worldwide', 'Medium Worldwide')))
Movie_Name <- mutate(Movie_Name, Date_Bins = ifelse(Movie_Name$Date < '2005-01-01', 'Pre-2005', 'Post-2005'))
Movie_Name <- mutate(Movie_Name, ROI = Profit/Budget)
Movie_Name <- mutate(Movie_Name, Profit_Bins = ifelse(Profit < 78.38, 'Small Profit', 
                                                      ifelse(Profit > 245.9, 'Large Profit', 'Medium Profit')))
library(plyr)
library(dplyr)
library(ggplot2)
library(data.table)
library(googleVis)
library(shiny)
library(shinydashboard)
sharks = fread(file = '~/attacks.csv')

start_year= 1900
end_year = 2017

shark.df = sharks %>%
  filter(Year>= start_year & Year < end_year) %>% 
  select(Date,Year,Type,Country,Location,Activity,Sex,Age,`Fatal (Y/N)`)

Country_attacks = shark.df %>% 
  group_by(Country) %>% 
  arrange(desc(Country)) %>% 
  summarise(Number_of_Attacks=n()) %>% 
  arrange(desc(Number_of_Attacks))
Country_attacks[1,1]="UNITED STATES"

all_year = shark.df %>%
  group_by(Year) %>% 
  summarise('num_Attacks'= n())

all_fatal = shark.df %>% 
  group_by(Year) %>% 
  filter(`Fatal (Y/N)` == 'Y') %>% 
  summarise('num_Attacks'=n())

all_nonfatal = shark.df %>% 
  group_by(Year) %>% 
  filter(`Fatal (Y/N)` == 'N') %>% 
  summarise('num_Attacks'=n())


map_attacks = shark.df %>% 
  select(Year, Country) %>% 
  group_by(Country, Year) %>%
  arrange(desc(Year)) %>% 
  summarise(Yearly_attacks=n())

choices = c("All Attacks", "Fatal Attacks", 'Non-Fatal Attacks')

choices2 = as.numeric(c(1900:2016))


us_attacks = shark.df %>% 
  select(Country, Year, Activity) %>% 
  filter (Country == 'USA') %>% 
  group_by(Activity) %>% 
  summarise(Attacked_activity = n()) %>% 
  arrange(desc(Attacked_activity)) %>% 
  top_n(Attacked_activity, n= 10)
us_attacks[3,1]="Activity Not reported"

choices1 = us_attacks[ ,1]



Country_attacks1 = shark.df %>% 
  group_by(Country) %>% 
  arrange(desc(Country)) %>% 
  summarise(Number_of_Attacks=n()) %>% 
  arrange(desc(Number_of_Attacks)) %>% 
  summarise('top_10' = n())
Country_attacks[1,1]="UNITED STATES"


 type_attack = shark.df %>% 
   group_by(Type) %>% 
   summarise('count'= n())
 
 act = shark.df %>% 
   select(Country, Year, Activity) %>% 
   group_by(Activity) %>% 
   summarise(Attacked_activity = n()) %>% 
   arrange(desc(Attacked_activity)) %>% 
   top_n(Attacked_activity, n= 10)
 act[3,1] = "Activity Not Reported"
 

  

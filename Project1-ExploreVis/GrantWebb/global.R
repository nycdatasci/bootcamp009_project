library(dplyr)
library(leaflet)
library(lazyeval)
library(ggplot2)
library(ggvis)


load(file = "data/finalmeetups.Rda")
city_choice <- unique(x = finalmeetups$city)
city_choice1 <- unique(x = finalmeetups$city)

choice <- c("Upcoming Meeting Price" = "upcoming_meeting_price","Group Reviews" ="group_reviews","Group Members" = "group_members",
            "Upcoming Meetings"="upcoming_meetings","Past Meetings"="past_meetings","Upcoming Meeting RSVP"="upcoming_meeting_rsvp",
            "Length of Group Descript"="len_group_descript")
#choice <- colnames(finalmeetups)
cat_choice <- unique(x = finalmeetups$category)
cat_choice <- c("All", cat_choice)
axis_vars <- c(
  "Tomato Meter" = "Meter",
  "Numeric Rating" = "Rating",
  "Number of reviews" = "Reviews",
  "Dollars at box office" = "BoxOffice",
  "Year" = "Year",
  "Length (minutes)" = "Runtime"
)

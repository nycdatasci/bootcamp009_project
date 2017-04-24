library(shiny)
library(leaflet)
library(dplyr)
library(shinydashboard)
library(googleVis)
library(datasets)
library(leaflet)
library(dplyr)
library(shinythemes)
library(ggplot2)
library(ggthemes)
library(dygraphs)
library(xts)
library(RColorBrewer)
###############################  data cleaning ###############################

# data cleaning  table1 f : film location(data from nyc open data gov website), 
#                table2 f2 : IMDB 5000(data from kaggle)

# #remove columns that we are not going to use from film f and make the imdblink column the same as film table 2
# f$link = sapply(f$Director.Filmmaker.IMDB.Link,function(x){paste(x,'?ref_=fn_tt_tt_1',sep="")})
# gsub("www.", "", "http://www.imdb.com/title/tt0499549/?ref_=fn_tt_tt_1")
# f2 <- f2 %>% mutate(link = gsub("www.", "", link))

#read table 2
# f2 = read.csv(file='movie_metadata.csv', header = TRUE, stringsAsFactors = FALSE)


# #join the two tables together:
#
# f_loc = merge(x = f, y = f2, by = "link", all.x = TRUE)
#subtract the columns Film name and turn it into another table f
#split the film names data string:
#f = cSplit(f, "Film", " ", "long")
#count the words
#f = f%>%group_by(Film)%>%tally(sort=TRUE)
#write it into another csv file for later wordcount use
#the most frequent words are the and of, I removed them because they do not serve the theme purpose

#read the movie location table
f_loc = read.csv(file='./f_loc.csv', header = TRUE, stringsAsFactors = FALSE)

#read the names table for the word count feature
movie_names = read.csv(file='./f.csv', header = TRUE, stringsAsFactors = FALSE)
movie_names$X = NULL



#map table 
map <- f_loc %>%
  select(
    Film = Film,
    Year = Year,
    Director = Director.Filmmaker.Name,
    longtitude = LONGITUDE,
    latitude= LATITUDE,
    Borough = Borough,
    Budget = budget,
    Gross = gross,
    Score = imdb_score,
    Genres = genres,
    Images = image
  )

# movie table 
movie_t <- f_loc %>%
    select(
        Film = Film,
        Year = Year,
        Director = Director.Filmmaker.Name,
        Budget = budget,
        Gross = gross,
        Score = imdb_score,
        Genres = genres
    )



#change all the columns into characters in order for searching purpose
#used the iconv() function
movie_t[,sapply(movie_t,is.character)] <- sapply(
    map[,sapply(movie_t,is.character)],
         iconv,"WINDOWS-1252","UTF-8")


# Genres list for the map 

Genres<-c(
    "Action"= "Action",
    "Adventure"="Adventure",
    "Biography"="Biography",
    "Comedy"="Comedy",
    "Crime"="Crime",       
    "Documentary"="Documentary",
    "Drama"="Drama",
    "Horror"="Horror",
    "Romance" ="Romance",
    "Sci-Fi" ="Sci-Fi"
)

#change the color of the map by genres
pal = colorFactor(
    palette = 'Set1',
    domain = c("Romance","Adventure","Biography","Comedy","Crime",      
                                                   "Documentary","Drama","Horror","Action","Sci-Fi")
)

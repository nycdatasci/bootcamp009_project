x<-read.csv("IMDB_genre.csv")
unique(x$year)
summary(aov(x$ROI ~ x$genre))
summary(aov(chickwts$weight ~ chickwts$feed))

####################Wordcloud of part of the twitter#######################

library(dplyr)
library(tidyr)
library(wordcloud2) 
library(SnowballC)
library(tm)
twitDB_partial <- read.csv("~/twitDB_partial.csv", header=FALSE, comment.char="#")
twit_par <- separate(twitDB_partial, "V4", into=c("delete","test"), sep=":")
t <- Corpus(VectorSource(twit_par$test))
# #inspect(text)
t <- tm_map(t, removePunctuation)
t <- tm_map(t, PlainTextDocument)
t <- tm_map(t, stemDocument)
t <- tm_map(t, removeNumbers)
t<- tm_map(t, content_transformer(tolower))
t <- tm_map(t,removeWords, stopwords("en"))
t <- tm_map(t,removeWords, c("https", "blockchain","cryptocurr","ethereum","bitcoin","price","btc",
                             "eth","fals","usd","like","survivor","trump","shakira","parishilton","gossip","scandal",
                             "news", "hot","summer", "paparazzi"))

tdm<-TermDocumentMatrix(t)
m<-as.matrix(tdm)
v<-sort(rowSums(m),decreasing = TRUE)
Docs2<-data.frame(word=names(v),freq =v)
head(Docs2)
wordcloud2(Docs2, color = "random-dark",size = 0.8, shape = "circle", backgroundColor = "white") 



#################################### Case studies##########################

#Play with different coins
# EUR:Almost the same pattern
plot(coin$USDEUR)
lines(coin$btc_USDEUR, col='red')

#btc above the real exchange all the time!
plot(coin$USDGBP)
lines(coin$btc_USDGBP, col='blue')

#Totally nuts.....But we found arbitrage opportunity!
plot(coin$USDCNY)
lines(coin$btc_USDCNY, col='green')

# Not much going on, but SLL is one of the currencies that has been traded very early (2011).
plot(coin$USDSLL)
lines(coin$btc_USDSLL, col='green')

plot(coin$VTWSX)

# GBP case study. Find out more from macro datas
IMF <- read.csv("~/Desktop/bccp/IFS_06-07-2017 10-01-45-19_timeSeries.csv")
library(dplyr)
dim(IMF)
View(IMF)

uk = filter(IMF, Country.Code == '112')
dim(uk)
View(uk)
uk = uk[!complete.cases(uk),]


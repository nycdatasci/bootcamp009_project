
# Install
install.packages("tm")  # for text mining
install.packages("SnowballC") # for text stemming
install.packages("wordcloud") # word-cloud generator 
install.packages("RColorBrewer") # color palettes

# Load
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")


#load the text for each of Michelin Ratings
text <- readLines(file.choose("review_clean.txt"))
text1 <- readLines(file.choose("review1_clean.txt"))
text2 <- readLines(file.choose("review2_clean.txt"))
text_bib <- readLines(file.choose("review_bib.txt"))


# Load the data as a corpus
docs <- Corpus(VectorSource(text))

#Text transformation
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")


# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))
# Remove your own stop word
# specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, c("restaurant", "cuisine","chef",
	"dishes","dining","yet","one","can","food",
	"chefs","menu","will","may","every","place",
	"also","black","dish","even","cooking","two",
	"meal","kitchen","produce","little","like")) 

# Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)
# Text stemming
# docs <- tm_map(docs, stemDocument)

#Build a term-document matrix

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
head(d, 10)

#Generate the Word cloud
set.seed(1234)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))


#Explore frequent terms and their associations
findFreqTerms(dtm, lowfreq = 4)

#words are associated with “restaurant”
findAssocs(dtm, terms = "restaurant", corlimit = 0.3)

#The frequency table of words
head(d, 10)

#Plot word frequencies
barplot(d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word,
        col ="lightblue", main ="Most frequent words",
        ylab = "Word frequencies")





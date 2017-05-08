library(tm)
library(wordcloud)
library(SnowballC)
library(ggplot2)
library(ggthemes)
library(stringr)
library(jsonlite)
library(readr)
library(dplyr)
library(tidytext)

setwd('/Users/clairevignon/DataScience/NYC_DSA/project2_webscraping/bestreads') # to be changed if needed
bestreads = read.csv("bestreads.csv", header = TRUE)

# 1- DATA CLEANING
# get unique observations
bestreads = unique(bestreads)

# remove commas in total score and turn into numeric
bestreads$TotalScore = as.integer(gsub(",", "", as.character(bestreads$TotalScore)))

# remove word pages in NumberOfPages column
bestreads$NumberOfPages = gsub('(\\d*)\\s*pages', '\\1', bestreads$NumberOfPages, perl=T)

# remove any punctuation in reviews except exclamation marks
bestreads$Reviews = gsub("[^\\w!]", " ", bestreads$Reviews, perl = TRUE)
# bestreads$Reviews = tolower(bestreads$Reviews)

# remove any word that doesn't matter in reviews (e.g. I, and, the etc)
corpus = Corpus(VectorSource(bestreads$Reviews))
corpus = tm_map(corpus, tolower)
corpus = tm_map(corpus, stripWhitespace)
corpus = tm_map(corpus,removeNumbers)
corpus = tm_map(corpus, removeWords, stopwords("english"))
corpus = tm_map(corpus, removeWords, "<U+0096>")
corpus = tm_map(corpus, PlainTextDocument)
corpus = tm_map(corpus, stemDocument, "english")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "don t", replacement = "")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "doesn t", replacement = "")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "didn t", replacement = "")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "isn t", replacement = "")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "hasn t", replacement = "")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "haven t", replacement = "")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "isn t", replacement = "")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "one", replacement = "")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "stori", replacement = "story")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "involv", replacement = "involve")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "realli", replacement = "really")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "read", replacement = "")
corpus = tm_map(corpus, content_transformer(gsub), pattern = "book", replacement = "")

for (i in seq(1:length(bestreads$Reviews))){
	bestreads$Reviews[i] = corpus[[i]]$content
}

bestreads$Reviews = gsub("*\\b[[:alpha:]]{1,2}\\b*", " ", bestreads$Reviews) # remove words with 1 or 2 letters
bestreads$Reviews = gsub("\\s+", " ", bestreads$Reviews, perl = TRUE) # remove extra white spaces

# add column to group books by ranking (top 100, top 200, etc.)
bestreads$Ranking = as.integer(bestreads$Ranking)

bestreads$RankingCat = ifelse(bestreads$Ranking >=1 & bestreads$Ranking<=100, 'Top 100', 
						ifelse(bestreads$Ranking >100 & bestreads$Ranking<=200, 'Top 100 - 200', 
						ifelse(bestreads$Ranking >200 & bestreads$Ranking<=300, 'Top 200 - 300', 
						ifelse(bestreads$Ranking >300 & bestreads$Ranking<=400, 'Top 300 - 400', 'Top 400 - 500'))))

###############################

# # save into .rda format and open rda
# bestreads = saveRDS(bestreads,file="bestreads.rda")
# bestreads = readRDS('./www/bestreads.rda') # to be changed


################################

# create term document matrix
dtm = DocumentTermMatrix(corpus)
inspect(dtm[1:2,1000:1005])

freq = colSums(as.matrix(dtm)) # look at occurence of each word in the matrix

length(freq) # look at total number of terms across the 500 top books

# create sort order (descending)
ord = order(freq,decreasing=TRUE)

# inspect most frequently occurring terms
freq[head(ord)]
 
#inspect least frequently occurring terms
freq[tail(ord)] 

# include words that only occur in 100 to 500 book's reviews to make sure we are not counting only 
# words that are overwhelmingly present in 1 book and not representative of the sample or words that are very specific to 
# a book and more descriptive of specific book. This helps strike a balance between frequency and specificity.
# enforce lower and upper limit to length of the words included (between 4 and 20 characters).
dtmr = DocumentTermMatrix(corpus, control=list(wordLengths=c(4, 20),
bounds = list(global = c(100,500))))

dtmr # dimension is reduced to [documents] x [terms]

freqr = colSums(as.matrix(dtmr))
# look at total number of terms across the 500 top books
length(freqr)

# create sort order (asc)
ordr = order(freqr,decreasing=TRUE)

# inspect most frequently occurring terms
freqr[head(ordr)]

# inspect least frequently occurring terms
freqr[tail(ordr)]

# find words that appear at least 500 times
findFreqTerms(dtmr,lowfreq=500) # result is ordered alphabetically, not by frequency.

# check for correlations between some of these terms and other terms that occur in the corpus.
# last arg of findAssocs() function is the correlation limit, which is a number between 0 and 1 that serves as
# the lower bound for the strength of the correlation between the search and results terms.
# if the correlation limit is 1, findAssocs() will return only words that always co-occur with the search term. 
# A correlation limit of 0.5 will return terms that have a search term co-occurrence of at least 50%.
findAssocs(dtmr, c("love","found"), c(0.05, 0.04))
# note the presence of a term in these list is not indicative of its frequency. Rather it is a 
# measure of the frequency with which the two (search and result term) co-occur in book reviews.
# also, that it is not an indicator of nearness or contiguity.


# # select only needed columns in best reads and turn df into one-row-per-term-per-bookreview
# reviews_words = bestreads %>%
# 						select(Reviews, 
# 							   MainGenre, 
# 							   NumberOfRating, 
# 							   TotalScore, 
# 							   Ranking,
# 							   Title, 
# 							   RankingCat) %>%
# 						unnest_tokens(word, Reviews) %>%
# 						filter(!word %in% stop_words$word,
# 							   str_detect(word, "^[a-z']+$"))

# # do inner join with bestreads
# dtmr_df = as.data.frame(as.matrix(dtmr))
# bestreads_sentiment = merge(reviews_words, dtmr_df, by = "row.names" )

##########################
# moving on to visualization 

# term-occurrence histogram (freq>1500)
wf = data.frame(term=names(freqr),occurrences=freqr)

ggplot(subset(wf, freqr>5000), aes(term, occurrences)) + 
	geom_bar(stat='identity') + 
	theme(axis.text.x=element_text(angle=45, hjust=1))

# wordcloud
# setting the same seed to ensure consistent look across clouds
set.seed(6) # or seed(2) or seed(10)
wordcloud(names(freqr),freqr,min.freq=5000,colors=brewer.pal(6,'Blues')) # limiting words by specifying min frequency

#######################
# sentiment analysis with tidytext

# select only needed columns in best reads and turn df into one-row-per-term-per-bookreview
reviews_words = bestreads %>%
						select(Reviews, 
							   MainGenre, 
							   NumberOfRating, 
							   TotalScore, 
							   Ranking,
							   Title, 
							   RankingCat,
							   Score) %>%
						unnest_tokens(word, Reviews) %>%
						filter(!word %in% stop_words$word,
							   str_detect(word, "^[a-z']+$")) # removing “stopwords” (e.g “I”, “the”, “and”, etc), and anything that is not a word(e.g. “—-“)

# perform sentiment analysis on each bookreviews using the AFINN lexicon, which provides a positivity score for each word, from -5 (most negative) to 5 (most positive). 
AFINN = sentiments %>%
  			filter(lexicon == "AFINN") %>%
  			select(word, afinn_score = score)

# do inner-join operation followed by a summary
reviews_sentiment = reviews_words %>%
						inner_join(AFINN, by = "word") %>%
						group_by(Title, RankingCat) %>%
						summarize(sentiment = mean(afinn_score))

# does positive or negative aspect of a word correlate with ranking?
ggplot(reviews_sentiment, aes(RankingCat, sentiment, group = RankingCat)) +
    geom_boxplot() +
    ylab("Average sentiment score") + theme_pander()

# our sentiment scores are somewhat correlated with positivity ratings. The sentiment score does not go below
# -1.5 which makes sense. We would not expect the best ever books to have highly negative sentiment score (i.e -3, -4 or -5)
# But we still, there’s a small amount of prediction error - some top 100 books have a negative sentiment score.

# which words are suggestive of a high ranking?
# do a per-word summary
reviews_words_counted = reviews_words %>%
							count(MainGenre, 
								  Title, 
								  RankingCat,
								  Ranking, 
								  word, 
								  TotalScore, 
								  Score) %>%
							ungroup()

# check word appeareance based on score and filter words that appear at least 1000 times
word_summaries_score = reviews_words_counted %>%
					group_by(word) %>%
					summarize(uses = sum(n),
					average_score = mean(Score)) %>%
					ungroup() %>%
  					filter(uses >= 1000)

# same with rank and filter words that appear at least 1000 times
word_summaries_rank = reviews_words_counted %>%
					group_by(word) %>%
					summarize(uses = sum(n),
					average_rank = mean(Ranking)) %>%
					ungroup() %>%
  					filter(uses >= 1000)


# which words are the most used by high ranked books
word_summaries_score %>% arrange(desc(average_score))
word_summaries_rank %>% arrange(desc(average_rank))

# which words are the most used by less highly ranked books
word_summaries_score %>% arrange(average_score)
word_summaries_rank %>% arrange(average_rank)

# which words are suggestive of higher rank/score - an analysis on how words can predict rank
# only looking at words that appear a least 200 times
ggplot(word_summaries_score, aes(uses, average_score)) +
  geom_point() +
  geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
  scale_x_log10() +
  geom_hline(yintercept = mean(bestreads$Score), color = "red", lty = 2) +
  xlab("# of times word appears") +
  ylab("Average Score")

# # same with ranking
# ggplot(word_summaries_rank, aes(uses, average_rank)) +
#   geom_point() +
#   geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
#   scale_x_log10() +
#   geom_hline(yintercept = mean(bestreads$Ranking), color = "red", lty = 2) +
#   xlab("# of times word appears") +
#   ylab("Average Rank")

# same with RankingCat
# reviews_words_ranked = reviews_words %>%
# 							count(RankingCat,
# 								  word) %>%
# 							ungroup() %>%
# 							filter (n>=300)

# ggplot(reviews_words_ranked, aes(RankingCat, n)) +
# 	geom_dotplot(binwidth=0.2, method='histodot', dotsize = 0.3) +
# 	geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
#   	xlab("Ranking Category") +
#   	ylab("# of times word is used")


# Instead of comparing the words with average score, we will define the possible positibve effect of 
# a word by comparing it to the AFINN lexicon.

# combine and compare the two datasets with inner_join.
words_afinn = word_summaries_score %>%
				inner_join(AFINN, by='word')

ggplot(words_afinn, aes(afinn_score, average_score, group = afinn_score)) +
    geom_boxplot() +
    xlab("AFINN score of word") +
    ylab("Average Score with this word")


# look at correlation between Afinn_score and average score. 
# Which positive/negative words were most successful in predicting a positive/negative review, 
# and which broke the trend?
ggplot(words_afinn, aes(afinn_score, average_score, size=uses)) +
    geom_point() +
    geom_smooth(method="lm", se=FALSE, show.legend=FALSE) +
    geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
    scale_x_continuous(limits = c(-6,6)) +
    xlab("# AFINN Sentiment Score") +
    ylab("Average Score")

# Check misclassification by adding the AFINN score component to previous dotpot. We see 
# that words like fear or critic predict a 
# negative review. "Fight" and "Death" which has a low rating AFINN score ranks high for our reviews
ggplot(words_afinn, aes(uses, average_score, color=afinn_score)) +
    geom_point() +
    geom_text(aes(label = word), check_overlap = TRUE, vjust = 1, hjust = 1) +
    scale_x_log10() +
    geom_hline(yintercept = mean(bestreads$Score), color = "red", lty = 2) +
    xlab("# of times word appears") +
    ylab("Average Score")



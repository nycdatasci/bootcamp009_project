library(syuzhet)

### I want to calculate the normalized interpretations for sentences and words for all 4 models
### That means I'll end up with 8 values

news = read.csv('../data/bitcoin_news_99bitcoins.csv', stringsAsFactors = F)
# strip dollar signs from val and val_after_10_days
news$val = as.numeric(sapply(news$val, function(x) gsub('\\$','',x)))
news$val_after_10days = as.numeric(sapply(news$val_after_10days, function(x) gsub('\\$','',x)))

# Calculate 10 day price difference from column
news$val_diff = news$val_after_10days - news$val

# Define the token function
get_tokes = function(x, meth) {
  mean(sign(get_sentiment(get_tokens(x, pattern = "\\W"),method=meth)))
}

# First I'll do the word vectors
syuz_word = sapply(news$long_story, get_tokes, meth = 'syuzhet')
bing_word = sapply(news$long_story, get_tokes, meth = 'bing')
afinn_word = sapply(news$long_story, get_tokes, meth = 'afinn')
nrc_word = sapply(news$long_story, get_tokes, meth = 'nrc')

svg(paste0('words_long','.svg'))
plot(jitter(syuz_word), news$val_diff, main = 'by the word')
points(jitter(bing_word), news$val_diff, col= 'red')
points(jitter(afinn_word), news$val_diff, col= 'blue')
points(jitter(nrc_word), news$val_diff, col= 'green')
dev.off()

# Now I'll do the sentences
get_vecs = function(x, meth) {
  mean(sign(get_sentiment(get_sentences(x),method=meth)))
}

syuz_vec = sapply(news$long_story, get_vecs, meth = 'syuzhet')
bing_vec = sapply(news$long_story, get_vecs, meth = 'bing')
afinn_vec = sapply(news$long_story, get_vecs, meth = 'afinn')
nrc_vec = sapply(news$long_story, get_vecs, meth = 'nrc')

svg(paste0('sentences_long','.svg'))
plot(jitter(syuz_vec), news$val_diff, main = 'by the sentence')
points(jitter(bing_vec), news$val_diff, col= 'red')
points(jitter(afinn_vec), news$val_diff, col= 'blue')
points(jitter(nrc_vec), news$val_diff, col= 'green')
dev.off()

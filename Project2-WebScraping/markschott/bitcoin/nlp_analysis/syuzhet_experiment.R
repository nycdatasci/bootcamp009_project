require(syuzhet)
require(dplyr)

news = read.csv('data/bitcoin_news_99bitcoins.csv', stringsAsFactors = F)
# strip dollar signs from val and val_after_10_days
news$val = as.numeric(sapply(news$val, function(x) gsub('\\$','',x)))
news$val_after_10days = as.numeric(sapply(news$val_after_10days, function(x) gsub('\\$','',x)))
news$val_diff = news$val_after_10days - news$val
news
stories = news$story
titles = news$title

# Check out syuzhet
# do by words instead of sentences (syuzhet can do both)

create_sentiment_plot = function(meth) {

  title_sentiments = rep(0, length(stories))
  story_sentiments = rep(0, length(stories))

  for (i in seq(1:length(stories))) {
    title_by_word <- get_tokens(titles[i], pattern = "\\W")
    story_by_word <- get_tokens(stories[i], pattern = "\\W")
    title_sentiments[i] <- sum(get_sentiment(title_by_word, method="syuzhet"))
    story_sentiments[i] <- sum(get_sentiment(story_by_word, method="syuzhet"))
  }

  news = cbind(news, title_sentiments)
  news = cbind(news, story_sentiments)

  # strip dollar signs from val and val_after_10_days
  news$val = as.numeric(sapply(news$val, function(x) gsub('\\$','',x)))
  news$val_after_10days = as.numeric(sapply(news$val_after_10days, function(x) gsub('\\$','',x)))
  news$val_diff = news$val_after_10days - news$val
  news$total_sentiment = news$title_sentiments + news$story_sentiments

  plot(news$total_sentiment, news$val_diff, main='syuzhet')
  
}

create_sentiment_plot = function(meth) {

  total_sentiments = rep(0, length(stories))
  
  for (i in seq(1:length(stories))) {
    title_by_word <- get_tokens(titles[i], pattern = "\\W")
    story_by_word <- get_tokens(stories[i], pattern = "\\W")
    total_sentiments[i] <- sum(get_sentiment(title_by_word, method = meth)) + 
                           sum(get_sentiment(story_by_word, method = meth))
  }

  #news = cbind(news, title_sentiments)
  #news = cbind(news, story_sentiments)

  svg(paste0(meth,'.svg'))
  plot(total_sentiments, news$val_diff, main = meth, panel.first = grid())
  dev.off()
  
}

# syuzhet, bing, afinn, nrc, and stanford* (requires coreNLP package)
types = c('syuzhet','bing','afinn','nrc')
lapply(types, create_sentiment_plot)

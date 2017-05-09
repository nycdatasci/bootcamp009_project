library(syuzhet)

### I want to calculate the normalized interpretations for sentences and words for all 4 models
### That means I'll end up with 8 values

#news = read.csv('../data/bitcoin_news_99bitcoins.csv', stringsAsFactors = F)
# strip dollar signs from val and val_after_10_days
news = readRDS('news.Rds')
news$val = as.numeric(sapply(news$val, function(x) gsub('\\$','',x)))
news$val_after_10days = as.numeric(sapply(news$val_after_10days, function(x) gsub('\\$','',x)))

###
## Fill in missing values from the headline blurb
#fill_in_missing = function(x) {
#  indy = which(news$long_story==x)
#  if (x=='') {
#    x=news$story[indy]
#  }
#}

for (i in seq(1:61)) {
  if (news$long_story[i] == '') {
    print(i)
    news$long_story[i] = news$story[i]
  }
}

#news$long_story = sapply(news$long_story, fill_in_missing)

# Calculate 10 day price difference from column
news$val_diff = news$val_after_10days - news$val

# Define the token function
get_tokes = function(x, meth) {
  a = get_sentiment(get_tokens(x, pattern = "\\W"),method=meth)
  if (is.null(a)) {
    return(0)
  }
  else { 
    return(mean(sign(a)))
  }
}
  
# First I'll do the word vectors
syuz_word = sapply(news$story, get_tokes, meth = 'syuzhet')
#bing_word = sapply(news$story, get_tokes, meth = 'bing')
#afinn_word = sapply(news$story, get_tokes, meth = 'afinn')
#nrc_word = sapply(news$story, get_tokes, meth = 'nrc')

svg(paste0('words','.svg'))
plot(jitter(syuz_word), news$val_diff, main = 'Blurbs by the word')
#points(jitter(bing_word), news$val_diff, col= 'red')
#points(jitter(afinn_word), news$val_diff, col= 'blue')
#points(jitter(nrc_word), news$val_diff, col= 'green')
dev.off()

# Now I'll do the sentences
get_vecs = function(x, meth) {
  a = get_sentiment(get_sentences(x),method=meth)
  if (is.null(a)) {
    return(0)
  }
  else { 
    return(mean(sign(a)))
  }
}

syuz_vec = sapply(news$story, get_vecs, meth = 'syuzhet')
#bing_vec = sapply(news$story, get_vecs, meth = 'bing')
#afinn_vec = sapply(news$story, get_vecs, meth = 'afinn')
#nrc_vec = sapply(news$story, get_vecs, meth = 'nrc')

model = lm(news$val_diff ~ syuz_vec)

svg(paste0('sentences','.svg'))
plot(jitter(syuz_vec), news$val_diff, xlab = 'Sentiment score',
     main = 'Blurbs by the Sentence',
     ylab = '10 day price difference',
     col = 'blue')
abline(model,lty=2)
#legend("topleft", c("Regression Line", "Conf. Band", "Pred. Band"),
#       lty = c(2, 1, 1), col = c("black", "blue", "red"))
str1 = paste('Intercept p =','0.986')
str2 = paste('Slope p =','0.284')
str3 = paste('Overall p =','0.2837')
str4 = paste('R^2 =','0.02125')
legend("topleft", c(str1,str2,str3,str4))
#points(jitter(bing_vec), news$val_diff, col= 'red')
#points(jitter(afinn_vec), news$val_diff, col= 'blue')
#points(jitter(nrc_vec), news$val_diff, col= 'green')
dev.off()

#Now I should compare the above two methods also for the small sample set of the 
# long news stories which I've collected
syuz_long_word = sapply(news$long_story, get_tokes, meth = 'syuzhet')
#bing_long_word = sapply(news$long_story, get_tokes, meth = 'bing')
#afinn_long_word = sapply(news$long_story, get_tokes, meth = 'afinn')
#nrc_long_word = sapply(news$long_story, get_tokes, meth = 'nrc')

#svg(paste0('words_long','.svg'))
#plot(syuz_long_word, news$val_diff, main = 'by the word')
#points(bing_long_word, news$val_diff, col= 'red')
#points(afinn_long_word, news$val_diff, col= 'blue')
#points(nrc_long_word, news$val_diff, col= 'green')
#dev.off()

syuz_long_vec = sapply(news$long_story, get_vecs, meth = 'syuzhet')
#bing_long_vec = sapply(news$long_story, get_vecs, meth = 'bing')
#afinn_long_vec = sapply(news$long_story, get_vecs, meth = 'afinn')
#nrc_long_vec = sapply(news$long_story, get_vecs, meth = 'nrc')

svg(paste0('sentiment_by_sentences_syuzhet','.svg'))
plot(syuz_long_vec, news$val_diff, 
     main = 'Text Article Vectorized by Sentence (Syuzhet method)',
     xlab = 'Sentiment Score',
     ylab = '10 Day Price Difference',
     col = 'blue')
#points(bing_long_vec, news$val_diff, col= 'red')
#points(afinn_long_vec, news$val_diff, col= 'blue')
#points(jitter(nrc_long_vec), news$val_diff, col= 'green')
dev.off()

### Create a data frame of all of the sentiments
df = as.data.frame(cbind( 
  seq(1,61),
  syuz_word,
 # bing_word,
#  afinn_word,
#  nrc_word,
  syuz_vec,
#  bing_vec,
#  afinn_vec,
#  nrc_vec,
  syuz_long_word,
#  bing_long_word,
#  afinn_long_word,
 # nrc_long_word,
  syuz_long_vec
#  bing_long_vec,
#  afinn_long_vec
  #nrc_long_vec
))
#names(df) = c('nums','s11','b11','a11','n11','s12','b12','a12','n12','s21',
#              'b21','a21','s22','b22','a22')

### Create the plot to view by time
library(dplyr)
news$sentiment_score = syuz_long_vec
svg(paste0('sentiments_over_time','.svg'))
plot(news$event_no, news$sentiment_score, type='l', 
     main = 'Sentiments over Time',
     xlab = 'Event Number',
     ylab = 'Sentiment Score')
dev.off()
  

### Create some bar charts
column_heads = c('anger','anticipation','disgust','fear','joy','sadness','surprise','trust','negative','positive')
find_emotions = function() {
  #emotions = as.data.frame(sapply(get_nrc_sentiment(get_sentences(news$long_story[1])),mean))
  snowball = sapply(get_nrc_sentiment(get_sentences(news$long_story[1])),mean)
  #names(emotions) = column_heads
  for (i in seq(2:61)) {
    tmp=sapply(get_nrc_sentiment(get_sentences(news$long_story[i])),mean)
    print(tmp)
    snowball = rbind(
      snowball,
      tmp
    )
  }
  return(as.data.frame(snowball))
}

feels = find_emotions()
row.names(feels) = seq(1:61)
feels$event_no = news$event_no
#feels$price = news$val
plot(feels$event_no, feels$anger, col='red',type='l')
points(feels$event_no, feels$anticipation, col='blue',type='l')
points(feels$event_no, feels$disgust, col='#abd8a0', type='l')
points(feels$event_no, feels$fear, col='black',type='l')
points(feels$event_no, feels$joy, col='#e54dff',type='l')
points(feels$event_no, feels$sadness, col='purple',type='l')
points(feels$event_no, feels$surprise, col='red',type='l')
points(feels$event_no, feels$trust, col='blue',type='l')
points(feels$event_no, feels$negative, col='#3c0017',type='l')
points(feels$event_no, feels$positive, col='blue',type='l')

### Need to clean this data frame
library(tidyr)
feels = gather(feels, event_no)
names(feels) = c('event_no','emotion','degree')

### Too many lines for one plot... I'll do a facet wrap
svg(paste0('emotion_facet_wrap','.svg'))
library(ggplot2)
feels %>% ggplot(aes(event_no, degree)) + geom_line() +
  facet_wrap(~emotion)
dev.off()

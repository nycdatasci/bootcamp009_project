require(syuzhet)
setwd('~/data/bitcoin/')
news = read.csv('data/bitcoin_news_99bitcoins.csv', stringsAsFactors = F)
text_size = sapply(news, nchar)[,'story']
test_story = news[which(text_size == max(text_size)),'story']
s_v = get_sentences(test_story)
class(s_v)
str(s_v)
head(s_v)
syuzhet_vector = get_sentiment(s_v, method='syuzhet')
bing_vector = get_sentiment(s_v, method='bing')
afinn_vector = get_sentiment(s_v, method='afinn')
nrc_vector = get_sentiment(s_v, method='nrc')
syuzhet_vector
bing_vector
afinn_vector
nrc_vector
rbind(
  sign(head(syuzhet_vector)),
  sign(head(bing_vector)),
  sign(head(afinn_vector)),
  sign(head(nrc_vector))
)

nrc_data = get_nrc_sentiment(s_v)

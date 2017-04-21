library(data.table)

#profiles = fread('profiles.csv', 
 #                stringsAsFactors = FALSE)

choice = colnames(p3)


p = fread('p.csv', 
          stringsAsFactors = FALSE)

p2 = fread('p2.csv', 
           stringsAsFactors = FALSE)

missing_values = fread('missing_values.csv', 
                       stringsAsFactors = FALSE)

p3 = fread('p3.csv', 
           stringsAsFactors = FALSE)



#WORD CLOUDS
# library(tm)
# library(SnowballC)
# library(wordcloud)
# library(RColorBrewer)
# 
# essaycorpus = Corpus(VectorSource(profiles[, essay0:essay9]))
# 
# essaycorpus <- tm_map(essaycorpus, PlainTextDocument)
# essaycorpus <- tm_map(essaycorpus, removePunctuation)
# essaycorpus <- tm_map(essaycorpus, removeWords, stopwords('english'))
# essaycorpus <- tm_map(essaycorpus, stemDocument)
# 
# essaycorpus = Corpus(VectorSource(essaycorpus))
# 
# wordcloud(essaycorpus,
#           max.words = 100,
#           random.order = FALSE,
#           colors = brewer.pal(7, 'Greens') )

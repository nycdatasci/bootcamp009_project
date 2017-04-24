require(tm)
require(wordcloud)

text = c("How are you doing today? It is a beautiful day isn\'t it? It\'s so nice to be alive and
    I really would like to thank you for listening to me today. It\'s been so long since I\'ve written
    anything on account of my focus on improving my computer skills. Consequently, my writing skills have 
    suffered and it feels as if I\'m meeting a long lost love or an old friend. The ability of writing 
    to tease out intricate thoughts and holes in logic is unparalleled elsewhere in the human experience.",
         "hello hello hello hello dividend dividend dividend understand understand understood")



lords = Corpus(DirSource('data/lords'))
#text = Corpus(VectorSource(test$text[1]))
lords = text   

lords = tm_map(lords, stripWhitespace)
lords = tm_map(lords, tolower)
lords = tm_map(lords, removeWords,
               stopwords('english'))
lords = tm_map(lords,stemDocument)

wordcloud(lords, scale=c(5,0.5), max.words=100, 
          random.order=FALSE, rot.per=0.35, 
          use.r.layout=FALSE, colors=brewer.pal(8, "Dark2"))


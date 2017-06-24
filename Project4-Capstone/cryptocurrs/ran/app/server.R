library(shiny)
library(datasets)
library(dygraphs)
library(XML)
library(tm)
library(igraph)
library(RColorBrewer)

#coin <- read.csv("~/Desktop/data_science/bootcamp009_project/Project4-Capstone/cryptocurrs/ran/app/coin.csv")
coin <- read.csv("./coin.csv")
coin = as.xts(coin[,c(2:55)], order.by = as.Date(coin$X))
btc_choix = c("btc_USDEUR", "btc_USDGBP", "btc_USDCAD", "btc_USDAUD",
          "btc_USDJPY", "btc_USDCNY", "btc_USDRUB", "btc_USDBRL",
          "btc_USDSLL")
choix = c("USDEUR", "USDGBP", "USDCAD", "USDAUD",
                           "USDJPY", "USDCNY", "USDRUB", "USDBRL",
                           "USDSLL")



function(input, output){
  bitex <- reactive({
      btc_choix[which(choix == input$ex)]
  })
  
output$plot1 <- renderDygraph({dygraph(cbind(coin[,input$ex],coin[,bitex()]),
                                        main = "Real Exhange Rate and Bitcoin Exchange Rate")%>%
    dyHighlight(highlightSeriesOpts = list(strokeWidth = 1)%>%dyLegend(show = "always", hideOnMouseOut = FALSE)
                
                  )})
output$plot2 <- renderDygraph({dygraph((coin[,bitex()]-coin[,input$ex])/coin[,input$ex],
                                         main = "Arbitrage Return Rate")%>%
    dyShading(from = -1, to = 0, axis = "y", color="#FFE6E6")%>%
    dySeries(input$btc_choix, label = "Return Rate")}) 



###########################
#real time twitter
setup_twitter_oauth("JKTbBC9Mfhy9Rt2Egq93zbfI3", "UyDtLKAZHCtXKzgnt7BSRZkF7DcsB9V5N7pkps0VerfEUkaWIV", 
                    "23561686-1VikNYEGafZ8BIlEsGKAlaCGrvIe4SoFuBsuTpVr4", 
                    "vEhjlf0CSMlfxA8BfqnRwOk34FMRsAOnrwgLt3kv5GTyr")

tweets<-reactive({
    tweet <- searchTwitter(input$searchTerm, n=input$maxTweets, lang=input$lang)
    tweets.df <- twListToDF(tweet)
    text = tweets.df$text })

wordclouds<-function(text)
{
  corpus<-Corpus(VectorSource(text))
  t <- tm_map(corpus, removePunctuation)
  t <- tm_map(t, function(x) iconv(x, "ASCII","UTF-8", sub="byte")) #"latin1", "ASCII"
  t <- tm_map(t, content_transformer(tolower))
  t <- tm_map(t, removeWords, stopwords("en"))
  t <- tm_map(t, removeNumbers)
  t <- tm_map(t, stripWhitespace)
  t <- tm_map(t,removeWords, c("https", "blockchain","cryptocurr","ethereum","bitcoin","price","btc",
                               "eth","fals","usd","like","survivor","trump","shakira","parishilton","gossip","scandal",
                               "news", "hot","summer", "input$searchTerm","paparazzi","����"))
  return(t)
}

text_word<-eventReactive(input$update,{
  text = wordclouds(tweets())
  tdm = TermDocumentMatrix(text)
  m<-as.matrix(tdm)
  v<-sort(rowSums(m),decreasing = TRUE)
  Docs2<-data.frame(word=names(v),freq =v)
  })

output$wordcloud<-renderWordcloud2({
  #wordcloud2(text_word(), shape = 'star',color ="random-dark",size = 0.8)
  letterCloud(text_word(), word = "B",color ="random-dark")		 #,size = 0.8
})

  }

library(shiny)
library(dplyr)
library(tidyr)
library(xts)
library(dygraphs)
library(twitteR)
library(stringr)
library(ROAuth)
library(tm)
library(wordcloud2)

navbarPage("CryptoCurrency",
  tabPanel("Currency Pairs",
  sidebarLayout(
        sidebarPanel(
          selectInput("ex","Currency Pairs",
                            choices = c("USDEUR", "USDGBP", "USDCAD", "USDAUD",
                                                 "USDJPY", "USDCNY", "USDRUB", "USDBRL",
                                                 "USDSLL"), width = '100%'),width = 2
                      ),
        mainPanel(
          dygraphOutput("plot1",height = "350px"),
          dygraphOutput("plot2",height = "350px")
                 )
               )),
  tabPanel("Real Time Twitter Visulization", 
          sidebarLayout(
           sidebarPanel(
             textInput("searchTerm","Enter hashtag to be searched with '#'","#bitcoin"),
             sliderInput("maxTweets","Number of recent tweets to use for analysis",min=5,max=1000,value=500),
             selectInput("lang","Language",
                         choices = c("en", "zh", "fr"),selected="en",width = "100%"),
             actionButton("update", "Update")
           ),
           mainPanel(
               wordcloud2Output("wordcloud",width = "100%", height = "600px")
             )
           ))
)

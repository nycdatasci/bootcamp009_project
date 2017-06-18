library(shiny)
library(data.table)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(googleVis)

fluidPage(
  titlePanel("Bitcoin hahaha"),
  sidebarLayout(
        sidebarPanel(
          selectInput("bitex","BTC Exchange Rate",
                             choices =  c("btc_USDEUR", "btc_USDGBP", "btc_USDCAD", "btc_USDAUD",
                                       "btc_USDJPY", "btc_USDCNY", "btc_USDRUB", "btc_USDBRL",
                                       "btc_USDSLL")),
          selectInput("ex","Exchange Rate",
                      choices = c("USDEUR", "USDGBP", "USDCAD", "USDAUD",
                         "USDJPY", "USDCNY", "USDRUB", "USDBRL",
                         "USDSLL")
                      )
        ),
        mainPanel(
          plotOutput("plot1", height = "300px")
                 )
               ))
      #tabPanel("Big days in Twitter", verbatimTextOutput("TW"))
  #))
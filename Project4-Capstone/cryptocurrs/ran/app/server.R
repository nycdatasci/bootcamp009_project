library(shiny)

coin <- read.csv("~/Desktop/data_science/bootcamp009_project/Project4-Capstone/cryptocurrs/mark/coin.csv")
coin = fortify.zoo(coin)
coin$Index <- as.Date(coin$Index)

function(input, output) {
  #curr = c("USDEUR","USDGBP","USDCAD","USDJPY","USDAUD","USDCNY","USDRUB","USDSLL")
  #btc= c("btc_usd","btc_eur","btc_cad","btc_aud","btc_gbp","btc_jpy","btc_cny","btc_brl","btc_rub","btc_sll")
  #currency = reactive({})
  
  output$plot1 <- renderPlotly({
    ggplotly(ggplot(coin, aes(x=Index,y=coin[,input$ex])) + geom_line()+
               geom_line(aes(x=Index,y=coin[,input$bitex]),col="red"))
      
  })
}
library(shinydashboard)

## server.R ##

source("helpers.R")

fares_by_date = getFaresData()

function(input, output) {
  
  output$messageMenu = renderMenu({
    msgs <- apply(messageData, 1, function(row) {
    messageItem(from = row[["from"]], message = row[["message"]])
  })
  # This is equivalent to calling:
  #   dropdownMenu(type="messages", msgs[[1]], msgs[[2]], ...)
  dropdownMenu(type = "messages", .list = msgs)
})
  
  output$mta_map = renderLeaflet(addMTAStations())
  output$fares_data = DT::renderDataTable(fares_by_date)

  }


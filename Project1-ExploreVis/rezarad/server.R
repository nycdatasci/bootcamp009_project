library(shiny)

## server.R ##

source("helpers.R")

fares_by_date = getFaresData()

function(input, output) {
  
#   output$messageMenu = renderMenu({
#     msgs <- apply(messageData, 1, function(row) {
#     messageItem(from = row[["from"]], message = row[["message"]])
#   })
#   # This is equivalent to calling:
#   #   dropdownMenu(type="messages", msgs[[1]], msgs[[2]], ...)
#   dropdownMenu(type = "messages", .list = msgs)
# })
  output$mtamap = renderLeaflet(addMTAStations())
  # output$q_train = renderLeaflet(addMTAStations() )
  # event = input$mtamap_marker_click 
  
  output$fares_data = DT::renderDataTable(fares_by_date)

  }


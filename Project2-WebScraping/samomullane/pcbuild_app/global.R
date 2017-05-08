library(data.table)
library(dplyr)
library(plotly)
library(shinydashboard)
library(ggplot2)
library(shiny)
library(shinydashboard)

dbname = "./pcpart.db"


dbConnector <- function(session, dbname) {
  require(RSQLite)
  ## setup connection to database
  conn <- dbConnect(drv = SQLite(), 
                    dbname = dbname)
  ## disconnect database when session ends
  session$onSessionEnded(function() {
    dbDisconnect(conn)
  })
  ## return connection
  conn
}

dbGetData <- function(conn, tblname, spec_vec, filter_str = "prod_price > 0", limit = "", orderby = "") {
  query <- paste("SELECT",
                 toString(spec_vec),
                 "FROM",
                 tblname,
                 "WHERE",
                 filter_str,
                 toString(orderby),
                 limit)
  as.data.table(dbGetQuery(conn = conn,
                           statement = query))
}




################################
## METRICS FOR EACH COMPONENT ##
# Case: 'rating_val', 'front panel usb 3.0 ports' (YN), 'internal 2.5in bays', 
#       'internal 3.5in bays', 'rating_n'
# Algorithm: 1) simple filter, rest) sort desc

# CPU: 'rating_val', 'operating frequency', 'max turbo frequency', 'cores', 'lithography',
# CPU cont.: 'l1 total', 'l2 total', 'l2-2 total', 'l3 total', 'rating_n'
# Algorithm: 1) simple filter on rating_val
#            2) weighted average based on freq's, cores and litho
#            3) sort by l's

# Cooler: 'rating_val', 'numeric size','liquid cooled' (YN), 'fan rpm max'

# GPU: 'rating_val', 'mem int', 'core n', 'boost n'
# Missing large number of boost n values

# Memory: 'rating_val', 'total mem', price/gb (doesnt exist), 'num sticks'

# Motherboard: 'rating_val', 'max mem int', 'sata 6 gb/s', 'sata express', 'u.2', 'max gpus'

# Power: 'rating_val', 'watt n'/price, 'rating str', 'modular' (full, semi, no)

# Storage: 'rating_val', 'capacity', 'price/gb'













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






















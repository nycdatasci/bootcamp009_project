### Create my custom data frame
library(RMySQL)
con = dbConnect(MySQL(),user='mes',host='127.0.0.1',dbname='bccs')
rs <- dbSendQuery(con, "select * from coinbaseUSDdaily;")
cbUSD <- fetch(rs, n=-1)
rs2 <- dbSendQuery(con, "select * from etherUSDdaily;")
etherUSD <- fetch(rs2, n=-1)
rs3 <- dbSendQuery(con, "select * from btceUSDdaily;")
btceUSD <- fetch(rs3, n=-1)

# source time series functions
setwd('/home/mes/Projects/nycdsa/communal/bootcamp009_project/Project4-Capstone/cryptocurrs/mark/')
source('ts_functions.R')


df = data.frame()
df$bc.rr.1 = 

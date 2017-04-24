## global.R ##
# convert matrix to dataframe
library(shiny)
library(shinydashboard)
library(htmltools)
library(rgdal)
library(dplyr)
library(sp)
library(raster)
library(ggmap)
library(leaflet)
library(googleVis)
library(ggplot2)


load("taxi.rda")


# neiborhood boundries polygon data is from below
# https://www1.nyc.gov/site/planning/data-maps/open-data/dwn-nynta.page
nh=spTransform(rgdal::readOGR("nynta.shp"),CRS("+proj=longlat +datum=WGS84"))


# ==========================polygon map data: tip and taxi Revenue vs neiborhood=============================
# =====================================================================================================
# select pickup vs credit card tip data

totalData=taxi%>%
  filter(payment_type==1) %>%
  dplyr::select(pickup_datetime,pickup_latitude,pickup_longitude,tip_amount,tip_per,NTACode=pickupCode,payment_amount) %>%
  mutate(tip_per=round(tip_per*100,digit=2)) 

# get data with total taxi revenue and tip revenue 
nhMapData=
  totalData %>% 
  group_by(NTACode) %>%
  summarise(tip_per=mean(tip_per),tip_value=sum(tip_amount)*100/6,taxi_revenue=sum(payment_amount)*100/6)

# merge data with spatial polygon data frame
nhMap <- sp::merge(nh,nhMapData,by.x="NTACode",by.y="NTACode",duplicateGeoms=TRUE)


# build a function to remove NA values
sp.na.omit <- function(x, margin=1) {
  if (!inherits(x, "SpatialPointsDataFrame") & !inherits(x, "SpatialPolygonsDataFrame"))
    stop("MUST BE sp SpatialPointsDataFrame OR SpatialPolygonsDataFrame CLASS OBJECT")
  na.index <- unique(as.data.frame(which(is.na(x@data),arr.ind=TRUE))[,margin])
  if(margin == 1) {
    cat("DELETING ROWS: ", na.index, "\n")
    return( x[-na.index,]  )
  }
  if(margin == 2) {
    cat("DELETING COLUMNS: ", na.index, "\n")
    return( x[,-na.index]  )
  }
}


# remove missing values in spacial polygon dataframe
nhMap=sp.na.omit(nhMap)

#=================================prepare for map data by time of a day==============================================
# pickup vs. tip vs time 
timeData=
  totalData %>% 
  mutate(pickup_datetime=as.numeric(format(as.POSIXct(pickup_datetime,"%Y-%M-%D %H:%M:%S"),"%H",tz="EST"))) %>% 
  group_by(pickup_datetime,NTACode) %>% 
  # group_by(NTACode) %>% 
  summarise(avg_tip_per=mean(tip_per),tip_value=round(sum(tip_amount)*2000/6),taxi_revenue=sum(payment_amount)*2000/6)

# remove missing values
# timeData=timeData[complete.cases(timeData),]





# ===========================taxi payment linear Regression Analysis===================================================
# data preparation
# linearTaxi=taxi %>%
#   filter(payment_amount!=0) %>% 
#    mutate(hr=as.numeric(format(as.POSIXct(pickup_datetime,"%Y-%M-%D %H:%M:%S"),"%H",tz="EST")))
# 
# 
# linearTaxi=subset(linearTaxi,select=(-c(pickup_datetime,pickup_date,pickup_time,
#              trip_distance,dropoff_datetime,dropoff_date,dropoff_time,speed)))
# 
# 
# 
# fit=lm(linearTaxi$payment_amount~
#          linearTaxi$pickup_longitude+linearTaxi$pickup_latitude+
#          linearTaxi$dropoff_longitude+linearTaxi$dropoff_latitude
#        +linearTaxi$hr+linearTaxi$passenger_count)
# summary(fit)


# =============================================linear regression result===============================
# Residuals:
#   Min      1Q  Median      3Q     Max 
# -71.161  -5.338  -1.842   3.413  98.073 
# 
# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)                   2.294e+04  1.688e+02 135.886  < 2e-16 ***
#   linearTaxi$pickup_longitude   1.413e+02  1.460e+00  96.770  < 2e-16 ***
#   linearTaxi$pickup_latitude   -7.358e+01  2.145e+00 -34.313  < 2e-16 ***
#   linearTaxi$dropoff_longitude  9.222e+01  1.634e+00  56.453  < 2e-16 ***
#   linearTaxi$dropoff_latitude  -6.506e+01  1.862e+00 -34.948  < 2e-16 ***
#   linearTaxi$hr                 3.832e-02  9.243e-03   4.146 3.39e-05 ***
#   linearTaxi$passenger_count    7.082e-02  4.017e-02   1.763   0.0779 .  
# ---
#   Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
# 
# Residual standard error: 9.761 on 34174 degrees of freedom
# Multiple R-squared:  0.3786,	Adjusted R-squared:  0.3785 
# F-statistic:  3470 on 6 and 34174 DF,  p-value: < 2.2e-16


# payment_amount= 22940+141.3* pickup_longitude -73.58* pickup_latitude+
# + 92.22* dropoff_longitude -65.06* dropoff_latitude-383.2* hr- 708.2*passenger_count

# ======================================================================================================
# ============================================address to long lat finder================================

geocodeAdddress <- function(address) {
  require(RJSONIO)
  url <- "http://maps.google.com/maps/api/geocode/json?address="
  url <- URLencode(paste(url, address, "&sensor=false", sep = ""))
  x <- fromJSON(url, simplify = FALSE)
  if (x$status == "OK") {
    out <- c(x$results[[1]]$geometry$location$lng,
             x$results[[1]]$geometry$location$lat)
  } else {
    out <- NA
  }
  Sys.sleep(0.2)  # API only allows 5 requests per second
  out
}


# 
# 
# 
# payment_amount= 22940+141.3* pickup_longitude -73.58* pickup_latitude + 92.22* dropoff_longitude -65.06* dropoff_latitude+0.03823* hr+ 0.07082*passenger_count
#   
# pickup_longitude =-74.013421
# pickup_latitude= 40.705576 
# dropoff_longitude=-73.98513
# dropoff_latitude = 40.75890
# hr =10
# passenger_count = 1


#=============================================NOT FOR USE===================================================
 
# # =========================chart data: tip vs time of the day =========================================
# pickupHrTip=
#   taxi%>%
#   filter(payment_type==1) %>%
#   dplyr::select(tip_per,pickup_datetime) %>% 
#   mutate(pickup_datetime=as.numeric(format(as.POSIXct(pickup_datetime,"%Y-%M-%D %H:%M:%S"),"%H",tz="EST"))) %>% 
#   group_by(pickup_datetime) %>%
#   summarise(avg_tip_per=mean(tip_per))
# 
# 
#  ggplot(pickupHrTip,aes(x=pickup_datetime,y=avg_tip_per))+geom_smooth()
#  
#  # =======================speed vs tip =================================================================
#  speedTip=
#    taxi %>%
#    filter(payment_type==1) %>%
#    mutate(hr=as.numeric(format(as.POSIXct(pickup_datetime,"%Y-%M-%D %H:%M:%S"),"%H",tz="EST"))) %>% 
#    # group_by(hr) %>% 
#    # summarise(tip_per=mean(tip_per),speed=mean(speed))
#    dplyr::select(speed, tip_per)
#  


# speedTip$hr <- as.factor(as.character(speedTip$hr))

# ggplot(speedTip,aes(x=speed,y=tip_per))+geom_smooth()

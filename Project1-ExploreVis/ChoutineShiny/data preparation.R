install.packages("dplyr")
install.packages("rgdal")
install.packages("sp")
install.packages("raster")
# install.packages("leaflet")
# install.packages("googleVis")


library(dplyr)
library(rgdal)
library(sp)
library(raster)
library(ggmap)
library(leaflet)
library(googleVis)

# ==========load the downloaded data=====================================
load("taxiData10p1.rda")
# rename columns
# names(taxi)[names(taxi)=="lpep_pickup_datetime"]="PickUpTime"
# names(taxi)[names(taxi)=="Lpep_dropoff_datetime"]="DroppOffTime"
# names(taxi)[names(taxi)=="ï..VendorID"]="VendorID"


#==========================using neiborhood shape file====================
# neiborhood boundries polygon data is from below
# https://www1.nyc.gov/site/planning/data-maps/open-data/dwn-nynta.page
nh=spTransform(rgdal::readOGR("nynta.shp"),CRS("+proj=longlat +datum=WGS84"))

# whrite shape file if you need to save it 
# writeOGR(nh, ".", "neiborhood", driver="ESRI Shapefile")

# select pickup long and lat data
Pickup_longvLat=taxiData3 %>% 
  dplyr::select(pickup_longitude,pickup_latitude)
colnames(Pickup_longvLat)=c("longitude","latitude")

# select dropoff long and lat data
Dropoff_longvLat=taxiData3 %>% 
  dplyr::select(dropoff_longitude,dropoff_latitude)
colnames(Dropoff_longvLat)=c("longitude","latitude")


# transform pick up long lat data
coordinates(Pickup_longvLat) <- ~longitude+latitude
proj4string(Pickup_longvLat) <- CRS("+proj=longlat +datum=WGS84")
Pickup_longvLat <- spTransform(Pickup_longvLat, proj4string(nh))

# transform drop off long lat data
coordinates(Dropoff_longvLat) <- ~longitude+latitude
proj4string(Dropoff_longvLat) <- CRS("+proj=longlat +datum=WGS84")
Dropoff_longvLat <- spTransform(Dropoff_longvLat, proj4string(nh))

# get the over layered neiborhood info
pickUpLayer=Pickup_longvLat%over%nh
dropoffLayer=Dropoff_longvLat%over%nh

# combind neiborhood info with long and lat
Pickup_longvLat=taxiData3 %>% 
  dplyr::select(pickup_longitude,pickup_latitude)
Dropoff_longvLat=taxiData3 %>% 
  dplyr::select(dropoff_longitude,dropoff_latitude)

# only select the columns we will use
pickBind=(cbind(Pickup_longvLat,pickUpLayer))[,c("pickup_longitude","pickup_latitude","NTACode","NTAName")]
dropBind=cbind(Dropoff_longvLat,dropoffLayer)[,c("dropoff_longitude","dropoff_latitude","NTACode","NTAName")]

# rename columns
colnames(pickBind)[3:4]=c("pickupCode","pickupNH")
colnames(dropBind)[3:4]=c("dropoffCode","dropoffNH")

# join all the tables
taxiData10pNh=taxiData3 %>% left_join(pickBind) 
taxiData10pNh=taxiData10pNh%>% left_join(dropBind)

# save the prepared data
write.csv(taxiData10pNh,"taxiNh10p.csv")

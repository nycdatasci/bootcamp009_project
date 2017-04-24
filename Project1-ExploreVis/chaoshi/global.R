##############################################
# Geospatial Data Digester Prototyped in R -- 
# A Shiny Project @ NYC Data Science Academy
# 
#
# Chao Shi
# chao.shi.datasci@gmail.com
# 4/23/2017
##############################################

# devtools::install_github("MangoTheCat/radarchart")
library(sp)
library(rgeos)
library(rgdal)
library(maptools)
library(dplyr)
library(leaflet)
library(scales)
library(data.table)
library(formattable)
library(googleVis)
# library(crosstalk)      # very promising development
library(maps)
library(radarchart)
library(geosphere)
library(RColorBrewer)
library(PerformanceAnalytics)
library(corrplot)
library(htmltools)
library(ggplot2)

source("./helpers.R")
source("./corr/sortable.R")
source("./corr/corTest.R")

scalar = 100

options(digits=4)

# ======== if each csv file is 100% ready to join, do this ==========
# filenames <- list.files("./data", pattern="*.csv", full.names=TRUE)
# ldf <- lapply(filenames, read.csv)
# res <- lapply(ldf, summary)
# names(res) <- substr(filenames, 8, 30)
# ===================================================================

# =============================================== 2016 election data ===================================================
votedat = readcsv_fips_value("./data/2016_US_County_Level_Presidential_Results.csv",11,c(5,6),c("per_dem","per_gop"))

votedat$perdiff = votedat$per_dem - votedat$per_gop


# =============================================== 2015 labor and income data ===========================================
colnames3_40_45 = c("Civilian_labor_force_2015", "Employed_2015", "Unemployed_2015",
                    "Unemployment_rate_2015", "Median_Household_Income_2015", "Med_HH_Income_Percent_of_State_Total_2015",
                    "county_state")

incdat = readcsv_fips_value("./data/Unemployment_Med_HH_Inc.csv", 1,c(40:45,3),colnames3_40_45,skip=7)

incdat$median_household_income_2015 = as.numeric(gsub("[$,]", "", incdat$median_household_income_2015))

# ============================================ 2015 living wage study by MIT ===========================================
# living wage data -- 3 main cases:  2 adults 2 kids,  1 adult 1 kid, 1 adult

# had to change to UTF 8 encoding

# [1] "Hourly.Wages"                      
# [2] "X1.Adult"                          
# [3] "X1.Adult.1.Child"                  
# [4] "X1.Adult.2.Children"               
# [5] "X1.Adult.3.Children"               
# [6] "X2.Adults..One.Working."           
# [7] "X2.Adults..One.Working..1.Child"   
# [8] "X2.Adults..One.Working..2.Children"
# [9] "X2.Adults..One.Working..3.Children"
# [10] "X2.Adults"                         
# [11] "X2.Adults.1.Child"                 
# [12] "X2.Adults.2.Children"              
# [13] "X2.Adults.3.Children"              
# [14] "FIPS.Code"                         
# [15] "Location"                          
# [16] "year"  
livingwagedat = readcsv_fips_value("./data/2015_Living_Wage.csv", 14, c(12,3,2),c("twoatwoc","oneaonec","onea"))

livingwagedat$twoatwoc = as.numeric(gsub("[$,]", "", livingwagedat$twoatwoc))
livingwagedat$oneaonec = as.numeric(gsub("[$,]", "", livingwagedat$oneaonec))
livingwagedat$onea     = as.numeric(gsub("[$,]", "", livingwagedat$onea))

livingwagedat[,2:4] = livingwagedat[,2:4]*40*52 # convert hourly wage to annual salary

# ========================================================= Crime data ======================================================


# crimedat = read.csv("./data/crime_data_w_population_and_crime_rate.csv")
# > names(crimedat)
# [1] "county_name"           "crime_rate_per_100000" "index"                 "EDITION"               "PART"                  "IDNO"                 
# [7] "CPOPARST"              "CPOPCRIM"              "AG_ARRST"              "AG_OFF"                "COVIND"                "INDEX"                
# [13] "MODINDX"               "MURDER"                "RAPE"                  "ROBBERY"               "AGASSLT"               "BURGLRY"              
# [19] "LARCENY"               "MVTHEFT"               "ARSON"                 "population"            "FIPS_ST"               "FIPS_CTY"   
crimedat = readcsv_fips_value("./data/crime_data_w_population_and_crime_rate.csv", 23, c(24,2,22),c("fips_last3","crime_rate_per_100k","population"))

crimedat$GEOID = paste0(fips_fix_dig(as.integer(crimedat$GEOID),2), fips_fix_dig(crimedat$fips_last3,3))

crimedat$fips_last3 = NULL


# =============================================== county polygon area data ===================================================


# > area = read.csv('./data/US_Counties.csv')
# > names(area)
# [1] "X_feature_id"        "X_feature_id_string" "the_geom"            "geo_id"              "state"               "county"              "name"                "lsad"               
# [9] "censusarea"          "shape_leng"          "shape_area"   


areadat = readcsv_fips_value("./data/US_Counties.csv", 4, 9,"censusarea")
areadat$GEOID = gsub("0500000US", "", areadat$GEOID)


# ============================================ real estate value data from zillow =============================================

# very nice data set, but not used in this 2-week project because# this data set only has 1181 rows -- zillow does not have 
# statistics for ALL counties (>3000 of them). Same with other real estate online agencies.

# all my other data sets are for at least 3100 counties; for the weighted-average scoring engine, 1 data category missing value
# for nearly half of the counties while other categories provide nearly full overage usually means 1) sacrifising data to create
# proper comparison, or 2) come up with good interpolation schemes to fill data holes (interp is rarely just a math problem).

# I made a decision to load this data for correlation analysis, but not for the map


# loading County_MedianValuePerSqft_AllHomes.csv from zillow.com
# > temp = read.csv('./data/County_MedianValuePerSqft_AllHomes.csv')
# > names(temp)
# [1] "RegionID"          "RegionName"        "State"             "Metro"             "StateCodeFIPS"     "MunicipalCodeFIPS" "SizeRank"          "X1996.04"          "X1996.05"         
# [10] "X1996.06"          "X1996.07"          "X1996.08"          "X1996.09"          "X1996.10"          "X1996.11"          "X1996.12"          "X1997.01"          "X1997.02"         
# [19] "X1997.03"          "X1997.04"          "X1997.05"          "X1997.06"          "X1997.07"          "X1997.08"          "X1997.09"          "X1997.10"          "X1997.11"         
# [28] "X1997.12"          "X1998.01"          "X1998.02"          "X1998.03"          "X1998.04"          "X1998.05"          "X1998.06"          "X1998.07"          "X1998.08"         
# [37] "X1998.09"          "X1998.10"          "X1998.11"          "X1998.12"          "X1999.01"          "X1999.02"          "X1999.03"          "X1999.04"          "X1999.05"         
# [46] "X1999.06"          "X1999.07"          "X1999.08"          "X1999.09"          "X1999.10"          "X1999.11"          "X1999.12"          "X2000.01"          "X2000.02"         
# [55] "X2000.03"          "X2000.04"          "X2000.05"          "X2000.06"          "X2000.07"          "X2000.08"          "X2000.09"          "X2000.10"          "X2000.11"         
# [64] "X2000.12"          "X2001.01"          "X2001.02"          "X2001.03"          "X2001.04"          "X2001.05"          "X2001.06"          "X2001.07"          "X2001.08"         
# [73] "X2001.09"          "X2001.10"          "X2001.11"          "X2001.12"          "X2002.01"          "X2002.02"          "X2002.03"          "X2002.04"          "X2002.05"         
# [82] "X2002.06"          "X2002.07"          "X2002.08"          "X2002.09"          "X2002.10"          "X2002.11"          "X2002.12"          "X2003.01"          "X2003.02"         
# [91] "X2003.03"          "X2003.04"          "X2003.05"          "X2003.06"          "X2003.07"          "X2003.08"          "X2003.09"          "X2003.10"          "X2003.11"         
# [100] "X2003.12"          "X2004.01"          "X2004.02"          "X2004.03"          "X2004.04"          "X2004.05"          "X2004.06"          "X2004.07"          "X2004.08"         
# [109] "X2004.09"          "X2004.10"          "X2004.11"          "X2004.12"          "X2005.01"          "X2005.02"          "X2005.03"          "X2005.04"          "X2005.05"         
# [118] "X2005.06"          "X2005.07"          "X2005.08"          "X2005.09"          "X2005.10"          "X2005.11"          "X2005.12"          "X2006.01"          "X2006.02"         
# [127] "X2006.03"          "X2006.04"          "X2006.05"          "X2006.06"          "X2006.07"          "X2006.08"          "X2006.09"          "X2006.10"          "X2006.11"         
# [136] "X2006.12"          "X2007.01"          "X2007.02"          "X2007.03"          "X2007.04"          "X2007.05"          "X2007.06"          "X2007.07"          "X2007.08"         
# [145] "X2007.09"          "X2007.10"          "X2007.11"          "X2007.12"          "X2008.01"          "X2008.02"          "X2008.03"          "X2008.04"          "X2008.05"         
# [154] "X2008.06"          "X2008.07"          "X2008.08"          "X2008.09"          "X2008.10"          "X2008.11"          "X2008.12"          "X2009.01"          "X2009.02"         
# [163] "X2009.03"          "X2009.04"          "X2009.05"          "X2009.06"          "X2009.07"          "X2009.08"          "X2009.09"          "X2009.10"          "X2009.11"         
# [172] "X2009.12"          "X2010.01"          "X2010.02"          "X2010.03"          "X2010.04"          "X2010.05"          "X2010.06"          "X2010.07"          "X2010.08"         
# [181] "X2010.09"          "X2010.10"          "X2010.11"          "X2010.12"          "X2011.01"          "X2011.02"          "X2011.03"          "X2011.04"          "X2011.05"         
# [190] "X2011.06"          "X2011.07"          "X2011.08"          "X2011.09"          "X2011.10"          "X2011.11"          "X2011.12"          "X2012.01"          "X2012.02"         
# [199] "X2012.03"          "X2012.04"          "X2012.05"          "X2012.06"          "X2012.07"          "X2012.08"          "X2012.09"          "X2012.10"          "X2012.11"         
# [208] "X2012.12"          "X2013.01"          "X2013.02"          "X2013.03"          "X2013.04"          "X2013.05"          "X2013.06"          "X2013.07"          "X2013.08"         
# [217] "X2013.09"          "X2013.10"          "X2013.11"          "X2013.12"          "X2014.01"          "X2014.02"          "X2014.03"          "X2014.04"          "X2014.05"         
# [226] "X2014.06"          "X2014.07"          "X2014.08"          "X2014.09"          "X2014.10"          "X2014.11"          "X2014.12"          "X2015.01"          "X2015.02"         
# [235] "X2015.03"          "X2015.04"          "X2015.05"          "X2015.06"          "X2015.07"          "X2015.08"          "X2015.09"          "X2015.10"          "X2015.11"         
# [244] "X2015.12"          "X2016.01"          "X2016.02"          "X2016.03"          "X2016.04"          "X2016.05"          "X2016.06"          "X2016.07"          "X2016.08"         
# [253] "X2016.09"          "X2016.10"          "X2016.11"          "X2016.12"          "X2017.01"          "X2017.02"      

zillowdat = readcsv_fips_value("./data/County_MedianValuePerSqft_AllHomes.csv", 5, c(6,234,246,258),c("fips_last3","medv201502","medv201602","medv201702"))

zillowdat$GEOID = paste0(fips_fix_dig(as.integer(zillowdat$GEOID),2), fips_fix_dig(zillowdat$fips_last3,3))

zillowdat$fips_last3 = NULL


# ============================================ air quality data =============================================


# url = "https://data.cdc.gov/api/views/cjae-szjv/rows.csv?accessType=DOWNLOAD"
# dat <- read.csv(url, stringsAsFactors = FALSE)

# 1 -- read csv
dat <- fread("./data/Air_Quality_Measures_on_the_National_Environmental_Health_Tracking_Network.csv", stringsAsFactors = FALSE)
names(dat) <- tolower(names(dat))


id_name <- dat %>%
  select(measureid,measurename,unit, unitname) %>%
  unique()

airdat <- dat %>%
  filter(measureid == "296" & reportyear == 2011) %>%
  select(countyfips, value)
# select(measureid, measurename,countyfips, value,unitname)
colnames(airdat) <- c("GEOID", "airqlty")

# Have to add leading zeos to any FIPS code that's less than 5 digits long to get a good match.
# airdat$GEOID <- formatC(airdat$GEOID, width = 5, format = "d", flag = "0")
airdat$GEOID <- fips_fix_dig(airdat$GEOID,5)



# ============================ special step because of county name and FIPS change ===========================

#  In 2015, Shannon County, SD (FIPS code 46113) is now Oglala Lakota County (FIPS code 46102)
airdat$GEOID        <- gsub("46113", "46102", airdat$GEOID)
votedat$GEOID       <- gsub("46113", "46102", votedat$GEOID)
livingwagedat$GEOID <- gsub("46113", "46102", livingwagedat$GEOID)
crimedat$GEOID      <- gsub("46113", "46102", crimedat$GEOID)
areadat$GEOID       <- gsub("46113", "46102", areadat$GEOID)

# ========================= 1 NA in crime data that I googled to get some estimated numbers ===================

# there are about 150 counties with 0 crime rate (per 100k people), it would be nice to have time to investigate...
dona_ana <- data.frame(GEOID="35013",crime_rate_per_100k=210, population=214000)
crimedat = rbind(crimedat, dona_ana)   # filling data for FIPS = 35013,  Dona Ana County, NM



# ============================= merge on GEOID / FIPS ====================================
county_dat <- full_join(airdat, votedat, by=c("GEOID"))
county_dat <- full_join(county_dat, incdat, by=c("GEOID"))
county_dat <- full_join(county_dat, livingwagedat, by=c("GEOID"))

county_dat$r_inc_cos = county_dat$median_household_income_2015 / county_dat$twoatwoc

county_dat <- full_join(county_dat, crimedat, by=c("GEOID"))
county_dat <- full_join(county_dat, areadat, by=c("GEOID"))

county_dat$pop_den_log = log(county_dat$population / county_dat$censusarea)
# county_dat$pop_den_log = county_dat$population / county_dat$censusarea

county_dat <- full_join(county_dat, zillowdat, by=c("GEOID"))






# ====================== this can be made into a function ==================
nums <- sapply(county_dat, is.numeric)


# ============ round ============== #
# testing if this is needed for slider range comparison to work for extreme cases
county_dat[,nums] = round(county_dat[,nums],2)

# here we generate a normalized version of county_dat, where each numeric column is shifted then normalized to a range of [0,scalar]
# this is done by  normed =  ( original_col - min_of_this_col ) / original_range_of_this_col  * scalar

to_be_normalized = county_dat[,nums]
normalized = as.data.frame(lapply(to_be_normalized, normalize, na.rm=TRUE))

county_dat_norm = county_dat
county_dat_norm[,nums] = normalized * scalar     # change to [0,scalar]

# ====================== next step is to set the default "good" direction for some measurement ==================

# for example, income and air quality data has both been mapped to [0,scalar] range, 
# yet a greater number is good for income, but bad for air quality.

# since these values will be used to generated an average "score" for each location, we want to align the "good" directions

# question still remains for subjective data like political vote results

county_dat_norm["airqlty"]                = scalar - county_dat_norm["airqlty"]
county_dat_norm["unemployment_rate_2015"] = scalar - county_dat_norm["unemployment_rate_2015"]
county_dat_norm["twoatwoc"]               = scalar - county_dat_norm["twoatwoc"]
county_dat_norm["oneaonec"]               = scalar - county_dat_norm["oneaonec"]
county_dat_norm["onea"]                   = scalar - county_dat_norm["onea"]

county_dat_norm$crime_rate_per_100k       = scalar - county_dat_norm$crime_rate_per_100k


# =========================================== I enjoyed learning from datascienceriot.com ==================================
# the key data cleaning steps are learned from here https://www.datascienceriot.com/mapping-us-counties-in-r-with-fips/kris/

# Download county shape file from Tiger.
# https://www.census.gov/geo/maps-data/data/cbf/cbf_counties.html

# ================================================= #
# every several years, there will be some changes in the county definition. 
# I have learned that for a county level map generation it is better to first look at when the majority of data are collected
# then start from a most relavent county shape set.
#
# us.map <- readOGR(dsn = "./shape", layer = "cb_2013_us_county_20m", stringsAsFactors = FALSE)
# us.map <- readOGR(dsn = "./shape", layer = "cb_2016_us_county_500k", stringsAsFactors = FALSE)

us.map <- readOGR(dsn = "./shape", layer = "cb_2016_us_county_20m", stringsAsFactors = FALSE)


# Remove Alaska(2), Hawaii(15), Puerto Rico (72), Guam (66), Virgin Islands (78), American Samoa (60)
#  Mariana Islands (69), Micronesia (64), Marshall Islands (68), Palau (70), Minor Islands (74)
us.map <- us.map[!us.map$STATEFP %in% c("02", "15", "72", "66", "78", "60", "69",
                                        "64", "68", "70", "74"),]
# Make sure other outling islands are removed.
us.map <- us.map[!us.map$STATEFP %in% c("81", "84", "86", "87", "89", "71", "76",
                                        "95", "79"),]

# ======================== lat lon data for each county ============================ 
# lat lon for each county
# I was assuming after finding so many county level csv file, lat lon data is in hand, but no :)
#
# It turns out that with the rgeos package, I can get this info from the shape files
# which is loaded as a SpatialPolygonDataFrame
#
# To learn more about how to deal with this structure, I find a good webpage
# http://zevross.com/blog/2015/10/14/manipulating-and-mapping-us-census-data-in-r-using-the-acs-tigris-and-leaflet-packages-3/
#
centroid = rgeos::gCentroid(us.map, byid=TRUE)

GEOID = us.map$GEOID
lat   = centroid$y
lon   = centroid$x

GEOID_lat_lon = data.frame(GEOID, lat, lon)

county_dat = dplyr::left_join(county_dat, GEOID_lat_lon, by=c("GEOID"))

# ==========================================================================================

# this is a turning point. after the merge, the returned data is in SpatialPolygonsDataFrame

# > class(leafmap)
# [1] "SpatialPolygonsDataFrame"
# attr(,"package")
# [1] "sp"

# It is not easy to manipulate. In this project I chose to use this leafmap data for geometry
# while keep data frames like county_dat in memory for filtering and other calculation
# Your suggestion to better deal with this situation is very welcome.

# Merge spatial df with downloade ddata.
leafmap <- merge(us.map, county_dat, by=c("GEOID"))

leafmap_norm <- merge(us.map, county_dat_norm, by=c("GEOID"))

# ==========================================================================================




mydf      = as.data.frame(leafmap)
dummy_norm = as.data.frame(leafmap_norm)

neededcols = c(10, 13, 18, 21, 24, 25, 28)
# neededcols = c("airqlty", "perdiff", "median_household_income_2015", "twoatwoc", "r_inc_cos","crime_rate_per_100k")



colnames = names(mydf)[neededcols]

mydf_norm     = dummy_norm %>% select(neededcols)   # this is the main set used in the weighted_val() calculation

dummy2   = mydf %>% select(neededcols)

# find min max for all needed cols
MINs = apply(dummy2,2,min)  
MAXs = apply(dummy2,2,max)

MINs <- formattable(MINs, digits = 2, format = "f")
MAXs <- formattable(MAXs, digits = 2, format = "f")

# MINs <- round(MINs,2)
# MAXs <- round(MAXs,2)

lon_lat_county_mat=cbind(mydf$lon, mydf$lat)

names(mydf)[c(17,18,19)] = c('unemployR2015','mdhhinc2015','medhhinc_perc_sta2015')
# ======================================================================
# ======================================================================
# ==================                               =====================
# ==================          TESTING PLOTS        =====================
# ==================                               =====================
# ======================================================================
# ======================================================================

# chart.Correlation(mydf[,c(10, 11, 12, 13, 17, 18, 21, 24, 25, 26, 27, 28, 29,30)])
# chart.Correlation(dummy_norm[,c(10, 11,12, 13, 17, 18, 21, 24, 25, 26, 27, 28)])


# names(mydf)
# [1] "GEOID"                                     "STATEFP"                                  
# [3] "COUNTYFP"                                  "COUNTYNS"                                 
# [5] "AFFGEOID"                                  "NAME"                                     
# [7] "LSAD"                                      "ALAND"                                    
# [9] "AWATER"                                    "airqlty"                                  
# [11] "per_dem"                                   "per_gop"                                  
# [13] "perdiff"                                   "civilian_labor_force_2015"                
# [15] "employed_2015"                             "unemployed_2015"                          
# [17] "unemployment_rate_2015"                    "median_household_income_2015"             
# [19] "med_hh_income_percent_of_state_total_2015" "county_state"                             
# [21] "twoatwoc"                                  "oneaonec"                                 
# [23] "onea"                                      "r_inc_cos"                                
# [25] "crime_rate_per_100k"                       "population"                               
# [27] "censusarea"                                "pop_den_log"                              
# [29] "lat"                                       "lon"   


# names(dummy_norm)

# [1] "GEOID"                                    
# [2] "STATEFP"                                  
# [3] "COUNTYFP"                                 
# [4] "COUNTYNS"                                 
# [5] "AFFGEOID"                                 
# [6] "NAME"                                     
# [7] "LSAD"                                     
# [8] "ALAND"                                    
# [9] "AWATER"                                   
# [10] "airqlty"                                  
# [11] "per_dem"                                  
# [12] "per_gop"                                  
# [13] "perdiff"                                  
# [14] "civilian_labor_force_2015"                
# [15] "employed_2015"                            
# [16] "unemployed_2015"                          
# [17] "unemployment_rate_2015"                   
# [18] "median_household_income_2015"             
# [19] "med_hh_income_percent_of_state_total_2015"
# [20] "county_state"                             
# [21] "twoatwoc"                                 
# [22] "oneaonec"                                 
# [23] "onea"                                     
# [24] "r_inc_cos"                                
# [25] "crime_rate_per_100k"                      
# [26] "population"                               
# [27] "censusarea"                               
# [28] "pop_den_log"  



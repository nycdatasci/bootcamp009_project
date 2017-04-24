library(dplyr)
library(tidyr)
library(ggplot2)
library(Hmisc)
library(rgdal)
library(scales)
library(ggmap)
library(Cairo)
library(stringr)
library(googleVis)
library(leaflet)
library(ggthemes)
library(RColorBrewer)

zip_code <- read.table("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/data/zip_tract.txt", 
                       sep=",",header = T)
zip_code <- zip_code %>% 
  mutate(zip_code = str_pad(as.character(ZCTA5), 5, pad = "0"),
         tractID = str_pad(as.character(GEOID), 11, pad = "0"))
zip_tract <- zip_code %>% dplyr::select(zip_code,tractID)
zip_tract
tract_data <- read.csv("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/data/tract_level.csv",
                       stringsAsFactors = F)
tract_data <- tract_data %>% mutate(tractID = str_pad(as.character(TractFIPS), 11, pad = "0")) %>%
  select(StateAbbr, PlaceName, tractID)
zip_list <- left_join(tract_data, zip_tract, c("tractID"="tractID"))
unique_zip <- zip_list %>% select(StateAbbr,PlaceName, zip_code) %>% unique()
checking <- unique_zip %>% group_by(zip_code) %>% summarise(count = n()) %>% arrange(desc(count))
View(checking)
unique_zip <- left_join(unique_zip, checking, by = ("zip_code"="zip_code"))
place_zip <- unique_zip %>% filter(count == 1)

hosp_info <- read.csv("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/data/Hospital_General_Information.csv",
                      stringsAsFactors = F)
hosp_info <- hosp_info %>% mutate(ZIP.Code = str_pad(as.character(ZIP.Code), 5, pad = "0"))
hosp_info <- left_join(hosp_info, place_zip, by = c("ZIP.Code"="zip_code"))

names(hosp_info)

hosp_info <- hosp_info %>% mutate(City = tolower(City)) %>%
  select(Hospital.Name, Hospital.Type, Address, City, State, ZIP.Code, Hospital.Ownership, Emergency.Services,
         Hospital.overall.rating, Place = PlaceName,count)
hosp_info1 <- hosp_info %>% mutate(city_matched = ifelse(is.na(count),City, Place)) %>% 
  mutate(city_matched = tolower(city_matched))

city_500 <- read.csv("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/data/city_level.csv",
                     stringsAsFactors = F)
city_selection <- city_500 %>% 
  mutate(city_lower = tolower(PlaceName)) %>%
  select(city_lower, PlaceName) %>%
  unique()

View(city_selection)

city_500 <- city_500 %>% mutate(PlaceName = tolower(PlaceName)) %>%
  select(StateAbbr, PlaceName, Population2010, Geolocation, ends_with("_AdjPrev"))

city_hosp <- inner_join(hosp_info1, city_500, by = c("city_matched"="PlaceName", "State" = "StateAbbr"))

city_hosp$owner_tri <- 0
city_hosp$owner_tri[city_hosp$Hospital.Ownership == "Government - Federal"] <- "Government"
city_hosp$owner_tri[city_hosp$Hospital.Ownership == "Government - Hospital District or Authority"] <- "Government"
city_hosp$owner_tri[city_hosp$Hospital.Ownership == "Government - Local"] <- "Government"
city_hosp$owner_tri[city_hosp$Hospital.Ownership == "Government - State"] <- "Government"
city_hosp$owner_tri[city_hosp$Hospital.Ownership == "Physician"] <- "Proprietary"
city_hosp$owner_tri[city_hosp$Hospital.Ownership == "Proprietary"] <- "Proprietary"
city_hosp$owner_tri[city_hosp$Hospital.Ownership == "Voluntary non-profit - Church"] <- "Non-profit"
city_hosp$owner_tri[city_hosp$Hospital.Ownership == "Voluntary non-profit - Other"] <- "Non-profit"
city_hosp$owner_tri[city_hosp$Hospital.Ownership == "Voluntary non-profit - Private"] <- "Non-profit"
city_hosp$owner_tri <- factor(city_hosp$owner_tri)

View(city_hosp)

city_hosp <- city_hosp %>% select(-Hospital.Ownership) %>% select(-City, -Place)
city_hosp$Hospital.overall.rating <- as.numeric(city_hosp$Hospital.overall.rating)
city_hosp <- left_join(city_hosp, city_selection, by = c("city_matched"="city_lower"))
names(city_selection)
names(city_hosp)

summary_city <- city_hosp %>% 
  group_by(city_matched, State, Geolocation) %>% 
  summarise(Population_city = mean(Population2010),
            hosp_count = n(),
            mean_rating = round(mean(Hospital.overall.rating, na.rm=TRUE)),
            median_rating = round(median(Hospital.overall.rating, na.rm=T)),
            ACCESS2_city = mean(ACCESS2_AdjPrev),
            hcoverage_city = 100 - ACCESS2_city,
            BINGE_city = mean(BINGE_AdjPrev),
            BPHIGH_city = mean(BPHIGH_AdjPrev),
            BPMED_city = mean(BPMED_AdjPrev),
            CANCER_city = mean(CANCER_AdjPrev),
            CASTHMA_city = mean(CASTHMA_AdjPrev),
            CHD_city = mean(CHD_AdjPrev),
            CHECKUP_city = mean(CHECKUP_AdjPrev),
            CHOLSCREEN_city = mean(CHOLSCREEN_AdjPrev),
            COLONSCREEN_city = mean(COLON_SCREEN_AdjPrev),
            COPD_city = mean(COPD_AdjPrev),
            COREM_city = mean(COREM_AdjPrev),
            COREW_city = mean(COREW_AdjPrev),
            CSMOKING_city = mean(CSMOKING_AdjPrev),
            DIABETES_city = mean(DIABETES_AdjPrev),
            HIGHCHOL_city = mean(HIGHCHOL_AdjPrev),
            KIDNEY_city = mean(KIDNEY_AdjPrev),
            LPA_city = mean(LPA_AdjPrev),
            MAMMOUSE_city = mean(MAMMOUSE_AdjPrev),
            MHLTH_city = mean(MHLTH_AdjPrev),
            OBESITY_city = mean(OBESITY_AdjPrev),
            PAPTEST_city = mean(PAPTEST_AdjPrev),
            SLEEP_city = mean(SLEEP_AdjPrev),
            STROKE_city = mean(STROKE_AdjPrev)) %>% 
  mutate(long = as.numeric(substr(Geolocation, 18,31)),
         lati = as.numeric(substr(Geolocation, 2,15)))

summary_city1 <- left_join(summary_city, city_selection, by = c("city_matched" = "city_lower"))
summary_city1 <- summary_city1 %>% unite(label, PlaceName, State ,sep = ", ", remove = FALSE)
summary_city1 <- summary_city1 %>% select(-Geolocation)

exclude <- summary_city1 %>% filter(!(is.na(mean_rating))) %>% filter(State != "AK", State != "HI")

write.csv(exclude, "/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/new_shiny_dashboard/exclude.csv",row.names= FALSE)

for (i in 9:32) {
  print(i)
  print(max(exclude[i]))
}


leaflet(data = exclude) %>%
  addProviderTiles("Esri.WorldGrayCanvas") %>%  # Add default OpenStreetMap map tiles
  addCircleMarkers(lng = exclude$long, lat = exclude$lati, label = exclude$label,
                   radius = exclude$hosp_count, color = ifelse(exclude$mean_rating==5,"Blue",ifelse(exclude$mean_rating==4,"Green",ifelse(exclude$mean_rating==3,"Gold",ifelse(exclude$mean_rating==2,"Orange","Red"))))) %>%
  addLegend("bottomright", colors = c("Blue", "Green", "Yellow", "Orange","Red"), title = "Hospital Rating", labels = c("5 Stars", "4 Stars","3 Stars","2 Stars","1 Star"))

CreateContTable(vars = c("hcoverage_city", "BINGE_city", "BPMED_city", "CHECKUP_city", "CHOLSCREEN_city",
                         "COLONSCREEN_city", "COREM_city","COREW_city", "CSMOKING_city", "LPA_city",
                         "MAMMOUSE_city", "OBESITY_city", "SLEEP_city", "PAPTEST_city", "BPHIGH_city",
                         "CANCER_city", "CASTHMA_city", "CHD_city", "COPD_city", "DIABETES_city", 
                         "HIGHCHOL_city", "MHLTH_city", "STROKE_city"), 
                strata = "mean_rating",
                data = exclude)
a <- aov(hcoverage_city ~ factor(mean_rating), data = exclude)
summary(a)

graph_box <- function(var) {
  g <- ggplot(data = exclude, aes(x= factor(mean_rating), y = exclude[,var])) + geom_boxplot() +
    ggtitle(var) + xlab("Overall Star Rating") + ylab("Prevalence %")
  g
}
exclude$mean_rating
g <- ggplot(data = exclude, aes(x = hcoverage_city)) + geom_density(aes(color = factor(mean_rating)))
g

graph_den <-function(var) {
  g <- ggplot(data = exclude, aes(x = exclude[,var])) + geom_density(aes(fill = factor(mean_rating)))
  g
}

graph_den("hcoverage_city")

graph_box("hcoverage_city")
graph_box("COLONSCREEN_city")
graph_box("COREM_city")
graph_box("COREW_city")


graph_box("BINGE_city")
graph_box("CSMOKING_city")
graph_box("LPA_city")
graph_box("SLEEP_city")


graph_box("BPHIGH_city")
graph_box("CASTHMA_city")
graph_box("COPD_city")
graph_box("CHD_city")
graph_box("DIABETES_city")
graph_box("HIGHCHOL_city")
graph_box("MHLTH_city")
graph_box("STROKE_city")

local_level <- read.csv("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/data/local_data.csv",
                        stringsAsFactors = FALSE)
national <- local_level %>% 
  filter(StateAbbr == "US", DataValueTypeID =="AgeAdjPrv") %>%
  select(MeasureId, StateAbbr, Data_Value) %>%
  unite(Mes,MeasureId,StateAbbr,sep="_") %>%
  spread(Mes,Data_Value) %>%
  mutate(hcoverage_US = 100-ACCESS2_US) %>%
  select(hcoverage_US, BINGE_US, BPHIGH_US, BPMED_US, CANCER_US,
         CASTHMA_US, CHD_US, CHECKUP_US, CHOLSCREEN_US, COLONSCREEN_US = COLON_SCREEN_US,
         COPD_US, COREM_US, COREW_US, CSMOKING_US, DIABETES_US, HIGHCHOL_US,KIDNEY_US, LPA_US,
         MAMMOUSE_US, MHLTH_US,OBESITY_US, PAPTEST_US, SLEEP_US, STROKE_US) %>% 
  gather(varname, Data_value, 1:24)


national
write.csv(national, "/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/new_shiny_dashboard/national.csv",row.names= FALSE)

final_corr <- exclude[,9:32]
M <- cor(final_corr, use = "pairwise.complete.obs",method="pearson")
M
corrplot(M, method="circle", type='upper')
a <-geocode("9729 Val Street Temple City CA91780")

require(devtools)  
devtools::install_github(repo = 'rCarto/photon')  
library(photon)

city_hosp <- city_hosp %>% filter(State!="HI", State!="AK")
address_book <- city_hosp %>% select(Hospital.Name, Address, PlaceName, State, ZIP.Code) %>% 
  filter(State != "HI", State != "AK") %>%
  unite(f_address, Address, PlaceName, State, ZIP.Code, sep = " ")
View(city_hosp)

for (i in 1:1425) {
  if (is.na(address_book[i,"long"]) == TRUE) {
    a <- ggmap::geocode(address_book[i,"f_address"])
    address_book[i,"long"] <- a$lon
    address_book[i,"lati"] <- a$lat
  }
}

a <- geocode("4301 W Markham St, Little Rock, AR 72205",limit=1)
address_book[66,"long"] <- a$lon
address_book[66,"lati"] <- a$lat

b <- geocode("1 Children's Way, Little Rock, AR 72202", limit = 1)
address_book[75,"long"] <- b$lon
address_book[75,"lati"] <- b$lat

c <- geocode("5555 Grossmont Center Dr, La Mesa, CA 91942", limit = 1)
address_book[83,"long"] <- c$lon
address_book[83,"lati"] <- c$lat

d <- geocode("505 Parnassus Ave San Francisco CA 94143", limit = 1)
address_book[207,"long"] <- d$lon
address_book[207,"lati"] <- d$lat

e <- ggmap::geocode("207 Old Lexington Rd, Thomasville, NC 27360")
address_book[911,"long"] <- e$lon
address_book[911,"lati"] <- e$lat

f <- ggmap::geocode("2131 S 17th St, Wilmington, NC 28401")
address_book[917,"long"] <- f$lon
address_book[917,"lati"] <- f$lat

g <- ggmap::geocode("1325 S Cliff Ave, Sioux Falls, SD 57105")
address_book[1101,"long"] <- g$lon
address_book[1101,"lati"] <- g$lat

h <- ggmap::geocode("353 Fairmont Blvd, Rapid City, SD 57701")
address_book[1103,"long"] <- h$lon
address_book[1103,"lati"] <- h$lat

i <- ggmap::geocode("3533 S ALAMEDA st Corpus Christi TX 78411")
address_book[1281,"long"] <- i$lon
address_book[1281,"lati"] <- i$lat

j <- ggmap::geocode("401 N 11th St, Richmond, VA 23298")
address_book[1315,"long"] <- j$lon
address_book[1315,"lati"] <- j$lat

k <- geocode("317 M.L.K. Jr Way, Tacoma, WA 98403", limit = 1)
address_book[1359,"long"] <- k$lon
address_book[1359,"lati"] <- k$lat

a <- "5555 GROSSMONT CENTER DRIVE BOX 58 San Diego CA 91942"
nchar(a)
substr(a,(nchar(a)-7), (nchar(a)-6))

address_book <- address_book %>% mutate(state = substr(f_address,(nchar(f_address)-7),(nchar(f_address)-6)))
View(address_book)

names(city_hosp)
city_hosp <- left_join(city_hosp,address_book, by = c("Hospital.Name"="Hospital.Name","State" = "state"))
View(city_hosp)
city_hosp <- city_hosp %>% unite(label, PlaceName, State,remove = FALSE, sep = ", ")


city_hosp[1062,"long.x"] <- -75.19396
city_hosp[1062,"lati.x"] <- 39.94891
city_hosp[1086,"long.x"] <- -75.19396
city_hosp[1086,"lati.x"] <- 39.94891
city_hosp[978,"long.x"] <- -83.16561
city_hosp[978,"lati.x"] <- 40.10208
city_hosp[city_hosp$label == "Columbus, OH",]
write.csv(city_hosp,"/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/new_shiny_dashboard/city_hosp.csv",row.names= FALSE)


city_specific <- city_hosp %>% filter(label == "Los Angeles, CA")
ggplot(data = city_specific, aes(x = Hospital.overall.rating)) + geom_bar() + 
  ggtitle("Hospital Overall Rating") + theme_few() + ylab("Count") + xlab("Rating") +
  scale_x_discrete(drop=FALSE)

tract_level <- read.csv("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/data/tract_level.csv",
                        stringsAsFactors = F)
tract_level <- tract_level %>% 
  select(StateAbbr, PlaceName, TractFIPS, population2010, Geolocation, ends_with("_CrudePrev")) %>%
  mutate(TractFIPS = str_pad(as.character(TractFIPS), 11, pad = "0"),
         TractFIPS = paste(paste("1400000US", TractFIPS, sep = ""))) %>%
  mutate(long = as.numeric(substr(Geolocation, 18,31)),
         lati = as.numeric(substr(Geolocation, 2,15)))
names(tract_level)
state_list <- exclude %>% group_by(State, PlaceName) %>% summarise(count=n())
View(state_list %>% group_by(State) %>% summarise(count=n()))
dim(state_list)

names(state_list)
names(tract_level)
place_tract <- left_join(state_list, tract_level, by = c("PlaceName"="PlaceName","State" = "StateAbbr"))
place_tract <- place_tract %>% unite(label, PlaceName, State, sep = ", ", remove = FALSE)

filepath = c()
layername = c()
for (i in c(1,4:6, 8:13, 16:42, 44:51, 53:56)){
  str_num = str_pad(as.character(i), 2, pad = "0")
  filedsn = paste0("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/censustract/gz_2010_",str_num,"_140_00_500k")
  filepath = c(filepath,filedsn)
  layer1 = paste0("gz_2010_",str_num,"_140_00_500k")
  layername = c(layername, layer1)
}

for (i in (1:length(filepath))) {
  data_name = paste0("censustract",as.character(i))
  assign(data_name, readOGR(dsn = filepath[i],layer=layername[i]))
}

dataframe_list = c()
for (i in (1:49)) {
  data_name = paste0("censustract", as.character(i))
  dataframe_list = c(dataframe_list, data_name)
}

command_line <- c()
for (i in (1:length(dataframe_list))) {
  a <- paste0(dataframe_list[i], "<-","fortify(",dataframe_list[i],", region = 'GEO_ID')")
  command_line <- c(command_line, a)
}

censustract1<-fortify(censustract1, region = 'GEO_ID')
censustract2<-fortify(censustract2, region = 'GEO_ID')
censustract3<-fortify(censustract3, region = 'GEO_ID')
censustract4<-fortify(censustract4, region = 'GEO_ID')
censustract5<-fortify(censustract5, region = 'GEO_ID')
censustract6<-fortify(censustract6, region = 'GEO_ID')
censustract7<-fortify(censustract7, region = 'GEO_ID')
censustract8<-fortify(censustract8, region = 'GEO_ID')
censustract9<-fortify(censustract9, region = 'GEO_ID')
censustract10<-fortify(censustract10, region = 'GEO_ID')
censustract11<-fortify(censustract11, region = 'GEO_ID')
censustract12<-fortify(censustract12, region = 'GEO_ID')
censustract13<-fortify(censustract13, region = 'GEO_ID')
censustract14<-fortify(censustract14, region = 'GEO_ID')
censustract15<-fortify(censustract15, region = 'GEO_ID')
censustract16<-fortify(censustract16, region = 'GEO_ID')
censustract17<-fortify(censustract17, region = 'GEO_ID')
censustract18<-fortify(censustract18, region = 'GEO_ID')
censustract19<-fortify(censustract19, region = 'GEO_ID')
censustract20<-fortify(censustract20, region = 'GEO_ID')
censustract21<-fortify(censustract21, region = 'GEO_ID')
censustract22<-fortify(censustract22, region = 'GEO_ID')
censustract23<-fortify(censustract23, region = 'GEO_ID')
censustract24<-fortify(censustract24, region = 'GEO_ID')
censustract25<-fortify(censustract25, region = 'GEO_ID')
censustract26<-fortify(censustract26, region = 'GEO_ID')
censustract27<-fortify(censustract27, region = 'GEO_ID')
censustract28<-fortify(censustract28, region = 'GEO_ID')
censustract29<-fortify(censustract29, region = 'GEO_ID')
censustract30<-fortify(censustract30, region = 'GEO_ID')
censustract31<-fortify(censustract31, region = 'GEO_ID')
censustract32<-fortify(censustract32, region = 'GEO_ID')
censustract33<-fortify(censustract33, region = 'GEO_ID')
censustract34<-fortify(censustract34, region = 'GEO_ID')
censustract35<-fortify(censustract35, region = 'GEO_ID')
censustract36<-fortify(censustract36, region = 'GEO_ID')
censustract37<-fortify(censustract37, region = 'GEO_ID')
censustract38<-fortify(censustract38, region = 'GEO_ID')
censustract39<-fortify(censustract39, region = 'GEO_ID')
censustract40<-fortify(censustract40, region = 'GEO_ID')
censustract41<-fortify(censustract41, region = 'GEO_ID')
censustract42<-fortify(censustract42, region = 'GEO_ID')
censustract43<-fortify(censustract43, region = 'GEO_ID')
censustract44<-fortify(censustract44, region = 'GEO_ID')
censustract45<-fortify(censustract45, region = 'GEO_ID')
censustract46<-fortify(censustract46, region = 'GEO_ID')
censustract47<-fortify(censustract47, region = 'GEO_ID')
censustract48<-fortify(censustract48, region = 'GEO_ID')
censustract49<-fortify(censustract49, region = 'GEO_ID')

paste(dataframe_list, collapse = ", ")

data_list <- list(censustract1, censustract2, censustract3, censustract4, censustract5, censustract6,
                  censustract7, censustract8, censustract9, censustract10, censustract11, censustract12,
                  censustract13, censustract14, censustract15, censustract16, censustract17, censustract18,
                  censustract19, censustract20, censustract21, censustract22, censustract23, censustract24,
                  censustract25, censustract26, censustract27, censustract28, censustract29, censustract30,
                  censustract31, censustract32, censustract33, censustract34, censustract35, censustract36,
                  censustract37, censustract38, censustract39, censustract40, censustract41, censustract42, 
                  censustract43, censustract44, censustract45, censustract46, censustract47, censustract48,
                  censustract49)

total <- do.call("rbind",data_list)

write.csv(total,"/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/data/total.csv",row.names= FALSE)

place_tract <- place_tract %>% rename(long_ori = long,
                                      lati_ori = lati)

top_30_list <- exclude %>% arrange(desc(Population_city)) %>% select(label) %>% head(30)
top_30_city <- unique(top_30_list$label)

only_30 <- left_join(top_30_list, place_tract, by = c("label" = "label"))
View(only_30)

total <- read.csv("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/data/total.csv", stringsAsFactors = FALSE)

plotdata <- left_join(only_30, total, by = c("TractFIPS" = "id"))

for (i in (8:35)){
  plotdata[i] = plotdata[i]/100
}

plotdata <- plotdata %>% mutate(hcoverage_CrudePrev = 1 - ACCESS2_CrudePrev) 
write.csv(plotdata,"/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/new_shiny_dashboard/plotdata.csv",row.names= FALSE)

library(dplyr)
library(ggplot2)
library(leaflet)

plotdata <- read.csv("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/new_shiny_dashboard/plotdata.csv", stringsAsFactors = FALSE)

plotdata1 <- plotdata %>% filter(label == "Philadelphia, PA")
city_hosp1 <- city_hosp %>% filter(label == "Philadelphia, PA")
city_hosp1
cols <- c("1" = "red", "2" = "orange", "3" = "yellow", "4" = "green", "5" = "blue")

p <- ggplot() +
  geom_polygon(data = plotdata1, aes(x = long, y = lat, group = group,
                                    fill = hcoverage_CrudePrev), color = "white", size = 0.25) +
  coord_map() + 
  geom_point(data = city_hosp1, aes(x = long.x, y = lati.x, color = factor(city_hosp1$Hospital.overall.rating)), size = 3) +
  theme_few() + scale_color_manual(values = cols, limits = c("1", "2","3","4","5")) +
  scale_fill_gradient(low = "white", high = "black") +
  guides(fill = guide_legend(title="Health Insurance Coverage")) +
  guides(color = guide_legend(title="Hospital Rating")) + ggtitle("New York City")
p


city_perf <- exclude %>%
  select(label, ends_with("_city")) %>%
  gather(varname, Data_value, 3:27) %>%
  filter(label == "New York, NY") %>%
  select(varname, Data_value) %>% 
  filter(varname != "ACCESS2_city")
View(city_perf)
total_perf <- rbind(city_perf, national) %>% separate(varname, into = c("mea", "level"))
national
total_perf
graphing$Measure[graphing$mea == "hcoverage"] = "Health Insurance Coverage"
graphing$Measure[graphing$mea == "COLONSCREEN"] = "Colorectal Cancer Screening"
graphing$Measure[graphing$mea == "COREM"] = "Preventative Care (Elderly Men)"
graphing$Measure[graphing$mea == "COREW"] = "Preventative Care (Elderly Women)"

graphing$Measure[graphing$mea == "BINGE"] = "Binge Drinking"
graphing$Measure[graphing$mea == "CSMOKING"] = "Smoking"
graphing$Measure[graphing$mea == "LPA"] = "Insufficient Exercise"
graphing$Measure[graphing$mea == "SLEEP"] = "Insufficient Sleep"

graphing$Measure[graphing$mea == "BPHIGH"] = "High Blood Pressure"
graphing$Measure[graphing$mea == "CASTHMA"] = "Asthma"
graphing$Measure[graphing$mea == "COPD"] = "COPD"
graphing$Measure[graphing$mea == "CHD"] = "CHD"
graphing$Measure[graphing$mea == "DIABETES"] = "Diabetes"
graphing$Measure[graphing$mea == "HIGHCHOL"] = "High Cholesterol"
graphing$Measure[graphing$mea == "MHLTH"] = "Mental Health"
graphing$Measure[graphing$mea == "STROKE"] = "Stroke"

graphing
prevention_list <- c("hcoverage","COLONSCREEN","COREM","COREW")
behavior_list <- c("BINGE","CSMOKING","LPA","SLEEP")
disease_list <- c("BPHIGH","CASTHMA","COPD","CHD","DIABETES","HIGHCHOL","MLHTH","STROKE")

bar<-graphing %>% filter(mea %in% prevention_list, label == "US", label == "New York, NY")

ggplot(data = bar, aes(x = reorder(Measure,-Data_value), y = Data_value, fill=level)) +
  geom_bar(stat = "identity", position=position_dodge()) + coord_flip() + ggtitle("Health Behavior") +
  theme_few() + ylab("Prevalence") + xlab("Prevention")


?gather
names(exclude)
  
national



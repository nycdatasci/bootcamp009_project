library(data.table)
library(geojsonio)
nyparking_data <- fread("nyparking_data.csv")
colnames(nyparking_data)
nyparking_data$`Fine Amount`<-as.factor(nyparking_data$`Fine Amount`)
nyparking_data$Precinct<-as.factor(nyparking_data$Precinct)
nyparking_data$`Issue Month`<-as.factor(nyparking_data$`Issue Month`)
nyparking_data$`Violation Code`<-as.factor(nyparking_data$`Violation Code`)
nyparking_data$`Vehicle Year`<-as.factor(nyparking_data$`Vehicle Year`)
nyparking_data$`Report Year`<-as.factor(nyparking_data$`Report Year`)
precinct_map<-''
precinct_map<- geojsonio::geojson_read("~/NYC Data Science Academy/NY Parking Dashboard/Police_Precincts.geojson",
                                       what = "sp")                                       

precinct_map_df = as.data.frame(precinct_map)
precinct_map_df$precinct<-as.character(precinct_map_df$precinct)
precinct_data<-''
precinct_data<-
  filter(nyparking_data,Item=="Precinct")%>%
  select(n,total_fine,Precinct,`Fiscal Year`)

precinct_data$Precinct<-as.character(precinct_data$Precinct)

precinct_map_df = left_join(precinct_map_df,
                            precinct_data,
                            by = c("precinct" = "Precinct"))

colnames(precinct_map_df)

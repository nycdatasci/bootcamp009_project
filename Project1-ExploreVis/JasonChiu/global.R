library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tableone)
library(corrplot)
library(Hmisc)
library(leaflet)
library(ggthemes)
library(shinydashboard)
library(plotly)
library(RColorBrewer)

exclude <- read.csv("./exclude.csv")

city_hosp <- read.csv("./city_hosp.csv")

national <- read.csv("./national.csv")

city_hosp <- city_hosp %>% filter(Hospital.Name!= "GOOD SAMARITAN HOSPITAL")

plotdata <- read.csv("./plotdata.csv", stringsAsFactors = FALSE)

city_hosp$Hospital.overall.rating <- factor(city_hosp$Hospital.overall.rating,
                                            levels = c("1","2","3","4","5"),
                                            ordered = TRUE)

top_30_list <- exclude %>% arrange(desc(Population_city)) %>% select(label) %>% head(30)
top_30_city <- unique(top_30_list$label)

var_list <- names(exclude)[9:32]

prevention_list <- c("hcoverage","COLONSCREEN","COREM","COREW")
behavior_list <- c("BINGE","CSMOKING","LPA","SLEEP")
disease_list <- c("BPHIGH","CASTHMA","COPD","CHD","DIABETES","HIGHCHOL","MLHTH","STROKE")


name_list <- c("Health Insurance Coverage", "Binge Drinking", "High Blood Pressure Prevalence",
               "Blood Pressure Meds",
               "Cancer Prevalence", "Asthma Prevalence", "Coronary Heart Disease Prevalence", 
               "Routine Health Check Up", "Cholesterol Screening", "Colorectal Cancer Screening", 
               "COPD Prevalence", "Preventative Care Coverage among Elderly Men", 
               "Preventative Care Coverage among Elderly Women",
               "Smoking","Diabetes Prevalence", "High Cholesterol Prevalence", 
               "Chronic Kidney Disease Prevalence", "Insufficient Exercise","Breast Cancer Screening",
               "Mental Health Conditions Prevalence", "Obesity", "Cervical Cancer Screening",
               "Insufficient Sleep","Stroke Prevalence")

notes_list <- c("% of adults (>= 18)","% of adults (>= 18)", 
                "% of adults (>= 18)", "% of adults (>= 18) with high blood pressure",
                "% of adults (>= 18)", "% of adults (>= 18)", "% of adults (>= 18)",
                "% of adults (>= 18)",
                "% of adults (>= 18)", "% of adults (>= 18)",
                "% of adults (>= 18)", 
                "% of male aged ≥ 65 years", 
                "% of female aged ≥ 65 years",
                "% of adults (>= 18)","% of adults (>= 18)",
                "% of adults (>= 18)",
                "% of adults (>= 18)",
                "% of adults (>= 18)",
                "% of adults (>= 18)",
                "% of adults (>= 18)", 
                "% of adult women aged 21–65 years",
                "% of adults (>= 18)",
                "% of adults (>= 18)","% of adults (>= 18)")

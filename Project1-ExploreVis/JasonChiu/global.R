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

exclude <- read.csv("./exclude.csv")

city_hosp <- read.csv("./city_hosp.csv")
city_hosp$Hospital.overall.rating <- factor(city_hosp$Hospital.overall.rating,
                                            levels = c("1","2","3","4","5"),
                                            ordered = TRUE)

city_list <- unique(exclude$label)

var_list <- names(exclude)[9:32]

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

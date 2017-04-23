library(shiny)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tableone)
library(corrplot)
library(openxlsx)
library(Hmisc)
library(googleVis)
library(leaflet)
library(ggthemes)
library(shinydashboard)

graph_hosp <- read.csv("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/data/graph_hosp.csv")

exclude <- read.csv("/Users/jasonchiu0803/Desktop/data_bootcamp/project_1/data/exclude.csv")

name_list <- c("Healthcare Access","Routine Doctor Checkup","Cholesterol Screening",
               "Colorectal Cancer Screening","Preventative Care among Elderly (Men)",
               "Preventative Care among Elderly (Women)","Breast Cancer Screening", "Cervical Cancer Screening",
<<<<<<< HEAD
               "Binge Drinking","Smoking","No Exercise","Obesity","Insufficient Sleep")
=======
               "Binge Drinking","Smoking","No Exercise","Obesity","Insufficient Sleep","High Bloodpressure Prevalence",
               "Cancer Prevalence","Asthma Prevalence","Coronary Heart Disease Prevalence","Chronic Obstructive Pulmonary Disease Prevalence",
               "Diabetes Prevalence","High Cholesterol","Mental Health Condition Prevalence","Stroke Prevalence")
>>>>>>> ef6b0d9d111f070a260be6500e4502ce5e9d1e6a

notes_list <- c("% of adults with health insurance", "% of adults with routine health checkup within the past year",
                "Cholesterol screening among adults", "Colorectal cancer screening among adults",
                "% of male aged≥65 years who are up to date with preventative services", 
                "% of female aged≥65 years who are up to date with preventative services",
                "Mammography use among women aged 50–74 years", "Papanicolaou smear use among adult women aged 21–65 years",
                "Binge drinking among adults","Current smoking among adults", "No leisure-time physical activity among adults",
<<<<<<< HEAD
                "Obesity among adults", "Sleeping less than 7 hours among adults")
=======
                "Obesity among adults", "Sleeping less than 7 hours among adults", "High Bloodpressure Prevalence",
                "Cancer Prevalence","Asthma Prevalence","Coronary Heart Disease Prevalence","Chronic Obstructive Pulmonary Disease Prevalence",
                "Diabetes Prevalence","High Cholesterol","Mental Health Condition Prevalence","Stroke Prevalence")
>>>>>>> ef6b0d9d111f070a260be6500e4502ce5e9d1e6a


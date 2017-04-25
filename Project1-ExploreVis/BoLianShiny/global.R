library(dplyr)
library(shinydashboard)
library(ggplot2)
library(DT)
library(data.table)

#creat country table

mental=read.csv("mentalsurvey.csv")
gage=ggplot(data = mental, aes(x= age))
country_count <- mental %>%
  group_by(country) %>%
  summarize(count = n())
country= arrange(country_count,desc(count))
country_10=top_n(arrange(country,desc(count)),10)


choice1 <- colnames(mental)[-c(2,3,6,25)]




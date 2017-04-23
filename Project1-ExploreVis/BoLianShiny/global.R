library(dplyr)
library(shinydashboard)
library(ggplot2)


#creat country table

mental=read.csv("mentalsurvey.csv")
gage=ggplot(data = mental, aes(x= age))
country_count <- mental %>%
  group_by(country) %>%
  summarize(count = n())
country= arrange(country_count,desc(count))
country_10=top_n(arrange(country,desc(count)),10)



# load data
state_stat <- data.frame(state.name = rownames(state.x77), state.x77)
# remove row names
rownames(state_stat) <- NULL
# create variable with colnames as choice, no stat name
choice1 <- colnames(mental)[-c(2,3,6,25)]
choice= colnames(state_stat)[-1]

chisq.test(mental$gender,mental$treatment)

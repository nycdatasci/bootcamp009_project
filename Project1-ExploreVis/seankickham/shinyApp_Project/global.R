library(data.table)
library(dplyr)



p = fread('p.csv', 
          stringsAsFactors = FALSE)

p2 = fread('p2.csv', 
           stringsAsFactors = FALSE)

missing_values = fread('missing_values.csv', 
                       stringsAsFactors = FALSE)


p3 = fread('p3.csv', 
           stringsAsFactors = FALSE)
p3$Income = as.numeric(p3$Income)
p3$Height = as.numeric(p3$Height)
p3$Age = as.numeric(p3$Age)
p3$Religion.Serious = as.numeric(p3$Religion.Serious)
p3$Sign.Serious = as.numeric(p3$Sign.Serious)




essays = fread('essays.csv', 
           stringsAsFactors = FALSE)


choice = colnames(p3)


##############################
#### Most basic results ######
##############################

#average male and female

Malep3 = p3 %>% 
  filter(Gender == 'm')

avgMale = sapply(colnames(Malep3), function(i)
  names(sort(table(Malep3[,i]),decreasing = TRUE)[1])
  )

avgMale = cbind(avgMale)


Femalep3 = p3 %>% 
  filter(Gender == 'f')

avgFemale = sapply(colnames(Femalep3), function(i)
  names(sort(table(Femalep3[,i]),decreasing = TRUE)[1])
)

avgFemale = cbind(avgFemale)

average = cbind(avgFemale, avgMale)

# proportion tables & mosaicplots
gender.by.orientation = table(p3$Gender, p3$Orientation)
mosaicplot(gender.by.orientation, shade = TRUE, las = 2)

gender.by.ethnicity = table(p3$Gender, p3$Ethnicity)
mosaicplot(gender.by.ethnicity, shade = TRUE, las = 2)

gender.by.education = table(p3$Gender, p3$Education)
mosaicplot(gender.by.education, main = 'Education by Gender', shade = TRUE, las = 2)

gender.by.drinks = table(p3$Gender, p3$Drinks)
mosaicplot(gender.by.drinks, shade = TRUE, las = 2)

ethnicity.by.education = table(p3$Ethnicity, p3$Education)
mosaicplot(ethnicity.by.education, shade = TRUE, las = 2)

orientation.by.ethnicity = table(p3$Ethnicity, p3$Orientation)
mosaicplot(orientation.by.ethnicity, shade = TRUE, main = 'Orientation by Ethnicity', las = 2)


####

p3 %>% mutate(Age_group = Age %/% 5  * 5) %>% group_by(Age_group) %>% 
  summarise(Avg.Income = mean(Income, na.rm = TRUE))

p3 = p3 %>% mutate(Age_group = Age %/% 5  * 5)


ggplot(p3, aes(x = Age_group)) +
  geom_bar(aes(fill = Drinks), position = 'fill') +
  coord_flip() + xlim(20,70)

ggplot(p3, aes(x = Age_group)) +
  geom_bar(aes(fill = Gender), position = 'fill') +
  coord_flip() + xlim(20,70)


ggplot(p3, aes(x = Age)) +
  geom_density(aes(fill = Gender), position = 'fill') +
  xlim(20,70)

p4 = p3 %>% 
  select(Gender, Age, Orientation, Religion, Religion.Serious) %>% 
  filter(!is.na(Religion.Serious), !is.na(Religion.Serious))
  
ggplot(p4, aes(x = Orientation)) +
  geom_bar(aes(fill = Religion), position = 'fill')

ggplot(p4, aes(x = Orientation)) +
  geom_bar(aes(fill = as.factor(Religion.Serious)), position = 'fill')

# Location = p3 %>% 
#   group_by(Location) %>% 
#   summarise(Observations = n(), Proportion = round(Observations/nrow(p3) * 100)) %>% 
#   arrange(desc(Observations))


#WORD CLOUDS
# library(tm)
# library(SnowballC)
# library(wordcloud)
# library(RColorBrewer)
# 
# essaycorpus = Corpus(VectorSource(profiles[, essay0:essay9]))
# 
# essaycorpus <- tm_map(essaycorpus, PlainTextDocument)
# essaycorpus <- tm_map(essaycorpus, removePunctuation)
# essaycorpus <- tm_map(essaycorpus, removeWords, stopwords('english'))
# essaycorpus <- tm_map(essaycorpus, stemDocument)
# 
# essaycorpus = Corpus(VectorSource(essaycorpus))
# 
# wordcloud(essaycorpus,
#           max.words = 100,
#           random.order = FALSE,
#           colors = brewer.pal(7, 'Greens') )

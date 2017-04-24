library(dplyr)
library(ggplot2)
library(tidyr)
library(plotly)
library(ggvis)


# First load the data set ================== #
nbadata = read.csv("NBA_Height.csv", stringsAsFactors = F)

#Should do some pre-processing to find the NAs and such
# weird stuff:
length((nbadata$SHOT_DIST[nbadata$SHOT_DIST > 23.75 & nbadata$PTS_TYPE == 2]))
length((nbadata$SHOT_DIST[nbadata$SHOT_DIST < 22 & nbadata$PTS_TYPE == 3]))

#Filter out the errant data:
trimmed1 = nbadata %>% 
          filter(.,!((SHOT_DIST > 23.75 & PTS_TYPE == 2) | SHOT_DIST < 22 & PTS_TYPE == 3) & 
                      (SHOT_DIST < 30) & 
                      (SHOT_DIST > 0) &
                      (CLOSE_DEF_DIST > 0) &
                      (CLOSE_DEF_DIST <= 25))

#Add a height disparity column:
trimmed1$heightdisp = trimmed1$SHOOTER_height - trimmed1$DEFENDER_height

#Trim away all the columns we don't need for quantiative analysis:
trimmed2 = subset(trimmed1,select = c(SHOT_DIST,PTS_TYPE,CLOSE_DEF_DIST, FGM,SHOOTER_height))

# Find shot % as a function of shot distance
shotacc = trimmed1 %>%
  group_by(.,SHOT_DIST,PTS_TYPE) %>%
  summarise(.,accuracy = sum(FGM)/n(), count =n())

#basic scatterplot
G1 = ggplot(data = shotacc, aes(x = SHOT_DIST, y = accuracy))
G1 = G1 + geom_point() + xlim(0,31) + xlab("Shot Distance") + ylab("Accuracy") + ggtitle("Accuracy vs. Shot Distance")

#want to investigate why in the 10-20 ft range no appargent decrease in accuracy
CDDvSD = trimmed1 %>%
  group_by(.,SHOT_DIST) %>%
  summarise(.,avgdefdist = mean(CLOSE_DEF_DIST))

#scatterplot of mean(CLOSE_DEF_DIST) vs. SHOT_DIST
s2 = ggplot(data = CDDvSD, aes(x = SHOT_DIST, y = avgdefdist))
s2 = s2 + geom_point() + xlim(0,31) + xlab("Shot Distance") + ylab("AVG Closest Defender Distance") + ggtitle("Average Closest Defender Distance vs. Shot Distance")



#Easiest way to return shot accuracy from original data frame:
trial = trimmed1 %>%
  group_by(.,SHOT_DIST) %>% 
  summarise(.,accuracy = sum(FGM)/n())

#Group_by pts_type so we can show 2 different colors
trial9 = trimmed1 %>%
  group_by(.,SHOT_DIST,PTS_TYPE) %>% 
  summarise(.,accuracy = sum(FGM)/n())

#Color scatterplot, separated by PTS_TYPE
ggplot(trial9, aes(x = SHOT_DIST, y = accuracy)) + geom_point(aes(color = as.character(PTS_TYPE)))

#Cut the original data by SHOT_DIST bins only
 # arrange(as.numeric(gr))

#Binned SHOT_DIST vs. CDD
trial5 = trimmed1 %>%
  group_by(SHOT_DIST=cut(SHOT_DIST, breaks= seq(0, 30, by = 3))) %>%
  summarise(.,accuracy = sum(FGM)/n(), MCDD = mean(CLOSE_DEF_DIST))
trial5

#Cut the original data by CLOSE_DEF_DIST bins only
trial6 = trimmed1 %>%
  group_by(CLOSE_DEF_DIST= cut(CLOSE_DEF_DIST, breaks = seq(0, 10, by = 1))) %>%
  summarise(.,mean(SHOT_DIST))
trial6

#GROUP_BY both variables, BIN both variables to prep for heat_map
trial2 = trimmed1 %>%
  group_by(SHOT_DIST = cut(SHOT_DIST, breaks = seq(0,30,by = 3)),
           CLOSE_DEF_DIST= cut(CLOSE_DEF_DIST, breaks = seq(0, 10, by = 1))) %>%
           summarise(.,accuracy = sum(FGM)/n(), count = n())
trial2

#Histogram for data set distribution
h1 = ggplot(data = trimmed1, aes(x = SHOT_DIST))+ geom_histogram(breaks = seq(0,30,by = 3))
h2 = ggplot(data = trimmed1, aes(x = CLOSE_DEF_DIST)) + geom_histogram(breaks = seq(0,30, by = 1))
G6 = ggplot(data = trimmed1, aes(x = SHOOTER_height)) + geom_histogram(bins = 15)

#Density curves for the same stuff
G4 = ggplot(data = trimmed1, aes(x = SHOT_DIST)) + geom_density()
G5 = ggplot(data = trimmed1, aes(x = CLOSE_DEF_DIST)) + geom_density()

# Heat map distribution
test1 = trimmed1 %>%
  group_by(.,SHOT_DIST,CLOSE_DEF_DIST) %>%
  summarise(., accuracy = sum(FGM)/n(),count = n())

#Changing NAs to the desire name in the factors column of trial2
T = as.character(trial2$CLOSE_DEF_DIST)
T[is.na(T)] = "10+"
T2 = as.factor(T)
trial2$CLOSE_DEF_DIST = T2

G7 = plot_ly(test1, x = ~SHOT_DIST, y = ~CLOSE_DEF_DIST, z = ~count) %>% 
  add_heatmap() %>%
  colorbar(title = "Count distribution")

#Heat map accuracy
G10 = plot_ly(trial2, x = ~SHOT_DIST, y = ~CLOSE_DEF_DIST, z = ~accuracy)%>% 
  add_heatmap() %>%
  colorbar(title = "Accuracy")


# Series of graphs conveying Accuracy vs SHOT_DIST/CLOSE_DEF_DIST
ggplot(trial2, aes(x = SHOT_DIST, y = accuracy))+geom_point()+facet_wrap(~ CLOSE_DEF_DIST) +
  xlab("Shot Distance")+ggtitle("Accuracy vs. Shot Distance for ~constant Closest Defender Distance")
ggplot(trial2, aes(x = CLOSE_DEF_DIST, y = accuracy))+geom_point()+facet_wrap(~ SHOT_DIST)


#Now let's look at expected value of shot based on SHOT_DIST alone:
EVofSD = trimmed1 %>%
  group_by(.,SHOT_DIST,PTS_TYPE) %>%
  summarise(.,accuracy = sum(SHOT_RESULT =="made")/n())

#Define EV 
EVofSD$ev = EVofSD$PTS_TYPE * EVofSD$accuracy

#Plot of EV
G13 = ggplot(EVofSD, aes(x = SHOT_DIST, y = ev)) + geom_point(aes(color = as.character(PTS_TYPE))) + xlab("Shot Distance") + ylab("Expected Value") + ggtitle("Expected Value vs. Shot Distance")


#distribution of shot selection by height:
# all heights
ggplot(data = trimmed1, aes(x = SHOT_DIST)) + geom_density()
#individually, all heights
ggplot(data = trimmed1, aes(x = SHOT_DIST)) + geom_density()+facet_wrap(~ SHOOTER_height)
ggplot(data = filter(trimmed1,SHOOTER_height == 73), aes(x = SHOT_DIST)) + geom_density()
ggplot(data = filter(trimmed1,SHOOTER_height == 85), aes(x = SHOT_DIST)) + geom_density()

#mean shot distance by height:
trimmed1 %>%
  group_by(.,SHOOTER_height) %>%
  summarise(.,mean(SHOT_DIST))

# mean accuracy of different shooter heights
#crude mean accuracy by shooter height only
trial13 = trimmed1 %>% 
  group_by(.,SHOOTER_height) %>%
  summarise(.,accuracy = sum(FGM)/n())

G2 = ggplot(trial13, aes(x = SHOOTER_height, y = accuracy)) + geom_point() + xlab("Shooter Height") + ylab("Accuracy")

#Mean accuracy vs CLOSE_DEF_DIST:
trial14 = trimmed1 %>%
  group_by(.,CLOSE_DEF_DIST) %>%
  summarise(., accuracy = sum(FGM)/n())

G3 = ggplot(trial14, aes(x = CLOSE_DEF_DIST, y = accuracy)) + geom_point()

# mean accuracy for shooter height vs shot distance + frequency of shot selection

trial10 = trimmed1 %>% 
  group_by(.,SHOOTER_height, SHOT_DIST = cut(SHOT_DIST, breaks= seq(0, 30, by = 3))) %>%
  summarise(.,accuracy = sum(FGM)/n(), count = n()) %>%
  mutate(freq = count / sum(count))

trial12 = trimmed1 %>% 
  group_by(.,SHOOTER_height, CLOSE_DEF_DIST = cut(CLOSE_DEF_DIST, breaks= c(seq(0, 10, by = 1),30))) %>%
             summarise(.,accuracy = sum(FGM)/n(), count = n()) %>%
             mutate(freq = count / sum(count))

#HEATmaps of the previous 2 attributes (frequency,accuracy)
G8 = plot_ly(trial10, x = ~SHOOTER_height, y = ~SHOT_DIST, z = ~freq) %>% 
  add_heatmap() %>%
  colorbar(title = "relative frequency")

G11 = plot_ly(trial10, x = ~SHOOTER_height, y = ~SHOT_DIST, z = ~accuracy) %>% 
  add_heatmap() %>%
  colorbar(title = "accuracy")

#Why do short players seem to be equally effective at short range/tall players long:
#Let's look how closely theyre guarded

trial11 = trimmed1 %>% 
  group_by(.,SHOOTER_height, SHOT_DIST = cut(SHOT_DIST, breaks= seq(0, 30, by = 3))) %>%
  summarise(.,MCDD = mean(CLOSE_DEF_DIST))

#Heatmap of mean close_def_dist as a function of player height and shot_distance.
MCDD = plot_ly(trial11, x = ~SHOOTER_height, y = ~SHOT_DIST, z = ~MCDD) %>% 
  add_heatmap() %>%
  colorbar(title = "MCDD")

#Heatmap of shooter_height and close_dd frequency
G9 = plot_ly(trial12, x = ~SHOOTER_height, y = ~CLOSE_DEF_DIST, z = ~freq) %>% 
  add_heatmap() %>%
  colorbar(title = "relative frequency")

G12 = plot_ly(trial12, x = ~SHOOTER_height, y = ~CLOSE_DEF_DIST, z = ~accuracy) %>% 
  add_heatmap() %>%
  colorbar(title = "accuracy")


# trimmed1 %>% 
#   group_by_(.,input$selected6a) %>%
#   summarise_(Num = interp(~mean(var),var = as.name(input$selected6b)))
# 
# 
# 
# as.data.table(trimmed1)[,.(avg=mean(input$selected6b)),by=input$selected6a] %>% 
#   ggplot(.,aes(x = input$selected6a, y = avg)) + geom_point()
#   group_by(.,input$selected6a) %>%
#   summarise(.,mean(input$selected6b))
# 
# ggplot()


# trimmed3 = trimmed1 %>%
#   group_by(.,player_name) %>%
#   summarize(., FG.Percent = sum(FGM)/n(), FG.Count = n())
# 
# trimmed4 = filter(trimmed1, PTS_TYPE == "3") %>%
#   group_by(.,player_name) %>%
#   summarize(., ThreePoint.Percent = sum(FGM)/n(), Three.Count = n())
# 
# trimmed5 = inner_join(trimmed3,trimmed4, by = "player_name")
# topshooters = trimmed5

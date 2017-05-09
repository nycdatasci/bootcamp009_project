### Batters
library(dplyr)

batters <- read.csv("batters_final.csv", header = TRUE)
summary(batters)
str(batters)


# Let's estimate the number of games they played. We'll say that for every 4 PAs, one
# game was played. We can round it up.
# I used google sheets for this since it was easier. There were only 3 players with games
# missing, and they were old school from the late 1800/early 1900s.


# Note!!! I imputed -999 for any missing Ks and BBs

colSums(is.na(batters))
# There are 269 missing runs, 304 missing rbi's, 359 missing sb's, and 2303 missing IBBs.
# First off, I think that because IBBs happen so rarely, I will replace the missing ones
# with 0.
batters$ibb <- ifelse(is.na(batters$ibb), 0, batters$ibb)
summary(batters$ibb)

# Impute missing RBIs, SBs, and runs with the overall
# number of runs per pa, rbi per pa, and sb per pa. Actually, Ill do that with with Ks
# and BBs for any value I imputed with 999
# ACTUALLY, why should I estimate this? If the HOF didn't have this data to go off, 
# then why should I make any assumptions? We should work with the same data.

batters$runs <- ifelse(is.na(batters$runs), 0, batters$runs)
batters$rbi <- ifelse(is.na(batters$rbi), 0, batters$rbi)
batters$sb <- ifelse(is.na(batters$sb), 0, batters$sb)

# For 999 values
batters$bb <- ifelse(batters$bb == -999, 0, batters$bb)
batters$so <- ifelse(batters$so == -999, 0, batters$so)

# recalculate bb_rate and so_rate
batters$bb_rate = batters$bb / batters$pa
batters$so_rate = batters$so / batters$pa


career_hof <- batters %>% group_by(name) %>%
  summarise(seasons = n(),
            last_year = max(year),
            games_played = sum(games),
            total_pa = sum(pa),
            total_ab = sum(ab),
            total_runs = sum(runs),
            total_hits = sum(hits),
            total_hr = sum(hr),
            total_rbi = sum(rbi),
            total_sb = sum(sb),
            total_bb = sum(bb),
            total_so = sum(so),
            total_ibb = sum(ibb),
            total_tb = sum(tb),
            career_ba = total_hits / total_ab,
            career_obp = (total_hits + total_bb + total_ibb) / total_pa,
            career_slg = total_tb / total_ab,
            total_ops = career_obp + career_slg,
            ov_bb_rate = total_bb / total_pa,
            ov_so_rate = total_so / total_pa
            )

write(career_hof)

# Okay. Now the fun part. We'll want to add a column full of # 1's so that we can 
# distinguish between the other data that we're about to join with this set. That way,
# we can have a decent set of training data. We'll take the totals like we did above,
# and then rbind.

# Note!! All these batters are NOT in the HOF (thank you baseball-reference)
recent_batters <- read.csv("players_since_1989_500_pas.csv", header = TRUE)

# No missing values. My lucky day.

recent_careers <- recent_batters %>% group_by(name) %>%
  summarise(seasons = n(),
            last_year = max(year),
            games_played = sum(games),
            total_pa = sum(pa),
            total_ab = sum(ab),
            total_runs = sum(runs),
            total_hits = sum(hits),
            total_hr = sum(hr),
            total_rbi = sum(rbi),
            total_sb = sum(sb),
            total_bb = sum(bb),
            total_so = sum(so),
            total_ibb = sum(ibb),
            career_ba = total_hits / total_ab,
            career_obp = (total_hits + total_bb + total_ibb) / total_pa,
            career_slg = mean(slg), # take avg b/c we don't have tb
            total_ops = career_obp + career_slg,
            ov_bb_rate = total_bb / total_pa,
            ov_so_rate = total_so / total_pa
  )

# Add column with ones to career_hof, and 0 to recent_careers
# Drop the total_tb column first from career_hof
career_hof <- career_hof %>% select(-total_tb)
career_hof$hof = 1
recent_careers$hof = 0

# Okay. Let's join
combined_data <- rbind(career_hof, recent_careers)
summary(combined_data)

# Make a few more vars. PAs/season, Hits/season, HR/season, RBI/season, SB/season
combined_data$pa_p_season = combined_data$total_pa / combined_data$seasons
combined_data$hits_p_season = combined_data$total_hits / combined_data$seasons
combined_data$hr_p_season = combined_data$total_hr / combined_data$seasons
combined_data$rbi_p_season = combined_data$total_rbi / combined_data$seasons
combined_data$sb_p_season = combined_data$total_sb / combined_data$seasons

# Okay. Let's make the training set any player with last_year played 2011 and before.
# the Test set will be 2012 and over
hof_train <- combined_data %>% filter(last_year <= 2011)
hof_test <- combined_data %>% filter(last_year > 2011)

#take out names and year to create glm model

nonvars = c("last_year","name")

#remove the nonvars from training and tes set

hof_train = hof_train[,!(names(hof_train) %in% nonvars)]
hof_test = hof_test[,!(names(hof_test) %in% nonvars)]

#first model

hofLog1 = glm(hof ~., data=hof_train, family=binomial)
summary(hofLog1)

# Okay, I think I'm overfitting. Let's redo this without including every variable. 
# I think what is most significant will be :
# seasons, games_played, total_ab, total_hits, total_hr, total_sb, career_ba,
# career_obp, career_slg, total_ops, ov_bb_rate, ov_so_rate

# We can determine which vars are highly correlated and remove correlated ones so that
# we avoid multicollinearity (I think that's how it works)

View(cor(hof_train))

hofLog2 = glm(hof ~ hits_p_season + career_ba  +
                rbi_p_season + sb_p_season + total_ops +
                ov_bb_rate + ov_so_rate, data=hof_train, family=binomial)
summary(hofLog2) #AIC = 221

# ^ I feel pretty good about this model, although the AIC is on the higher side, it's
# not much different when I exclude career_ba, and we're able to see hps is a sig
# coefficient.
# How about we make two models? one with the rates, and one with the counts. And we'll
# see which one is better
hofLog3 = glm(hof ~ total_hits + total_hr +
                total_rbi + total_sb + total_bb +
                total_so, data=hof_train, family=binomial)
summary(hofLog3) # AIC = 157



# In hofLog2 & hofLog3, I don't include # of games/seasons/pa's because these are highly
# correlated with the number of htis

### Some notes:
# We want to avoid collinearity
### Higher values in the cofficient estimate variable are indicative of HOF #'s,
# Preferred model is the one with the lowest AIC, it measures the quality of the model.
# is like adjusted R^2 in that accounts for # of vars used compared to # of observations
# We need a standard baseline model to compare our prediction model against

#Let's predict our accuracy for each model
# model 1
predictTest1 = predict(hofLog1,newdata = hof_test, type="response")
table(hof_test$hof, predictTest1 > 0.45)
table(hof_test$hof, predictTest1 > 0.5)

# model 2
predictTest2 = predict(hofLog2,newdata = hof_test, type="response")
table(hof_test$hof, predictTest2 > 0.45)
table(hof_test$hof, predictTest2 > 0.5)
accuracy = (309+19)/(309+5+40+19)
#create baseline model, aka predict the most frequent outcome for all observations
#in this case, an easier model would be to pick the most frequent outcome (a song is not a Top 10 hit)
# model 3
predictTest3 = predict(hofLog3,newdata = hof_test, type="response")
table(hof_test$hof, predictTest3 > 0.45)
table(hof_test$hof, predictTest3 > 0.5)

table(SongsTest$Top10)
baseline = 314/(314+59)
#model 3 gives us a small improvement over our baseline model
sensitivity = 19/(19+40)

# something about confusion matrices...

# make the training set about 65% of the data, so that the test set actually includes
# hofers. that way, you know the actual accuracy of your data
library(caTools)

set.seed(1000)
split = sample.split(combined_data$hof, SplitRatio = 0.65)
train = subset(combined_data, split == TRUE)
train = train %>% dplyr::select(-name)
test = subset(combined_data, split == FALSE)
test = test %>% dplyr::select(-name)

# build our LGM using the training set
bbLog1 = glm(hof ~ ., data = train, family = binomial)
summary(bbLog1)

#2
bbLog2 = glm(hof ~ hits_p_season + career_ba +
                rbi_p_season + sb_p_season + total_ops +
                ov_bb_rate + ov_so_rate, data=train, family=binomial)
summary(bbLog2)

# 3
bbLog3 = glm(hof ~ total_hits + total_hr +
                total_rbi + total_sb + total_bb +
                total_so, data=train, family=binomial)
summary(bbLog3)

#Let's predict our accuracy for each model
# model 1
predTest1 = predict(bbLog1,newdata = test, type="response")
table(test$hof, predTest1 > 0.5)
accuracy1 = (298+55)/(298+55+2) #99.4
#baseline is where nothof happens more than hof, so
baseline = 298/(298+2+55)
# preTest1 is way more accurate

# model 2 MOST ACCURATE!!!
predTest2 = predict(bbLog2,newdata = test, type="response")
table(test$hof, predTest2 > 0.5)
accuracy2= (297+48)/(297+1+9+48)
accuracy2 # 97.2

#create baseline model, aka predict the most frequent outcome for all observations
#in this case, an easier model would be to pick the most frequent outcome (a song is not a Top 10 hit)
# model 3
predTest3 = predict(bbLog3,newdata = test, type="response")
table(test$hof, predTest3 > 0.5)
accuracy3 = (292+45)/(292+6+12+45) # 95%
accuracy3


# COMPUTE THE OUT OF SAMPLE AUC (area under the curve)
library(ROCR)
ROCRpred1 = prediction(predTest1, test$hof)
as.numeric(performance(ROCRpred1, "auc")@y.values) # 1
# this gives us AUC value on our testing set

# try the other models
ROCRpred2 = prediction(predTest2, test$hof)
as.numeric(performance(ROCRpred2, "auc")@y.values) # 0.975

ROCRpred3 = prediction(predTest3, test$hof)
as.numeric(performance(ROCRpred3, "auc")@y.values) # 98.71

# pred2 and 3 can differentiate b/t hall of famers and non hall of famers VERY well,
# but the 3rd model (with counting stats) is a better predictor.

# The AUC gives the probability that the model correctly ranks a pair of observations.





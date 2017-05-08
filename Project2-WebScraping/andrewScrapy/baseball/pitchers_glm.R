### Pitchers
library(dplyr)

pitchers <- read.csv("pitchers_final.csv", header = TRUE)
summary(pitchers)
str(pitchers)


colSums(is.na(pitchers))

# Let's impute. Get rid of any lines with 0 IP, remove ERA plus, impute missing er with 0,
# bb's with 0, and possibly hr's with 0? We need these columns to computer FIP

pitchers <- pitchers %>% filter(ip != 0)
summary(batters$ibb)

pitchers[is.na(pitchers$er),]
pitchers %>% filter(name == 'Satchel Paige')

# remove blank er's
pitchers <- pitchers[!is.na(pitchers$er),]


pitchers[is.na(pitchers$hr),]

# Remove lines with missing K's and HR's
pitchers <- pitchers[!is.na(pitchers$hr),]
pitchers <- pitchers[!is.na(pitchers$k),]

# Replace missing HBP with zeros (since they happen rarely). Same with balks (bk)
pitchers$hbp <- ifelse(is.na(pitchers$hbp), 0, pitchers$hbp)
pitchers$bk <- ifelse(is.na(pitchers$bk), 0, pitchers$bk)

# summarise ip	er	k	h	hr	bb	ibb	hbp	wp	bk	era	fip	whip	h9	hr9	bb9	k9
career_pitchers <- pitchers %>% group_by(name) %>%
  summarise(seasons = n(),
            total_ip = sum(ip),
            total_er = sum(er),
            total_k = sum(k),
            total_h = sum(h),
            total_hr = sum(hr),
            total_bb = sum(bb),
            total_ibb = sum(ibb),
            total_hbp = sum(hbp),
            total_wp = sum(wp),
            total_bk = sum(bk),
            era = (total_er / total_ip) * 9,
            fip = ((13*total_hr + 3*total_bb - 2*total_k)/total_ip) + 3.2,
            whip = (total_bb + total_h)/total_ip,
            h9 = (total_h / total_ip) * 9,
            hr9 = (total_hr / total_ip) * 9,
            bb9 = (total_bb / total_ip) * 9,
            k9 = (total_k / total_ip) * 9)

# Okay. Read in the other dataset, transform it, and join this baby

recent_pitchers <- read.csv("pitchers_nonHOF_1989-2016.csv", header = TRUE)

colSums(is.na(recent_pitchers))

recent_careers <- recent_pitchers %>% group_by(name) %>%
  summarise(seasons = n(),
            total_ip = sum(IP),
            total_er = sum(ER),
            total_k = sum(SO),
            total_h = sum(H),
            total_hr = sum(HR),
            total_bb = sum(BB),
            total_ibb = sum(IBB),
            total_hbp = sum(HBP),
            total_wp = sum(WP),
            total_bk = sum(BK),
            era = (total_er / total_ip) * 9,
            fip = ((13*total_hr + 3*total_bb - 2*total_k)/total_ip) + 3.2,
            whip = (total_bb + total_h)/total_ip,
            h9 = (total_h / total_ip) * 9,
            hr9 = (total_hr / total_ip) * 9,
            bb9 = (total_bb / total_ip) * 9,
            k9 = (total_k / total_ip) * 9)

# Add the column HOF in each, 1 indicating that they're in the HOF, 0 otherwise
career_pitchers$hof = 1
recent_careers$hof = 0

# Now we join
combined_pitchers <- rbind(career_pitchers, recent_careers)
summary(combined_pitchers)

# add IP per season
combined_pitchers <- combined_pitchers %>% mutate(ip_per_season = total_ip / seasons)

# Randomize the samples and let's do this.

library(caTools)

set.seed(1000)
split = sample.split(combined_pitchers$hof, SplitRatio = 0.65)
train = subset(combined_pitchers, split == TRUE)
train = train %>% dplyr::select(-name)
test = subset(combined_pitchers, split == FALSE)
test = test %>% dplyr::select(-name)

# test correlation
View(cor(train))
# more seasons are highly correlated with higher counting stats, as we can imagine.
# I hope that the best model will show the ratios.


# build our LGM using the training set
pLog1 = glm(hof ~ ., data = train, family = binomial)
summary(pLog1)

#2 Counting Stats
pLog2 = glm(hof ~ total_ip + total_er  +
               total_k + total_h + total_hr +
               total_bb, data=train, family=binomial)
summary(pLog2)

# 3
pLog3 = glm(hof ~ ip_per_season + fip + whip + hr9 + k9,
             data=train, family=binomial)
summary(pLog3)

#Let's predict our accuracy for each model
# model 1
predTest1 = predict(pLog1,newdata = test, type="response")
table(test$hof, predTest1 > 0.5)
accuracy1 = (231+25)/(231+25) #99.4
accuracy1
#baseline is where nothof happens more than hof, so
baseline = 72/(72+660)
baseline
# preTest1 is way more accurate

# model 2
predTest2 = predict(pLog2,newdata = test, type="response")
table(test$hof, predTest2 > 0.5)
accuracy2= (230+25)/(230+25+1)
accuracy2 # 97.2

#create baseline model, aka predict the most frequent outcome for all observations
#in this case, an easier model would be to pick the most frequent outcome (a song is not a Top 10 hit)
# model 3
predTest3 = predict(pLog3,newdata = test, type="response")
table(test$hof, predTest3 > 0.5)
accuracy3 = (225+12)/(225+6+13+12) # 95%
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







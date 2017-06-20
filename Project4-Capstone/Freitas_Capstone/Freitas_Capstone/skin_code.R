######################
## Capstone Project ##
##  Brandy Freitas  ##
##   20 June 2017   ##
## NYCDSA Bootcamp9 ##
######################


##Examine correlation between the symptoms:
install.packages("corrplot")
library(corrplot)
M <- cor(dermatology2[, -35])
corrplot(M, method="circle")
summary(dermatology2[, -35])

corrplot(M, order ="AOE")
corrplot(M, order="hclust", addrect=3, tl.cex = 0.6, tl.col = "black")

# library("Hmisc")
# M2 <- rcorr(as.matrix(dermatology2[, -35]))
# M2
# corrplot(M2$P, order="hclust", addrect=3, tl.cex = 0.6, tl.col = "black", 
#          sig.level = 0.01, insig = 'pch', pch = 3)


dermatology.clincal <- subset(dermatology2, select=c("erythema", "scaling", "definite_borders", "itching", "koebner_phenomenon", "polygonal_papules",
                                                     "follicular_papules", "oral_mucosal_involvement", "knee_elbow_involvement", "scalp_involvement", 
                                                     "family_history", "Age", "Diagnosis"))

summary(dermatology.clincal)



######################
## load data, clean ##
######################

library(ISLR)

dermatology2 <- read_csv("~/Desktop/dermatology.txt", col_names = FALSE)

colnames(dermatology2) <- c("erythema", "scaling", "definite_borders", "itching", "koebner_phenomenon", "polygonal_papules", 
                           "follicular_papules", "oral_mucosal_involvement", "knee_elbow_involvement", "scalp_involvement", 
                           "family_history", "melanin_incontinence", "eosinophils_infiltrate", "pnl_infiltrate", 
                           "fibrosis_papillary_dermis", "exocytosis", "acanthosis", "hyperkeratosis", "parakeratosis", 
                           "clubbing_reteridges", "elongation_reteridges", "thinning_suprapapillary_epidermis",
                           "spongiform_pustule", "munro_microabcess", "focal_hypergranulosis", "disappearance_granular_layer",
                           "vacuolisation_damage_basallayer", "spongiosis", "sawtooth_retes", 
                           "follicular_hornplug", "perifollicular_parakeratosis", "inflammatory_monoluclear_infiltrate", 
                           "bandlike_infiltrate", "Age", "Diagnosis")

#add labels of the diagnosis category
dermatology2$Diagnosis[dermatology2$Diagnosis == 1] <- 'psoriasis'
dermatology2$Diagnosis[dermatology2$Diagnosis == 2] <- 'seboreic_dermatitis'
dermatology2$Diagnosis[dermatology2$Diagnosis == 3] <- 'lichen_planus'
dermatology2$Diagnosis[dermatology2$Diagnosis == 4] <- 'pityriasis_rosea'
dermatology2$Diagnosis[dermatology2$Diagnosis == 5] <- 'cronic_dermatitis'
dermatology2$Diagnosis[dermatology2$Diagnosis == 6] <- 'pityriasis_rubra_pilaris'

summary(dermatology2)

#Impute missing age values in Age column
dermatology2$Age[dermatology2$Age == '?'] <- '36'
unique(dermatology2$Age)
table(dermatology2$Age)

dermatology2$Age = as.numeric(as.character(dermatology2$Age))

################
## tree model ##
################

# load tree package for multiclass trees
library(rpart)
install.packages("rpart.plot")
library(rpart.plot)

# fit model for skin conditions
fit.derma <- rpart(Diagnosis ~ ., dermatology)
fit.derma2 <- rpart(Diagnosis ~ ., dermatology2)
# summarize the fit
summary(fit.derma)
summary(fit.derma2)
# make predictions
predictions.derma <- predict(fit.derma, dermatology[,1:34], type="class")
predictions.derma2 <- predict(fit.derma2, dermatology2[,1:34], type="class")

# summarize accuracy
table(predictions.derma, dermatology$Diagnosis)
table(predictions.derma2, dermatology2$Diagnosis)

#Fancy plot
rpart.plot(fit.derma, tweak=1.4)
fit.derma

rpart.plot(fit.derma2)
fit.derma2

printcp(fit.derma)
plotcp(fit.derma)

fit.derma$variable.importance

###########
## Party ##
###########

#Need to make sure that the data is numeric to use this
dermatology3 <- read_csv("~/Desktop/dermatology.txt", col_names = FALSE)

colnames(dermatology3) <- c("erythema", "scaling", "definite_borders", "itching", "koebner_phenomenon", "polygonal_papules", 
                            "follicular_papules", "oral_mucosal_involvement", "knee_elbow_involvement", "scalp_involvement", 
                            "family_history", "melanin_incontinence", "eosinophils_infiltrate", "pnl_infiltrate", 
                            "fibrosis_papillary_dermis", "exocytosis", "acanthosis", "hyperkeratosis", "parakeratosis", 
                            "clubbing_reteridges", "elongation_reteridges", "thinning_suprapapillary_epidermis",
                            "spongiform_pustule", "munro_microabcess", "focal_hypergranulosis", "disappearance_granular_layer",
                            "vacuolisation_damage_basallayer", "spongiosis", "sawtooth_retes", 
                            "follicular_hornplug", "perifollicular_parakeratosis", "inflammatory_monoluclear_infiltrate", 
                            "bandlike_infiltrate", "Age", "Diagnosis")

summary(dermatology3)

#Impute missing age values in Age column
dermatology3$Age[dermatology3$Age == '?'] <- '36'
unique(dermatology3$Age)
table(dermatology3$Age)

dermatology3$Age = as.numeric(as.character(dermatology3$Age))

###Use Derma 2 instead:
install.packages("party")
library(party)

fit.party <- ctree(Diagnosis ~ ., dermatology2)
plot(fit.party)
fit.party

summary(dermatology2)


##Test with Derma Party for the plot to work better:
dermatology.party <- read_csv("~/Desktop/dermatology.txt", col_names = FALSE)

colnames(dermatology.party) <- c("erythema", "scaling", "definite_borders", "itching", "koebner_phenomenon", "polygonal_papules", 
                                 "follicular_papules", "oral_mucosal_involvement", "knee_elbow_involvement", "scalp_involvement", 
                                 "family_history", "melanin_incontinence", "eosinophils_infiltrate", "pnl_infiltrate", 
                                 "fibrosis_papillary_dermis", "exocytosis", "acanthosis", "hyperkeratosis", "parakeratosis", 
                                 "clubbing_reteridges", "elongation_reteridges", "thinning_suprapapillary_epidermis",
                                 "spongiform_pustule", "munro_microabcess", "focal_hypergranulosis", "disappearance_granular_layer",
                                 "vacuolisation_damage_basallayer", "spongiosis", "sawtooth_retes", 
                                 "follicular_hornplug", "perifollicular_parakeratosis", "inflammatory_monoluclear_infiltrate", 
                                 "bandlike_infiltrate", "Age", "Diagnosis")

#add labels of the diagnosis category
dermatology.party$Diagnosis[dermatology.party$Diagnosis == 1] <- 'p' #'psoriasis'
dermatology.party$Diagnosis[dermatology.party$Diagnosis == 2] <- 'sd' #'seboreic_dermatitis'
dermatology.party$Diagnosis[dermatology.party$Diagnosis == 3] <- 'lp'  #'lichen_planus'
dermatology.party$Diagnosis[dermatology.party$Diagnosis == 4] <- 'pro'  #'pityriasis_rosea'
dermatology.party$Diagnosis[dermatology.party$Diagnosis == 5] <- 'cd' #'cronic_dermatitis'
dermatology.party$Diagnosis[dermatology.party$Diagnosis == 6] <- 'prp'  #'pityriasis_rubra_pilaris'

dermatology.party$Age[dermatology.party$Age == '?'] <- '36'
dermatology.party$Age = as.numeric(as.character(dermatology.party$Age))
dermatology.party$Diagnosis = as.factor(dermatology.party$Diagnosis)

fit.partylabels <- ctree(Diagnosis ~ ., dermatology.party)
plot(fit.partylabels)
fit.partylabels

###################
## Random Forest ##
###################

library(randomForest)
fit.rfderma <- randomForest(Diagnosis ~ ., dermatology2)
print(fit.rfderma) # view results 
importance(fit.rfderma) # importance of each predictor
plot(fit.rfderma) #see plot of how many trees were needed and the error improvements 

varImpPlot(fit.rfderma,type=2)

##########################################
## Train Test Split: Testing the Models ##
##########################################

#RPART TREE
#70/30 split for training and testing 
set.seed(0)
train1 = sample(1:nrow(dermatology), 7*nrow(dermatology)/10) #Training indices.
dermatology.test = dermatology[-train1, ] #Test dataset.

fit.trainderma1 <- rpart(Diagnosis ~ ., data = dermatology, subset = train1)
rpart.plot(fit.trainderma1)

summary(fit.trainderma1)
fit.trainderma1

#Using the trained decision tree to classify the test data.
pred.trainderma1 <- predict(fit.trainderma1, dermatology.test, type = "class")
pred.trainderma1

#Assessing the accuracy of the overall tree by constructing a confusion matrix.
table(pred.trainderma1, dermatology.test$Diagnosis)
accuracy.rpart <- sum(diag(table(pred.trainderma1, dermatology.test$Diagnosis))) / sum(table(pred.trainderma1, dermatology.test$Diagnosis))
accuracy.rpart
precision.rpart <- diag(table(pred.trainderma1, dermatology.test$Diagnosis)) / rowSums(table(pred.trainderma1, dermatology.test$Diagnosis))
precision.rpart
recall.rpart <- diag(table(pred.trainderma1, dermatology.test$Diagnosis)) / colSums(table(pred.trainderma1, dermatology.test$Diagnosis))
recall.rpart

confusionMatrix(pred.trainderma1, dermatology.test$Diagnosis)

#10-fold cross validation results:
printcp(fit.trainderma1)
fit.trainderma1$variable.importance


#PARTY TREE
#70/30 split for training and testing 
set.seed(0)
train2 = sample(1:nrow(dermatology2), 7*nrow(dermatology2)/10) #Training indices.
dermatology2.test = dermatology2[-train2, ] #Test dataset.

fitparty.trainderma2 <- ctree(Diagnosis ~ ., data = dermatology2, subset = train2)

#Using the trained decision tree to classify the test data.
pred.partytrain <- predict(fitparty.trainderma2, dermatology2.test)
pred.partytrain

#Assessing the accuracy of the overall tree by constructing a confusion matrix.
table(pred.partytrain, dermatology2.test$Diagnosis)
confusionMatrix(pred.partytrain, dermatology2.test$Diagnosis)

#RANDOM FOREST
#70/30 split for training and testing 
summary(dermatology2)
dermatology2$Diagnosis = as.factor(dermatology2$Diagnosis)

set.seed(0)
train3 = sample(1:nrow(dermatology2), 7*nrow(dermatology2)/10) #Training indices.
dermatologyrf.test = dermatology2[-train3, ] #Test dataset.

rffit.trainderma3 <- randomForest(Diagnosis ~ ., data = dermatology2, subset = train3)

plot(rffit.trainderma3)
print(rffit.trainderma3)

#Using the trained decision tree to classify the test data.
pred.rftrain <- predict(rffit.trainderma3, dermatologyrf.test)

#Assessing the accuracy of the overall tree by constructing a confusion matrix.
confusionMatrix(pred.rftrain, dermatologyrf.test$Diagnosis)



#######################
## Clincal Data Only ##
#######################

summary(dermatology.clincal)

#########RPART Clinical########
#rpart fitting
fit.clincal <- rpart(Diagnosis ~ ., dermatology.clincal)
# summarize the fit
summary(fit.clincal)
# make predictions
predictions.clinical <- predict(fit.clincal, dermatology.clincal[,1:12], type="class")
# summarize accuracy
table(predictions.clinical, dermatology.clincal$Diagnosis)
#Fancy plot
rpart.plot(fit.clincal)

##RPart Testing Clinical
set.seed(0)
train.clinical = sample(1:nrow(dermatology.clincal), 7*nrow(dermatology.clincal)/10) #Training indices.
dermatology.clinicaltest = dermatology.clincal[-train.clinical, ] #Test dataset.

fit.clinicaltest <- rpart(Diagnosis ~ ., data = dermatology.clincal, subset = train.clinical)
rpart.plot(fit.clinicaltest, tweak = 1.4)

summary(fit.clinicaltest)
fit.clinicaltest

#10-fold cross validation results:
printcp(fit.clinicaltest)
fit.clinicaltest$variable.importance

#Using the trained decision tree to classify the test data.
pred.clincaltest <- predict(fit.clinicaltest, dermatology.clinicaltest, type = "class")
pred.clincaltest

#Assessing the accuracy of the overall tree by constructing a confusion matrix.
table(pred.clincaltest, dermatology.clinicaltest$Diagnosis)
accuracy.clinical <- sum(diag(table(pred.clincaltest, dermatology.clinicaltest$Diagnosis))) / sum(table(pred.clincaltest, dermatology.clinicaltest$Diagnosis))
accuracy.clinical
precision.clinical <- diag(table(pred.clincaltest, dermatology.clinicaltest$Diagnosis)) / rowSums(table(pred.clincaltest, dermatology.clinicaltest$Diagnosis))
precision.clinical
recall.clinical <- diag(table(pred.clincaltest, dermatology.clinicaltest$Diagnosis)) / colSums(table(pred.clincaltest, dermatology.clinicaltest$Diagnosis))
recall.clinical

confusionMatrix(pred.clincaltest, dermatology.clinicaltest$Diagnosis)


##########Party Clinical########
fit.partyclinical <- ctree(Diagnosis ~ ., dermatology.clincal)
plot(fit.partyclinical)

##Clinical Party Train Test
set.seed(0)
train.clinical = sample(1:nrow(dermatology.clincal), 7*nrow(dermatology.clincal)/10) #Training indices.
dermatology.clinicaltest = dermatology.clincal[-train.clinical, ] #Test dataset.

fitparty.clinicaltrain <- ctree(Diagnosis ~ ., data = dermatology.clincal, subset = train.clinical)

#Using the trained decision tree to classify the test data.
pred.partytrainclinical <- predict(fitparty.clinicaltrain, dermatology.clinicaltest)
pred.partytrainclinical

#Assessing the accuracy of the overall tree by constructing a confusion matrix.
table(pred.partytrainclinical, dermatology.clinicaltest$Diagnosis)
confusionMatrix(pred.partytrainclinical, dermatology.clinicaltest$Diagnosis)


###########Random Forest Clinical########

##Clinical RF Train Test
set.seed(0)
train.clinical = sample(1:nrow(dermatology.clincal), 7*nrow(dermatology.clincal)/10) #Training indices.
dermatology.clinicaltest = dermatology.clincal[-train.clinical, ] #Test dataset.

fitrf.clinicaltrain <- randomForest(Diagnosis ~ ., data = dermatology.clincal, subset = train.clinical)

#Using the trained decision tree to classify the test data.
pred.rftrainclinical <- predict(fitrf.clinicaltrain, dermatology.clinicaltest)
pred.rftrainclinical

#Assessing the accuracy of the overall tree by constructing a confusion matrix.
table(pred.rftrainclinical, dermatology.clinicaltest$Diagnosis)
confusionMatrix(pred.rftrainclinical, dermatology.clinicaltest$Diagnosis)

#Importance:
varImpPlot(fitrf.clinicaltrain,type=2)
importance(fitrf.clinicaltrain)



#########
## SVM ##
#########

library(e1071)

##Clinical Data Only SVM:

#Performing the cross-validation.
set.seed(0)
cv.multiclincal = tune(svm,
                       Diagnosis ~ .,
                       data = dermatology.clincal[train.clinical, ],
                       kernel = "radial",
                       ranges = list(cost = 10^(seq(-1, 1.5, length = 20)),
                                     gamma = 10^(seq(-2, 1, length = 20))))

#Inspecting the cross-validation output.
summary(cv.multiclincal)

#Plotting the cross-validation results.
library(rgl)
plot3d(cv.multiclincal$performances$cost,
       cv.multiclincal$performances$gamma,
       cv.multiclincal$performances$error,
       xlab = "Cost",
       ylab = "Gamma",
       zlab = "Error",
       type = "s",
       size = 1)

#Inspecting the best model.
best.multiclinical.model = cv.multiclincal$best.model
summary(best.multiclinical.model)

#Using the best model to predict the test data.
ypred = predict(best.multiclinical.model, dermatology.clinicaltest)
table("Predicted Values" = ypred, "True Values" = dermatology.clinicaltest$Diagnosis)

#Constructing and visualizing the final model.
svm.bestclinical.multi = svm(Diagnosis ~ .,
                             data = dermatology.clincal,
                             kernel = "radial",
                             cost = best.multiclinical.model$cost,
                             gamma = best.multiclinical.model$gamma)
summary(svm.bestclinical.multi)
svm.bestclinical.multi$index
ypred.final = predict(svm.bestclinical.multi, dermatology.clincal)
table("Predicted Values" = ypred.final, "True Values" = dermatology.clincal$Diagnosis)

confusionMatrix(ypred.final, dermatology.clincal$Diagnosis)


##Full Data Set SVM:

set.seed(0)
train.svm = sample(1:nrow(dermatology2), 7*nrow(dermatology2)/10) #Training indices.
dermatology.svm.test = dermatology2[-train.svm, ] #Test dataset.

#Performing the cross-validation.
set.seed(0)
cv.multiall = tune(svm,
                       Diagnosis ~ .,
                       data = dermatology2[train.svm, ],
                       kernel = "radial",
                       ranges = list(cost = 10^(seq(-1, 1.5, length = 20)),
                                     gamma = 10^(seq(-2, 1, length = 20))))

#Inspecting the cross-validation output.
summary(cv.multiall)

#Plotting the cross-validation results.
library(rgl)
plot3d(cv.multiall$performances$cost,
       cv.multiall$performances$gamma,
       cv.multiall$performances$error,
       xlab = "Cost",
       ylab = "Gamma",
       zlab = "Error",
       type = "s",
       size = 1)

#Inspecting the best model.
best.multiall.model = cv.multiall$best.model
summary(best.multiall.model)

#Using the best model to predict the test data.
ypred.all = predict(best.multiall.model, dermatology.svm.test)
table("Predicted Values" = ypred.all, "True Values" = dermatology.svm.test$Diagnosis)

#Constructing and visualizing the final model.
svm.bestall.multi = svm(Diagnosis ~ .,
                             data = dermatology2,
                             kernel = "radial",
                             cost = best.multiall.model$cost,
                             gamma = best.multiall.model$gamma)
summary(svm.bestall.multi)
svm.bestall.multi$index
ypred.allfinal = predict(svm.bestall.multi, dermatology2)
table("Predicted Values" = ypred.allfinal, "True Values" = dermatology2$Diagnosis)

confusionMatrix(ypred.allfinal, dermatology2$Diagnosis)




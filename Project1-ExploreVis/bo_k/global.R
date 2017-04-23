library(dplyr)
library(tidyr)

state_stat <- data.frame(state.name = rownames(state.x77), state.x77)
# remove row names
rownames(state_stat) <- NULL

loan <- read.csv("LoanStats3a.csv",skip=1,stringsAsFactors = F)
loan <- loan[!is.na(loan$loan_amnt),]
loan <- loan[!is.na(loan$annual_inc),]
loan <- loan[loan$annual_inc < 300000,]
loan <- mutate(loan,loan_rate=as.numeric(substr(loan$int_rate,1,nchar(loan$int_rate)-1)))
loan <- select(loan, loan_amnt,dti,installment,loan_rate,term,grade,annual_inc,addr_state)
totalloanbal = sum(loan$loan_amnt)

loangroupbystate <- data.frame( summarise(group_by(loan,addr_state), loan_amnt=(sum(loan_amnt,na.rm=T)),dti=(mean(dti,na.rm=T)),
                              loan_rate=(mean(loan_rate,na.rm=T)),annual_inc=(mean(annual_inc,na.rm=T)),
                              installment=(mean(installment,na.rm=T))) %>% arrange(addr_state))
loangroupbygrade <- data.frame( summarise(group_by(loan,grade), loan_amnt=(sum(loan_amnt,na.rm=T)),dti=(mean(dti,na.rm=T)),
                                          loan_rate=(mean(loan_rate,na.rm=T)),annual_inc=(mean(annual_inc,na.rm=T)),
                                          installment=(mean(installment,na.rm=T))) %>% arrange(grade))
colnames(loangroupbystate) <- c("state.ab" ,"loan_amnt" ,"dti","loan_rate" ,"annual_inc","installment")
loangroupbystate[,2:6] <- round(loangroupbystate[,2:6] ,2)
state_stat <- mutate(state_stat, state.ab = state.abb[match(as.character(state.name),state.name)])
state_stat<-left_join(state_stat, loangroupbystate,by = "state.ab")

choice <- c('loan_rate','loan_amnt','dti','installment','annual_inc')

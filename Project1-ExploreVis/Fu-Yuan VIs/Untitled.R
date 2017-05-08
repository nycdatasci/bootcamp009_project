#install.packages("rsconnect")
library(rsconnect)
#install.packages("RSQLite")
library(tidyr)

library(data.table)
library(dplyr)
library(ggplot2)



data <- fread("Final_data.csv")
data_grade<-data %>% group_by(grade) %>% summarise(mean(int_rate), mean(loan_amnt), mean(annual_inc))
boxplot<-ggplot(data, aes(x= grade, y= annual_inc)) + geom_boxplot()

data_1<-filter(data, grade=="D"| grade =="A")
histogram <-ggplot(data_1, aes(x=annual_inc,fill= "grade")) + geom_histogram(position ="dodge" )+ xlim (5000,100000)
histogram
max(data_1$annual_inc)


ggplot(data, aes(x = int_rate, fill = as.factor(grade))) +
  geom_density(alpha = .3)

ggplot(data, aes(x = loan_amnt, fill = as.factor(grade))) +
  geom_density(alpha = .3)


Lst=c(10.,11.,12.,13.,14.,15.)
v <- Lst[2:6]/Lst[1:5]-1
vnames(data)
data$loan_F_status <- replace(data$loan_status, data$loan_status =="Late (31-120 days)", "Default")
term_data <- data %>% group_by(term,grade) %>% summarise(mean(loan_amnt))

data$loan_F_status <- replace(data$loan_F_status, data$loan_F_status =="Charged Off", "Default")

#lending club

ggplot(data, aes(x=int_rate, fill = loan_F_status)) + geom_histogram(aes(y=..density..),breaks=seq(5,30, by= 2), alpha=0.5)

ggplot(data, aes(x=int_rate)) +
geom_histogram(aes(y=..density..),breaks=seq(5,30, by= 2), alpha=0.5) +
facet_wrap(~loan_F_status)  

ggplot(data, aes(x=loan_amnt)) +
  geom_histogram(aes(y=..density..),breaks=seq(0,37000, by= 5000), alpha=0.5) +
  facet_wrap(~loan_F_status)  

ggplot(data, aes(x=loan_amnt)) +
  geom_histogram(breaks=seq(0,37000, by= 5000), alpha=0.5) +
  facet_wrap(~loan_F_status)  

ggplot(data, aes(x=loan_amnt)) +
  geom_histogram(breaks=seq(0,37000, by= 5000), alpha=0.5) +
  facet_wrap(~loan_F_status)

ggplot(data, aes(x=grade, fill =loan_F_status)) + geom_bar(position = "dodge")



ggplot(data, aes(x=grade))+
geom_bar(aes(fill=as.factor(loan_F_status)), position="fill")


ggplot(data, aes(x=annual_inc)) +
  geom_histogram(breaks=seq(0,200000, by= 5000), alpha=0.5) +
  facet_wrap(~loan_F_status)


ggplot(data, aes(x=term))+
  geom_bar(aes(fill=as.factor(loan_F_status)), position="fill")





data$issue_d <- strptime(data$issue_d,"%m-%C")

#### create term grade stat!

term_data<- data %>% group_by(term,grade) %>% summarise(M_Loan=mean(loan_amnt))
term_data$term_m <- 36
term_data[8:14,4] <- 60
term_data<-mutate(term_data, PerMonth = M_Loan/term_m)
library(psych) # describe EDA

describe(term_data$PerMonth)

D_data<-subset(data, loan_F_status=="Default")

ggplot(D_data, aes(x= grade))+geom_bar(position="dodge")
ggplot(D_data, aes(x=int_rate, fill = addr_state)) + geom_density(alpha = 0.2)

data$int_interval<-cut(data$int_rate, breaks = 10)

write.csv(data,"Final_data.csv")
aa<-data %>% group_by(purpose)  %>% summarise(default_rate = mean(loan_F_status=='Default'))


###Case study: using group_by & tidyr to investigate the purpose variable ###
a<- data %>% group_by(purpose) %>% summarise(count=n()) 
b<-data %>% group_by(purpose,int_interval) %>% summarise(count=n()) 
#%>%
 # ggplot(aes(x=purpose))+ geom_bar()

int <- data %>% group_by(purpose,int_interval) %>% 
                summarise(mean(loan_F_status=="Default")) %>%
                ggplot(aes())

 data %>% filter(purpose == "debt_consolidation") %>%
        group_by(int_interval) %>% summarise(count=n(), Prob=mean(loan_F_status=="Default"))%>%
        ggplot(aes(x=int_interval,y=Prob)) +
        geom_bar(stat="identity")+
        xlab("Interest rate interval") +
        ylab("Default rate") +
   ggtitle("Interest rate interval V.S. Default rate")
aa<-data %>% 
    group_by(target = (purpose=='debt_consolidation' & int_interval=='(24.3,26.6]'), loan_F_status)%>% 
    summarise(n())

int_rate_interval<-spread(data=aa, key=loan_F_status, value='n()')
int_rate_interval<-int_rate_interval[,-1]
c<-chisq.test(int_rate_interval)
c
names(data)
data<-data[,c(-1,-2)]

get_month <- function(x){
  substr(x, 1, 3)
}
get_year <- function(x){
  substr(x, 5, 6)
}
data <- data%>% mutate(month = get_month(issue_d))
data <- data%>% mutate(year = get_year(issue_d))

na.zero <- function (x) {
  x[is.na(x)] <- 0
  return(x)
}

#'x' is the column of a data.frame that holds 2 digit state codes
stateFromLower <-function(x) {
  #read 52 state codes into local variable [includes DC (Washington D.C. and PR (Puerto Rico)]
  st.codes<-data.frame(
    state=as.factor(c("AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA",
                      "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME",
                      "MI", "MN", "MO", "MS",  "MT", "NC", "ND", "NE", "NH", "NJ", "NM",
                      "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN",
                      "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY")),
    full=as.factor(c("alaska","alabama","arkansas","arizona","california","colorado",
                     "connecticut","district of columbia","delaware","florida","georgia",
                     "hawaii","iowa","idaho","illinois","indiana","kansas","kentucky",
                     "louisiana","massachusetts","maryland","maine","michigan","minnesota",
                     "missouri","mississippi","montana","north carolina","north dakota",
                     "nebraska","new hampshire","new jersey","new mexico","nevada",
                     "new york","ohio","oklahoma","oregon","pennsylvania","puerto rico",
                     "rhode island","south carolina","south dakota","tennessee","texas",
                     "utah","virginia","vermont","washington","wisconsin",
                     "west virginia","wyoming"))
  )
  #create an nx1 data.frame of state codes from source column
  st.x<-data.frame(state=x)
  #match source codes with codes from 'st.codes' local variable and use to return the full state name
  refac.x<-st.codes$full[match(st.x$state,st.codes$state)]
  #return the full state names in the same order in which they appeared in the original source
  return(refac.x)
  
}

data$addr_state <-stateFromLower(data$addr_state)

total <- merge(states,data,by=c("region","addr_state"))
##### Map
library(maps)
states = map_data("state") # Using the built-in USA county
# map dataset.
ggplot(data = temp, aes(x = long, y = lat, fill=D_rate)) +
  geom_polygon(aes(group = group))



data %>% group_by(addr_state) %>% summarize(D_rate=mean(loan_F_status=="Default"))%>% 
merge(states, by.x="addr_state", by.y="region")
## map year 

 data %>% filter(year=="11") %>% group_by(addr_state) %>% summarize(count=n()) %>% 
    merge(states, by.x = "addr_state", by.y = "region", all.y = TRUE) %>% mutate(count=na.zero(count))%>%
    ggplot(aes(x = long, y = lat, fill=count)) +
    geom_polygon(aes(group = group))

#_____________________________

data %>% group_by(input$select_dis_1, loan_F_status) %>% 
  summarise(mean(Num=input$select_con_1)) %>%
  ggplot(aes(x = input$select_con_1, y = Num)) +
  geom_bar(stat = 'identity', aes(fill = loan_F_status), position = 'dodge') +
  ggtitle("Average delay")
  
data %>% group_by($input$select_dis_1,loan_F_status) %>% summarise(Num=mean(input$select_con_1)) %>%
ggplot(aes(x=input$select_con_1, y = Num)) + geom_bar(stat = 'identity', aes(fill = input$select_con_1), position = 'dodge')


data %>% group_by(term,loan_F_status) %>% summarise(Num=mean(int_rate)) %>%
  ggplot(aes(x= term, y = Num, fill =loan_F_status)) + geom_bar(stat = 'identity', position = 'dodge')



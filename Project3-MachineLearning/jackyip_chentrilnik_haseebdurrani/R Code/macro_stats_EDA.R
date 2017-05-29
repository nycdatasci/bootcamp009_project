library(ggplot2)
library(dplyr)
library(zoo)

#importing the data
macro= read.csv('macro.csv')
macro_full=read.csv('macro_full.csv')
data1 = read.csv('full_new_features.csv')

#exploring the classes of the features
sapply(macro,class)

write.csv(house_f, 'housing_new_features.csv', row.names = FALSE)

house_f = data1[c('id','ration_popul','state')]

#adding year_month column

# pasting '0' before one digit months
macro_full$month = ifelse(macro_full$month<10,
                          paste0('0',macro_full$month),
                          macro_full$month)

#create a year / month column
macro_full$year_month= with(macro_full, paste0(year,'/',month))

###############################################
#creating subsets for multi feature line graphs 
###############################################

#4
cpi = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(cpi)) %>%
  mutate(type = 'cpi')

gdp_quart_growth = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(gdp_quart_growth)) %>%
  mutate(type = 'gdp_quart_growth')
#1
usd = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(usdrub)) %>%
  mutate(type = 'usdrub')

#3
unemployment = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(unemployment*10)) %>%
  mutate(type = 'unemployment')

#4
rent = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(rent_price_4.room_bus)) %>%
  mutate(type = 'rent_price')

#4
salary = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(salary)) %>%
  mutate(type = 'salary')


salary_growth = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(salary_growth)) %>%
  mutate(type = 'salary_growth')

#3
mortgage_rate = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(mortgage_rate)) %>%
  mutate(type = 'mortgage_rate')

#3
deposits_rate = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(deposits_rate)) %>%
  mutate(type = 'deposits_rate')
#1
#important
oil_urals = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(oil_urals)) %>%
  mutate(type = 'oil_urals')


rts = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(rts)/10) %>%
  mutate(type = 'rts')

invest_fixed_capital_per_cap = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(invest_fixed_capital_per_cap)) %>%
  mutate(type = 'invest_fixed_capital_per_cap')


#A fixed asset is a long-term tangible piece of property 
#that a firm owns and uses in the production of its income 
#and is not expected to be consumed or converted into cash 
#any sooner than at least one year's time. 

invest_fixed_assets = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(invest_fixed_assets)) %>%
  mutate(type = 'invest_fixed_assets')

#not changing over time
average_provision_of_build_contract_moscow = macro_full %>% 
  group_by(year_month) %>% 
  summarize(value= mean(average_provision_of_build_contract_moscow)) %>%
  mutate(type = 'average_provision_of_build_contract_moscow')

real_dispos_income_per_cap_growth = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(real_dispos_income_per_cap_growth)) %>%
  mutate(type = 'real_dispos_income_per_cap_growth')


#A positive NCO means that the country invests outside 
#more than the world invests in it and vice versa. 
#When the net capital outflow is positive, 
#domestic residents are buying more foreign assets 
#than foreigners are purchasing domestic assets. 
#When it’s negative, foreigners are purchasing more domestic
#assets than residents are purchasing foreign assets.


#2
net_capital_export = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(net_capital_export)) %>%
  mutate(type = 'net_capital_export')

#2
gdp_annual_growth = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(deposits_rate)) %>%
  mutate(type = 'gdp_annual_growth')

#1
balance_trade_growth = macro_full %>% 
  group_by(year) %>% 
  summarize(value= mean(balance_trade_growth)) %>%
  mutate(type = 'balance_trade_growth')




###################### Graphs ###########################

######## Annual Oil price, Currency trend, Trade surplus & RTS Index 
annual_graph = rbind(usd,oil_urals,balance_trade_growth,rts)

ggplot(annual_graph,aes(x=year,y = value, color = type))+
  geom_line(aes(linetype=type), size=1) +
  geom_point(aes(shape=type, size=1)) +
  ggtitle('Oil Prices, Trade balance, RTS Index, USD/RUB')

######## Deposit Rave vs. Mortgage rate 
annual_graph3 = rbind(mortgage_rate,deposits_rate)

ggplot(annual_graph3,aes(x=year,y = value, color = type))+
  geom_line(aes(linetype=type), size=1) +
  geom_point(aes(shape=type, size=1)) +
  ggtitle('Deposit Rave vs. Mortgage rate')

#################Unemploymet rate ###########################
ggplot(unemployment,aes(x=year,y = value, color = type))+
  geom_line(aes(linetype=type), size=1) +
  geom_point(aes(shape=type, size=1)) +
  ggtitle('Unemployment Rate & Salary Growth')


################# Investment in fixed assests ###############
ggplot(invest_fixed_assets,aes(x=year,y = value, color = type))+
  geom_line(aes(linetype=type), size=1) +
  geom_point(aes(shape=type, size=1)) +
  ggtitle('Investment in fixed assets')


#################### Real GDP growth ###################

ggplot(gdp_quart_growth,aes(x=year,y = value, color = type))+
  geom_line(aes(linetype=type), size=1) +
  geom_point(aes(shape=type, size=1)) +
  ggtitle('gdp_quart_growth')


############### Unemployment & Growth of nominal wages ### 

unemployment_salary = rbind(unemployment,salary_growth)

ggplot(unemployment_salary,aes(x=year,y = value, color = type))+
  geom_line(aes(linetype=type), size=1) +
  geom_point(aes(shape=type, size=1)) +
  ggtitle('Unemployment & Growth of nominal wages')







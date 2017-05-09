library(lubridate)
library(dplyr)
library(FactSet3)
library(rClr)
library(RSQLite)
library(ggplot2)
library(ggthemes)
library(scales)
library(MASS)
###########################################Connecting to Sources & Prepping Data#########################################
#########################################################################################################################

#############Reading In Company Unique Identifiers for Companies' in Factset Selected Indices#############
company_names = read.csv('company_table.csv')
company_tickers = company_names$Ticker
company_tickers = paste(company_tickers,collapse=",")
benchmark_tickers = 'SPY,IWM'

#############Setting up SQL Connection for Data Scraped from Google Correlate#############

# connect to the sqlite file and reading in the 
con = dbConnect(SQLite(), dbname='IBD.db')
alltables = dbListTables(con)

#############Downloading Search Activity from SQL Database for Searches in Companies' Names#############

company_searches = paste(company_names$search_term,collapse="', '")
company_searches = paste("\'", company_searches, '\');', sep="")
search_activity_query= paste('select * FROM Google WHERE search_term IN (', company_searches)
search_activity = dbGetQuery(con, search_activity_query)
search_activity = left_join(search_activity,company_names)
names(search_activity)[names(search_activity)=="date"] <- "Date"
search_activity$Date = as.Date(search_activity$Date)

#############Prepping API calls and Request/Download/Prep Data from Factset API#############

industry_series = 'FREF_ENTITY_NAICS_CODE(SECT,NAME,RANK1),FREF_ENTITY_NAICS_CODE(SECT,NAME,RANK1),FREF_ENTITY_NAICS_CODE(SECT,NAME,RANK1)'
price_valuation_series = 'FG_PSALES(0,-14AY,W),FF_SALES(QTR,-14AY,NOW,FQ),FF_ENTRPR_VAL_EBITDA_OPER(QTR,-14AY,NOW,W,RF),FG_PRICE(0,-14AY,W,,,0),P_MARKET_VAL(0,-14AY,W)'

price_valuation_data = F.ExtractFormulaHistory(company_tickers,price_valuation_series,'')
industry_data = F.ExtractFormulaHistory(company_tickers,industry_series,'')
bench_price_data = F.ExtractFormulaHistory(benchmark_tickers,'FG_PRICE(0,-14AY,W,,,0)','')

price_valuation_data = price_valuation_data %>%
  filter(!(is.na(ff.sales) & is.na(fg.price)))

#Aligning Friday's closing market information (weekly time series) with Google's weekly Sunday report date.
price_valuation_data = price_valuation_data %>%
  mutate(Date = ymd(Date) + days(2))
bench_price_data = bench_price_data %>%
  mutate(Date = ymd(Date) + days(2))

#Merge industrial data with search activity data.
industry_data$Date = NULL
search_activity = left_join(search_activity, industry_data)

##Imputes the sales & EV/EBITDA value report from the most recent period, if available, to ensure non-end of week earnings
##reports are lined up with the remaining week-end data series.
price_valuation_data$ff.sales.rp[1] = NA
price_valuation_data$ff.entrpr.val.ebitda.oper.rp[1] = NA

for (i in 2:nrow(price_valuation_data)) {
  if (is.na(price_valuation_data$ff.sales[i])) {
    if (!is.na(price_valuation_data$ff.sales[(i-1)]) & is.na(price_valuation_data$fg.price[(i-1)])) {
    price_valuation_data$ff.sales.rp[i] = price_valuation_data$ff.sales[(i-1)]
  }}
}
for (i in 2:nrow(price_valuation_data)) {
  if (is.na(price_valuation_data$ff.sales[i])) {
    price_valuation_data$ff.sales[i] = price_valuation_data$ff.sales.rp[i]
  }
}

for (i in 2:nrow(price_valuation_data)) {
  if (is.na(price_valuation_data$ff.entrpr.val.ebitda.oper[i])) {
    if (!is.na(price_valuation_data$ff.entrpr.val.ebitda.oper[(i-1)]) & is.na(price_valuation_data$fg.price[(i-1)])) {
      price_valuation_data$ff.entrpr.val.ebitda.oper.rp[i] = price_valuation_data$ff.entrpr.val.ebitda.oper[(i-1)]
  }}
}
for (i in 2:nrow(price_valuation_data)) {
  if (is.na(price_valuation_data$ff.entrpr.val.ebitda.oper[i])) {
    price_valuation_data$ff.entrpr.val.ebitda.oper[i] = price_valuation_data$ff.entrpr.val.ebitda.oper.rp[i]
  }
}
price_valuation_data$ff.entrpr.val.ebitda.oper.rp = NULL
price_valuation_data$ff.sales.rp = NULL
price_valuation_data$Id = as.factor(price_valuation_data$Id)

## Reduce data to quarterly with sales information included.

data = price_valuation_data %>%
  filter(!is.na(ff.sales) & !is.na(fg.price))

#############Examine and Transform Data for Potential Modeling#############

## Examine search activity series for normality.
## Visually inspect the histo of the search activity distributions, as a whole, and a sample of individual companies'.

ggplot(search_activity, aes(x=search_activity, fill = ..count..)) + geom_histogram(colour='lightsalmon2',bins = 100) + xlim (-3,4.5) +
  theme_bw() + theme( panel.grid.major.y = element_blank()) + scale_fill_gradient(low='firebrick',high='firebrick2') +
  xlab(expression(paste('Standardized Weekly Activity for a Search Term: ', mu, " of 0, ", sigma," of 1"))) +
  geom_vline(aes(xintercept = 0, colour = 'Mean'), linetype='dashed', size = .7) +
  scale_y_continuous(labels=comma) +  ylab('Number of Observations')

search_activity %>%
  filter(Id %in% c('GOOGL','ADP','CTSH','LOGM','NPK')) %>%
  ggplot(aes(x=search_activity, fill = ..count..)) + geom_histogram(colour='orangered1',bins = 100) +
  facet_grid(. ~ Id) + xlim (-3,5) + theme_bw() + theme( panel.grid.major.y = element_blank()) +
  scale_fill_gradient(low='firebrick4',high='firebrick2') + xlab('Standardized Weekly Activity for a Given Search Term') +
  geom_vline(aes(xintercept = 0, colour = 'Mean'), linetype='dashed', size = .7) +
  scale_y_continuous(labels=comma) +  ylab('Number of Observations') +
  theme(strip.text.x = element_text(size = 10,face = "bold", colour = "firebrick", angle = 0))


## Based on visual inspection of many plots and the overall histogram of search activity,
## it's obvious that there's 

## Standardize the data for share price and sales with a mean of zero and SD of one for each company.


## Examine search activity series for normality.
## Visually inspect the histo of the sales and price distributions, as a whole, and a sample of individual companies'.

ggplot(data, aes(x=fg.price, fill = ..count..)) + geom_histogram(colour='lightsalmon2',bins = 100) + xlim (-3,4.5) +
  theme_bw() + theme( panel.grid.major.y = element_blank()) + scale_fill_gradient(low='firebrick',high='firebrick2') +
  xlab(expression(paste('Standardized Quarterly Share Price for a Company: ', mu, " of 0, ", sigma," of 1"))) +
  geom_vline(aes(xintercept = 0, colour = 'Mean'), linetype='dashed', size = .7) +
  scale_y_continuous(labels=comma) +  ylab('Number of Observations')

ggplot(data, aes(x=ff.sales, fill = ..count..)) + geom_histogram(colour='lightsalmon2',bins = 100) + xlim (-3,4.5) +
  theme_bw() + theme( panel.grid.major.y = element_blank()) + scale_fill_gradient(low='firebrick',high='firebrick2') +
  xlab(expression(paste('Standardized Quarterly Sales for a Company: ', mu, " of 0, ", sigma," of 1"))) +
  geom_vline(aes(xintercept = 0, colour = 'Mean'), linetype='dashed', size = .7) +
  scale_y_continuous(labels=comma) +  ylab('Number of Observations')

data %>%
  filter(Id %in% c('GOOGL','ADP','CTSH','LOGM','NPK')) %>%
  ggplot(aes(x=ff.sales, fill = ..count..)) + geom_histogram(colour='orangered1',bins = 50) +
  facet_grid(. ~ Id) + xlim (-3,5) + theme_bw() + theme( panel.grid.major.y = element_blank()) +
  scale_fill_gradient(low='firebrick4',high='firebrick2') + xlab('Standardized Quarterly Sales for a Given Company') +
  geom_vline(aes(xintercept = 0, colour = 'Mean'), linetype='dashed', size = .7) +
  scale_y_continuous(labels=comma) +  ylab('Number of Observations') +
  theme(strip.text.x = element_text(size = 10,face = "bold", colour = "firebrick", angle = 0))

data %>%
  filter(Id %in% c('GOOGL','ADP','CTSH','LOGM','NPK')) %>%
  ggplot(aes(x=fg.price, fill = ..count..)) + geom_histogram(colour='orangered1',bins = 50) +
  facet_grid(. ~ Id) + xlim (-3,5) + theme_bw() + theme( panel.grid.major.y = element_blank()) +
  scale_fill_gradient(low='firebrick4',high='firebrick2') + xlab('Standardized Quarterly Share Price for a Given Company') +
  geom_vline(aes(xintercept = 0, colour = 'Mean'), linetype='dashed', size = .7) +
  scale_y_continuous(labels=comma) +  ylab('Number of Observations') +
  theme(strip.text.x = element_text(size = 10,face = "bold", colour = "firebrick", angle = 0))
  
##It's obvious that significant positive skewness exists across all variables at the general level and
##at each company/search term level, on average.  Let's do a Box-Cox transform on the variables after
##attempting an initial linear correlation model.

## Combine search activity and factset data into one data frame for examination and modelling.
data = inner_join(data,search_activity, by = c('Id','Date'))

## Re-standardize search activity with respect to the periods examined based on available fundamental data.

data = data %>%
  group_by(Id) %>%
  mutate_each_(funs(scale(.) %>% as.vector), vars=c("ff.sales","fg.price"))

## Create initial linear regression model.
sales_model = lm(ff.sales ~ search_activity, data = data)
price_model = lm(fg.price ~ search_activity, data = data)
summary(sales_model)
summary(price_model)
plot(sales_model)
plot(data$search_activity, data$ff.sales)

plot(sales_model$fitted, sales_model$residuals,
     xlab = "Fitted Values", ylab = "Residual Values",
     main = "Residual Plot for Cars Dataset")
qqnorm(sales_model$residuals)
qqline(sales_model$residuals)

## Create box_cox transformed data for re-modelling.
data_bc = data
data_bc$ff.sales = data_bc$ff.sales + 10
data_bc$fg.price = data_bc$fg.price + 10
data_bc$search_activity = data_bc$search_activity + 10
price10_model = lm(fg.price ~ search_activity, data = data_bc)
sales10_model = lm(ff.sales ~ search_activity, data = data_bc)

sales10_loglikely = boxcox(sales10_model)
price10_loglikely = boxcox(price10_model)
pricemodel_lambda = price10_loglikely$x[which(price10_loglikely$y == max(price10_loglikely$y))]
salesmodel_lambda = sales10_loglikely$x[which(sales10_loglikely$y == max(sales10_loglikely$y))]
salesmodel_lambda = -.25
data_bc$search_activity[1] = NA
data_bc$search_activity = (data_bc$ff.sales^(salesmodel_lambda) - 1) / salesmodel_lambda
sales_model_bc = lm(ff.sales ~ search_activity, data = data_bc)
price_model_bc = lm(fg.price ~ search_activity, data = data_bc)
summary(sales_model_bc)
summary(price_model_bc)
plot(sales_model_bc)
plot(data_bc$search_activity, data_bc$ff.sales)
abline(sales_model_bc, lty = 2)

sub_data = data %>%
  filter(fref.entity.naics.code %in% c('Information', 'Professional, Scientific, and Technical Services'))

sales_model = lm(search_activity ~ ff.sales, data = sub_data)
price_model = lm(search_activity ~ fg.price, data = sub_data)
summary(sales_model)
summary(price_model)
plot(sales_model)

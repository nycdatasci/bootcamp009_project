library(dplyr)
library(ggplot2)
library(shiny)
library(ggthemes)
library(gplots)
library(graphics)
library(grDevices)
library(zoo)
library(lubridate)
library(scales)
data = read.csv('SpinData.csv')
data = data.frame(data)

## Create Spinoff Analysis Windows & Prospective Return Metrics 

## Creating field for key metrics.

data = data %>%
  mutate(ff.sales.ebit.t12m = fg.ebit.oper.l/ff.sales) %>%
  mutate(ff.mkt.val.cash = ff.cash.st/ff.mkt.val)


# Variables that can be put on the x-axis or color gradient.
axis_vars <- c(
  "Market Value ($M)" = "ff.mkt.val",
  "Enterprise Value ($M)" = "ff.entrpr.val",
  "Enterprise Value / Sales" = "ff.entrpr.val.sales",
  "Enterprise Value / EBIT" = "ff.entrpr.val.ebit.oper",  
  "Enterprise Value / EBITDA" = "ff.entrpr.val.ebitda.oper",
  "Enterprise Value / Trailing FCF" = "ff.entrpr.val.fcf",
  "Price / Trailing FCF" = "ff.pfcf",
  "Long-Term Debt / Total Capital" = "ff.ltd.tcap",
  "Cash as % of Market Value of Equity" = "ff.mkt.val.cash",   
  "Price / Book Value of Equity per Share" = "ff.bps",
  "Return on Total Capital" = "ff.oper.inc.tcap",
  "Operating Income Margin" = "ff.sales.ebit.t12m",
  "Avg. Compounded Annual Outperformance % vs. S&P 500 to 24 Mo. Post-Spin" = "rt_rel_sp_0.24",
  "Avg. Compounded Annual Outperformance % vs. S&P 500 to 36 Mo. Post-Spin" = "rt_rel_sp_0.36"
)

## At-Spin / 1st Earnings Release with Forward 12, 24, and 36 month return.
a = data %>%
  filter(days_exspin %in% 10:102 & FundData == 1) %>%
  mutate(rt_0.24 = (((price.twoyear / price.atspin)^(1/2))-1) * 100) %>%
  mutate(sp_rt_0.24 = (((SPY.twoyear / SPY.atspin)^(1/2))-1)* 100) %>%
  mutate(ru_rt_0.24 = (((IWM.twoyear / IWM.atspin)^(1/2))-1)* 100) %>%
  mutate(rt_rel_sp_0.24 = rt_0.24 - sp_rt_0.24) %>%
  mutate(rt_rel_ru_0.24 = rt_0.24 - ru_rt_0.24) %>%
  mutate(rt_0.36 = (((price.threeyear / price.atspin)^(1/3))-1)* 100) %>%
  mutate(sp_rt_0.36 = (((SPY.threeyear / SPY.atspin)^(1/3))-1)* 100) %>%
  mutate(ru_rt_0.36 = (((IWM.threeyear / IWM.atspin)^(1/3))-1)* 100) %>%
  mutate(rt_rel_sp_0.36 = rt_0.36 - sp_rt_0.24) %>%
  mutate(rt_rel_ru_0.36 = rt_0.36 - ru_rt_0.36) %>%
  mutate(spin_year = as.character(year(ExDate)))
  
## 2nd Earnings Release with Forward 12, 24, and 36 month return.
b = data %>%
  filter(days_exspin %in% 135:227 & FundData == 1) %>%
  mutate(rt_0.24 = (( (price.twoyear / p.price)^(1/((730-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_0.24 = (((SPY.twoyear / SPY.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_0.24 = (((IWM.twoyear / IWM.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(rt_rel_sp_0.24 = rt_0.24 - sp_rt_0.24) %>%
  mutate(rt_rel_ru_0.24 = rt_0.24 - ru_rt_0.24) %>%
  mutate(rt_0.36 = (( (price.threeyear / p.price)^(1/((1095-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_0.36 = (((SPY.threeyear / SPY.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_0.36 = (((IWM.threeyear / IWM.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(rt_rel_sp_0.36 = rt_0.36 - sp_rt_0.24) %>%
  mutate(rt_rel_ru_0.36 = rt_0.36 - ru_rt_0.36) %>%
  mutate(spin_year = as.character(year(ExDate)))
  
## 4th Earnings Release, 12-15 Months After Spin with 12, 24, & 36 Month Forward Return
d = data %>%
  filter(days_exspin %in% 320:412 & FundData == 1) %>%
  mutate(rt_0.24 = (( (price.twoyear / p.price)^(1/((730-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_0.24 = (((SPY.twoyear / SPY.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_0.24 = (((IWM.twoyear / IWM.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(rt_rel_sp_0.24 = rt_0.24 - sp_rt_0.24) %>%
  mutate(rt_rel_ru_0.24 = rt_0.24 - ru_rt_0.24) %>%
  mutate(rt_0.36 = (( (price.threeyear / p.price)^(1/((1095-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_0.36 = (((SPY.threeyear / SPY.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_0.36 = (((IWM.threeyear / IWM.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(rt_rel_sp_0.36 = rt_0.36 - sp_rt_0.24) %>%
  mutate(rt_rel_ru_0.36 = rt_0.36 - ru_rt_0.36) %>%
  mutate(spin_year = as.character(year(ExDate)))


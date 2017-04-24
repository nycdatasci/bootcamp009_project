library(FactSet3)
library(rClr)
library(dplyr)
library(lubridate)
## Tickers of all spinoffs for 1/1/2009 to 12/31/2015
## I have excluded GOOG, companies spun to foreign exchanges, REMY, DEMBF, SBGL, & SVNT (Seventy Seven Energy).
## I have reduced multi class spin-off's to the selection of one with significant market cap.
## It is possible to re-integrate REMY & SVNT but will take some data wrangling outside of time scope.
## For future ref, try using 00GCCV-E for REMY in fund. database.  Price doesn't work with this ticker.
## Fund data needs fixing on DEMBF, SBGL.  Price works but fund doesn't.
spinoff_ticker_fund = 'HAWKQ,CFN,AOL,MSG,FAF,FURX,QEP,VPG,BWC,PAMT,HHC,SBRA,CTGO,MMI.XX2-US,APEMY,HII,UAN,TSRYY,MPC,AMCX,LPR,FBHS,LMOS,XLS,XYL,GNE,VAC,NRGM,TRIP,OSH,WPX,RSE,SXC,POST,ARP,RXII,PSX,NCQ,FRGI,ALEX,EGL,SHOS,ADT,HY,KRFT,FUTU,CNSI,PRTA,AAMC,RESI,PBKEF,ABBV,GCNG,ERA,CWGL,BPY,CST,NRZ,NRCIA,WWAV,NWS,NWSA,MNK,STRP,MUSA,SAIC,RGT,FTD,BSTG,GLPI,AHP,ALLE,OGS,SFR,CTRV,NEWM,KN,AMRK,LE,NAVI,CMCM,WPG,CVEO,DNOW,TBPH,CTRE,TIME,RYAM,FNFV,TMST,NSAM,VRTV,AST,TRNC,FWONK,NAME,PGNPQ,LTRPA,VEC,CDK,HYH,KE,KEYS,LBRDA,SNR,ENVA,AINC,CRC,KLXI,UE,PATI,XHR,VSTO,JMG'
spinoff_ticker_price = 'HAWKQ,CFN,AOL,MSG,FAF,FURX,QEP,VPG,BWC,PAMT,HHC,SBRA,CTGO,MMI.XX2-US,APEMY,HII,UAN,TSRYY,MPC,AMCX,LPR,FBHS,LMOS,XLS,XYL,GNE,VAC,NRGM,TRIP,OSH,WPX,RSE,SXC,POST,ARP,RXII,PSX,NCQ,FRGI,ALEX,EGL,SHOS,ADT,HY,KRFT,FUTU,CNSI,PRTA,AAMC,RESI,PBKEF,ABBV,GCNG,ERA,CWGL,BPY,CST,NRZ,NRCIA,WWAV,NWS,NWSA,MNK,STRP,MUSA,SAIC,RGT,FTD,BSTG,GLPI,AHP,ALLE,OGS,SFR,CTRV,NEWM,KN,AMRK,LE,NAVI,CMCM,WPG,CVEO,DNOW,TBPH,CTRE,TIME,RYAM,FNFV,TMST,NSAM,VRTV,AST,TRNC,FWONK,NAME,PGNPQ,LTRPA,VEC,CDK,HYH,KE,KEYS,LBRDA,SNR,ENVA,AINC,CRC,KLXI,UE,PATI,XHR,VSTO,JMG'
## Benchmark index ETF tickers for performance comparison purposes.
SP500_ticker = 'SPY'
R2000_ticker = 'IWM'
## Factset data series mostly in the FF database for spinoffs, calling 36 quarters backward from today.
spinoff_fund_series1 = 'FF_LTD_TCAP(QTR,-36,0,Q,,USD),FF_DEBT_LT(QTR,-36,0,Q,,USD),FF_CAPEX(LTM,-36,0,Q,,USD),FF_CASH_ST(QTR,-36,0,Q,,USD),FF_BPS(QTR,-36,0,Q,,USD),FF_DIV_COM_CF(QTR,-36,0,Q,,USD),FF_MKT_VAL(QTR,-36,0,Q,,USD),FF_OPER_INC_TCAP(QTR,-36,0,Q,,USD),FF_PBK_TANG(QTR,-36,0,Q,,USD),FF_PFCF(QTR,-36,0,Q,,USD),FF_SALES(LTM,-36,0,Q,,USD),FF_ENTRPR_VAL(QTR,-36,0,Q,,USD),FF_ENTRPR_VAL_EBIT_OPER(QTR,-36,0,Q,,USD),FF_ENTRPR_VAL_EBITDA_OPER(QTR,-36,0,Q,,USD),FF_ENTRPR_VAL_SALES(QTR,-36,0,Q,,USD),FF_ENTRPR_VAL_FCF(QTR,-36,0,Q,,USD),FF_EBIT_OPER_ROA(ANN_R,-40,0),FF_SALES_GR(LTM,-36,0,Q,,USD),FF_SALES_GR(QTR,-36,0,Q,,USD)' 
## Factset data series mostly in the FB database for spinoffs, calling 36 quarters backward from today.
spinoff_fund_series2 = 'FG_EBITDA_OPER_L(-36,0),FG_EBIT_OPER_L(-36,0),FG_NET_INC(-36,0)'
## Factset data series involving daily price or shareholder information, calling 36 quarters backward from today.
spinoff_fund_series3 = 'P_DIVS_PD_F(-36Q,0),P_PRICE(-36Q,0)'
## Importing data through the Factset module and basic spinoff list with parent and ex-spin date.
spinoff_fund_data = F.ExtractFormulaHistory(spinoff_ticker_fund,spinoff_fund_series1,'');
spinoff_fund_data2 = F.ExtractFormulaHistory(spinoff_ticker_fund,spinoff_fund_series2,'-36:0:Q');
spinoff_fund_data3 = F.ExtractFormulaHistory(spinoff_ticker_price,spinoff_fund_series3,'');
spinoff_fund_data4 = read.csv('Spinoffs.csv')
spinoff_fund_data5 = F.ExtractFormulaHistory(SP500_ticker,'P_PRICE(-36Q,0)','');
spinoff_fund_data6 = F.ExtractFormulaHistory(R2000_ticker,'P_PRICE(-36Q,0)','');
# Ensuring uniform date data and ticker coding / adding 49 day delay to fundamental data.
spinoff_fund_data$Date = as.Date(spinoff_fund_data$Date) + 49
spinoff_fund_data2$Date = as.Date(spinoff_fund_data2$Date) + 49
spinoff_fund_data3$Date = as.Date(spinoff_fund_data3$Date)
spinoff_fund_data4$ExDate = as.Date(spinoff_fund_data4$ExDate,'%m/%d/%Y')
spinoff_fund_data5$Date = as.Date(spinoff_fund_data5$Date)
spinoff_fund_data6$Date = as.Date(spinoff_fund_data6$Date)
colnames(spinoff_fund_data4)[1] = 'Id'
colnames(spinoff_fund_data5)[3] = 'SPY.price'
colnames(spinoff_fund_data6)[3] = 'IWM.price'
spinoff_fund_data5$Id = NULL
spinoff_fund_data6$Id = NULL
# Clean-up of pricing data using a join of ex-spin data to help sort the extraneous data.
# Filtering any price data prior to the spin date.
spinoff_price_data = left_join(spinoff_fund_data3,spinoff_fund_data4)
spinoff_price_data = spinoff_price_data %>% 
  filter(Date >= ExDate)
spinoff_price_data$Company = NULL
spinoff_price_data$Parent.Company = NULL
spinoff_price_data$ExDate = NULL
# Assembling data set in total / label dates with fund. data.
data = left_join(spinoff_fund_data,spinoff_fund_data2)
data$FundData = as.vector(rep(1,nrow(data)))
data = full_join(data,spinoff_price_data,by=c('Id','Date'))
data = full_join(data,spinoff_fund_data4,by=c('Id'))
data = full_join(data,spinoff_fund_data5)
data = full_join(data,spinoff_fund_data6)
data = data %>%
  filter(!(is.na(ff.cash.st) & is.na(ff.sales) & is.na(ff.ebit.oper.roa) & is.na(p.price)))
data = data %>%
  mutate(days_exspin = difftime(Date,ExDate, units = c('days')))
## Create time point benchmarks to attach to all data.
spin.price = data %>%
  select(Id,p.price,SPY.price,IWM.price,days_exspin) %>%
  filter(days_exspin %in% seq(0, 100, by = 1)) %>%
  group_by(Id) %>%
  filter(days_exspin == min(days_exspin))
colnames(spin.price)[2] = 'price.atspin'
colnames(spin.price)[3] = 'SPY.atspin'
colnames(spin.price)[4] = 'IWM.atspin'
spin.price$days_exspin = NULL

OneYear.price = data %>%
  select(Id,p.price,SPY.price,IWM.price,days_exspin) %>%
  filter(days_exspin %in% seq(300, 367, by=1)) %>%
  group_by(Id) %>%
  filter(days_exspin == max(days_exspin))
colnames(OneYear.price)[2] = 'price.oneyear'
colnames(OneYear.price)[3] = 'SPY.oneyear'
colnames(OneYear.price)[4] = 'IWM.oneyear'
OneYear.price$days_exspin = NULL

TwoYear.price = data %>%
  select(Id,p.price,SPY.price,IWM.price,days_exspin) %>%
  filter(days_exspin %in% seq(728, 731, by=1)) %>%
  group_by(Id) %>%
  filter(days_exspin == max(days_exspin))
colnames(TwoYear.price)[2] = 'price.twoyear'
colnames(TwoYear.price)[3] = 'SPY.twoyear'
colnames(TwoYear.price)[4] = 'IWM.twoyear'
TwoYear.price$days_exspin = NULL

ThreeYear.price = data %>%
  select(Id,p.price,SPY.price,IWM.price,days_exspin) %>%
  filter(days_exspin %in% seq(1093, 1096, by=1)) %>%
  group_by(Id) %>%
  filter(days_exspin == max(days_exspin))
colnames(ThreeYear.price)[2] = 'price.threeyear'
colnames(ThreeYear.price)[3] = 'SPY.threeyear'
colnames(ThreeYear.price)[4] = 'IWM.threeyear'
ThreeYear.price$days_exspin = NULL

## Assemble price snapshots onto all data.

data = full_join(data,spin.price)
data = full_join(data,OneYear.price)
data = full_join(data,TwoYear.price)
data = full_join(data,ThreeYear.price)
data_fields = colnames(data)
data$days_exspin = as.integer(data$days_exspin)
write.csv(data, file = 'SpinData.csv')

## Create Prospective Return Metrics 

a = data %>%
  filter(days_exspin %in% -1:91 & FundData == 1) %>%
  mutate(rt_0.12 = (((price.oneyear / price.atspin) - 1) * 100)) %>%
  mutate(sp_rt_0.12 = (((SPY.oneyear / SPY.atspin) - 1) * 100)) %>%
  mutate(ru_rt_0.12 = (((IWM.oneyear / IWM.atspin) - 1) * 100)) %>%
  mutate(rt_0.24 = (((price.twoyear / price.atspin)^(1/2))-1) * 100) %>%
  mutate(sp_rt_0.24 = (((SPY.twoyear / SPY.atspin)^(1/2))-1)* 100) %>%
  mutate(ru_rt_0.24 = (((IWM.twoyear / IWM.atspin)^(1/2))-1)* 100) %>%
  mutate(rt_0.36 = (((price.threeyear / price.atspin)^(1/3))-1)* 100) %>%
  mutate(sp_rt_0.36 = (((SPY.threeyear / SPY.atspin)^(1/3))-1)* 100) %>%
  mutate(ru_rt_0.36 = (((IWM.threeyear / IWM.atspin)^(1/3))-1)* 100) %>%
  mutate(spin_year = as.character(year(ExDate)))
  
b = data %>%
  filter(days_exspin %in% 92:183 & FundData == 1) %>%
  mutate(rt_2ndRep.12 = ((((price.oneyear / p.price) - 1) * 100)) * (365/(365-days_exspin))) %>%
  mutate(sp_rt_2ndRep.12 = (((SPY.oneyear / SPY.price) - 1) * 100) * (365/(365-days_exspin))) %>%
  mutate(ru_rt_2ndRep.12 = (((IWM.oneyear / IWM.price) - 1) * 100) * (365/(365-days_exspin))) %>%
  mutate(rt_2ndRep.24 = (( (price.twoyear / p.price)^(1/((730-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_2ndRep.24 = (((SPY.twoyear / SPY.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_2ndRep.24 = (((IWM.twoyear / IWM.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(rt_2ndRep.36 = (( (price.threeyear / p.price)^(1/((1095-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_2ndRep.36 = (((SPY.threeyear / SPY.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_2ndRep.36 = (((IWM.threeyear / IWM.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(spin_year = as.character(year(ExDate)))

c = data %>%
  filter(days_exspin %in% 184:275 & FundData == 1) %>%
  mutate(rt_3rdRep.12 = ((((price.oneyear / p.price) - 1) * 100)) * (365/(365-days_exspin))) %>%
  mutate(sp_rt_3rdRep.12 = (((SPY.oneyear / SPY.price) - 1) * 100) * (365/(365-days_exspin))) %>%
  mutate(ru_rt_3rdRep.12 = (((IWM.oneyear / IWM.price) - 1) * 100) * (365/(365-days_exspin))) %>%
  mutate(rt_3rdRep.24 = (( (price.twoyear / p.price)^(1/((730-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_3rdRep.24 = (((SPY.twoyear / SPY.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_3rdRep.24 = (((IWM.twoyear / IWM.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(rt_3rdRep.36 = (( (price.threeyear / p.price)^(1/((1095-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_3rdRep.36 = (((SPY.threeyear / SPY.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_3rdRep.36 = (((IWM.threeyear / IWM.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(spin_year = as.character(year(ExDate)))
  
d = data %>%
  filter(days_exspin %in% 363:455 & FundData == 1) %>%
  mutate(rt_FullYear.24 = (( (price.twoyear / p.price)^(1/((730-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_FullYear.24 = (((SPY.twoyear / SPY.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_FullYear.24 = (((IWM.twoyear / IWM.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(rt_FullYear.36 = (( (price.threeyear / p.price)^(1/((1095-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_FullYear.36 = (((SPY.threeyear / SPY.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_FullYear.36 = (((IWM.threeyear / IWM.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(spin_year = as.character(year(ExDate)))
  
e = data %>%
  filter(days_exspin %in% 543:635 & FundData == 1) %>%
  mutate(rt_18.24 = (( (price.twoyear / p.price)^(1/((730-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_18.24 = (((SPY.twoyear / SPY.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_18.24 = (((IWM.twoyear / IWM.price)^(1/((730-days_exspin)/365)) )-1)* 100) %>%
  mutate(rt_18.36 = (( (price.threeyear / p.price)^(1/((1095-days_exspin)/365) )-1))* 100) %>%
  mutate(sp_rt_18.36 = (((SPY.threeyear / SPY.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(ru_rt_18.36 = (((IWM.threeyear / IWM.price)^(1/((1095-days_exspin)/365)) )-1)* 100) %>%
  mutate(spin_year = as.character(year(ExDate)))
  

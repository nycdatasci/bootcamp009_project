### Team github repo for Kaggle competition occuring in May 2017. 
* Kaggle Competition: Sberbank Russian Housing Market
* Can you predict realty price fluctuations in Russia’s volatile economy?
* https://www.kaggle.com/c/sberbank-russian-housing-market

### Team Members (by last name): 
* Haseeb Durrani 
* Chen Trilnik
* Jack Yip

### Folder Structure (more or less in chronological order)
* __chen_df.csv, haseeb_data.csv, jack.csv__: We had each imputed different features (train and test)
* __full_data_kaggle.csv__: This data set combines the features from the previous csv's (train and test)
* __train_df.csv, test_df.csv__: The iteration contains the following features: id, kindergarten_km, school_km, metro_km_avto, public_healthcare_km, month, year, sub_area, full_sq, build_year, floor, max_floor, price_doc (train only), product_type
* __train_df2.csv, test_df2.csv__: The iteration contains the following features: id, kindergarten_km, school_km, metro_km_avto, public_healthcare_km, month, year, sub_area, full_sq, build_year, floor, max_floor, price_doc, product_type, area_m, raion_popul, metro_min_avto, park_km, green_zone_km, industrial_km, public_transport_station_km, water_km, big_road1_km, railroad_km, radiation_km, fitness_km, shopping_centers_km, preschool_km
* __Macro_Train.csv, Macro_test.csv__: This dataset contains the list of top 20 macro features based on XGBoost importance. The features contained are id, timestamp, price_doc, usdrub, eurrub, brent, micex_cbi_tr, micex, micex_rgbi_tr, rts, oil_urals, cpi, balance_trade, gdp_quart, ppi, net_capital_export, rent_price_4+room_bus, income_per_cap (dropped due to missing values), deposits_growth, rent_price_2room_bus     0, gdp_quart_growth, rent_price_3room_bus, rent_price_1room_bus
* __train_df3.csv, test_df3__: This iteration contains the features from df2 plus macro features, which includes: id, kindergarten_km, school_km, metro_km_avto, public_healthcare_km, month, year, sub_area, full_sq	build_year, floor, max_floor, price_doc, product_type, area_m, raion_popul, metro_min_avto, park_km, green_zone_km, industrial_km, public_transport_station_km, water_km	big_road1_km, railroad_km, radiation_km, fitness_km, shopping_centers_km, preschool_km, timestamp, usdrub, eurrub, brent, micex_cbi_tr, micex, micex_rgbi_tr, rts	oil_urals, cpi, balance_trade, gdp_quart, ppi	net_capital_export, rent_price_4+room_bus, deposits_growth	rent_price_2room_bus, gdp_quart_growth, rent_price_3room_bus, rent_price_1room_bus
* __Data_Cleaning_Jack.ipynb__: Contains outliers and imputation work
* __GBM_Jack.R__: Contains work on Gradient Boosting Trees Model
* __MLR_RF_Jack.R__: Contains work on Multiple Linear Regression and Random Forest
* __xgboost_Jack.ipynb__: Contains work on XGBoost

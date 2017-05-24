# @author Scott Dobbins
# @date 2017-05-24 15:30
# @version 0.6.3


### FUTURE IMPROVEMENTS ###
#*** should I set keys on any of the data.table objects?
#*** generate avg_log_price and avg_Log_price_per_log_fullsq for each aggregate (join into existing data sets?)


### import packages ###

# (in ascending order of importance)
library(lubridate)
library(data.table)
library(dplyr)


### global constants ###

# filenames
train_raw_filename <- 'train.csv'
test_raw_filename <- 'test.csv'
macro_raw_filename <- 'macro.csv'

train_total_filename <- 'train_total.csv'
test_total_filename <- 'test_total.csv'
train_total_complete_filename <- 'train_total_complete.csv'
test_total_complete_filename <- 'test_total_complete.csv'

train_barebones_price_filename <- 'train_barebones_price.csv'
train_barebones_logprice_filename <- 'train_barebones_logprice.csv'
test_barebones_filename <- 'test_barebones.csv'
train_barebones_price_complete_filename <- 'train_barebones_price_complete.csv'
train_barebones_logprice_complete_filename <- 'train_barebones_logprice_complete.csv'
test_barebones_complete_filename <- 'test_barebones_complete.csv'

train_transforms_price_filename <- 'train_transforms_price.csv'
train_transforms_logprice_filename <- 'train_transforms_logprice.csv'
test_transforms_filename <- 'test_transforms.csv'
train_transforms_price_complete_filename <- 'train_transforms_price_complete.csv'
train_transforms_logprice_complete_filename <- 'train_transforms_logprice_complete.csv'
test_transforms_complete_filename <- 'test_transforms_complete.csv'

raion_filename <- 'raion.csv'
yearly_filename <- 'yearly.csv'
quarterly_filename <- 'quarterly.csv'
monthly_filename <- 'monthly.csv'
daily_filename <- 'daily.csv'

# colnames
raion_colnames <- c("area_m",
                    "raion_popul",
                    "green_zone_part",
                    "indust_part",
                    "children_preschool",
                    "preschool_quota",
                    "preschool_education_centers_raion",
                    "children_school",
                    "school_quota",
                    "school_education_centers_raion",
                    "school_education_centers_top_20_raion",
                    "hospital_beds_raion",
                    "healthcare_centers_raion",
                    "university_top_20_raion",
                    "sport_objects_raion",
                    "additional_education_raion",
                    "culture_objects_top_25",
                    "culture_objects_top_25_raion",
                    "shopping_centers_raion",
                    "office_raion",
                    "thermal_power_plant_raion",
                    "incineration_raion",
                    "oil_chemistry_raion",
                    "radiation_raion",
                    "railroad_terminal_raion",
                    "big_market_raion",
                    "nuclear_reactor_raion",
                    "detention_facility_raion",
                    "full_all",
                    "male_f",
                    "female_f",
                    "young_all",
                    "young_male",
                    "young_female",
                    "work_all",
                    "work_male",
                    "work_female",
                    "ekder_all",
                    "ekder_male",
                    "ekder_female",
                    "0_6_all",
                    "0_6_male",
                    "0_6_female",
                    "7_14_all",
                    "7_14_male",
                    "7_14_female",
                    "0_17_all",
                    "0_17_male",
                    "0_17_female",
                    "16_29_all",
                    "16_29_male",
                    "16_29_female",
                    "0_13_all",
                    "0_13_male",
                    "0_13_female",
                    "raion_build_count_with_material_info",
                    "build_count_block",
                    "build_count_wood",
                    "build_count_frame",
                    "build_count_brick",
                    "build_count_monolith",
                    "build_count_panel",
                    "build_count_foam",
                    "build_count_slag",
                    "build_count_mix",
                    "raion_build_count_with_builddate_info",
                    "build_count_before_1920",
                    "build_count_1921-1945",
                    "build_count_1946-1970",
                    "build_count_1971-1995",
                    "build_count_after_1995")

yearly_colnames <- c("gdp_deflator", 
                     "gdp_annual", 
                     "gdp_annual_growth", 
                     "grp", 
                     "grp_growth", 
                     "real_dispos_income_per_cap_growth", 
                     "salary", 
                     "salary_growth", 
                     "retail_trade_turnover", 
                     "retail_trade_turnover_per_cap", 
                     "retail_trade_turnover_growth", 
                     "labor_force", 
                     "unemployment", 
                     "employment", 
                     "invest_fixed_capital_per_cap", 
                     "invest_fixed_assets", 
                     "profitable_enterpr_share", 
                     "unprofitable_enterpr_share", 
                     "share_own_revenues", 
                     "overdue_wages_per_cap", 
                     "fin_res_per_cap", 
                     "marriages_per_1000_cap", 
                     "divorce_rate", 
                     "construction_value", 
                     "invest_fixed_assets_phys", 
                     "pop_natural_increase", 
                     "pop_migration", 
                     "pop_total_inc", 
                     "childbirth", 
                     "mortality", 
                     "housing_fund_sqm", 
                     "lodging_sqm_per_cap", 
                     "water_pipes_share", 
                     "baths_share", 
                     "sewerage_share", 
                     "gas_share", 
                     "hot_water_share", 
                     "electric_stove_share", 
                     "heating_share", 
                     "old_house_share", 
                     "average_life_exp", 
                     "infant_mortarity_per_1000_cap", 
                     "perinatal_mort_per_1000_cap", 
                     "incidence_population", 
                     "load_of_teachers_preschool_per_teacher", 
                     "child_on_acc_pre_school", 
                     "load_of_teachers_school_per_teacher", 
                     "students_state_oneshift", 
                     "modern_education_share", 
                     "old_education_build_share", 
                     "provision_doctors", 
                     "provision_nurse", 
                     "load_on_doctors", 
                     "power_clinics", 
                     "hospital_beds_available_per_cap", 
                     "hospital_bed_occupancy_per_year", 
                     "provision_retail_space_sqm", 
                     "provision_retail_space_modern_sqm", 
                     "turnover_catering_per_cap", 
                     "theaters_viewers_per_1000_cap", 
                     "seats_theather_rfmin_per_100000_cap", 
                     "museum_visitis_per_100_cap", 
                     "bandwidth_sports", 
                     "population_reg_sports_share", 
                     "students_reg_sports_share", 
                     "apartment_build", 
                     "apartment_fund_sqm")

quarterly_colnames <- c("gdp_quart", 
                        "gdp_quart_growth", 
                        "balance_trade_growth", 
                        "average_provision_of_build_contract", 
                        "average_provision_of_build_contract_moscow")

monthly_colnames <- c("oil_urals", 
                      "cpi", 
                      "ppi", 
                      "balance_trade", 
                      "net_capital_export", 
                      "deposits_value", 
                      "deposits_growth", 
                      "deposits_rate", 
                      "mortgage_value", 
                      "mortgage_growth", 
                      "mortgage_rate", 
                      "income_per_cap", 
                      "fixed_basket", 
                      "rent_price_4+room_bus", 
                      "rent_price_3room_bus", 
                      "rent_price_2room_bus", 
                      "rent_price_1room_bus", 
                      "rent_price_3room_eco", 
                      "rent_price_2room_eco", 
                      "rent_price_1room_eco")

daily_colnames <- c("timestamp", 
                    "usdrub", 
                    "eurrub", 
                    "brent", 
                    "rts", 
                    "micex", 
                    "micex_rgbi_tr", 
                    "micex_cbi_tr")

# data reading data types
macro_classes <- c(rep("character", 1), 
                   rep("double", 20), 
                   rep("integer", 1), 
                   rep("double", 2), 
                   rep("integer", 1), 
                   rep("double", 20), 
                   rep("integer", 1), 
                   rep("double", 10), 
                   rep("integer", 1), 
                   rep("double", 21), 
                   rep("character", 1), 
                   rep("double", 2), 
                   rep("character", 2), 
                   rep("double", 4), 
                   rep("integer", 6), 
                   rep("double", 1), 
                   rep("integer", 2), 
                   rep("double", 2), 
                   rep("integer", 1), 
                   rep("double", 1))

raion_classes <- c(rep("factor", 1), 
                   rep("double", 1), 
                   rep("integer", 1), 
                   rep("double", 2), 
                   rep("integer", 12), 
                   rep("factor", 1), 
                   rep("integer", 3), 
                   rep("factor", 8), 
                   rep("integer", 43))

features_within_radius_classes <- c(rep("double", 2), 
                                    rep("integer", 5), 
                                    rep("double", 3), 
                                    rep("integer", 13))

test_raw_classes <- c(rep("integer", 1), 
                      rep("character", 1), 
                      rep("double", 2), 
                      rep("integer", 5), 
                      rep("double", 1), 
                      rep("integer", 1), 
                      rep("factor", 1), 
                      raion_classes, 
                      rep("integer", 1), 
                      rep("double", 14), 
                      rep("integer", 1), 
                      rep("double", 2), 
                      rep("integer", 1), 
                      rep("double", 3), 
                      rep("factor", 1), 
                      rep("double", 6), 
                      rep("integer", 1), 
                      rep("factor", 1), 
                      rep("double", 1), 
                      rep("integer", 1), 
                      rep("double", 1), 
                      rep("factor", 1), 
                      rep("double", 1), 
                      rep("integer", 1), 
                      rep("double", 1), 
                      rep("integer", 1), 
                      rep("double", 29), 
                      rep("factor", 1), 
                      rep(features_within_radius_classes, 6))

train_raw_classes <- c(test_raw_classes, 
                       "integer")

transform_classes <- rep("double", 6)
price_transform_classes <- rep("double", 4)

train_total_classes <- c(train_raw_classes, 
                         "integer", 
                         transform_classes, 
                         price_transform_classes)

test_total_classes <- c(test_raw_classes, 
                        transform_classes)

train_barebones_logprice_classes <- c(test_raw_classes, 
                                      "double")
train_barebones_price_classes <- train_raw_classes
test_barebones_classes <- test_raw_classes

train_transforms_logprice_classes <- train_total_classes[-c(3:6,9:10,221,229:230)]
train_transforms_price_classes <- train_total_classes[-c(3:6,9:10,222,231:232)]
test_transforms_classes <- test_total_classes[-c(-6:-1)]

# date constants
years <- c("2010", 
           "2011", 
           "2012", 
           "2013", 
           "2014", 
           "2015", 
           "2016")
quarters <- c("2010-Q1", 
              "2010-Q2", 
              "2010-Q3", 
              "2010-Q4", 
              "2011-Q1", 
              "2011-Q2", 
              "2011-Q3", 
              "2011-Q4", 
              "2012-Q1", 
              "2012-Q2", 
              "2012-Q3", 
              "2012-Q4", 
              "2013-Q1", 
              "2013-Q2", 
              "2013-Q3", 
              "2013-Q4", 
              "2014-Q1", 
              "2014-Q2", 
              "2014-Q3", 
              "2014-Q4", 
              "2015-Q1", 
              "2015-Q2", 
              "2015-Q3", 
              "2015-Q4", 
              "2016-Q1", 
              "2016-Q2", 
              "2016-Q3", 
              "2016-Q4")
months <- c("2010-01", 
            "2010-02", 
            "2010-03", 
            "2010-04", 
            "2010-05", 
            "2010-06", 
            "2010-07", 
            "2010-08", 
            "2010-09", 
            "2010-10", 
            "2010-11", 
            "2010-12", 
            "2011-01", 
            "2011-02", 
            "2011-03", 
            "2011-04", 
            "2011-05", 
            "2011-06", 
            "2011-07", 
            "2011-08", 
            "2011-09", 
            "2011-10", 
            "2011-11", 
            "2011-12", 
            "2012-01", 
            "2012-02", 
            "2012-03", 
            "2012-04", 
            "2012-05", 
            "2012-06", 
            "2012-07", 
            "2012-08", 
            "2012-09", 
            "2012-10", 
            "2012-11", 
            "2012-12", 
            "2013-01", 
            "2013-02", 
            "2013-03", 
            "2013-04", 
            "2013-05", 
            "2013-06", 
            "2013-07", 
            "2013-08", 
            "2013-09", 
            "2013-10", 
            "2013-11", 
            "2013-12", 
            "2014-01", 
            "2014-02", 
            "2014-03", 
            "2014-04", 
            "2014-05", 
            "2014-06", 
            "2014-07", 
            "2014-08", 
            "2014-09", 
            "2014-10", 
            "2014-11", 
            "2014-12", 
            "2015-01", 
            "2015-02", 
            "2015-03", 
            "2015-04", 
            "2015-05", 
            "2015-06", 
            "2015-07", 
            "2015-08", 
            "2015-09", 
            "2015-10", 
            "2015-11", 
            "2015-12", 
            "2016-01", 
            "2016-02", 
            "2016-03", 
            "2016-04", 
            "2016-05", 
            "2016-06", 
            "2016-07", 
            "2016-08", 
            "2016-09", 
            "2016-10")

# other useful constants
possible_materials <- c(1,2,4,5,6)
possible_product_types <- c("Investment", "OwnerOccupier")
raion_colindices <- 13:84


### data reading functions ###
# parameter specifications: dataset can be 'all', 'train', 'test', 'macro', or 'raion'
#                         : type can be 'total', 'barebones', 'transforms', or 'raw'
read_data <- function(directory = 'data/', dataset = 'all', type = 'raw', complete_only = FALSE, log_price = TRUE, data_frame = FALSE) {
  if(dataset == 'all') {
    if(type == 'raw') {
      macro <- fread(input = paste0(directory, macro_raw_filename), colClasses = macro_classes)
    } else {
      raion <- fread(input = paste0(directory, raion_filename), colClasses = raion_classes)
    }
    if(type == 'total') {
      if(complete_only) {
        train <- fread(input = paste0(directory, train_total_complete_filename), colClasses = train_total_classes)
        test <- fread(input = paste0(directory, test_total_complete_filename), colClasses = test_total_classes)
      } else {
        train <- fread(input = paste0(directory, train_total_filename), colClasses = train_total_classes)
        test <- fread(input = paste0(directory, test_total_filename), colClasses = test_total_classes)
      }
    } else if(type == 'barebones') {
      if(complete_only) {
        test <- fread(input = paste0(directory, test_barebones_complete_filename), colClasses = test_barebones_classes)
        if(log_price) {
          train <- fread(input = paste0(directory, train_barebones_logprice_complete_filename), colClasses = train_barebones_classes)
        } else {
          train <- fread(input = paste0(directory, train_barebones_price_complete_filename), colClasses = train_barebones_classes)
        }
      } else {
        test <- fread(input = paste0(directory, test_barebonesfilename), colClasses = test_barebones_classes)
        if(log_price) {
          train <- fread(input = paste0(directory, train_barebones_logprice_filename), colClasses = train_barebones_classes)
        } else {
          train <- fread(input = paste0(directory, train_barebones_price_filename), colClasses = train_barebones_classes)
        }
      }
    } else if(type == 'transforms') {
      if(complete_only) {
        test <- fread(input = paste0(directory, test_transforms_complete_filename), colClasses = test_transforms_classes)
        if(log_price) {
          train <- fread(input = paste0(directory, train_transform_logprice_complete_filename), colClasses = train_transforms_classes)
        } else {
          train <- fread(input = paste0(directory, train_transform_price_complete_filename), colClasses = train_transforms_classes)
        }
      } else {
        test <- fread(input = paste0(directory, test_transforms_filename), colClasses = test_transforms_classes)
        if(log_price) {
          train <- fread(input = paste0(directory, train_barebones_logprice_filename), colClasses = train_transforms_classes)
        } else {
          train <- fread(input = paste0(directory, train_barebones_price_filename), colClasses = train_transforms_classes)
        }
      }
    } else if(type == 'raw') {
      train <- fread(input = paste0(directory, train_raw_filename), colClasses = train_raw_classes)
      test <- fread(input = paste0(directory, test_raw_filename), colClasses = test_raw_classes)
    } else {
      print("You asked for a type that doesn't exist")# raise error?
    }
    if(data_frame) {
      train <- data.frame(train)
      test <- data.frame(test)
      macro <- data.frame(macro)
      raion <- data.frame(raion)
    }
    if(type == 'raw') {
      return(list('train' = train, 'test' = test, 'macro' = macro))
    } else {
      return(list('train' = train, 'test' = test, 'raion' = raion))
    }
  } else if(dataset == 'train') {
    if(type == 'total') {
      if(complete_only) {
        train <- fread(input = paste0(directory, train_total_complete_filename), colClasses = train_total_classes)
      } else {
        train <- fread(input = paste0(directory, train_total_filename), colClasses = train_total_classes)
      }
    } else if(type == 'barebones') {
      if(log_price) {
        if(complete_only) {
          train <- fread(input = paste0(directory, train_barebones_logprice_complete_filename), colClasses = train_barebones_classes)
        } else {
          train <- fread(input = paste0(directory, train_barebones_logprice_filename), colClasses = train_barebones_classes)
        }
      } else {
        if(complete_only) {
          train <- fread(input = paste0(directory, train_barebones_price_complete_filename), colClasses = train_barebones_classes)
        } else {
          train <- fread(input = paste0(directory, train_barebones_price_filename), colClasses = train_barebones_classes)
        }
      }
    } else if(type == 'transforms') {
      if(log_price) {
        if(complete_only) {
          train <- fread(input = paste0(directory, train_transform_logprice_complete_filename), colClasses = train_transforms_classes)
        } else {
          train <- fread(input = paste0(directory, train_transform_logprice_filename), colClasses = train_transforms_classes)
        }
      } else {
        if(complete_only) {
          train <- fread(input = paste0(directory, train_transform_price_complete_filename), colClasses = train_transforms_classes)
        } else {
          train <- fread(input = paste0(directory, train_transform_price_filename), colClasses = train_transforms_classes)
        }
      }
    } else if(type == 'raw') {
      train <- fread(input = paste0(directory, train_raw_filename), colClasses = train_raw_classes)
    } else {
      print("You asked for a type that doesn't exist")# raise error?
    }
    if(data_frame) {
      train <- data.frame(train)
    }
    return(list('train' = train))
  } else if(dataset == 'test') {
    if(type == 'total') {
      if(complete_only) {
        test <- fread(input = paste0(directory, test_total_complete_filename), colClasses = test_total_classes)
      } else {
        test <- fread(input = paste0(directory, test_total_filename), colClasses = test_total_classes)
      }
    } else if(type == 'barebones') {
      if(complete_only) {
        test <- fread(input = paste0(directory, test_barebones_complete_filename), colClasses = test_barebones_classes)
      } else {
        test <- fread(input = paste0(directory, test_barebones_filename), colClasses = test_barebones_classes)
      }
    } else if(type == 'transforms') {
      if(complete_only) {
        test <- fread(input = paste0(directory, test_transforms_complete_filename), colClasses = test_transforms_classes)
      } else {
        test <- fread(input = paste0(directory, test_transforms_filename), colClasses = test_transforms_classes)
      }
    } else if(type == 'raw') {
      test <- fread(input = paste0(directory, test_raw_filename), colClasses = test_raw_classes)
    } else {
      print("You asked for a type that doesn't exist")# raise error?
    }
    if(data_frame) {
      test <- data.frame(test)
    }
    return(list('test' = test))
  } else if(dataset == 'macro') {
    yearly <- fread(input = paste0(directory, yearly_filename))#, colClasses = )
    quarterly <- fread(input = paste0(directory, quarterly_filename))#, colClasses = )
    monthly <- fread(input = paste0(directory, monthly_filename))#, colClasses = )
    daily <- fread(input = paste0(directory, daily_filename))#, colClasses = )
    return(list('yearly' = yearly, 'quarterly' = quarterly, 'monthly' = monthly, 'daily' = daily))
  } else if(dataset == 'raion') {
    raion <- fread(input = paste0(directory, raion_filename), colClasses = raion_classes)
    if(data_frame) {
      raion <- data.frame(raion)
    }
    return(list('raion' = raion))
  } else {
    print("You asked for a dataset that doesn't exist")# raise error?
  }
}

transform_data <- function(data) {
  if("data.table" %in% class(data)) {
    return(transform_data.table(data))
  } else {
    return(transform_data.frame(data))
  }
}

transform_data.table <- function(data) {
  data[, year := year(timestamp)]
  data[, quarter := (paste0(year, "-Q", quarter(timestamp)))]
  data[, month := (paste0(year, "-", month(timestamp)))]
  data[, log_fullsq := (log(full_sq))]
  data[, log_lifesq := (log(life_sq))]
  data[, log_10p_floor := (log(10L + floor))]
  data[, log_10p_maxfloor := (log(10L + max_floor))]
  data[, log_1p_numroom := (log(1L + num_room))]
  data[, log_kitchsq := (log(kitch_sq))]
  if("price_doc" %in% colnames(data)) {
    data[, log_price := (log(price_doc))]
    data[, price_per_room := (price_doc / num_room)]
    data[, price_per_fullsq := (price_doc / full_sq)]
    data[, log_price_per_10p_log_room := (log(price_doc) / (10 + log(num_room)))]
    data[, log_price_per_log_fullsq := (log(price_doc) / log(full_sq))]
  }
  return(data)
}

transform_data.frame <- function(data) {
  data$year <- year(data$timestamp)
  data$quarter <- paste0(data$year, "-Q", quarter(data$timestamp))
  data$month <- paste0(data$year, "-", month(data$timestamp))
  data$log_fullsq <- log(data$full_sq)
  data$log_lifesq <- log(data$life_sq)
  data$log_10p_floor <- log(10L + data$floor)
  data$log_10p_maxfloor <- log(10L + data$max_floor)
  data$log_1p_numroom <- log(1L + data$num_room)
  data$log_kitchsq <- log(data$kitch_sq)
  if("price_doc" %in% colnames(data)) {
    data$log_price <- log(data$price_doc)
    data$price_per_room <- data$price_doc / data$num_room
    data$price_per_fullsq <- data$price_doc / data$full_sq
    data$log_price_per_10p_log_room <- log(data$price_doc) / (10 + log(data$num_room))
    data$log_price_per_log_fullsq <- log(data$price_doc) / log(data$full_sq)
  }
  return(data)
}

### cleaner function definitions ###

# master function that can handle either a data.frame object or a data.table object
# calls one of two sub-functions as necessary based on which class of input you give it
# the data.table sub-function is optimized for data.table and uses sets (:=) for speed and memory
# the data.frame sub-function does the same thing but using what's available in data.frame syntax
# behavior specifics: drop_dependents only drops known dependents (won't drop any new dependent columns you create)
#                   : drop_transforms only drops columns that start with "log_"
#                   : drop_high_NA drops *all* columns (regardless of keep_ratios) with >=10% NA values
#                   : keep_ratios only keeps columns that contain "_per_" (keep_ratios does *not* keep "_per_"-containing columns in dependents)
#                   : edge_cases will process known specific edge cases as discovered in the training data set (not test data set yet)
#                   : complete_cases drops all incomplete observations
clean_data <- function(data, drop_dependents = FALSE, drop_transforms = FALSE, drop_NA_threshold = 1, keep_ratios = FALSE, special_cases = TRUE, complete_cases = FALSE) {
  if("data.table" %in% class(data)) {
    return(clean_data.table(data, drop_dependents, drop_transforms, drop_NA_threshold, keep_ratios, special_cases, complete_cases))
  } else {
    return(clean_data.frame(data, drop_dependents, drop_transforms, drop_NA_threshold, keep_ratios, special_cases, complete_cases))
  }
}

# data.table-optimized sub-function
clean_data.table <- function(data, drop_dependents = FALSE, drop_transforms = FALSE, drop_NA_threshold = 1, keep_ratios = FALSE, special_cases = TRUE, complete_cases = FALSE) {
  data_colnames <- colnames(data)
  if(drop_dependents) {
    # figure out indices for each dependent (raion) column that is present in data set, pass that collection of indices into the selector
    data_dependent_indices <- c()
    for(colname in raion_colnames) {
      if(colname %in% data_colnames) {
        colname_index <- which(colname == data_colnames)
        data_dependent_indices <- c(data_dependent_indices, colname_index)
      }
    }
    data[, (data_dependent_indices) := NULL]
  }
  if(drop_transforms) {
    if(keep_ratios) {
      data[, (starts_with("log_") & !contains("_per_")) := NULL]
    } else {
      data[, (starts_with("log_")) := NULL]
    }
  }
  if(drop_NA_threshold < 1.0) {
    # get NA % for each column, then threshold, then pass those indices into selector
    portion_NA <- unlist(lapply(data, function(x) sum(is.na(x))/length(x)), use.names = FALSE)
    cols_to_drop <- which(portion_NA > drop_NA_theshold)
    data[, (cols_to_drop) := NULL]
  }
  if(special_cases) {
    if("log_10p_floor" %in% data_colnames) {
      data[(floor > 76L) & ((floor %% 11L) == 0L), c("floor", "log_10p_floor") := list(floor %/% 11L, log(10 + (floor %/% 11L)))]
      data[(floor > 76L) & ((floor %/% 100L) == ((floor %% 100L) %/% 10L)), c("floor", "log_10p_floor") := list((floor %/% 100L)*10L + floor %% 10L, log(10 + (floor %/% 100L)*10L + floor %% 10L))]
      data[(floor > 76L) & (((floor %% 100L) %/% 10L) == (floor %% 10L)), c("floor", "log_10p_floor") := list(floor %% 10L, log(10 + (floor %% 10L)))]
    } else {
      data[(floor > 76L) & ((floor %% 11L) == 0L), floor := (floor %/% 11L)]
      data[(floor > 76L) & ((floor %/% 100L) == ((floor %% 100L) %/% 10L)), floor := ((floor %/% 100L)*10L + floor %% 10L)]
      data[(floor > 76L) & (((floor %% 100L) %/% 10L) == (floor %% 10L)), floor := (floor %% 10L)]
    }
    if("log_10p_maxfloor" %in% data_colnames) {
      data[(max_floor > 76L) & ((max_floor %% 11L) == 0L), c("max_floor", "log_10p_maxfloor") := list(max_floor %/% 11L, log(10 + (max_floor %/% 11L)))]
      data[(max_floor > 76L) & ((max_floor %/% 100L) == ((max_floor %% 100L) %/% 10L)), c("max_floor", "log_10p_maxfloor") := list((max_floor %/% 100L)*10L + max_floor %% 10L, log(10 + (max_floor %/% 100L)*10L + max_floor %% 10L))]
      data[(max_floor > 76L) & (((max_floor %% 100L) %/% 10L) == (max_floor %% 10L)), c("max_floor", "log_10p_maxfloor") := list(max_floor %% 10L, log(10 + max_floor %% 10L))]
    } else {
      data[(max_floor > 76L) & ((max_floor %% 11L) == 0L), max_floor := (max_floor %/% 11L)]
      data[(max_floor > 76L) & ((max_floor %/% 100L) == ((max_floor %% 100L) %/% 10L)), max_floor := ((max_floor %/% 100L)*10L + max_floor %% 10L)]
      data[(max_floor > 76L) & (((max_floor %% 100L) %/% 10L) == (max_floor %% 10L)), max_floor := (max_floor %% 10L)]
    }
    data[build_year > 1e8L, build_year := (build_year %% 1e5L)]
    data[build_year == 1901, c("build_year") := list(NA)]
    data[build_year < 100L, build_year := (build_year + 1900L)]
    data[build_year < 217L, build_year := (build_year - (build_year %% 100L)) + 1800L + (build_year %% 100L)]
    data[build_year > 2017L, build_year := (build_year - as.integer(round((build_year - 2000L) / 1000L) * 1000L))]
    if("log_1p_numroom" %in% data_colnames) {
      data[num_room == 0L, c("num_room", "log_1p_numroom") := list(1L, log(1L + 1L))]
    } else {
      data[num_room == 0L, c("num_room") := list(1L)]
    }
    data[((state >= 10L) & (state < 100L)), state := (state %/% 10L)]
  }
  # simple cleaning based on single columns
  if("log_lifesq" %in% data_colnames) {
    data[life_sq <= 5, c("life_sq", "log_lifesq") := list(NA, NA)]
  } else {
    data[life_sq <= 5, c("life_sq") := list(NA)]
  }
  if("log_fullsq" %in% data_colnames) {
    data[full_sq <= 5, c("full_sq", "log_fullsq") := list(NA, NA)]
  } else {
    data[full_sq <= 5, c("full_sq") := list(NA)]
  }
  if("log_lifesq" %in% data_colnames) {
    data[life_sq > full_sq, c("life_sq", "log_lifesq") := list(life_sq / 10, log_lifesq - log(10))]
    data[life_sq > full_sq, c("life_sq", "log_lifesq") := list(life_sq / 10, log_lifesq - log(10))]
  } else {
    data[life_sq > full_sq, life_sq := life_sq / 10]
    data[life_sq > full_sq, life_sq := life_sq / 10]
  }
  if("log_kitchsq" %in% data_colnames) {
    data[kitch_sq > full_sq, c("kitch_sq", "log_kitchsq") := list(kitch_sq / 10, log_kitchsq - log(10))]
    data[kitch_sq > full_sq, c("kitch_sq", "log_kitchsq") := list(kitch_sq / 10, log_kitchsq - log(10))]
  } else {
    data[kitch_sq > full_sq, kitch_sq := kitch_sq / 10]
    data[kitch_sq > full_sq, kitch_sq := kitch_sq / 10]
  }
  if("log_fullsq" %in% data_colnames) {
    data[full_sq >= 10*life_sq, c("full_sq", "log_fullsq") := list(full_sq / 10, log_fullsq - log(10))]
    data[full_sq >= 10*life_sq, c("full_sq", "log_fullsq") := list(full_sq / 10, log_fullsq - log(10))]
  } else {
    data[full_sq >= 10*life_sq, full_sq := full_sq / 10]
    data[full_sq >= 10*life_sq, full_sq := full_sq / 10]
  }
  if("log_10p_floor" %in% data_colnames) {
    data[(floor < 1L) | (floor > 76L), c("floor", "log_10p_floor") := list(NA, NA)]
  } else {
    data[(floor < 1L) | (floor > 76L), c("floor") := list(NA)]
  }
  if("log_10p_maxfloor" %in% data_colnames) {
    data[(max_floor < 1L) | (max_floor > 76L), c("max_floor", "log_10p_maxfloor") := list(NA, NA)]
    data[floor > max_floor, c("max_floor", "log_10p_maxfloor") := list(NA, NA)]
  } else {
    data[(max_floor < 1L) | (max_floor > 76L), c("max_floor") := list(NA)]
    data[floor > max_floor, c("max_floor") := list(NA)]
  }
  data[!(material %in% possible_materials), c("material") := list(NA)]
  data[(build_year < 1850L) | (build_year > 2017L), c("build_year") := list(NA)]
  if("log_1p_numroom" %in% data_colnames) {
    data[num_room >= 10L, c("num_room", "log_1p_numroom") := list(NA, NA)]
  } else {
    data[num_room >= 10L, c("num_room") := list(NA)]
  }
  if("log_kitchsq" %in% data_colnames) {
    data[(kitch_sq <= 1) | (kitch_sq > 25), c("kitch_sq", "log_kitchsq") := list(NA, NA)]
  } else {
    data[(kitch_sq <= 1) | (kitch_sq > 25), c("kitch_sq") := list(NA)]
  }
  data[(state < 1) | (state > 4), c("state") := list(NA)]
  data[!(product_type %in% possible_product_types), c("product_type") := list(NA)]
  # further cleaning based on multiple columns
  if("log_price" %in% data_colnames) {
    if(("log_fullsq" %in% data_colnames) & ("log_lifesq" %in% data_colnames) & ("price_per_fullsq" %in% data_colnames) & ("log_price_per_log_fullsq") %in% data_colnames) {
      data[(full_sq > 250) & (log_price < 16.5), full_sq := full_sq / 10]
      data[life_sq > full_sq, life_sq := life_sq / 10]
      data[(price_per_fullsq > 5e5) & (full_sq < 25), c("full_sq", "life_sq", "log_fullsq", "log_lifesq", "price_per_fullsq", "log_price_per_log_fullsq") := list(full_sq * 10, life_sq * 10, log_fullsq + log(10), log_lifesq + log(10), price_per_fullsq / 10, log_price_per_log_fullsq - log(10))]
      data[price_per_fullsq > 5e5, c("price_doc", "log_price", "price_per_fullsq", "log_price_per_log_fullsq") := list(as.integer(price_doc / 10), log_price - log(10), price_per_fullsq / 10, log_price_per_log_fullsq - log(10))]
    } else {
      data[(full_sq > 250) & (log_price < 16.5), full_sq := full_sq / 10]
      data[life_sq > full_sq, life_sq := life_sq / 10]
      data[((price_doc / full_sq) > 5e5) & (full_sq < 25), c("full_sq", "life_sq") := list(full_sq * 10, life_sq * 10)]
      data[(price_doc / full_sq) > 5e5, c("price_doc", "log_price") := list(price_doc / 10, log_price - log(10))]
    }
  } else if("price_doc" %in% data_colnames) {
    data[(full_sq > 250) & (price_doc < exp(16.5)), full_sq := full_sq / 10]
    data[life_sq > full_sq, life_sq := life_sq / 10]
    data[((price_doc / full_sq) > 5e5) & (full_sq < 25), c("full_sq", "life_sq") := list(full_sq * 10, life_sq * 10)]
    data[(price_doc / full_sq) > 5e5, price_doc := (price_doc %/% 10L)]
  }
  # fix feature data types
  data[, material := as.factor(material)]
  data[, state := as.factor(state)]
  return(data)
}

# data.frame (plain) sub-function
clean_data.frame <- function(data, drop_dependents = FALSE, drop_transforms = FALSE, drop_NA_threshold = 1, keep_ratios = FALSE, special_cases = TRUE, complete_cases = FALSE) {
  data_colnames <- colnames(data)
  if(drop_dependents) {
    # figure out indices for each dependent (raion) column that is present in data set, pass that collection of indices into the selector
    data_dependent_indices <- c()
    for(colname in raion_colnames) {
      if(colname %in% data_colnames) {
        colname_index <- which(colname == data_colnames)
        data_dependent_indices <- c(data_dependent_indices, colname_index)
      }
    }
    data[, data_dependent_indices] <- NULL
  }
  if(drop_transforms) {
    if(keep_ratios) {
      data[, starts_with("log_") & !contains("_per_")] <- NULL
    } else {
      data[, starts_with("log_")] <- NULL
    }
  }
  if(drop_NA_threshold < 1) {
    # get NA % for each column, then threshold for >= 10%, then pass those indices into selector
    portion_NA <- unlist(lapply(train, function(x) sum(is.na(x))/length(x)), use.names = FALSE)
    cols_to_drop <- which(portion_NA > drop_NA_theshold)
    data[, cols_to_drop] <- NULL
  }
  if(special_cases) {
    data$floor[(data$floor > 76) & ((data$floor %% 11) == 0)] <- data$floor[(data$floor > 76) & ((data$floor %% 11) == 0)] %/% 11
    data$floor[(data$floor > 76) & ((data$floor %/% 100) == ((data$floor %% 100) %/% 10))] <- (data$floor[(data$floor > 76) & ((data$floor %/% 100) == ((data$floor %% 100) %/% 10))] %/% 100)*10 + data$floor[(data$floor > 76) & ((data$floor %/% 100) == ((data$floor %% 100) %/% 10))] %% 10
    data$floor[(data$floor > 76) & (((data$floor %% 100) %/% 10) == (data$floor %% 10))] <- data$floor[(data$floor > 76) & (((data$floor %% 100) %/% 10) == (data$floor %% 10))] %% 10
    data$max_floor[(data$max_floor > 76) & ((data$max_floor %% 11) == 0)] <- data$max_floor[(data$max_floor > 76) & ((data$max_floor %% 11) == 0)] %/% 11
    data$max_floor[(data$max_floor > 76) & ((data$max_floor %/% 100) == ((data$max_floor %% 100) %/% 10))] <- (data$max_floor[(data$max_floor > 76) & ((data$max_floor %/% 100) == ((data$max_floor %% 100) %/% 10))] %/% 100)*10 + data$max_floor[(data$max_floor > 76) & ((data$max_floor %/% 100) == ((data$max_floor %% 100) %/% 10))] %% 10
    data$max_floor[(data$max_floor > 76) & (((data$max_floor %% 100) %/% 10) == (data$max_floor %% 10))] <- data$max_floor[(data$max_floor > 76) & (((data$max_floor %% 100) %/% 10) == (data$max_floor %% 10))] %% 10
    data$build_year[data$build_year > 1e8] <- data$build_year[data$build_year > 1e8] %% 1e5
    data$build_year[data$build_year == 1901] <- NA
    data$build_year[data$build_year < 100] <- data$build_year[data$build_year < 100] + 1900L
    data$build_year[data$build_year < 217] <- data$build_year[data$build_year < 217] - (data$build_year[data$build_year < 217] %% 100) + 1800L + data$build_year[data$build_year < 217] %% 100
    data$build_year[data$build_year > 2017] <- data$build_year[data$build_year > 2017] - round((data$build_year[data$build_year > 2017] - 2000) / 1000)
    data$num_room[data$num_room == 0] <- 1
    data$state[(data$state >= 10) & (data$state < 100)] <- data$state[(data$state >= 10) & (data$state < 100)] %/% 10
  }
  # simple cleaning based on single columns
  data$life_sq[data$life_sq <= 5] <- NA
  data$full_sq[data$full_sq <= 5] <- NA
  data$life_sq[data$life_sq > data$full_sq] <- data$life_sq[data$life_sq > data$full_sq] / 10
  data$life_sq[data$life_sq > data$full_sq] <- data$life_sq[data$life_sq > data$full_sq] / 10
  data$kitch_sq[data$kitch_sq > data$full_sq] <- data$kitch_sq[data$kitch_sq > data$full_sq] / 10
  data$kitch_sq[data$kitch_sq > data$full_sq] <- data$kitch_sq[data$kitch_sq > data$full_sq] / 10
  data$full_sq[data$full_sq >= 10*data$life_sq] <- data$full_sq[data$full_sq >= 10*data$life_sq] / 10
  data$full_sq[data$full_sq >= 10*data$life_sq] <- data$full_sq[data$full_sq >= 10*data$life_sq] / 10
  data$floor[(data$floor < 1) | (data$floor > 76)] <- NA
  data$max_floor[(data$max_floor < 1) | (data$max_floor > 76)] <- NA
  data$max_floor[data$floor > data$max_floor] <- NA
  data$material[!(data$material %in% possible_materials)] <- NA
  data$build_year[(data$build_year < 1850) | (data$build_year > 2017)] <- NA
  data$num_room[data$num_room >= 10] <- NA
  data$kitch_sq[(data$kitch_sq <= 1) | (data$kitch_sq > 25)] <- NA
  data$state[(data$state >= 1) & (data$state <= 4)] <- NA
  data$product_type[!(data$product_type %in% possible_product_types)] <- NA
  # further cleaning based on multiple columns
  if("log_price" %in% data_colnames) {
    if(("log_fullsq" %in% data_colnames) & ("log_lifesq" %in% data_colnames) & ("price_per_fullsq" %in% data_colnames) & ("log_price_per_log_fullsq") %in% data_colnames) {
      data$full_sq[(data$full_sq > 250) & (data$log_price) < 16.5] <- data$full_sq[(data$full_sq > 250) & (data$log_price) < 16.5] / 10
      data$life_sq[data$life_sq > data$full_sq] <- data$life_sq[data$life_sq > data$full_sq] / 10
      data$full_sq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] <- data$full_sq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] * 10
      data$life_sq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] <- data$life_sq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] * 10
      data$log_fullsq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] <- data$log_fullsq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] + log(10)
      data$log_lifesq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] <- data$log_lifesq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] + log(10)
      data$price_per_fullsq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] <- data$price_per_fullsq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] / 10
      data$log_price_per_log_fullsq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] <- data$log_price_per_log_fullsq[(data$price_per_fullsq > 5e5) & (data$full_sq < 25)] - log(10)
      data$price_doc[data$price_per_fullsq > 5e5] <- as.integer(data$price_doc[data$price_per_fullsq > 5e5] / 10)
      data$log_price[data$price_per_fullsq > 5e5] <- data$log_price[data$price_per_fullsq > 5e5] - log(10)
      data$price_per_fullsq[data$price_per_fullsq > 5e5] <- data$price_per_fullsq[data$price_per_fullsq > 5e5] / 10
      data$log_price_per_log_fullsq[data$price_per_fullsq > 5e5] <- data$log_price_per_log_fullsq[data$price_per_fullsq > 5e5] - log(10)
    } else {
      data$full_sq[(data$full_sq > 250) & (data$log_price < 16.5)] <- data$full_sq[(data$full_sq > 250) & (data$log_price < 16.5)] / 10
      data$life_sq[data$life_sq > data$full_sq] <- data$life_sq[data$life_sq > data$full_sq] / 10
      data$full_sq[((data$price_doc / data$full_sq) > 5e5) & (data$full_sq < 25)] <- data$full_sq[((data$price_doc / data$full_sq) > 5e5) & (data$full_sq < 25)] * 10
      data$life_sq[((data$price_doc / data$full_sq) > 5e5) & (data$full_sq < 25)] <- data$life_sq[((data$price_doc / data$full_sq) > 5e5) & (data$full_sq < 25)] * 10
      data$price_doc[(data$price_doc / data$full_sq) > 5e5] <- data$price_doc[(data$price_doc / data$full_sq) > 5e5] / 10
      data$log_price[(data$price_doc / data$full_sq) > 5e5] <- data$log_price[(data$price_doc / data$full_sq) > 5e5] - log(10)
    }
  } else {
    data$full_sq[(data$full_sq > 250) & (data$price_doc < exp(16.5))] <- data$full_sq[(data$full_sq > 250) & (data$price_doc < exp(16.5))] / 10
    data$life_sq[data$life_sq > data$full_sq] <- data$life_sq[data$life_sq > data$full_sq] / 10
    data$full_sq[((data$price_doc / data$full_sq) > 5e5) & (data$full_sq < 25)] <- data$full_sq[((data$price_doc / data$full_sq) > 5e5) & (data$full_sq < 25)] * 10
    data$life_sq[((data$price_doc / data$full_sq) > 5e5) & (data$full_sq < 25)] <- data$life_sq[((data$price_doc / data$full_sq) > 5e5) & (data$full_sq < 25)] * 10
    data$price_doc[(data$price_doc / data$full_sq) > 5e5] <- data$price_doc / 10
  }
  return(data)
}

# read raw data and write fresh cleaned data
refresh_data <- function(read_directory = 'data/', write_directory = 'data/') {
  
  # read data
  data_list <- read_data(read_directory)
  train <- data_list[['train']]
  test <- data_list[['test']]
  macro <- data_list[['macro']]
  
  # process macro data
  yearly <- unique(macro[, yearly_colnames, with = FALSE])
  yearly[, years := .(years)]
  setcolorder(yearly, c(ncol(yearly), 1:(ncol(yearly)-1)))
  fwrite(yearly, file = paste0(write_directory, yearly_filename), append = FALSE)
  
  quarterly <- unique(macro[, quarterly_colnames, with = FALSE])
  quarterly[, quarters := .(quarters)]
  setcolorder(quarterly, c(ncol(quarterly), 1:(ncol(quarterly)-1)))
  fwrite(quarterly, file = paste0(write_directory, quarterly_filename), append = FALSE)
  
  monthly <- unique(macro[, monthly_colnames, with = FALSE])
  monthly <- monthly[!duplicated(monthly[, .(oil_urals, cpi)]),]
  monthly[, months := .(months)]
  setcolorder(monthly, c(ncol(monthly), 1:(ncol(monthly)-1)))
  monthly[nrow(monthly), (which(!(colnames(monthly) %in% c("months", "cpi", "ppi")))) := NA]
  fwrite(monthly, file = paste0(write_directory, monthly_filename), append = FALSE)
  
  daily <- unique(macro[, daily_colnames, with = FALSE])
  fwrite(daily, file = paste0(write_directory, daily_filename), append = FALSE)
  
  # process raion data from train and test data
  raion_train <- train[, raion_colindices, with = FALSE]
  raion_test <- test[, raion_colindices, with = FALSE]
  setkey(raion_train, sub_area)
  setkey(raion_test, sub_area)
  raion_train <- unique(raion_train)
  raion_test <- unique(raion_test)
  raion <- rbind(raion_train, raion_test)
  setkey(raion, sub_area)
  raion <- unique(raion)
  fwrite(raion, file = paste0(write_directory, raion_filename), append = FALSE)
  
  # clean data
  train <- clean_data(train, drop_dependents = TRUE)
  test <- clean_data(test, drop_dependents = TRUE)
  
  # transform data
  train <- transform_data(train)
  test <- transform_data(test)
  
  # all features (native and composite/transform)
  fwrite(train, paste0(write_directory, train_total_filename), append = FALSE)
  fwrite(test, paste0(write_directory, test_total_filename), append = FALSE)
  train_complete <- train[complete.cases(train),]
  test_complete <- test[complete.cases(test),]
  fwrite(train_complete, paste0(write_directory, train_total_complete_filename), append = FALSE)
  fwrite(test_complete, paste0(write_directory, test_total_complete_filename), append = FALSE)
  
  # barebones features only
  train_barebones_almost <- select(train, -log_fullsq, -log_lifesq, -log_kitchsq, -log_10p_floor, -log_10p_maxfloor, -log_1p_numroom, -price_per_room, -price_per_fullsq, -log_price_per_10p_log_room, -log_price_per_log_fullsq)
  fwrite(select(train_barebones_almost, -log_price), paste0(write_directory, train_barebones_price_filename), append = FALSE)
  fwrite(select(train_barebones_almost, -price_doc), paste0(write_directory, train_barebones_logprice_filename), append = FALSE)
  
  test_barebones <- select(test, -log_fullsq, -log_lifesq, -log_kitchsq, -log_10p_floor, -log_10p_maxfloor, -log_1p_numroom)
  fwrite(test_barebones, paste0(write_directory, test_barebones_filename), append = FALSE)
  
  train_barebones_almost_complete <- train_barebones_almost[complete.cases(train_barebones_almost),]
  fwrite(select(train_barebones_almost_complete, -log_price), paste0(write_directory, train_barebones_price_complete_filename), append = FALSE)
  fwrite(select(train_barebones_almost_complete, -price_doc), paste0(write_directory, train_barebones_logprice_complete_filename), append = FALSE)
  
  test_barebones_complete <- test_barebones[complete.cases(test_barebones),]
  fwrite(test_barebones_complete, paste0(write_directory, test_barebones_complete_filename), append = FALSE)

  # composite/transform replacing native
  train_transforms_almost <- select(train, -full_sq, -life_sq, -kitch_sq, -floor, -max_floor, -num_room, -price_per_room, -price_per_fullsq, -log_price_per_10p_log_room, -log_price_per_log_fullsq)
  fwrite(select(train_transforms_almost, -log_price), paste0(write_directory, train_transforms_price_filename), append = FALSE)
  fwrite(select(train_transforms_almost, -price_doc), paste0(write_directory, train_transforms_logprice_filename), append = FALSE)
  
  test_transforms <- select(test, -full_sq, -life_sq, -kitch_sq, -floor, -max_floor, -num_room)
  fwrite(test_transforms, paste0(write_directory, test_transforms_filename), append = FALSE)
  
  train_transforms_almost_complete <- train_transforms_almost[complete.cases(train_transforms_almost),]
  fwrite(select(train_transforms_almost_complete, -log_price), paste0(write_directory, train_transforms_price_complete_filename), append = FALSE)
  fwrite(select(train_transforms_almost_complete, -price_doc), paste0(write_directory, train_transforms_logprice_complete_filename), append = FALSE)
  
  test_transforms_complete <- test_transforms[complete.cases(test_transforms),]
  fwrite(test_transforms_complete, paste0(write_directory, test_transforms_complete_filename), append = FALSE)
  
  # return datasets as list
  return(list('train' = train, 'test' = test, 'raion' = raion, 'yearly' = yearly, 'quarterly' = quarterly, 'monthly' = monthly, 'daily' = daily))
}


# @author Scott Dobbins
# @date 2017-05-20 21:00
# @version 0.5
#*** reformulate colclasses for train so that it includes raion classes within it to be less obtuse
#*** colclasses needs some altering based on which version it is too
#*** make sure product_type is clean in both train and test
#*** should I set keys on any of the data.table objects?

#*** generate avg_log_price and avg_Log_price_per_log_fullsq for each aggregate


### import packages ###

# (in ascending order of importance)
library(data.table)
library(dplyr)


### global constants ###

# filenames
train_raw_filename <- 'train.csv'
test_raw_filename <- 'test.csv'

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

# dependent colnames
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

# data reading data types
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
                      rep("integer", 2),
                      rep("factor", 1), 
                      rep("integer", 2), 
                      rep("double", 1), 
                      rep("factor", 2), 
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

# other useful constants
possible_materials <- c(1,2,4,5,6)
raion_colindices <- 13:84


stupid <- function(a = 1, b = 2) {
  return(paste0(toString(a+b)))
}

### data reading functions ###
# parameter specifications: dataset can be 'all', 'train', 'test', or 'raion'
#                         : type can be 'total', 'barebones', 'transforms', or 'raw'
read_data <- function(directory = 'data/', dataset = 'all', type = 'raw', complete_only = FALSE, log_price = TRUE, data_frame = FALSE) {
  if(dataset == 'all') {
    if(type != 'raw') {
      raion <- fread(input = paste0(directory, raion_filename), 
                     header = TRUE, 
                     stringsAsFactors = FALSE, 
                     colClasses = raion_classes)
    }
    if(type == 'total') {
      if(complete_only) {
        train <- fread(input = paste0(directory, train_total_complete_filename), 
                       header = TRUE, 
                       stringsAsFactors = FALSE,
                       colClasses = train_classes)
        test <- fread(input = paste0(directory, test_total_complete_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
      } else {
        train <- fread(input = paste0(directory, train_total_filename), 
                       header = TRUE, 
                       stringsAsFactors = FALSE,
                       colClasses = train_classes)
        test <- fread(input = paste0(directory, test_total_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
      }
    } else if(type == 'barebones') {
      if(complete_only) {
        test <- fread(input = paste0(directory, test_barebones_complete_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
        if(log_price) {
          train <- fread(input = paste0(directory, train_barebones_logprice_complete_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        } else {
          train <- fread(input = paste0(directory, train_barebones_price_complete_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        }
      } else {
        test <- fread(input = paste0(directory, test_barebonesfilename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
        if(log_price) {
          train <- fread(input = paste0(directory, train_barebones_logprice_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        } else {
          train <- fread(input = paste0(directory, train_barebones_price_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        }
      }
    } else if(type == 'transforms') {
      if(complete_only) {
        test <- fread(input = paste0(directory, test_transforms_complete_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
        if(log_price) {
          train <- fread(input = paste0(directory, train_transform_logprice_complete_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        } else {
          train <- fread(input = paste0(directory, train_transform_price_complete_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        }
      } else {
        test <- fread(input = paste0(directory, test_transforms_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
        if(log_price) {
          train <- fread(input = paste0(directory, train_barebones_logprice_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        } else {
          train <- fread(input = paste0(directory, train_barebones_price_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        }
      }
    } else if(type == 'raw') {
      train <- fread(input = paste0(directory, train_raw_filename), 
                     header = TRUE, 
                     stringsAsFactors = FALSE,
                     colClasses = train_classes)
      test <- fread(input = paste0(directory, test_raw_filename), 
                    header = TRUE, 
                    stringsAsFactors = FALSE,
                    colClasses = test_classes)
    } else {
      print("You asked for a type that doesn't exist")# raise error?
    }
    if(data_frame) {
      train <- data.frame(train)
      test <- data.frame(test)
      raion <- data.frame(raion)
    }
  } else if(dataset == 'train') {
    if(type == 'total') {
      if(complete_only) {
        train <- fread(input = paste0(directory, train_total_complete_filename), 
                       header = TRUE, 
                       stringsAsFactors = FALSE,
                       colClasses = train_classes)
      } else {
        train <- fread(input = paste0(directory, train_total_filename), 
                       header = TRUE, 
                       stringsAsFactors = FALSE,
                       colClasses = train_classes)
      }
    } else if(type == 'barebones') {
      if(log_price) {
        if(complete_only) {
          train <- fread(input = paste0(directory, train_barebones_logprice_complete_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        } else {
          train <- fread(input = paste0(directory, train_barebones_logprice_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        }
      } else {
        if(complete_only) {
          train <- fread(input = paste0(directory, train_barebones_price_complete_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        } else {
          train <- fread(input = paste0(directory, train_barebones_price_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        }
      }
    } else if(type == 'transforms') {
      if(log_price) {
        if(complete_only) {
          train <- fread(input = paste0(directory, train_transform_logprice_complete_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        } else {
          train <- fread(input = paste0(directory, train_transform_logprice_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        }
      } else {
        if(complete_only) {
          train <- fread(input = paste0(directory, train_transform_price_complete_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        } else {
          train <- fread(input = paste0(directory, train_transform_price_filename), 
                         header = TRUE, 
                         stringsAsFactors = FALSE,
                         colClasses = train_classes)
        }
      }
    } else if(type == 'raw') {
      train <- fread(input = paste0(directory, train_raw_filename), 
                     header = TRUE, 
                     stringsAsFactors = FALSE,
                     colClasses = train_classes)
    } else {
      print("You asked for a type that doesn't exist")# raise error?
    }
    if(data_frame) {
      train <- data.frame(train)
    }
  } else if(dataset == 'test') {
    if(type == 'total') {
      if(complete_only) {
        test <- fread(input = paste0(directory, test_total_complete_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
      } else {
        test <- fread(input = paste0(directory, test_total_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
      }
    } else if(type == 'barebones') {
      if(complete_only) {
        test <- fread(input = paste0(directory, test_barebones_complete_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
      } else {
        test <- fread(input = paste0(directory, test_barebones_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
      }
    } else if(type == 'transforms') {
      if(complete_only) {
        test <- fread(input = paste0(directory, test_transforms_complete_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
      } else {
        test <- fread(input = paste0(directory, test_transforms_filename), 
                      header = TRUE, 
                      stringsAsFactors = FALSE,
                      colClasses = test_classes)
      }
    } else if(type == 'raw') {
      test <- fread(input = paste0(directory, test_raw_filename), 
                    header = TRUE, 
                    stringsAsFactors = FALSE,
                    colClasses = test_classes)
    } else {
      print("You asked for a type that doesn't exist")# raise error?
    }
    if(data_frame) {
      test <- data.frame(test)
    }
  } else if(dataset == 'raion') {
    raion <- fread(input = paste0(directory, raion_filename), 
                   header = TRUE, 
                   stringsAsFactors = FALSE, 
                   colClasses = raion_classes)
    if(data_frame) {
      raion <- data.frame(raion)
    }
  } else {
    print("You asked for a dataset that doesn't exist")# raise error?
  }
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
    return(clean_data.table(data, drop_dependents, drop_transforms, special_cases, complete_cases))
  } else {
    return(clean_data.frame(data, drop_dependents, drop_transforms, special_cases, complete_cases))
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
    data[, data_dependent_indices, with = FALSE] <- NULL
  }
  if(drop_transforms) {
    if(keep_ratios) {
      data[, starts_with("log_") & !contains("_per_"), with = FALSE] <- NULL
    } else {
      data[, starts_with("log_"), with = FALSE] <- NULL
    }
  }
  if(drop_NA_threshold < 1) {
    # get NA % for each column, then threshold for >= 10%, then pass those indices into selector
    portion_NA <- unlist(lapply(train, function(x) sum(is.na(x))/length(x)), use.names = FALSE)
    cols_to_drop <- which(portion_NA > drop_NA_theshold)
    data[, cols_to_drop, with = FALSE] <- NULL
  }
  if(special_cases) {
    data[(floor > 76) & ((floor %% 11) == 0), floor := (floor %/% 11)]
    data[(floor > 76) & ((floor %/% 100) == ((floor %% 100) %/% 10)), floor := ((floor %/% 100)*10 + floor %% 10)]
    data[(floor > 76) & (((floor %% 100) %/% 10) == (floor %% 10)), floor := (floor %% 10)]
    data[(max_floor > 76) & ((max_floor %% 11) == 0), max_floor := (max_floor %/% 11)]
    data[(max_floor > 76) & ((max_floor %/% 100) == ((max_floor %% 100) %/% 10)), max_floor := ((max_floor %/% 100)*10 + max_floor %% 10)]
    data[(max_floor > 76) & (((max_floor %% 100) %/% 10) == (max_floor %% 10)), max_floor := (max_floor %% 10)]
    data[build_year > 1e8, build_year := (build_year %% 1e5)]
    data[build_year < 100, build_year := build_year + 1900L]
    data[build_year < 217, build_year := (build_year - (build_year %% 100)) + 1800L + (build_year %% 100)]
    data[build_year > 2017, build_year := (build_year - round((build_year - 2000) / 1000))]
    data[num_room == 0, c("num_room")] <- 1
    data[((state >= 10) & (state < 100)), state := (state %/% 10)]
  }
  # simple cleaning based on single columns
  data[life_sq <= 5, c("life_sq")] <- NA
  data[full_sq <= 5, c("full_sq")] <- NA
  data[life_sq > full_sq, life_sq := life_sq / 10]
  data[life_sq > full_sq, life_sq := life_sq / 10]
  data[kitch_sq > full_sq, kitch_sq := kitch_sq / 10]
  data[kitch_sq > full_sq, kitch_sq := kitch_sq / 10]
  data[full_sq >= 10*life_sq, full_sq := full_sq / 10]
  data[full_sq >= 10*life_sq, full_sq := full_sq / 10]
  data[(floor < 1) | (floor > 76), c("floor")] <- NA
  data[(max_floor < 1) | (max_floor > 76), c("max_floor")] <- NA
  data[floor > max_floor, c("max_floor")] <- NA
  data[!(material %in% possible_materials), c("material")] <- NA
  data[(build_year < 1850) | (build_year > 2017), c("build_year")] <- NA
  data[num_room >= 10, c("num_room")] <- NA
  data[(kitch_sq <= 1) | (kitch_sq > 25), c("kitch_sq")] <- NA
  data[(state >= 1) & (state <= 4), c("state")] <- NA
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
  } else {
    data[(full_sq > 250) & (price_doc < exp(16.5)), full_sq := full_sq / 10]
    data[life_sq > full_sq, life_sq := life_sq / 10]
    data[((price_doc / full_sq) > 5e5) & (full_sq < 25), c("full_sq", "life_sq") := list(full_sq * 10, life_sq * 10)]
    data[(price_doc / full_sq) > 5e5, price_doc := (price_doc / 10)]
  }
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

transform_data <- function(data) {
  if("data.table" %in% class(data)) {
    return(transform_data.table(data))
  } else {
    return(transform_data.frame(data))
  }
}

transform_data.table <- function(data) {
  data[, log_fullsq := log(full_sq)]
  data[, log_lifesq := log(life_sq)]
  data[, log_10p_floor := log(10+floor)]
  data[, log_10p_maxfloor := log(10+max_floor)]
  data[, log_1p_numroom := log(1+num_room)]
  data[, log_kitchsq := log(kitch_sq)]
  if("price_doc" %in% colnames(data)) {
    data[, log_price := log(price_doc)]
    data[, price_per_room := price_doc / num_room]
    data[, price_per_fullsq := price_doc / full_sq]
    data[, log_price_per_10p_log_room := log(price_doc) / (10+log(num_room))]
    data[, log_price_per_log_fullsq := log(price_doc) / log(full_sq)]
  }
  return(data)
}

transform_data.frame <- function(data) {
  data$log_fullsq <- log(data$full_sq)
  data$log_lifesq <- log(data$life_sq)
  data$log_10p_floor <- log(10+data$floor)
  data$log_10p_maxfloor <- log(10+data$max_floor)
  data$log_1p_numroom <- log(1+data$num_room)
  data$log_kitchsq <- log(data$kitch_sq)
  if("price_doc" %in% colnames(data)) {
    data$log_price <- log(data$price_doc)
    data$price_per_room <- data$price_doc / data$num_room
    data$price_per_fullsq <- data$price_doc / data$full_sq
    data$log_price_per_10p_log_room <- log(data$price_doc) / (10+log(data$num_room))
    data$log_price_per_log_fullsq <- log(data$price_doc) / log(data$full_sq)
  }
  return(data)
}

# read raw data and write fresh cleaned data
refresh_data <- function(read_directory = 'data/', write_directory = 'data/') {
  
  # read data
  read_data(read_directory)
  
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
}


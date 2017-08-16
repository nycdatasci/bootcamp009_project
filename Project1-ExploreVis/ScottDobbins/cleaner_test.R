# @author Scott Dobbins
# @version 0.9.8.1
# @date 2017-08-15 21:00


### Context -----------------------------------------------------------------

context("Cleaning raw data")

debug_message("unit testing cleaned bomb data")


### Cardinality -------------------------------------------------------------

test_that("no data column is completely empty or identical across all rows", {
  WW1_bombs %>% map_int(~expect_gt(cardinality(.), 1L))
  WW2_bombs %>% map_int(~expect_gt(cardinality(.), 1L))
  Korea_bombs1 %>% select(-Takeoff_Latitude, -Takeoff_Longitude) %>% map_int(~expect_gt(cardinality(.), 1L))
  Korea_bombs2 %>% select(-Reference_Source) %>% map_int(~expect_gt(cardinality(.), 1L))
  Vietnam_bombs %>% select(-Weapon_Class2) %>% map_int(~expect_gt(cardinality(.), 1L))
})


### Text Length -------------------------------------------------------------

test_that("no text column is excessively long", {
  WW1_bombs %>% keep(is.character) %>% map_int(~expect_lt(max(nchar(levels(as.factor(.)))), max_string_length))
  WW2_bombs %>% keep(is.character) %>% map_int(~expect_lt(max(nchar(levels(as.factor(.)))), max_string_length))
  Korea_bombs1 %>% keep(is.character) %>% map_int(~expect_lt(max(nchar(levels(as.factor(.)))), max_string_length))
  Korea_bombs2 %>% keep(is.character) %>% map_int(~expect_lt(max(nchar(levels(as.factor(.)))), max_string_length))
  Vietnam_bombs %>% keep(is.character) %>% map_int(~expect_lt(max(nchar(levels(as.factor(.)))), max_string_length))
  
  WW1_bombs %>% keep(is.factor) %>% map_int(~expect_lt(max(nchar(levels(.))), max_string_length))
  WW2_bombs %>% keep(is.factor) %>% map_int(~expect_lt(max(nchar(levels(.))), max_string_length))
  Korea_bombs1 %>% keep(is.factor) %>% map_int(~expect_lt(max(nchar(levels(.))), max_string_length))
  Korea_bombs2 %>% keep(is.factor) %>% map_int(~expect_lt(max(nchar(levels(.))), max_string_length))
  Vietnam_bombs %>% keep(is.factor) %>% map_int(~expect_lt(max(nchar(levels(.))), max_string_length))
})


### Value Range -------------------------------------------------------------

test_that("value ranges for mission dates are reasonable", {
  expect_true(WW1_bombs[, all(range(Mission_Date, na.rm = TRUE) %between% c(WW1_first_mission, WW1_last_mission))])
  expect_true(WW2_bombs[, all(range(Mission_Date, na.rm = TRUE) %between% c(WW2_first_mission, WW2_last_mission))])
  expect_true(Korea_bombs1[, all(range(Mission_Date, na.rm = TRUE) %between% c(Korea_first_mission, Korea_last_mission))])
  expect_true(Korea_bombs2[, all(range(Mission_Date, na.rm = TRUE) %between% c(Korea_first_mission, Korea_last_mission))])
  expect_true(Vietnam_bombs[, all(range(Mission_Date, na.rm = TRUE) %between% c(Vietnam_first_mission, Vietnam_last_mission))])
})

test_that("didn't somehow delete USA from unit countries (as proxy for basic unit country handling)", {
  expect_true("USA" %c% levels(WW1_bombs$Unit_Country))
  expect_true("USA" %c% levels(WW2_bombs$Unit_Country))
  
  expect_true("USA" %c% levels(Vietnam_bombs$Unit_Country))
})

test_that("value ranges for altitudes are reasonable", {
  expect_equal(WW1_bombs[Bomb_Altitude_Feet == 0L, .N], 0L)
  expect_lte(WW1_bombs[, max(Bomb_Altitude_Feet, na.rm = TRUE)], WW1_altitude_max_feet)
  
  expect_equal(WW2_bombs[Bomb_Altitude_Feet == 0L, .N], 0L)
  expect_lte(WW2_bombs[, max(Bomb_Altitude_Feet, na.rm = TRUE)], WW2_altitude_max_feet)
  
  expect_equal(Korea_bombs2[Bomb_Altitude_Feet_Low == 0L | Bomb_Altitude_Feet_High == 0L, .N], 0L)
  expect_lte(Korea_bombs2[, max(Bomb_Altitude_Feet_Low, Bomb_Altitude_Feet_High, na.rm = TRUE)], Korea_altitude_max_feet)
  
  expect_equal(Vietnam_bombs[Bomb_Altitude_Feet == 0L, .N], 0L)
  expect_lte(Vietnam_bombs[, max(Bomb_Altitude_Feet, na.rm = TRUE)], Vietnam_altitude_max_feet)
})

test_that("no zero values for essential integer columns", {
  expect_equal(WW1_bombs[Aircraft_Attacking_Num == 0L, .N], 0L)
  expect_equal(WW1_bombs[Weapon_Expended_Num == 0L, .N], 0L)
  expect_equal(WW1_bombs[Weapon_Weight_Pounds == 0L, .N], 0L)
  
  expect_equal(WW2_bombs[Aircraft_Attacking_Num == 0L, .N], 0L)
  expect_equal(WW2_bombs[Weapon_Expl_Num == 0L & Weapon_Incd_Num == 0L & Weapon_Frag_Num == 0L, .N], 0L)
  expect_equal(WW2_bombs[Weapon_Expl_Pounds == 0L & Weapon_Incd_Pounds == 0L & Weapon_Frag_Pounds == 0L, .N], 0L)
  
  expect_equal(Korea_bombs1[Aircraft_Attacking_Num == 0L, .N], 0L)
  # expect_equal(Korea_bombs1[Weapon_Expended_Num == 0L, .N], 0L)
  expect_equal(Korea_bombs1[Weapon_Weight_Pounds == 0L, .N], 0L)
  
  expect_equal(Korea_bombs2[Aircraft_Attacking_Num == 0L, .N], 0L)
  expect_equal(Korea_bombs2[Weapon_Expended_Num == 0L, .N], 0L)
  expect_equal(Korea_bombs2[Weapon_Weight_Pounds == 0L, .N], 0L)
  
  expect_equal(Vietnam_bombs[Aircraft_Attacking_Num == 0L, .N], 0L)
  expect_equal(Vietnam_bombs[Weapon_Expended_Num == 0L & Weapon_Jettisoned_Num == 0L & Weapon_Returned_Num == 0L, .N], 0L)
  expect_equal(Vietnam_bombs[Weapon_Weight_Pounds == 0L, .N], 0L)
})


### Completeness ------------------------------------------------------------

test_that("no string values are NA", {
  WW1_bombs %>% keep(is.character) %>% map_lgl(~expect_false(anyNA(.)))
  WW2_bombs %>% keep(is.character) %>% map_lgl(~expect_false(anyNA(.)))
  Korea_bombs1 %>% keep(is.character) %>% map_lgl(~expect_false(anyNA(.)))
  Korea_bombs2 %>% keep(is.character) %>% map_lgl(~expect_false(anyNA(.)))
  Vietnam_bombs %>% keep(is.character) %>% map_lgl(~expect_false(anyNA(.)))
  
  WW1_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(anyNA(.)))
  WW2_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(anyNA(.)))
  Korea_bombs1 %>% keep(is.factor) %>% map_lgl(~expect_false(anyNA(.)))
  Korea_bombs2 %>% keep(is.factor) %>% map_lgl(~expect_false(anyNA(.)))
  Vietnam_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(anyNA(.)))
})

test_that("there are no NA levels in factors", {
  WW1_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(anyNA(levels(.))))
  WW2_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(anyNA(levels(.))))
  Korea_bombs1 %>% keep(is.factor) %>% map_lgl(~expect_false(anyNA(levels(.))))
  Korea_bombs2 %>% keep(is.factor) %>% map_lgl(~expect_false(anyNA(levels(.))))
  Vietnam_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(anyNA(levels(.))))
})

test_that("no missing levels exist", {
  WW1_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(tabulate(.) == 0L)))
  WW2_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(tabulate(.) == 0L)))
  Korea_bombs1 %>% keep(is.factor) %>% map_lgl(~expect_false(any(tabulate(.) == 0L)))
  Korea_bombs2 %>% keep(is.factor) %>% map_lgl(~expect_false(any(tabulate(.) == 0L)))
  Vietnam_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(tabulate(.) == 0L)))
})


### Formatting --------------------------------------------------------------

test_that("all times formatted properly", {
  expect_equal(WW1_bombs[Takeoff_Time != "" & Takeoff_Time %!like% "^[0-9]{2}:[0-9]{2}$", .N], 0L)
  
  expect_equal(WW2_bombs[Bomb_Time != "" & Bomb_Time %!like% "^[0-9]{1,2}:[0-9]{2}$", .N], 0L)
  
  levels(Vietnam_bombs[["Bomb_Time_Start"]]) %>% (expect_false(any(. != "" & . %!like% "^[0-9]{1,2}:[0-9]{2}$")))
  expect_equal(Vietnam_bombs[Bomb_Time_Finish != "" & Bomb_Time_Finish %!like% "^[0-9]{1,2}:[0-9]{2}$", .N], 0L)
})

test_that("no double whitespace in factor columns", {
  WW1_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = "\\s{2,}"))))
  WW2_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = "\\s{2,}"))))
  Korea_bombs1 %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = "\\s{2,}"))))
  Korea_bombs2 %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = "\\s{2,}"))))
  Vietnam_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = "\\s{2,}"))))
})

test_that("no quotation marks in text columns", {
  WW1_bombs %>% keep(is.character) %>% map_lgl(~expect_false(any(grepl(., pattern = '\\"', fixed = TRUE))))
  WW2_bombs %>% keep(is.character) %>% map_lgl(~expect_false(any(grepl(., pattern = '\\"', fixed = TRUE))))
  Korea_bombs1 %>% keep(is.character) %>% map_lgl(~expect_false(any(grepl(., pattern = '\\"', fixed = TRUE))))
  Korea_bombs2 %>% keep(is.character) %>% map_lgl(~expect_false(any(grepl(., pattern = '\\"', fixed = TRUE))))
  Vietnam_bombs %>% keep(is.character) %>% map_lgl(~expect_false(any(grepl(., pattern = '\\"', fixed = TRUE))))
  
  WW1_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = '\\"', fixed = TRUE))))
  WW2_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = '\\"', fixed = TRUE))))
  Korea_bombs1 %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = '\\"', fixed = TRUE))))
  Korea_bombs2 %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = '\\"', fixed = TRUE))))
  Vietnam_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = '\\"', fixed = TRUE))))
})

test_that("no backslashes in text columns", {
  WW1_bombs %>% keep(is.character) %>% map_lgl(~expect_false(any(grepl(., pattern = "\\\\", fixed = TRUE))))
  WW2_bombs %>% keep(is.character) %>% map_lgl(~expect_false(any(grepl(., pattern = "\\\\", fixed = TRUE))))
  Korea_bombs1 %>% keep(is.character) %>% map_lgl(~expect_false(any(grepl(., pattern = "\\\\", fixed = TRUE))))
  Korea_bombs2 %>% keep(is.character) %>% map_lgl(~expect_false(any(grepl(., pattern = "\\\\", fixed = TRUE))))
  Vietnam_bombs %>% keep(is.character) %>% map_lgl(~expect_false(any(grepl(., pattern = "\\\\", fixed = TRUE))))
  
  WW1_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = "\\\\", fixed = TRUE))))
  WW2_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = "\\\\", fixed = TRUE))))
  Korea_bombs1 %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = "\\\\", fixed = TRUE))))
  Korea_bombs2 %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = "\\\\", fixed = TRUE))))
  Vietnam_bombs %>% keep(is.factor) %>% map_lgl(~expect_false(any(grepl(levels(.), pattern = "\\\\", fixed = TRUE))))
})


### Names -------------------------------------------------------------------

test_that("none of the levels have names", {
  WW1_bombs %>% keep(is.factor) %>% walk(~expect_null(names(levels(.))))
  WW2_bombs %>% keep(is.factor) %>% walk(~expect_null(names(levels(.))))
  Korea_bombs1 %>% keep(is.factor) %>% walk(~expect_null(names(levels(.))))
  Korea_bombs2 %>% keep(is.factor) %>% walk(~expect_null(names(levels(.))))
  Vietnam_bombs %>% keep(is.factor) %>% walk(~expect_null(names(levels(.))))
})

test_that("none of the data has names", {
  WW1_bombs %>% walk(~expect_null(names(.)))
  WW2_bombs %>% walk(~expect_null(names(.)))
  Korea_bombs1 %>% walk(~expect_null(names(.)))
  Korea_bombs2 %>% walk(~expect_null(names(.)))
  Vietnam_bombs %>% walk(~expect_null(names(.)))
})

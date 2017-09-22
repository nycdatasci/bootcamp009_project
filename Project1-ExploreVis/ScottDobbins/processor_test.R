# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


### Context -----------------------------------------------------------------

context("Processing clean data")

debug_message("unit testing processed clean data")


### Cardinality -------------------------------------------------------------

test_that("no data column is completely empty or identical across all rows", {
  WW1_clean %>% map_int(~expect_gt(cardinality(.), 1L))
  WW2_clean %>% map_int(~expect_gt(cardinality(.), 1L))
  Korea_clean1 %>% select(-Weapon_Type) %>% map_int(~expect_gt(cardinality(.), 1L))
  Korea_clean2 %>% select(-Unit_Country) %>% map_int(~expect_gt(cardinality(.), 1L))
  Vietnam_clean %>% map_int(~expect_gt(cardinality(.), 1L))
})


### Tooltips ----------------------------------------------------------------

test_that("no tooltips are empty", {
  walk(clean_data, 
       function(dt) dt %>% select(starts_with("tooltip")) %>% 
         map_lgl(~expect_false(any(. == ""))))
})

test_that("no tooltips are NA", {
  walk(clean_data, 
       function(dt) dt %>% select(starts_with("tooltip")) %>% 
         map_lgl(~expect_false(anyNA(.))))
})

test_that("tooltips all have HTML formatting", {
  walk(clean_data, 
       function(dt) expect_true(all(grepl(pattern = "<br>", dt[["tooltip"]], fixed = TRUE))))
})

test_that("no tooltip is missing any component", {
  walk(clean_data, 
       function(dt) expect_false(any(grepl(pattern = "<br><br>", dt[["tooltip"]], fixed = TRUE))))
})


### Missingness -------------------------------------------------------------

if (empty_text != "") {
  test_that("no empty string factor levels", {
    walk(clean_data, 
         function(dt) dt %>% keep(is.factor) %>% 
           map_lgl(~expect_false("" %c% levels(.))))
  })
}

test_that("no missing levels exist", {
  WW1_clean %>% keep(is.factor) %>% 
    map_lgl(~expect_false(any(tabulate_factor(.) == 0L)))
  WW2_clean %>% keep(is.factor) %>% 
    map_lgl(~expect_false(any(tabulate_factor(.) == 0L)))
  Korea_clean1 %>% keep(is.factor) %>% 
    map_lgl(~expect_false(any(tabulate_factor(.) == 0L)))
  Korea_clean2 %>% keep(is.factor) %>% 
    map_lgl(~expect_false(any(tabulate_factor(.) == 0L)))
  Vietnam_clean %>% keep(is.factor) %>% select(-Year) %>% 
    map_lgl(~expect_false(any(tabulate_factor(.) == 0L)))
})


### Names -------------------------------------------------------------------

test_that("none of the levels have names", {
  walk(clean_data, 
       function(dt) dt %>% keep(is.factor) %>% 
         walk(~expect_null(names(levels(.)))))
})

test_that("none of the data has names", {
  walk(clean_data, 
       function(dt) dt %>% 
         walk(~expect_null(names(.))))
})

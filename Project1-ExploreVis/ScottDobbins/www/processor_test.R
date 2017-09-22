# @author Scott Dobbins
# @version 0.9.8.2
# @date 2017-08-15 22:30


### Context -----------------------------------------------------------------

context("Processing clean data")

debug_message("unit testing processed clean data")


### Cardinality -------------------------------------------------------------

test_that("no data column is completely empty or identical across all rows", {
  WW1_clean %>% map_int(~expect_gt(cardinality(.), 1L))
  WW2_clean %>% map_int(~expect_gt(cardinality(.), 1L))
  Korea_clean1 %>% select(-Unit_Country, -Weapon_Type) %>% map_int(~expect_gt(cardinality(.), 1L))
  Korea_clean2 %>% select(-Unit_Country) %>% map_int(~expect_gt(cardinality(.), 1L))
  Vietnam_clean %>% map_int(~expect_gt(cardinality(.), 1L))
})


### Tooltips ----------------------------------------------------------------

test_that("no tooltips are empty", {
  WW1_clean %>% select(starts_with("tooltip")) %>% map_lgl(~expect_false(any(. == "")))
  WW2_clean %>% select(starts_with("tooltip")) %>% map_lgl(~expect_false(any(. == "")))
  Korea_clean1 %>% select(starts_with("tooltip")) %>% map_lgl(~expect_false(any(. == "")))
  Korea_clean2 %>% select(starts_with("tooltip")) %>% map_lgl(~expect_false(any(. == "")))
  Vietnam_clean %>% select(starts_with("tooltip")) %>% map_lgl(~expect_false(any(. == "")))
})

test_that("no tooltips are NA", {
  WW1_clean %>% select(starts_with("tooltip")) %>% map_lgl(~expect_false(anyNA(.)))
  WW2_clean %>% select(starts_with("tooltip")) %>% map_lgl(~expect_false(anyNA(.)))
  Korea_clean1 %>% select(starts_with("tooltip")) %>% map_lgl(~expect_false(anyNA(.)))
  Korea_clean2 %>% select(starts_with("tooltip")) %>% map_lgl(~expect_false(anyNA(.)))
  Vietnam_clean %>% select(starts_with("tooltip")) %>% map_lgl(~expect_false(anyNA(.)))
})

test_that("tooltips all have HTML formatting", {
  expect_true(all(grepl(pattern = "<br>", WW1_clean[["tooltip"]], fixed = TRUE)))
  expect_true(all(grepl(pattern = "<br>", WW2_clean[["tooltip"]], fixed = TRUE)))
  expect_true(all(grepl(pattern = "<br>", Korea_clean1[["tooltip"]], fixed = TRUE)))
  expect_true(all(grepl(pattern = "<br>", Korea_clean2[["tooltip"]], fixed = TRUE)))
  expect_true(all(grepl(pattern = "<br>", Vietnam_clean[["tooltip"]], fixed = TRUE)))
})

test_that("no tooltip is missing any component", {
  expect_false(any(grepl(pattern = "<br><br>", WW1_clean[["tooltip"]], fixed = TRUE)))
  expect_false(any(grepl(pattern = "<br><br>", WW2_clean[["tooltip"]], fixed = TRUE)))
  expect_false(any(grepl(pattern = "<br><br>", Korea_clean1[["tooltip"]], fixed = TRUE)))
  expect_false(any(grepl(pattern = "<br><br>", Korea_clean2[["tooltip"]], fixed = TRUE)))
  expect_false(any(grepl(pattern = "<br><br>", Vietnam_clean[["tooltip"]], fixed = TRUE)))
})


### Missingness -------------------------------------------------------------

if (empty_text != "") {
  test_that("no empty string factor levels", {
    WW1_clean %>% keep(is.factor) %>% map_lgl(~expect_false("" %c% levels(.)))
    WW2_clean %>% keep(is.factor) %>% map_lgl(~expect_false("" %c% levels(.)))
    Korea_clean1 %>% keep(is.factor) %>% map_lgl(~expect_false("" %c% levels(.)))
    Korea_clean2 %>% keep(is.factor) %>% map_lgl(~expect_false("" %c% levels(.)))
    Vietnam_clean %>% keep(is.factor) %>% map_lgl(~expect_false("" %c% levels(.)))
  })
}

test_that("no missing levels exist", {
  WW1_clean %>% keep(is.factor) %>% map_lgl(~expect_false(any(tabulate(.) == 0L)))
  WW2_clean %>% keep(is.factor) %>% map_lgl(~expect_false(any(tabulate(.) == 0L)))
  Korea_clean1 %>% keep(is.factor) %>% map_lgl(~expect_false(any(tabulate(.) == 0L)))
  Korea_clean2 %>% keep(is.factor) %>% map_lgl(~expect_false(any(tabulate(.) == 0L)))
  Vietnam_clean %>% keep(is.factor) %>% map_lgl(~expect_false(any(tabulate(.) == 0L)))
})


### Names -------------------------------------------------------------------

test_that("none of the levels have names", {
  WW1_clean %>% keep(is.factor) %>% walk(~expect_null(names(levels(.))))
  WW2_clean %>% keep(is.factor) %>% walk(~expect_null(names(levels(.))))
  Korea_clean1 %>% keep(is.factor) %>% walk(~expect_null(names(levels(.))))
  Korea_clean2 %>% keep(is.factor) %>% walk(~expect_null(names(levels(.))))
  Vietnam_clean %>% keep(is.factor) %>% walk(~expect_null(names(levels(.))))
})

test_that("none of the data has names", {
  WW1_clean %>% walk(~expect_null(names(.)))
  WW2_clean %>% walk(~expect_null(names(.)))
  Korea_clean1 %>% walk(~expect_null(names(.)))
  Korea_clean2 %>% walk(~expect_null(names(.)))
  Vietnam_clean %>% walk(~expect_null(names(.)))
})

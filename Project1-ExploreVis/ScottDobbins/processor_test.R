# @author Scott Dobbins
# @version 0.9.8
# @date 2017-08-11 23:30


### Context -----------------------------------------------------------------

context("Processing clean data")

debug_message("unit testing clean data")

test_that("no data column is completely empty or identical across all rows", {
  WW1_clean %>% map_int(~expect_gt(diversity(.), 1L))
  WW2_clean %>% map_int(~expect_gt(diversity(.), 1L))
  Korea_clean1 %>% select(-Unit_Country, -Weapon_Type) %>% map_int(~expect_gt(diversity(.), 1L))
  Korea_clean2 %>% select(-Unit_Country) %>% map_int(~expect_gt(diversity(.), 1L))
  Vietnam_clean %>% map_int(~expect_gt(diversity(.), 1L))
})

test_that("no tooltips are empty or NA", {
  WW1_clean %>% select(starts_with("tooltip")) %>% map_int(~expect_equal(sum(is_na_or_empty(.)), 0L))
  WW2_clean %>% select(starts_with("tooltip")) %>% map_int(~expect_equal(sum(is_na_or_empty(.)), 0L))
  Korea_clean1 %>% select(starts_with("tooltip")) %>% map_int(~expect_equal(sum(is_na_or_empty(.)), 0L))
  Korea_clean2 %>% select(starts_with("tooltip")) %>% map_int(~expect_equal(sum(is_na_or_empty(.)), 0L))
  Vietnam_clean %>% select(starts_with("tooltip")) %>% map_int(~expect_equal(sum(is_na_or_empty(.)), 0L))
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

if (empty_text != "") {
  test_that("no empty string factor levels", {
    WW1_clean %>% keep(is.factor) %>% map_lgl(~expect_false("" %c% levels(.)))
    WW2_clean %>% keep(is.factor) %>% map_lgl(~expect_false("" %c% levels(.)))
    Korea_clean1 %>% keep(is.factor) %>% map_lgl(~expect_false("" %c% levels(.)))
    Korea_clean2 %>% keep(is.factor) %>% map_lgl(~expect_false("" %c% levels(.)))
    Vietnam_clean %>% keep(is.factor) %>% map_lgl(~expect_false("" %c% levels(.)))
  })
}

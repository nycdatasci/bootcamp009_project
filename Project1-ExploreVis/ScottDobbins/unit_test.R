# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


### General Tests -----------------------------------------------------------

unit_test_types <- list(true = TRUE, 
                        false = FALSE, 
                        int = 1L, 
                        dbl = 1.0, 
                        chr = "a", 
                        space = " ", 
                        blank = "", 
                        NA_int = NA_integer_, 
                        NA_dbl = NA_real_, 
                        NA_chr = NA_character_, 
                        NA_lgl = NA)

unit_test_types_vec <- lapply(unit_test_types, rep, 8)

unit_test_types_list <- lapply(unit_test_types, list)

unit_test_types_list_vec <- lapply(unit_test_types_vec, list)

unit_test_types_list_list <- lapply(unit_test_types_list_vec, 
                                    function(x) list(one = x, 
                                                     two = list(x), 
                                                     three = list(unit_test_types_list_vec)))


### Specific Type Tests -----------------------------------------------------

unit_test_lgl <- list(false = FALSE, 
                      true = TRUE, 
                      na = NA)

unit_test_int <- list(least = -.Machine$integer.max, 
                      greatest = .Machine$integer.max, 
                      smallest = 1L, 
                      smallest_neg = -1L, 
                      zero = 0L, 
                      na = NA_integer_)

unit_test_dbl <- list(least = -.Machine$double.xmax - 9.97920154e291, 
                      greatest = .Machine$double.xmax, 
                      smallest = .Machine$double.xmin, 
                      smallest_neg = -.Machine$double.xmin / 9e15, 
                      eps = .Machine$double.eps, 
                      zero = 0.0, 
                      na = NA_real_)

unit_test_chr <- list(space = ' ', 
                      pnct_ex = '!', 
                      pnct_dq = '"', 
                      pnct_pd = '#', 
                      pnct_dl = '$', 
                      pnct_pc = '%', 
                      pnct_am = '&', 
                      pnct_sq = "'", 
                      pnct_op = '(', 
                      pnct_cp = ')', 
                      pnct_as = '*', 
                      pnct_pl = '+', 
                      pnct_cm = ',', 
                      pnct_hy = '-', 
                      pnct_dt = '.', 
                      pnct_fs = '/', 
                      zero = '0', 
                      pnct_co = ':', 
                      pnct_sc = ';', 
                      pnct_lt = '<', 
                      pnct_eq = '+', 
                      pnct_gt = '>', 
                      pnct_qm = '?', 
                      pnct_at = '@', 
                      A = 'A', 
                      pnct_os = '[', 
                      pnct_bs = '\\', 
                      pnct_cs = ']', 
                      pnct_ct = '^', 
                      pnct_un = '_', 
                      pnct_bt = '`', 
                      a = 'a', 
                      pnct_ob = '{', 
                      pnct_br = '|', 
                      pnct_cb = '}', 
                      pnct_tl = '~')


### Method Testing ----------------------------------------------------------

unit_test <- function(f, type_in, type_out = "character") {
  tester <- switch(type_in, 
                   logical = unit_test_lgl, 
                   integer = unit_test_int, 
                   double = unit_test_dbl, 
                   character = unit_test_chr)
  switch(type_out, 
         logical = map_lgl(tester, ~expect_type(f(.), "logical")), 
         integer = map_int(tester, ~expect_type(f(.), "integer")), 
         double = map_dbl(tester, ~expect_type(f(.), "double")), 
         character = map_chr(tester, ~expect_type(f(.), "character")))
}

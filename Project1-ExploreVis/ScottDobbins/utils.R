# @author Scott Dobbins
# @version 0.9.8.3
# @date 2017-08-24 22:30


### Package Functions -------------------------------------------------------

is_package_installed <- function(package_name) {
  return (package_name %in% rownames(installed.packages()))
}

# could replace with package:R.utils::isPackageLoaded
is_package_loaded <- function(package_name) {
  return (paste0("package:", package_name) %in% search())
}


### Piping ------------------------------------------------------------------

if (is_package_installed("pipeR")) {
  # overwrite the magrittr pipe (%>%) with the better pipeR pipe (normally %>>%)
  `%>%` <- pipeR::`%>>%`
}


### Debugging Functions -----------------------------------------------------

debug_message <- function(string) {
  if (debug_mode_on) message(string)
}

debug_message0 <- function(...) {
  if (debug_mode_on) message(paste(...))
}

with_debug_message <- function(func_call) {
  debug_message(deparse(substitute(func_call)))
  eval(func_call)
}


### Unit Testing Functions --------------------------------------------------

cardinality <- function(column, na.rm = TRUE) {
  if (is.null(column)) {
    warning("cardinality(NULL) = NA")
    return (NA)
  }
  if (is.factor(column)) {
    return (nlevels(column))
  } else {
    if (na.rm) {
      return (length(unique(drop_NA(column))))
    } else {
      return (length(unique(column)))
    }
  } 
}

diversity <- function(column, calibrated = TRUE, na.rm = NULL) {
  if (is.null(column)) {
    warning("diversity(NULL) = NA")
    return (NA)
  }
  if (is.null(na.rm)) {
    na.rm = TRUE
    give_warnings <- TRUE
  } else {
    give_warnings <- FALSE
  }
  num_cats <- cardinality(column, na.rm = na.rm)
  if (num_cats <= 1L) {
    return (0)
  } else {
    if (!is.factor(column)) {
      column <- as.factor(column)
    }
    tab_counts <- tabulate_factor(column)
    if (sum(tab_counts == 0L) > 0L) {
      if (na.rm) {
        tab_counts <- tab_counts %[!=]% 0
        num_cats <- length(tab_counts)
        if (give_warnings) {
          warning("Skipped levels not present in data")
        }
      } else {
        warning("Some levels are not present in the data, so diversity is 0")
        return (0)
      }
    }
    num_total <- sum(tab_counts, na.rm = TRUE)
    result <- 1
    for (i in seq_len(num_cats)) {
      result <- result * tab_counts[[i]] / num_total * num_cats
    }
    if (calibrated) {
      return (result ^ (1/num_cats))
    } else {
      return (result)
    }
  }
}


### Predicates --------------------------------------------------------------

is_scalar <- function(thing) {
  return (length(thing) == 1L)
}

is_plural <- function(thing) {
  return (length(thing) > 1L)
}

is_NULL <- function(thing) {
  return (sapply(thing, is.null))
}


### Slicers -----------------------------------------------------------------

keep_NA <- function(thing) {
  return (thing[is.na(thing)])
}

drop_NA <- function(thing) {
  return (thing[!is.na(thing)])
}

drop_NULL <- function(thing) {
  return (thing[!is_NULL(thing)])
}

keep_true <- function(thing) {
  return (thing[thing])
}

keep_false <- function(thing) {
  return (thing[!thing])
}

slice_from <- function(thing, from) {
  return (seq(from, length(thing)))
}

### Numeric Functions -------------------------------------------------------

bounded <- function(number, lower, upper) {
  if (number > upper) {
    return (upper)
  } else if (number < lower) {
    return (lower)
  } else {
    return (number)
  }
}

if (is_package_installed("dplyr")) {
  # best version of this function using the faster dplyr::if_else
  bounded_vectorized <- function(numbers, lowers, uppers) {
    return (dplyr::if_else(numbers > uppers, uppers, dplyr::if_else(numbers < lowers, lowers, numbers)))
  }
} else {
  # if dplyr isn't loaded, then this function is still supported with base::ifelse
  bounded_vectorized <- function(numbers, lowers, uppers) {
    return (ifelse(numbers > uppers, uppers, ifelse(numbers < lowers, lowers, numbers)))
  }
}

is_int <- function(double) {
  return (near(double, as.integer(double)))
}

round_to_int <- function(numbers, digits = 0L) {
  return (as.integer(round(numbers, digits)))
}

is_NA_or_0L <- function(ints) {
  if (!is.integer(ints)) {
    if (is.double(ints)) {
      warning("This method is for integers; you supplied doubles")
    } else {
      stop("This method is for integers; you supplied some non-numeric type")
    }
  }
  return (is.na(ints) | ints == 0L)
}

is_NA_or_0 <- function(dbls, tol = NULL) {
  if (!is.double(dbls)) {
    if (is.integer(dbls)) {
      warning("This method is for doubles; you supplied something else")
    } else {
      stop("This method is for doubles; you supplied some non-numeric type")
    }
  }
  if (is.null(tol)) {
    return (is.na(dbls) | dbls == 0)
  } else {
    return (is.na(dbls) | near(dbls, 0, tol = tol))
  }
}


### Character Functions -----------------------------------------------------

grem <- function(x, pattern, ...) {
  return (gsub(pattern = pattern, replacement = "", x = x, ...))
}

is_na_or_empty <- function(strings) {
  return (is.na(strings) | strings == "")
}


### Attribute Functions -----------------------------------------------------

get_names <- function(vec) {
  return (names(vec) %||% rep("", length(vec)))
}


### Factor Functions --------------------------------------------------------

tabulate_factor <- function(fact) {
  return (tabulate(fact, nbins = nlevels(fact)))
}

mode_factor <- function(fact) {
  return (levels(fact)[which.max(tabulate_factor(fact))])
}

level_proportions <- function(column, na.rm = FALSE) {
  assert_that(is.factor(column), 
              msg = "You supplied a non-factor vector/column to a factor-only method")
  tab_counts <- tabulate_factor(column)
  if (na.rm && (sum(tab_counts == 0L) > 0L)) {
    tab_counts <- tab_counts %[!=]% 0
  }
  tab_total <- sum(tab_counts)
  return (tab_counts / tab_total)
}

missing_levels <- function(fact) {
  return (levels(fact)[tabulate_factor(fact) == 0L])
}

if (is_package_loaded("data.table")) {
  fill_matching_values <- function(data, fact_col, code_col, drop.codes = FALSE, backfill = FALSE, drop.values = FALSE, numeric_code = TRUE, extra.codes = 'reduce') {
    fact_colname <- deparse(substitute(fact_col))
    code_colname <- deparse(substitute(code_col))
    lookup_table <- eval(parse(text = paste0("data[, as.character(first(unique(", fact_colname, ") %[!=]% '')), keyby = ", code_colname, "]")))
    setnames(lookup_table, c(code_colname, "V1"), c("codes", "values"))
    if (numeric_code) {
      lookup_table <- lookup_table[!is.na(codes), ]
    } else {
      lookup_table <- lookup_table[codes != "", ]
      lookup_table[, codes := as.character(codes)]
    }
    codes <- drop_NA(unique(data[[code_colname]]))
    verified_codes <- lookup_table[["codes"]]
    for (code in codes) {
      if (code %c% verified_codes) {
        replacement <- lookup_table[codes == code, ][["values"]]
        eval(parse(text = paste0("data[", code_colname, " == ", as.character(code), ", ", fact_colname, " := replacement]")))
      } else if (drop.codes) {
        if (numeric_code) {
          eval(parse(text = paste0("data[", code_colname, " == ", as.character(code), ", ", code_colname, " := NA]")))
        } else {
          eval(parse(text = paste0("data[", code_colname, ' == "', as.character(code), '", ', code_colname, ' := ""]')))
        }
      }
    }
    drop_missing_levels(data[[fact_colname]])
    if (backfill) {
      values <- levels(data[[fact_colname]]) %[!=]% ""
      verified_values <- lookup_table[["values"]]
      for (value in values) {
        if (value %c% verified_values) {
          replacement <- lookup_table[values == value, ][["codes"]]
          if (is_plural(replacement)) {
            if (extra.codes == 'reduce') {
              if (numeric_code) {
                eval(parse(text = paste0("sub_data <- data[", fact_colname, ' == "', as.character(value), '", as.factor(', code_colname, ")]")))
              } else {
                eval(parse(text = paste0("sub_data <- data[", fact_colname, ' == "', as.character(value), '", ', code_colname, "][, drop = TRUE]")))
              }
              if (numeric_code) {
                best_code <- as.integer(mode_factor(sub_data))
              } else {
                best_code <- mode_factor(sub_data)
              }
              other_codes <- replacement %d% best_code
              for (other_code in other_codes) {
                if (numeric_code) {
                  eval(parse(text = paste0("data[", code_colname, " == ", as.character(other_code), ", ", code_colname, " := ", as.character(best_code), "]")))
                } else {
                  eval(parse(text = paste0("data[", code_colname, ' == "', as.character(other_code), '", ', code_colname, ' := "', as.character(best_code), '"]')))
                }
              }
              replacement <- best_code
            } else if (extra.codes == 'recycle') {
              replacement <- rep_len(replacement, eval(parse(text = paste0("data[", fact_colname, ' == "', as.character(value), '", .N]'))))
            }
          }
          eval(parse(text = paste0("data[", fact_colname, ' == "', as.character(value), '", ', code_colname, " := replacement]")))
        } else if (drop.values) {
          eval(parse(text = paste0("data[", fact_colname, ' == "', as.character(value), '", ', fact_colname, ' := ""]')))
        }
      }
    }
    invisible(data)
  }
}

if (is_package_installed("data.table")) {
  # best versions of the factor functions set levels (and names) by reference using data.table::setattr
  re_name <- function(vec, new_names) {
    data.table::setattr(vec, "names", new_names)
  }
  
  re_level <- function(vec, new_levels) {
    data.table::setattr(vec, "levels", new_levels)
  }
} else {
  re_name <- function(vec, new_names) {
    names(vec) <- new_names
  }
  
  re_level <- function(vec, new_levels) {
    levels(vec) <- new_levels
  }
}

format_levels <- function(fact, func, ...) {
  re_level(fact, func(levels(fact), ...))
}

replace_level <- function(fact, from, to) {
  assert_that(length(from) == 1L && length(to) == 1L, 
              msg = "either (or both) 'from' or 'to' are of length >1L (you may have intended to use replace_levels, not replace_level")
  new_levels <- levels(fact)
  new_levels[new_levels == from] <- to
  re_level(fact, new_levels)
}

replace_levels <- function(fact, from, to) {
  assert_that(length(from) == length(to) || length(to) == 1L, 
              msg = "Lengths of 'from' and 'to' don't match")
  new_levels <- levels(fact)
  if (length(to) == 1L) {
    for (i in seq_along(from)) {
      new_levels[new_levels == from[[i]]] <- to
    }
  } else {
    for (i in seq_along(from)) {
      new_levels[new_levels == from[[i]]] <- to[[i]]
    }
  }
  re_level(fact, new_levels)
}

recode_levels <- function(fact, changes) {
  new_levels <- levels(fact)
  re_name(new_levels, new_levels)
  changes_names <- get_names(changes)
  for (i in seq_along(changes)) {
    new_levels[[changes[[i]]]] <- changes_names[[i]]
  }
  re_level(fact, unname(new_levels))
}

recode_similar_levels <- function(fact, changes, exact = FALSE) {
  new_levels <- levels(fact)
  changes_names <- get_names(changes)
  for (i in seq_along(changes)) {
    new_levels <- gsub(pattern = changes[[i]], replacement = changes_names[[i]], new_levels, fixed = exact)
  }
  re_level(fact, new_levels)
}

drop_levels <- function(fact, drop, to = "") {
  new_levels <- levels(fact)
  re_name(new_levels, new_levels)
  for (i in seq_along(drop)) {
    new_levels[[drop[[i]]]] <- to
  }
  re_level(fact, unname(new_levels))
}

drop_similar_levels <- function(fact, drop, to = "", exact = FALSE) {
  new_levels <- levels(fact)
  for (i in seq_along(drop)) {
    new_levels[grepl(pattern = drop[[i]], fixed = exact, new_levels)] <- to
  }
  re_level(fact, new_levels)
}

drop_missing_levels <- function(fact, to = "") {
  drop_levels(fact, drop = missing_levels(fact), to)
}

drop_missing_levels_by_col <- function(data, cols = colnames(data), to = "") {
  for (col in cols) {
    drop_missing_levels(data[[col]], to)
  }
  invisible(data)
}

drop_levels_formula <- function(fact, expr, to = "") {
  drop_levels <- eval(parse(text = paste0("levels(fact) %[]% ", deparse(substitute(expr)))))
  drop_levels(fact, drop = drop_levels, to)
}

keep_levels <- function(fact, keep, to = "") {
  new_levels <- levels(fact)
  new_levels[new_levels %!in% keep] <- to
  re_level(fact, new_levels)
}

keep_similar_levels <- function(fact, keep, to = "", exact = FALSE) {
  levels_to_drop <- levels(fact)
  for (i in seq_along(keep)) {
    levels_to_drop[grepl(pattern = keep[[i]], fixed = exact, levels_to_drop)] <- to
  }
  levels_to_drop <- levels_to_drop[levels_to_drop != to]
  drop_levels(fact, drop = levels_to_drop, to = to)
}

reduce_levels <- function(fact, rules, other = "other", exact = FALSE) {
  replacements <- get_names(rules)
  patterns <- unname(rules)
  old_levels <- levels(fact)
  new_levels <- rep(other, length(old_levels))
  for (i in seq_along(rules)) {
    slicer <- grepl(pattern = patterns[[i]], fixed = exact, old_levels)
    new_levels[slicer] <- replacements[[i]]
    old_levels[slicer] <- ""
  }
  re_level(fact, new_levels)
}

otherize_levels_rank <- function(fact, rank, other = "other", exact = FALSE) {
  contains_empty_level <- "" %c% levels(fact)
  lookup_table <- data.table(levels = levels(fact), count = tabulate_factor(fact))
  if (contains_empty_level) {
    lookup_table <- lookup_table[levels != ""]
  }
  setkey(lookup_table, count)
  dropped_levels <- lookup_table[1:(.N-rank), levels]
  if (contains_empty_level) {
    dropped_levels <- append(dropped_levels, "")
  }
  drop_levels(fact, drop = dropped_levels, to = other)
}

otherize_levels_prop <- function(fact, cutoff, other = "other", exact = FALSE) {
  contains_empty_level <- "" %c% levels(fact)
  lookup_table <- data.table(levels = levels(fact), prop = level_proportions(fact))
  if (contains_empty_level) {
    lookup_table <- lookup_table[levels != ""]
  }
  dropped_levels <- lookup_table[prop < cutoff, levels]
  if (contains_empty_level) {
    dropped_levels <- append(dropped_levels, "")
  }
  drop_levels(fact, drop = dropped_levels, to = other)
}

by_col <- function(data, col_func, cols = colnames(data), ...) {
  for (col in cols) {
    col_func(data[[col]], ...)
  }
  invisible(data)
}

format_levels_by_col <- function(data, func, cols = colnames(data), ...) {
  for (col in cols) {
    format_levels(data[[col]], func, ...)
  }
  invisible(data)
}

replace_level_by_col <- function(data, from, to, cols = colnames(data)) {
  for (col in cols) {
    replace_level(data[[col]], from, to)
  }
  invisible(data)
}

replace_levels_by_col <- function(data, from, to, cols = colnames(data)) {
  for (col in cols) {
    replace_levels(data[[col]], from, to)
  }
  invisible(data)
}

recode_levels_by_col <- function(data, changes, cols = colnames(data)) {
  for (col in cols) {
    recode_levels(data[[col]], changes)
  }
  invisible(data)
}

recode_similar_levels_by_col <- function(data, changes, cols = colnames(data), exact = FALSE) {
  for (col in cols) {
    recode_similar_levels(data[[col]], changes, exact)
  }
  invisible(data)
}

drop_levels_by_col <- function(data, drop, cols = colnames(data), to = "") {
  for (col in cols) {
    drop_levels(data[[col]], drop, to)
  }
  invisible(data)
}

drop_similar_levels_by_col <- function(data, drop, cols = colnames(data), to = "", exact = FALSE) {
  for (col in cols) {
    drop_similar_levels(data[[col]], drop, to, exact)
  }
  invisible(data)
}

keep_levels_by_col <- function(data, keep, cols = colnames(data), to = "") {
  for (col in cols) {
    keep_levels(data[[col]], keep, to)
  }
  invisible(data)
}

keep_similar_levels_by_col <- function(data, keep, cols = colnames(data), to = "", exact = FALSE) {
  for (col in cols) {
    keep_similar_levels(data[[col]], keep, to, exact)
  }
  invisible(data)
}

reduce_levels_by_col <- function(data, rules, cols = colnames(data), other = "other", exact = FALSE) {
  for (col in cols) {
    reduce_levels(data[[col]], rules, other, exact)
  }
  invisible(data)
}


### Functional Operators ----------------------------------------------------

compose <- function(f, g) {
  function(...) f(g(...))
}

compose_rev <- function(f, g) {
  function(...) g(f(...))
}


### Infix Functions ---------------------------------------------------------

### convenience

# safe defaults
`%||%` <- function(a, b) if (!is.null(a)) a else b

# slicing
`%[==]%` <- function(a, b) a[a == b]
`%[!=]%` <- function(a, b) a[a != b]
`%[>]%`  <- function(a, b) a[a > b]
`%[>=]%` <- function(a, b) a[a >= b]
`%[<]%`  <- function(a, b) a[a < b]
`%[<=]%` <- function(a, b) a[a <= b]

# complicated slices
`%[]%`   <- function(a, b) {
  a[eval(parse(text = paste0(deparse(substitute(a)), " %>% ", deparse(substitute(b)))), env = parent.frame())]
}
`%[!]%`  <- function(a, b) {
  a[!eval(parse(text = paste0(deparse(substitute(a)), " %>% ", deparse(substitute(b)))), env = parent.frame())]
}

### logical operators
`%><%` <- function(a, b) xor(a, b)

# bitwise logical operators
`%&%` <- function(a, b) bitwAnd(a, b)
`%|%` <- function(a, b) bitwOr(a, b)
`%^%` <- function(a, b) bitwXor(a, b)

# bitshifts
`%<<%` <- function(a, n) bitwShiftL(a, n)
`%>>%` <- function(a, n) bitwShiftR(a, n)

### set operations

# set operations, standard
`%u%` <- function(a, b) base::union(a, b)
`%i%` <- function(a, b) base::intersect(a, b)
`%e%` <- function(a, b) base::setequal(a, b)
`%d%` <- function(a, b) base::setdiff(a, b)
`%dd%` <- function(a, b) base::setdiff(base::union(a, b), base::intersect(a, b))

# set operations, length one
`%c%` <- function(a, b) {
  if (length(a) > 1L) debug_message("%c%: condition (LHS) length greater than 1")
  return (is.element(a[1], b))
}

# set operations, negations
`%!c%` <- function(a, b) {
  if (length(a) > 1L) debug_message("%!c%: condition (LHS) length greater than 1")
  return (!is.element(a[1], b))
}
`%!in%` <- function(a, b) {
  return (!(a %in% b))
}

# data.table add-ons
if (!(is_package_loaded("data.table") && exists("like") && is.function(like))) {
  if (!is_package_installed("data.table")) {
    between <- function(a, b1, b2) (a >= b1) & (a <= b2)
    `%between%` <- function(a, b) between(a, b[1], b[2])
    like <- function(a, b) grepl(pattern = b, a)
    `%like%` <- function(a, b) like(a, b)
  } else {
    between <- data.table::between
    `%between%` <- data.table::`%between%`
    like <- data.table::like
    `%like%` <- data.table::`%like%`
  }
}
`%!between%` <- function(a, b) !between(a, b[1], b[2])
`%!like%` <- function(a, b) !like(a, b)
`%exactlylike%` <- function(a, b) grepl(pattern = b, fixed = TRUE, a)
`%whichlike%` <- function(a, b) a[a %like% b]
`%!whichlike%` <- function(a, b) a[a %!like% b]

### functional operators
`%.%` <- compose
`%,%` <- compose_rev


### Parallel ----------------------------------------------------------------

if (use_parallel) {
  max_useful_cores <- function(col_names, virtual = FALSE) {
    if (virtual) {
      return (min(length(col_names), all_cores))
    } else {
      return (min(length(col_names), virtual_cores_only))
    }
  }
}

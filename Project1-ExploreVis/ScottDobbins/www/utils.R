# @author Scott Dobbins
# @version 0.9.8.2
# @date 2017-08-15 22:30


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
  if (debug_mode_on) {
    message(string)
  }
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


### Factor Functions --------------------------------------------------------

tabulate_factor <- function(fact) {
  return (tabulate(fact, nbins = nlevels(fact)))
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

if (is_package_installed("data.table")) {
  # best versions of these functions set levels (and names) by reference using data.table::setattr
  format_levels <- function(fact, func, ...) {
    data.table::setattr(fact, "levels", func(levels(fact), ...))
  }
  
  replace_level <- function(fact, from, to) {
    assert_that(length(from) == 1L && length(to) == 1L, 
                msg = "either (or both) 'from' or 'to' are of length >1L (you may have intended to use replace_levels, not replace_level")
    new_levels <- levels(fact)
    new_levels[new_levels == from] <- to
    data.table::setattr(fact, "levels", new_levels)
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
    data.table::setattr(fact, "levels", new_levels)
  }
  
  recode_levels <- function(fact, changes) {
    new_levels <- levels(fact)
    data.table::setattr(new_levels, "names", new_levels)
    changes_names <- names(changes) %||% rep("", length(changes))
    for (i in seq_along(changes)) {
      new_levels[[changes[[i]]]] <- changes_names[[i]]
    }
    data.table::setattr(fact, "levels", unname(new_levels))
  }
  
  recode_similar_levels <- function(fact, changes, exact = FALSE) {
    new_levels <- levels(fact)
    changes_names <- names(changes) %||% rep("", length(changes))
    for (i in seq_along(changes)) {
      new_levels <- gsub(pattern = changes[[i]], replacement = changes_names[[i]], new_levels, fixed = exact)
    }
    data.table::setattr(fact, "levels", new_levels)
  }
  
  drop_levels <- function(fact, drop, to = "") {
    new_levels <- levels(fact)
    data.table::setattr(new_levels, "names", new_levels)
    for (i in seq_along(drop)) {
      new_levels[[drop[[i]]]] <- to
    }
    data.table::setattr(fact, "levels", unname(new_levels))
  }
  
  drop_similar_levels <- function(fact, drop, to = "", exact = FALSE) {
    new_levels <- levels(fact)
    for (i in seq_along(drop)) {
      new_levels[grepl(pattern = drop[[i]], fixed = exact, new_levels)] <- to
    }
    data.table::setattr(fact, "levels", new_levels)
  }
  
  keep_levels <- function(fact, keep, to = "") {
    new_levels <- levels(fact)
    new_levels[new_levels %!in% keep] <- to
    data.table::setattr(fact, "levels", new_levels)
  }
} else {
  # if data.table isn't installed, then this function is still supported with base::`names<-` and base::`levels<-`
  format_levels <- function(fact, func, ...) {
    levels(fact) <- func(levels(fact), ...)
  }
  
  replace_level <- function(fact, from, to) {
    stopifnot(length(from) == 1L && length(to) == 1L)
    new_levels <- levels(fact)
    new_levels[new_levels == from] <- to
    levels(fact) <- new_levels
  }
  
  replace_levels <- function(fact, from, to) {
    stopifnot(length(from) == length(to) || length(to) == 1L, "Lengths of 'from' and 'to' don't match")
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
    levels(fact) <- new_levels
  }
  
  recode_levels <- function(fact, changes) {
    new_levels <- levels(fact)
    names(new_levels) <- new_levels
    changes_names <- names(changes) %||% rep("", length(changes))
    for (i in seq_along(changes)) {
      new_levels[[changes[[i]]]] <- changes_names[[i]]
    }
    levels(fact) <- unname(new_levels)
  }
  
  recode_similar_levels <- function(fact, changes, exact = FALSE) {
    new_levels <- levels(fact)
    changes_names <- names(changes) %||% rep("", length(changes))
    for (i in seq_along(changes)) {
      new_levels <- gsub(pattern = changes[[i]], replacement = changes_names[[i]], new_levels, fixed = exact)
    }
    levels(fact) <- new_levels
  }
  
  drop_levels <- function(fact, drop, to = "") {
    new_levels <- levels(fact)
    names(new_levels) <- new_levels
    for (i in seq_along(drop)) {
      new_levels[[drop[[i]]]] <- to
    }
    levels(fact) <- unname(new_levels)
  }
  
  drop_similar_levels <- function(fact, drop, to = "", exact = FALSE) {
    new_levels <- levels(fact)
    for (i in seq_along(drop)) {
      new_levels[grepl(pattern = drop[[i]], fixed = exact, new_levels)] <- to
    }
    levels(fact) <- new_levels
  }
  
  keep_levels <- function(fact, keep, to = "") {
    new_levels <- levels(fact)
    new_levels[new_levels %!in% keep] <- to
    levels(fact) <- new_levels
  }
}

drop_missing_levels <- function(fact, to = "") {
  missing_levels <- levels(fact)[tabulate_factor(fact) == 0L]
  drop_levels(fact, drop = missing_levels, to)
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

keep_similar_levels <- function(fact, keep, to = "", exact = FALSE) {
  levels_to_drop <- levels(fact)
  for (i in seq_along(keep)) {
    levels_to_drop[grepl(pattern = keep[[i]], fixed = exact, levels_to_drop)] <- to
  }
  levels_to_drop <- levels_to_drop[levels_to_drop != to]
  drop_levels(fact, drop = levels_to_drop, to = to)
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

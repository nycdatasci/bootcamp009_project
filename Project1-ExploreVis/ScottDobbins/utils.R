# @author Scott Dobbins
# @version 0.9.8
# @date 2017-08-11 23:30


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

diversity <- function(column) {
  if (is.factor(column)) {
    return (length(levels(column)))
  } else {
    return (length(unique(column)))
  } 
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

bounded_vectorized <- function(numbers, lowers, uppers) {
  return (dplyr::if_else(numbers > uppers, uppers, dplyr::if_else(numbers < lowers, lowers, numbers)))
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

grem <- function(pattern, x, ...) {
  return (gsub(pattern = pattern, replacement = "", x = x, ...))
}

is_na_or_empty <- function(strings) {
  return (is.na(strings) | strings == "")
}


### Factor Functions --------------------------------------------------------

if (is_package_loaded("data.table") && exists("setattr") && is.function(setattr)) {
  # best versions of these functions set levels (and names) by reference using data.table::setattr
  format_levels <- function(fact, func, ...) {
    setattr(fact, "levels", func(levels(fact), ...))
  }
  
  replace_level <- function(fact, from, to) {
    assert_that(length(from) == 1L && length(to) == 1L, 
                msg = "either (or both) 'from' or 'to' are of length >1L (you may have intended to use replace_levels, not replace_level")
    new_levels <- levels(fact)
    new_levels[new_levels == from] <- to
    setattr(fact, "levels", new_levels)
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
    setattr(fact, "levels", new_levels)
  }
  
  recode_levels <- function(fact, changes) {
    new_levels <- levels(fact)
    setattr(new_levels, "names", new_levels)
    changes_names <- names(changes)
    for (i in seq_along(changes)) {
      new_levels[[changes[[i]]]] <- changes_names[[i]]
    }
    setattr(fact, "levels", new_levels)
  }
  
  recode_similar_levels <- function(fact, changes, exact = FALSE) {
    new_levels <- levels(fact)
    changes_names <- names(changes) %||% rep("", length(changes))
    for (i in seq_along(changes)) {
      new_levels <- gsub(pattern = changes[[i]], replacement = changes_names[[i]], new_levels, fixed = exact)
    }
    setattr(fact, "levels", new_levels)
  }
  
  drop_levels <- function(fact, drop, to = "") {
    new_levels <- levels(fact)
    setattr(new_levels, "names", new_levels)
    for (i in seq_along(drop)) {
      new_levels[[drop[[i]]]] <- to
    }
    setattr(fact, "levels", new_levels)
  }
  
  drop_similar_levels <- function(fact, drop, to = "", exact = FALSE) {
    new_levels <- levels(fact)
    for (i in seq_along(drop)) {
      new_levels[grepl(pattern = drop[[i]], fixed = exact, new_levels)] <- to
    }
    setattr(fact, "levels", new_levels)
  }
  
  keep_levels <- function(fact, keep, to = "") {
    new_levels <- levels(fact)
    new_levels[new_levels %!in% keep] <- to
    setattr(fact, "levels", new_levels)
  }
} else {
  # if data.table isn't loaded, then this function is still supported with base::`names<-` and base::`levels<-`
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
    changes_names <- names(changes)
    for (i in seq_along(changes)) {
      new_levels[[changes[[i]]]] <- changes_names[[i]]
    }
    levels(fact) <- new_levels
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
    levels(fact) <- new_levels
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

keep_similar_levels <- function(fact, keep, to = "", exact = FALSE) {
  levels_to_drop <- levels(fact)
  for (i in seq_along(keep)) {
    levels_to_drop[grepl(pattern = keep[[i]], fixed = exact, levels_to_drop)] <- to
  }
  levels_to_drop <- levels_to_drop[levels_to_drop != to]
  drop_levels(fact, drop = levels_to_drop, to = to)
}


### Functional Operators ----------------------------------------------------

compose <- function(f, g) {
  function(...) f(g(...))
}

compose_rev <- function(f, g) {
  function(...) g(f(...))
}


### Infix Functions ---------------------------------------------------------

# convenience
`%||%` <- function(a, b) if (!is.null(a)) a else b

# set operations
`%u%` <- function(a, b) union(a, b)
`%i%` <- function(a, b) intersect(a, b)
`%d%` <- function(a, b) setdiff(a, b)
`%e%` <- function(a, b) setequal(a, b)
`%dd%` <- function(a, b) setdiff(union(a, b), intersect(a, b))

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

# functional operators
`%.%` <- compose
`%,%` <- compose_rev

# logical operators
`%><%` <- function(a, b) xor(a, b)

# bitwise logical operators
`%&%` <- function(a, b) bitwAnd(a, b)
`%|%` <- function(a, b) bitwOr(a, b)
`%^%` <- function(a, b) bitwXor(a, b)

# bitshifts
`%<<%` <- function(a, n) bitwShiftL(a, n)
`%>>%` <- function(a, n) bitwShiftR(a, n)

if (!(is_package_loaded("data.table") && exists("like") && is.function(like))) {
  `%like%` <- function(a, b) grepl(pattern = b, a)
}
`%!like%` <- function(a, b) !like(a, b)

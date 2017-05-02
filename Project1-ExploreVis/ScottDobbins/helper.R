# @author Scott Dobbins
# @version 0.9.3
# @date 2017-05-01 01:30

### text formatting functions ###

capitalize <- function(word) {
  return(paste0(toupper(substring(word, 1, 1)), substring(word, 2)))
}

capitalize_from_caps <- function(word) {
  return(paste0(substring(word, 1, 1), tolower(substring(word, 2))))
}

proper_noun <- function(word) {
  if(regexpr(pattern = "-", word)[1] > 0) {
    return(paste0(sapply(X = strsplit(word, split = '-')[[1]], FUN = proper_noun), collapse = '-'))
  } else {
    first_letter <- regexpr(pattern = "[A-Za-z]", word)[1]
    if(first_letter > 1) {
      return(paste0(substring(word, 1, first_letter-1), proper_noun(substring(word, first_letter))))
    } else {
      word = tolower(word)
      if(any(word %in% c("e", "n", "ne", "nw", "s", "se", "sw", "w", "uk", "usa"))) {#, "i", "ii", "iii", "iv", "v", "vi", "vii", "vii", "ix", "x", "xi", "xii", "xiii"))) {
        return(toupper(word))
      } else {
        if(any(word %in% c("and", "aux", "di", "in", "of", "on", "or", "the", "to", "km", "mi", "m", "st", "nd", "rd", "th"))) {
          return(word)
        } else {
          return(capitalize(word))
        }
      }
    }
  }
}

proper_noun_phrase <- function(line) {
  return(paste(sapply(X = strsplit(line, split = ' ')[[1]], FUN = proper_noun), collapse = " "))
}

remove_quotes <- function(cell) {
  return(gsub(pattern = "\"", replacement = "", cell))
}

remove_nonASCII_chars <- function(cell) {
  return(gsub(pattern = '[^ -~]+', replacement = "", cell))
}

add_commas <- function(number) {
  num_groups <- log(number, base = 1000)
  if(num_groups < 1) {
    return(toString(number))
  } else {
    num_rounds <- floor(num_groups)
    output_string <- ""
    for(round in 1:num_rounds) {
      this_group_int <- number %% 1000
      if(this_group_int < 10) {
        this_group_string <- paste0("00", toString(this_group_int))
      } else if(this_group_int < 100) {
        this_group_string <- paste0("0", toString(this_group_int))
      } else {
        this_group_string <- toString(this_group_int)
      }
      output_string <- paste0(",", this_group_string, output_string)
      number <- number %/% 1000
    }
    output_string <- paste0(toString(number), output_string)
    return(output_string)
  }
}

# @author Scott Dobbins
# @version 0.5
# @date 2017-04-21 18:53

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
      if(any(word %in% c("e", "n", "ne", "nw", "s", "se", "sw", "w"))) {
        return(toupper(word))
      } else {
        if(any(word %in% c("and", "aux", "di", "in", "of", "on", "or", "the", "km", "mi", "m"))) {
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

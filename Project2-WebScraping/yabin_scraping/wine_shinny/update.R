# update.R 
# this file contains the data, package dependencies, and functions that
# do the heavy lifting for the app

##### package dependencies for text mining and stemming algorithm
require(tm)
require(SnowballC)

# data needed for shiny app
load(file = 'wine.Rdata')

###### FUNCTIONS used in the shiny app

# takes input from the text box of any type (Caps, lowercase, punctuation, etc) 
# and cleans it so it can be recognized by the model. Removes punctuation,
# numbers, capital letters, and stems words.
DescriptionParser <- function(description) {
  c <- removePunctuation(description)
  c <- removeNumbers(c)
  c <- tolower(c)
  c <- stemDocument(c)
  c <- stripWhitespace(c)
  return(c)
}

# given a wine and a vector of words, calculates the bayesian posterior 
# probability of being that wine given words. Wine words come from the
# wine.word.lists, indexed by varietal
calc.posterior <- function(wine, words, prior = 1/length(wine.word.lists), c=1e-6, ...) {
  WineList = wine.word.lists
  df = WineList[wine][[1]]
  # take words and create vector
  words = DescriptionParser(words)
  w = do.call(rbind, strsplit(words, '\\s'))
  # find intersection of words
  w.match = intersect(w, df$term)
  if(length(w.match) < 1) {
    return(prior*c^(length(w)))
  } else {
    match.probs = df$occurrence[match(w.match, df$term)]
    return(prior * prod(match.probs) * c^(length(w)-length(w.match)))
  }
}

# main function to rank wines. Calls calc.posterior for each varietal and
# returns the probability in a data frame.
RankWineProbabilities <- function(words, ...) {
  results = sapply(names(wine.word.lists), calc.posterior, words = words)
  ordered.results = results[order(-results)]
  results.df = data.frame(ordered.results)
  names(results.df) <- 'Probability'
  results.df$Wine <- factor(row.names(results.df))
  # to get color
  results.df <- merge(results.df, colorMap)
  results.df$Wine <- reorder(results.df$Wine, -results.df$Probability)
  return(results.df)
}


## function that gets random words for inspiration. Uses words in allWords since
## they are not stemmed.
GetRandomWords <- function(words = 20) {
 # gets random words proporional to their frequency
  words <- sample(x=allWords$term, size= words, prob=allWords$p)
  return(words)
}
# Public APIs Collection
# Source: https://github.com/public-apis/public-apis
# A curated list of free public APIs for various purposes

#' Fetch Random Inspirational Quote
#' 
#' @param source Source of quotes: "quotable", "zenquotes", or "advice"
#'
#' @return List with status, data (quote, author), and metadata
#'
#' @details
#' Returns a random inspirational or thought-provoking quote.
#' No API key required - all endpoints are completely free.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_random_quote()
#'   if (is_success(result)) print(result$data)
#' }
#'
fetch_random_quote <- function(source = "quotable") {
  url <- switch(tolower(source),
    quotable = "https://api.quotable.io/random",
    zenquotes = "https://zenquotes.io/api/random",
    advice = "https://api.adviceslip.com/advice",
    "https://api.quotable.io/random"  # default
  )
  
  result <- safe_api_call(url, sprintf("Random Quote (%s)", source))
  
  if (is_success(result)) {
    # Normalize different quote API responses
    data <- result$data
    
    quote_text <- data$content %||% data$q %||% data$slip$advice %||% "No quote found"
    author <- data$author %||% data$a %||% "Unknown"
    
    result$data <- list(
      quote = quote_text,
      author = author,
      source = source
    )
  }
  
  return(result)
}

#' Fetch Random Cat Fact
#'
#' @return List with status, data (fact), and metadata
#'
#' @details
#' Returns a random fun fact about cats.
#' No API key required - completely free.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_cat_fact()
#'   if (is_success(result)) print(result$data$fact)
#' }
#'
fetch_cat_fact <- function() {
  url <- "https://catfact.ninja/fact"
  
  result <- safe_api_call(url, "Cat Facts")
  
  if (is_success(result)) {
    result$data <- list(
      fact = result$data$fact,
      length = result$data$length
    )
  }
  
  return(result)
}

#' Fetch Random Dog Fact
#'
#' @return List with status, data (fact), and metadata
#'
#' @details
#' Returns a random fun fact about dogs.
#' No API key required - completely free.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_dog_fact()
#'   if (is_success(result)) print(result$data$fact)
#' }
#'
fetch_dog_fact <- function() {
  url <- "https://dog-facts-api.herokuapp.com/api/v1/resources/dogs?number=1"
  
  result <- safe_api_call(url, "Dog Facts")
  
  if (is_success(result)) {
    facts <- result$data
    if (length(facts) > 0) {
      result$data <- list(
        fact = facts[[1]]$fact %||% "No fact found"
      )
    }
  }
  
  return(result)
}

#' Fetch Random Useless Fact
#'
#' @return List with status, data (fact), and metadata
#'
#' @details
#' Returns a random useless but true fact.
#' No API key required - completely free.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_useless_fact()
#'   if (is_success(result)) print(result$data$fact)
#' }
#'
fetch_useless_fact <- function() {
  url <- "https://uselessfacts.jscinc.com/random.json?language=en"
  
  result <- safe_api_call(url, "Useless Facts")
  
  if (is_success(result)) {
    result$data <- list(
      fact = result$data$text %||% "No fact found"
    )
  }
  
  return(result)
}

#' Fetch Random Zen Quote
#'
#' @return List with status, data (quote), and metadata
#'
#' @details
#' Returns a random Zen quote for meditation and reflection.
#' No API key required - completely free.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_zen_quote()
#'   if (is_success(result)) print(result$data$quote)
#' }
#'
fetch_zen_quote <- function() {
  url <- "https://zenquotes.io/api/random"
  
  result <- safe_api_call(url, "Zen Quotes")
  
  if (is_success(result)) {
    if (length(result$data) > 0) {
      quote_data <- result$data[[1]]
      result$data <- list(
        quote = quote_data$q %||% "No quote found",
        author = quote_data$a %||% "Unknown"
      )
    }
  }
  
  return(result)
}

#' Fetch Random Advice
#'
#' @return List with status, data (advice), and metadata
#'
#' @details
#' Returns random advice from Advice Slip API.
#' No API key required - completely free.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_random_advice()
#'   if (is_success(result)) print(result$data$advice)
#' }
#'
fetch_random_advice <- function() {
  url <- "https://api.adviceslip.com/advice"
  
  result <- safe_api_call(url, "Random Advice")
  
  if (is_success(result)) {
    advice_text <- result$data$slip$advice %||% "No advice found"
    result$data <- list(
      advice = advice_text
    )
  }
  
  return(result)
}

#' Fetch Programming Humor Quote
#'
#' @return List with status, data (quote), and metadata
#'
#' @details
#' Returns a random programming-related quote or joke.
#' No API key required - completely free.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_programming_quote()
#'   if (is_success(result)) print(result$data$quote)
#' }
#'
fetch_programming_quote <- function() {
  url <- "https://api.quotable.io/random?tags=programming"
  
  result <- safe_api_call(url, "Programming Quotes")
  
  if (is_success(result)) {
    result$data <- list(
      quote = result$data$content %||% "No quote found",
      author = result$data$author %||% "Unknown",
      tags = paste(result$data$tags, collapse = ", ")
    )
  }
  
  return(result)
}

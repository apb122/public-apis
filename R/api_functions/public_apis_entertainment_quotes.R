# Public APIs - Entertainment, Quotes, Jokes, and Fun Facts
# Source: https://github.com/public-apis/public-apis

#' Fetch Random Quote from Multiple Sources
#' 
#' @param source Quote source: "quotable", "zenquotes", "advice", "kanye", "programming"
#' 
#' @return List with status, data (text, author), and metadata
#'
fetch_quote <- function(source = "quotable") {
  url <- switch(source,
    quotable = "https://api.quotable.io/random",
    zenquotes = "https://zenquotes.io/api/random",
    advice = "https://api.adviceslip.com/advice",
    kanye = "https://api.kanye.rest",
    programming = "https://programming-quotes-api.herokuapp.com/quotes/random",
    "https://api.quotable.io/random"
  )
  
  result <- safe_api_call(url, paste("Random Quote -", source))
  
  if (is_success(result)) {
    if (source == "zenquotes") {
      result$data <- list(
        text = result$data[[1]]$q %||% "Unknown",
        author = result$data[[1]]$a %||% "Unknown"
      )
    } else if (source == "advice") {
      result$data <- list(
        text = result$data$slip_text %||% "Unknown",
        author = "Advice Slip"
      )
    } else if (source == "kanye") {
      result$data <- list(
        text = result$data$quote %||% "Unknown",
        author = "Kanye West"
      )
    } else if (source == "programming") {
      result$data <- list(
        text = result$data$quote %||% "Unknown",
        author = result$data$author %||% "Unknown"
      )
    } else {
      result$data <- list(
        text = result$data$content %||% "Unknown",
        author = result$data$author %||% "Unknown"
      )
    }
  }
  return(result)
}

#' Fetch Inspirational Quote
#'
#' @return List with status, data (text, author), and metadata
#'
fetch_inspirational_quote <- function() {
  url <- "https://api.api-ninjas.com/v1/quotes?category=inspirational"
  result <- safe_api_call(url, "Inspirational Quote")
  
  if (is_success(result)) {
    quotes <- result$data
    if (length(quotes) > 0 && is.list(quotes[[1]])) {
      quote_obj <- quotes[[1]]
      result$data <- list(
        text = quote_obj$quote %||% "Unknown",
        author = quote_obj$author %||% "Unknown"
      )
    }
  }
  return(result)
}

#' Fetch Zen Quote
#'
#' @return List with status, data (text, author), and metadata
#'
fetch_zen_quote <- function() {
  url <- "https://zenquotes.io/api/random"
  result <- safe_api_call(url, "Zen Quote")
  
  if (is_success(result)) {
    result$data <- list(
      text = result$data[[1]]$q %||% "Unknown",
      author = result$data[[1]]$a %||% "Unknown"
    )
  }
  return(result)
}

#' Fetch Random Joke
#'
#' @param category Joke category: "programming", "knock-knock", "general"
#'
#' @return List with status, data (joke/setup/delivery), and metadata
#'
fetch_random_joke <- function(category = "programming") {
  url <- switch(category,
    programming = "https://official-joke-api.appspot.com/random",
    knock_knock = "https://official-joke-api.appspot.com/jokes/knock-knock/random",
    general = "https://official-joke-api.appspot.com/jokes/general/random",
    "https://official-joke-api.appspot.com/random"
  )
  
  result <- safe_api_call(url, paste("Random Joke -", category))
  
  if (is_success(result)) {
    setup <- result$data$setup %||% ""
    delivery <- result$data$delivery %||% result$data$joke %||% ""
    result$data <- list(
      joke = if (setup != "") paste(setup, delivery, sep = " ") else delivery,
      type = result$data$type %||% category
    )
  }
  return(result)
}

#' Fetch Random Fact (Fun)
#'
#' @return List with status, data (fact), and metadata
#'
fetch_random_fact <- function() {
  url <- "https://uselessfacts.jsponge.com/random.json"
  result <- safe_api_call(url, "Random Useless Fact")
  
  if (is_success(result)) {
    result$data <- list(
      fact = result$data$text %||% "Unknown fact"
    )
  }
  return(result)
}

#' Fetch Dad Joke
#'
#' @return List with status, data (joke), and metadata
#'
fetch_dad_joke <- function() {
  url <- "https://icanhazdadjoke.com/slack"
  result <- safe_api_call(url, "Dad Joke")
  
  if (is_success(result)) {
    # Slack format returns attachments array
    attachments <- result$data$attachments %||% list()
    if (length(attachments) > 0) {
      joke_text <- attachments[[1]]$text %||% "Unknown"
    } else {
      joke_text <- result$data$text %||% "Unknown"
    }
    result$data <- list(
      joke = joke_text
    )
  }
  return(result)
}

#' Fetch Random Excuse
#'
#' @return List with status, data (excuse), and metadata
#'
fetch_random_excuse <- function() {
  url <- "https://excuser.herokuapp.com/v1/excuse"
  result <- safe_api_call(url, "Random Excuse")
  
  if (is_success(result)) {
    result$data <- list(
      excuse = result$data$excuse %||% "Unknown excuse"
    )
  }
  return(result)
}

#' Fetch Corporate Buzz Words
#'
#' @return List with status, data (buzzword), and metadata
#'
fetch_buzz_word <- function() {
  url <- "https://corporatebs-generator.sameerkummar.com/"
  result <- safe_api_call(url, "Corporate Buzz Word")
  
  if (is_success(result)) {
    result$data <- list(
      buzzword = result$data$phrase %||% "Unknown buzzword"
    )
  }
  return(result)
}

#' Fetch Techy Phrase
#'
#' @return List with status, data (phrase), and metadata
#'
fetch_techy_phrase <- function() {
  url <- "https://techy-api.vercel.app/api/text"
  result <- safe_api_call(url, "Techy Phrase")
  
  if (is_success(result)) {
    result$data <- list(
      phrase = result$data$text %||% "Unknown phrase"
    )
  }
  return(result)
}

#' Fetch Motivational Quote
#'
#' @return List with status, data (text, author), and metadata
#'
fetch_motivational_quote <- function() {
  url <- "https://api.motivational.live/"
  result <- safe_api_call(url, "Motivational Quote")
  
  if (is_success(result)) {
    result$data <- list(
      text = result$data$thought %||% "Unknown",
      author = result$data$author %||% "Unknown"
    )
  }
  return(result)
}

#' Fetch Chuck Norris Joke
#'
#' @return List with status, data (joke), and metadata
#'
fetch_chuck_norris_joke <- function() {
  url <- "https://api.chucknorris.io/jokes/random"
  result <- safe_api_call(url, "Chuck Norris Joke")
  
  if (is_success(result)) {
    result$data <- list(
      joke = result$data$value %||% "Unknown joke"
    )
  }
  return(result)
}

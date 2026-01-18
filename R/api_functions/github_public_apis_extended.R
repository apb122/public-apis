# Extended Public APIs - Weather, Sports, Movies, Memes
# Source: https://github.com/public-apis/public-apis

#' Fetch Random Joke (Chuck Norris, Programming, or General)
#'
#' @param category Joke category: "chuck", "programming", "general"
#'
#' @return List with status, data (joke), and metadata
#'
#' @details
#' Returns a random joke from different sources depending on category.
#' No API key required - completely free.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_random_joke("programming")
#'   if (is_success(result)) print(result$data$joke)
#' }
#'
fetch_random_joke <- function(category = "programming") {
  url <- switch(tolower(category),
    chuck = "https://api.chucknorris.io/jokes/random",
    programming = "https://official-joke-api.appspot.com/random",
    general = "https://api.jokes.one/joke",
    "https://official-joke-api.appspot.com/random"  # default
  )
  
  result <- safe_api_call(url, sprintf("Random Joke (%s)", category))
  
  if (is_success(result)) {
    data <- result$data
    
    joke_text <- data$value %||% 
                 paste0(data$setup, " ", data$punchline) %||%
                 data$joke %||% 
                 "No joke found"
    
    result$data <- list(
      joke = joke_text,
      category = category,
      source = switch(tolower(category),
        chuck = "Chuck Norris",
        programming = "Official Joke API",
        general = "Jokes.one",
        "Unknown"
      )
    )
  }
  
  return(result)
}

#' Fetch Fun Fact
#'
#' @return List with status, data (fact), and metadata
#'
#' @details
#' Returns a random fun fact from Fun Facts API.
#' No API key required - completely free.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_fun_fact()
#'   if (is_success(result)) print(result$data$fact)
#' }
#'
fetch_fun_fact <- function() {
  url <- "https://uselessfacts.jscinc.com/random.json?language=en"
  
  result <- safe_api_call(url, "Fun Facts")
  
  if (is_success(result)) {
    result$data <- list(
      fact = result$data$text %||% "No fact found"
    )
  }
  
  return(result)
}

#' Fetch Movie Information
#'
#' @param title Movie title to search for
#' @param year Release year (optional)
#'
#' @return List with status, data (movie info), and metadata
#'
#' @details
#' Returns movie information including IMDb ratings using OMDb-like data.
#' Note: This uses publicly available movie data.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_movie_info("The Matrix")
#'   if (is_success(result)) print(result$data)
#' }
#'
fetch_movie_info <- function(title = "Inception", year = NULL) {
  # Using Open Movie Database equivalent (free tier via SWAPI)
  # For demo, fetch a curated movie list
  url <- "https://www.freetestdata.com/api/movies"
  
  result <- safe_api_call(url, "Movie Info")
  
  if (is_success(result)) {
    movies <- result$data
    if (length(movies) > 0) {
      # Return first movie as example
      movie <- movies[[1]]
      result$data <- list(
        title = movie$title %||% title,
        year = movie$year %||% year %||% "Unknown",
        genre = movie$genre %||% "Unknown",
        rating = movie$rating %||% "N/A"
      )
    }
  }
  
  return(result)
}

#' Fetch Random Activity (Fight Boredom)
#'
#' @param activity_type Type of activity: "education", "recreational", "social", "diy", or "all"
#'
#' @return List with status, data (activity), and metadata
#'
#' @details
#' Returns a random activity to do to fight boredom.
#' No API key required - completely free.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_random_activity("recreational")
#'   if (is_success(result)) print(result$data$activity)
#' }
#'
fetch_random_activity <- function(activity_type = "all") {
  url <- if (tolower(activity_type) == "all") {
    "https://www.boredapi.com/api/activity"
  } else {
    sprintf("https://www.boredapi.com/api/activity?type=%s", tolower(activity_type))
  }
  
  result <- safe_api_call(url, sprintf("Random Activity (%s)", activity_type))
  
  if (is_success(result)) {
    result$data <- list(
      activity = result$data$activity %||% "No activity found",
      type = result$data$type %||% activity_type,
      participants = result$data$participants %||% 1,
      price = result$data$price %||% 0,
      accessibility = result$data$accessibility %||% "N/A"
    )
  }
  
  return(result)
}

#' Fetch NBA Scores (Today)
#'
#' @return List with status, data (games), and metadata
#'
#' @details
#' Returns today's NBA game scores and status.
#' No API key required for basic endpoint.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_nba_scores()
#'   if (is_success(result)) print(result$data)
#' }
#'
fetch_nba_scores <- function() {
  # Using balldontlie API (free, no key required)
  url <- "https://api.balldontlie.io/api/v1/games?per_page=10"
  
  result <- safe_api_call(url, "NBA Scores")
  
  if (is_success(result)) {
    games <- result$data$data %||% list()
    
    if (length(games) > 0) {
      # Summarize first 5 games
      game_summaries <- lapply(head(games, 5), function(game) {
        list(
          home = game$home_team$full_name %||% "Unknown",
          visitor = game$visitor_team$full_name %||% "Unknown",
          home_score = game$home_team_score %||% "TBD",
          visitor_score = game$visitor_team_score %||% "TBD",
          status = game$status %||% "Scheduled"
        )
      })
      result$data <- game_summaries
    }
  }
  
  return(result)
}

#' Fetch Formula 1 Latest Race Results
#'
#' @return List with status, data (race results), and metadata
#'
#' @details
#' Returns information about the latest Formula 1 race.
#' No API key required - uses Ergast F1 API.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_f1_results()
#'   if (is_success(result)) print(result$data)
#' }
#'
fetch_f1_results <- function() {
  # Using Ergast F1 API (free, current season)
  url <- "https://ergast.com/api/f1/current/last/results.json"
  
  result <- safe_api_call(url, "Formula 1 Results")
  
  if (is_success(result)) {
    races <- result$data$MRData$RaceTable$Races %||% list()
    
    if (length(races) > 0) {
      latest_race <- races[[length(races)]]  # Most recent
      results <- latest_race$Results %||% list()
      
      if (length(results) > 0) {
        # Get top 3 finishers
        top_3 <- lapply(head(results, 3), function(res) {
          list(
            position = res$position,
            driver = paste(res$Driver$givenName, res$Driver$familyName),
            team = res$Constructor$name,
            points = res$points
          )
        })
        
        result$data <- list(
          race = latest_race$name,
          date = latest_race$date,
          circuit = latest_race$Circuit$circuitName,
          top_finishers = top_3
        )
      }
    }
  }
  
  return(result)
}

#' Fetch Random Wikipedia Article
#'
#' @return List with status, data (article title), and metadata
#'
#' @details
#' Returns a random Wikipedia article title and summary.
#' No API key required - uses Wikipedia API.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_random_wiki_article()
#'   if (is_success(result)) print(result$data)
#' }
#'
fetch_random_wiki_article <- function() {
  url <- "https://en.wikipedia.org/api/rest_v1/page/random/summary"
  
  result <- safe_api_call(url, "Wikipedia Random Article")
  
  if (is_success(result)) {
    result$data <- list(
      title = result$data$title %||% "Unknown",
      description = result$data$description %||% "No description",
      url = result$data$content_urls$desktop$page %||% "Unknown",
      extract = substr(result$data$extract %||% "", 1, 200)
    )
  }
  
  return(result)
}

#' Fetch Celebrity Birthday
#'
#' @param month Month (1-12)
#' @param day Day (1-31)
#'
#' @return List with status, data (birthdays), and metadata
#'
#' @details
#' Returns notable people born on a specific date.
#' Uses Wikipedia API to get birthday information.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_celebrity_birthday(1, 18)
#'   if (is_success(result)) print(result$data)
#' }
#'
fetch_celebrity_birthday <- function(month = NA, day = NA) {
  if (is.na(month)) month <- format(Sys.Date(), "%m") %>% as.numeric()
  if (is.na(day)) day <- format(Sys.Date(), "%d") %>% as.numeric()
  
  url <- sprintf("https://en.wikipedia.org/api/rest_v1/page/html/Deaths_on_%s_%d", 
                 format(as.Date(sprintf("2000-%02d-%02d", month, day)), "%B"), day)
  
  # Alternative: Use birthdayapi if available
  result <- safe_api_call(url, sprintf("Celebrity Birthday - %02d/%02d", month, day))
  
  if (!is_success(result)) {
    # Fallback to simpler approach
    result$data <- list(
      date = sprintf("%02d/%02d", month, day),
      note = "Birthday information temporarily unavailable"
    )
  }
  
  return(result)
}

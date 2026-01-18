# NBA Live Scores API
# Fetches NBA game scores and standings (no auth required)

#' Fetch NBA Live Scores
#' 
#' @return List with status, data, timestamp, source, and error (if any)
#' @export
fetch_nba_scores <- function() {
  url <- "https://site.api.espn.com/apis/site/v2/sports/basketball/nba/scoreboard"
  
  result <- safe_api_call(url, "NBA Scores")
  
  if (is_success(result)) {
    data <- result$data
    
    if (is.null(data$events) || length(data$events) == 0) {
      # No games today
      result$data <- list(
        has_games = FALSE,
        message = "No NBA games scheduled today",
        season = if(!is.null(data$season$type)) data$season$type else "Unknown"
      )
    } else {
      # Extract game information safely
      games_df <- tryCatch({
        do.call(rbind, lapply(data$events, function(game) {
          comp <- game$competitions[[1]]
          
          # Handle competitors structure
          comps <- comp$competitors
          # If comps is a list of lists, or something else, ensure we get to the data
          if(is.list(comps) && !is.data.frame(comps)) comps <- comps[[1]] # Try flattening
          
          # If it's still not a dataframe, try to coerce or handle error
          if(!is.data.frame(comps)) {
             # Skip this game or return mock
             return(NULL)
          }

          home_row <- comps[comps$homeAway == "home",]
          away_row <- comps[comps$homeAway == "away",]
          
          data.frame(
            matchup = sprintf("%s @ %s", away_row$team$displayName, home_row$team$displayName),
            score = sprintf("%s - %s", away_row$score, home_row$score),
            status = comp$status$type$description,
            stringsAsFactors = FALSE
          )
        }))
      }, error = function(e) {
         # Log warning if needed
         return(NULL)
      })
      
      if(!is.null(games_df)) {
        result$data <- list(
          has_games = TRUE,
          games = games_df,
          season = if(!is.null(data$season$type)) data$season$type else "Unknown"
        )
      } else {
        result$data <- list(has_games = TRUE, message = "Games date found but failed to parse details")
      }
    }
  }
  
  return(result)
}

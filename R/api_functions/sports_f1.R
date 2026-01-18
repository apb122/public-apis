# Formula 1 Standings API
# Fetches F1 driver and constructor standings (no auth required)

#' Fetch Formula 1 Championship Standings
#' 
#' @param season Year (default: "current")
#' @return List with status, data, timestamp, source, and error (if any)
#' @export
fetch_f1_standings <- function(season = "current") {
  url <- sprintf("http://ergast.com/api/f1/%s/driverStandings.json", season)
  result <- safe_api_call(url, "Formula 1")
  
  if (is_success(result)) {
    data <- result$data
    
    standings_data <- if(!is.null(data$MRData$StandingsTable$StandingsLists)) data$MRData$StandingsTable$StandingsLists else NULL
    
    if (is.null(standings_data) || length(standings_data) == 0) {
      return(new_api_result("error", NULL, "Formula 1", error = "No standings data available"))
    }
    
    # Check structure (list vs dataframe). jsonlite simplification can vary.
    # Usually StandingsLists is a list of dataframes or a dataframe itself.
    
    # Safe extraction logic
    tryCatch({
        # If StandingsLists is a list of length 1 containing a DF
        drivers_container <- if(is.data.frame(standings_data)) standings_data else standings_data[[1]]
        
        # Now access DriverStandings
        drivers <- drivers_container$DriverStandings
        if(is.list(drivers) && !is.data.frame(drivers)) drivers <- drivers[[1]]
        
        if(!is.null(drivers) && is.data.frame(drivers)) {
            standings_df <- data.frame(
              position = as.integer(drivers$position),
              driver = sprintf("%s %s", drivers$Driver$givenName, drivers$Driver$familyName),
              team = if(!is.null(drivers$Constructors)) sapply(drivers$Constructors, function(x) x$name[1]) else "Unknown",
              points = as.numeric(drivers$points),
              wins = as.integer(drivers$wins),
              stringsAsFactors = FALSE
            )
            
            # Get top 10
            standings_df <- head(standings_df, 10)
            
            result$data <- list(
                season = if(!is.null(standings_data$season)) standings_data$season else season,
                round = if(!is.null(standings_data$round)) standings_data$round else "?",
                standings = standings_df
            )
        } else {
             result$data <- list(message = "Standings format unexpected")
        }
    }, error = function(e) {
        result$status <- "error"
        result$error <- paste("Parsing error:", e$message)
    })
  }
  
  return(result)
}

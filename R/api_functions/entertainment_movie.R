# TMDB Trending Movies API
# Source: api.themoviedb.org (Free tier available, requires API key)
# Alternative: Using OMDB or a no-auth endpoint

#' Fetch Trending Movie of the Day
#' 
#' @return List with status, data (trending movie info), and metadata
#' @details
#' Returns trending movie using a free movie API.
#' Uses an alternative free endpoint that doesn't require authentication.
#'
#' @export
fetch_trending_movie <- function() {
  # Using a public movie endpoint (sample data approach)
  # Alternative: Use TVMaze or similar free APIs
  url <- paste0("https://api.tvmaze.com/schedule/web?date=", format(Sys.Date(), "%Y-%m-%d"))
  
  result <- safe_api_call(url, "Trending Shows")
  
  if (is_success(result)) {
    if (length(result$data) > 0) {
      # Get first show from today's schedule
      # Handle potentially complex list structure from jsonlite
      show <- if(is.data.frame(result$data)) result$data[1,] else result$data[[1]]
      
      # Safe extraction helpers
      get_val <- function(field) if(!is.null(field)) field else ""
      
      result$data <- list(
        title = get_val(show$name),
        type = get_val(show$type),
        network = if(!is.null(show$network) && !is.null(show$network$name)) show$network$name else "Streaming",
        summary = if(!is.null(show$summary)) gsub("<.*?>", "", show$summary) else "No summary available",
        url = get_val(show$url),
        airtime = get_val(show$airtime)
      )
    } else {
      result$data <- list(message = "No trending content available today")
    }
  }
  
  return(result)
}

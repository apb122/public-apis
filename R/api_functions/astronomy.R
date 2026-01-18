# NASA Astronomy Picture of the Day API
# Source: https://api.nasa.gov/

#' Fetch NASA Astronomy Picture of the Day
#' 
#' @param api_key NASA API key (default: DEMO_KEY for testing)
#' 
#' @return List with status, data (title, date, url, explanation), and metadata
#' 
#' @details
#' Returns the latest Astronomy Picture of the Day from NASA.
#' Note: DEMO_KEY has rate limits. For production, use a real API key.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_astronomy_daily()
#'   if (is_success(result)) {
#'     print(result$data$title)
#'   }
#' }
#'
fetch_astronomy_daily <- function(api_key = NULL) {
  if (is.null(api_key)) {
    api_key <- Sys.getenv("NASA_API_KEY", unset = "DEMO_KEY")
  }
  
  # Note: DEMO_KEY is rate-limited. If you get HTTP 429, get a free key at https://api.nasa.gov
  url <- sprintf(
    "https://api.nasa.gov/planetary/apod?api_key=%s",
    api_key
  )
  
  result <- safe_api_call(url, "NASA APOD")
  
  if (is_success(result)) {
    # Extract relevant fields
    result$data <- list(
      title = result$data$title,
      date = result$data$date,
      url = result$data$url,
      explanation = result$data$explanation,
      media_type = result$data$media_type,
      copyright = result$data$copyright
    )
  }
  
  return(result)
}

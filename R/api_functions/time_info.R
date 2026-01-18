# World Time API
# Source: https://worldtimeapi.org (No API key required)

#' Fetch Current Time and Timezone Information
#' 
#' @param timezone IANA timezone string (e.g., "America/New_York", "Europe/London")
#'
#' @return List with status, data (time, date, timezone info), and metadata
#'
#' @details
#' Returns current time, date, timezone offset, and other temporal information.
#' No API key required. Supports any IANA timezone.
#'
#' @examples
#' \dontrun{
#'   # New York time
#'   result <- fetch_current_time()
#'   
#'   # London time
#'   result <- fetch_current_time("Europe/London")
#'   
#'   # Tokyo time
#'   result <- fetch_current_time("Asia/Tokyo")
#' }
#'
fetch_current_time <- function(timezone = "America/New_York") {
  url <- sprintf("https://worldtimeapi.org/api/timezone/%s", timezone)
  
  result <- safe_api_call(url, sprintf("World Time - %s", timezone))
  
  if (is_success(result)) {
    # Extract relevant time information
    result$data <- list(
      timezone = result$data$timezone,
      datetime = result$data$datetime,
      utc_offset = result$data$utc_offset,
      utc_datetime = result$data$utc_datetime,
      week_number = result$data$week_number,
      day_of_year = result$data$day_of_year,
      is_dst = result$data$dst
    )
  }
  
  return(result)
}

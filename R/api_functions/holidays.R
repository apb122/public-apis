# Nager.Date Public Holidays API
# Source: https://date.nager.at (No API key required)

#' Fetch Public Holidays for a Country and Year
#' 
#' @param country_code ISO 3166-1 country code (default: "US")
#' @param year Year to fetch holidays for (default: current year)
#'
#' @return List with status, data (all holidays + today's holidays), and metadata
#'
#' @details
#' Returns all public holidays for specified country/year.
#' Also identifies if today is a holiday.
#' No API key required. Covers 200+ countries.
#'
#' @examples
#' \dontrun{
#'   # US holidays this year
#'   result <- fetch_todays_holidays()
#'   
#'   # UK holidays
#'   result <- fetch_todays_holidays("GB")
#'   
#'   # Japan holidays for 2025
#'   result <- fetch_todays_holidays("JP", 2025)
#' }
#'
fetch_todays_holidays <- function(country_code = "US", 
                                  year = as.numeric(format(Sys.Date(), "%Y"))) {
  url <- sprintf(
    "https://date.nager.at/api/v3/PublicHolidays/%s/%s",
    year, country_code
  )
  
  result <- safe_api_call(
    url, 
    sprintf("Holidays - %s (%s)", country_code, year)
  )
  
  if (is_success(result)) {
    # Get today's date for filtering
    today <- format(Sys.Date(), "%Y-%m-%d")
    
    # Filter for today's holidays - safely handle result structure
    todays_holidays <- tryCatch({
      if (is.list(result$data) && length(result$data) > 0) {
        # Check if result$data is a list of lists (holidays) or data.frame
        holidays_list <- if (is.data.frame(result$data)) {
          as.list(result$data)
        } else {
          result$data
        }
        
        # Filter for today
        Filter(function(h) {
          !is.null(h$date) && h$date == today
        }, holidays_list)
      } else {
        list()
      }
    }, error = function(e) {
      # If filtering fails, return empty list
      list()
    })
    
    # Create standardized return format
    result$data <- list(
      country_code = country_code,
      year = year,
      all_holidays = result$data,
      todays_holidays = todays_holidays,
      is_holiday_today = length(todays_holidays) > 0
    )
  }
  
  return(result)
}

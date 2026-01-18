# Open-Meteo Weather API
# Source: https://open-meteo.com (No API key required)

#' Fetch Current Weather Data
#' 
#' @param latitude Geographic latitude (default: 40.7128 for New York)
#' @param longitude Geographic longitude (default: -74.0060 for New York)
#' @param location_name Human-readable location name
#'
#' @return List with status, data (temperature, wind, humidity), and metadata
#'
#' @details
#' Returns current weather for specified coordinates using Open-Meteo API.
#' No API key required. High rate limits.
#'
#' @examples
#' \dontrun{
#'   # Weather for New York
#'   result <- fetch_current_weather()
#'   
#'   # Weather for London
#'   result <- fetch_current_weather(51.5074, -0.1278, "London")
#' }
#'
fetch_current_weather <- function(latitude = 40.7128, longitude = -74.0060,
                                  location_name = "New York") {
  url <- sprintf(
    "https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&current=temperature_2m,weather_code,wind_speed_10m,relative_humidity_2m,apparent_temperature&timezone=auto",
    latitude, longitude
  )
  
  result <- safe_api_call(url, sprintf("Weather - %s", location_name))
  
  if (is_success(result)) {
    # Extract and standardize current weather
    current <- result$data$current
    result$data <- list(
      location = location_name,
      latitude = latitude,
      longitude = longitude,
      temperature = current$temperature_2m,
      apparent_temperature = current$apparent_temperature,
      weather_code = current$weather_code,
      wind_speed = current$wind_speed_10m,
      humidity = current$relative_humidity_2m,
      time = result$data$current_units$time
    )
  }
  
  return(result)
}

# R Script: Fetch Current Information from Public APIs
# This script demonstrates how to fetch real-time data from various public APIs
# No authentication required for these endpoints

library(httr)
library(jsonlite)
library(dplyr)

# ============================================================================
# 1. FETCH ASTRONOMY PICTURE OF THE DAY (NASA)
# ============================================================================
fetch_astronomy_daily <- function() {
  cat("📡 Fetching Astronomy Picture of the Day...\n")
  
  url <- "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"
  
  tryCatch({
    response <- GET(url)
    
    if (status_code(response) == 200) {
      data <- fromJSON(content(response, as = "text"))
      
      cat("Title:", data$title, "\n")
      cat("Date:", data$date, "\n")
      cat("Explanation:", substr(data$explanation, 1, 150), "...\n")
      cat("URL:", data$url, "\n\n")
      
      return(data)
    } else {
      cat("Error: Status code", status_code(response), "\n\n")
      return(NULL)
    }
  }, error = function(e) {
    cat("Error fetching data:", e$message, "\n\n")
    return(NULL)
  })
}

# ============================================================================
# 2. FETCH CURRENT WEATHER DATA (Open-Meteo - No API Key Required)
# ============================================================================
fetch_current_weather <- function(latitude = 40.7128, longitude = -74.0060, 
                                  location_name = "New York") {
  cat("🌤️ Fetching Current Weather Data...\n")
  
  url <- sprintf(
    "https://api.open-meteo.com/v1/forecast?latitude=%f&longitude=%f&current=temperature_2m,weather_code,wind_speed_10m&timezone=auto",
    latitude, longitude
  )
  
  tryCatch({
    response <- GET(url)
    
    if (status_code(response) == 200) {
      data <- fromJSON(content(response, as = "text"))
      current <- data$current
      
      cat("Location:", location_name, "\n")
      cat("Temperature:", current$temperature_2m, "°C\n")
      cat("Weather Code:", current$weather_code, "\n")
      cat("Wind Speed:", current$wind_speed_10m, "km/h\n")
      cat("Time:", current$time, "\n\n")
      
      return(data)
    } else {
      cat("Error: Status code", status_code(response), "\n\n")
      return(NULL)
    }
  }, error = function(e) {
    cat("Error fetching weather:", e$message, "\n\n")
    return(NULL)
  })
}

# ============================================================================
# 3. FETCH CRYPTOCURRENCY PRICES (CoinGecko API - Free, No Key Required)
# ============================================================================
fetch_crypto_prices <- function() {
  cat("₿ Fetching Cryptocurrency Prices...\n")
  
  url <- paste0(
    "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,cardano",
    "&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true"
  )
  
  tryCatch({
    response <- GET(url)
    
    if (status_code(response) == 200) {
      data <- fromJSON(content(response, as = "text"))
      
      for (coin in names(data)) {
        cat(sprintf("\n%s:\n", toupper(coin)))
        cat(sprintf("  Price: $%s\n", data[[coin]]$usd))
        cat(sprintf("  Market Cap: $%s\n", data[[coin]]$usd_market_cap))
        cat(sprintf("  24h Volume: $%s\n", data[[coin]]$usd_24h_vol))
      }
      cat("\n\n")
      
      return(data)
    } else {
      cat("Error: Status code", status_code(response), "\n\n")
      return(NULL)
    }
  }, error = function(e) {
    cat("Error fetching crypto data:", e$message, "\n\n")
    return(NULL)
  })
}

# ============================================================================
# 4. FETCH CURRENT TIME & DATE INFO (World Time API)
# ============================================================================
fetch_current_time <- function(timezone = "America/New_York") {
  cat("⏰ Fetching Current Time Information...\n")
  
  url <- sprintf("https://worldtimeapi.org/api/timezone/%s", timezone)
  
  tryCatch({
    response <- GET(url)
    
    if (status_code(response) == 200) {
      data <- fromJSON(content(response, as = "text"))
      
      cat("Timezone:", data$timezone, "\n")
      cat("Current Time:", data$datetime, "\n")
      cat("UTC Offset:", data$utc_offset, "\n")
      cat("Week Number:", data$week_number, "\n\n")
      
      return(data)
    } else {
      cat("Error: Status code", status_code(response), "\n\n")
      return(NULL)
    }
  }, error = function(e) {
    cat("Error fetching time data:", e$message, "\n\n")
    return(NULL)
  })
}

# ============================================================================
# 5. FETCH TRENDING TOPICS (Generic JSON API Example)
# ============================================================================
fetch_random_facts <- function() {
  cat("💡 Fetching Random Facts...\n")
  
  url <- "https://uselessfacts.jsph.pl/random.json?language=en"
  
  tryCatch({
    response <- GET(url)
    
    if (status_code(response) == 200) {
      data <- fromJSON(content(response, as = "text"))
      
      cat("Fact:", data$text, "\n")
      cat("Source URL:", data$source_url, "\n\n")
      
      return(data)
    } else {
      cat("Error: Status code", status_code(response), "\n\n")
      return(NULL)
    }
  }, error = function(e) {
    cat("Error fetching facts:", e$message, "\n\n")
    return(NULL)
  })
}

# ============================================================================
# 6. FETCH PUBLIC HOLIDAYS (Nager.Date API)
# ============================================================================
fetch_todays_holidays <- function(country_code = "US", year = format(Sys.Date(), "%Y")) {
  cat("🎉 Fetching Today's Holidays...\n")
  
  url <- sprintf("https://date.nager.at/api/v3/PublicHolidays/%s/%s", year, country_code)
  
  tryCatch({
    response <- GET(url)
    
    if (status_code(response) == 200) {
      holidays <- fromJSON(content(response, as = "text"))
      
      # Get today's date
      today <- format(Sys.Date(), "%Y-%m-%d")
      
      # Filter for today
      todays_holidays <- Filter(function(h) h$date == today, holidays)
      
      if (length(todays_holidays) > 0) {
        cat("🎊 Today is a holiday!\n")
        for (holiday in todays_holidays) {
          cat(sprintf("  - %s\n", holiday$name))
        }
      } else {
        cat("No holidays today in", country_code, "\n")
      }
      cat("\n")
      
      return(holidays)
    } else {
      cat("Error: Status code", status_code(response), "\n\n")
      return(NULL)
    }
  }, error = function(e) {
    cat("Error fetching holidays:", e$message, "\n\n")
    return(NULL)
  })
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

cat("\n")
cat("════════════════════════════════════════════════════════════════\n")
cat("       CURRENT INFORMATION FETCH - ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("════════════════════════════════════════════════════════════════\n\n")

# Execute all fetches
apod <- fetch_astronomy_daily()
weather <- fetch_current_weather()
crypto <- fetch_crypto_prices()
time_info <- fetch_current_time()
facts <- fetch_random_facts()
holidays <- fetch_todays_holidays()

cat("════════════════════════════════════════════════════════════════\n")
cat("All data fetches completed!\n")
cat("════════════════════════════════════════════════════════════════\n")

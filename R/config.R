# Centralized Configuration
# All default settings and constants for the dashboard

CONFIG <- list(
  # API settings
  api = list(
  timeout = 8,             # Reduced from 10 seconds
  max_retries = 2,         # Reduced from 3 (was already 2, but confirm)
  cache_ttl = 900,
  parallel_workers = 6,    # Reduced from 8 to prevent worker deadlock
  user_agent = "CurrentInfoDashboard/1.0 (R project)"
),
  
  # Weather configuration
  weather = list(
    default_lat = 40.7128,   # New York
    default_lon = -74.0060,
    cities = list(
      new_york = list(lat = 40.7128, lon = -74.0060),
      london = list(lat = 51.5074, lon = -0.1278),
      tokyo = list(lat = 35.6762, lon = 139.6503)
    )
  ),
  
  # Cryptocurrency configuration
  crypto = list(
    default_coins = c("bitcoin", "ethereum", "cardano"),
    all_coins = c("bitcoin", "ethereum", "cardano", "solana", "ripple", "dogecoin")
  ),
  
  # Time zones
  timezones = list(
    new_york = "America/New_York",
    london = "Europe/London",
    tokyo = "Asia/Tokyo"
  ),
  
  # Holidays
  holidays = list(
    default_country = "US",
    year = format(Sys.Date(), "%Y")
  ),
  
  # News APIs
  news = list(
    hacker_news_count = 5,
    reddit_limit = 5,
    reddit_default_sub = "all"
  ),
  
  # Sports APIs (for upcoming phase)
  sports = list(
    nba_limit = 5,
    f1_current_season = TRUE
  ),
  
  # Paths
  paths = list(
    cache_dir = "cache",
    logs_dir = "logs",
    output_dir = "output",
    reports_dir = "reports"
  )
)

# Helper function to get config values
get_config <- function(...) {
  path <- list(...)
  result <- CONFIG
  for (key in path) {
    result <- result[[key]]
    if (is.null(result)) {
      stop(sprintf("Config path not found: %s", paste(path, collapse = ".")))
    }
  }
  result
}

# Export
if (!exists("CONFIG_LOADED")) {
  CONFIG_LOADED <- TRUE
}

# Visualization Functions for Current Information Dashboard
# This module creates interactive charts and gauges for the daily report

library(ggplot2)
library(plotly)
library(dplyr)
library(scales)

# ============================================================================
# CRYPTOCURRENCY VISUALIZATIONS
# ============================================================================

#' Create Interactive Crypto Price Chart
#'
#' @param crypto_data List of crypto data from fetch_crypto_prices()
#' @param title Chart title
#'
#' @return plotly chart object
#'
#' @details
#' Creates a plotly bar chart showing cryptocurrency prices with 24h change indicator.
#' Shows price in USD and 24h percentage change with color coding (green = up, red = down).
#'
#' @examples
#' \dontrun{
#'   result <- fetch_crypto_prices()
#'   if (is_success(result)) {
#'     plot_crypto_prices(result$data)
#'   }
#' }
#'
plot_crypto_prices <- function(crypto_data, title = "Cryptocurrency Prices (USD)") {
  # Transform data for plotting
  crypto_df <- do.call(rbind, lapply(names(crypto_data), function(coin) {
    data.frame(
      Coin = toupper(coin),
      Price = crypto_data[[coin]]$price,
      Change24h = crypto_data[[coin]]$change_24h,
      MarketCap = crypto_data[[coin]]$market_cap,
      Volume24h = crypto_data[[coin]]$volume_24h
    )
  }))
  
  # Determine color based on 24h change
  crypto_df$Color <- ifelse(crypto_df$Change24h >= 0, "Positive", "Negative")
  
  # Create plotly bar chart
  plot_ly(
    data = crypto_df,
    x = ~Coin,
    y = ~Price,
    type = "bar",
    marker = list(
      color = ~Change24h,
      colorscale = "RdYlGn",
      line = list(color = "rgba(255, 255, 255, 1)", width = 2),
      colorbar = list(
        title = "24h Change %",
        thickness = 15,
        len = 0.7
      )
    ),
    text = ~paste0(
      "<b>", Coin, "</b><br>",
      "Price: $", format(Price, big.mark = ",", digits = 0), "<br>",
      "24h Change: ", round(Change24h, 2), "%<br>",
      "Market Cap: $", format(MarketCap / 1e9, digits = 2), "B<br>",
      "24h Volume: $", format(Volume24h / 1e9, digits = 2), "B"
    ),
    hovertemplate = "%{text}<extra></extra>",
    showlegend = FALSE
  ) %>%
    layout(
      title = list(text = title, x = 0, xanchor = "left", font = list(size = 16, color = "#FFF")),
      xaxis = list(
        title = "",
        tickfont = list(color = "#FFF", size = 12),
        gridcolor = "rgba(255, 255, 255, 0.1)"
      ),
      yaxis = list(
        title = "Price (USD)",
        tickfont = list(color = "#FFF", size = 11),
        gridcolor = "rgba(255, 255, 255, 0.1)",
        type = "log"
      ),
      plot_bgcolor = "rgba(30, 30, 30, 1)",
      paper_bgcolor = "rgba(50, 50, 50, 1)",
      font = list(family = "Arial, sans-serif", color = "#FFF"),
      margin = list(l = 60, r = 60, t = 60, b = 60),
      hovermode = "closest"
    )
}

#' Create Crypto Comparison Card
#'
#' @param crypto_data List of crypto data
#' @return data.frame formatted for display
#'
#' @details
#' Creates a formatted table showing price, market cap, volume, and 24h change.
#' Includes emoji indicators for price direction.
#'
create_crypto_card <- function(crypto_data) {
  if (is.null(crypto_data) || length(crypto_data) == 0) {
    return(data.frame(
      Coin = "N/A",
      Price = "N/A",
      `24h Change` = "N/A",
      `Market Cap` = "N/A",
      check.names = FALSE
    ))
  }
  
  do.call(rbind, lapply(names(crypto_data), function(coin) {
    coin_data <- crypto_data[[coin]]
    
    # Check if coin_data has required fields
    if (is.null(coin_data) || is.null(coin_data$price)) {
      return(data.frame(
        Coin = toupper(coin),
        Price = "N/A",
        `24h Change` = "N/A",
        `Market Cap` = "N/A",
        check.names = FALSE
      ))
    }
    
    change <- coin_data$change_24h %||% 0
    indicator <- ifelse(change >= 0, "UP", "DOWN")

    data.frame(
      Coin = paste0(indicator, " ", toupper(coin)),
      Price = paste0("$", format(coin_data$price, big.mark = ",", scientific = FALSE, digits = 0)),
      `24h Change` = paste0(round(change, 2), "%"),
      `Market Cap` = paste0("$", format((coin_data$market_cap %||% 0) / 1e9, digits = 2), "B"),
      check.names = FALSE
    )
  }))
}

# ============================================================================
# WEATHER VISUALIZATIONS
# ============================================================================

#' Create Weather Gauge Visualization
#'
#' @param weather_data List with temperature, wind_speed, humidity
#' @param title Chart title
#'
#' @return plotly gauge chart object
#'
#' @details
#' Creates a plotly gauge showing current temperature with color scaling.
#' Blue (cold) → Green (comfortable) → Red (hot).
#'
#' @examples
#' \dontrun{
#'   result <- fetch_current_weather()
#'   if (is_success(result)) {
#'     plot_weather_gauge(result$data)
#'   }
#' }
#'
plot_weather_gauge <- function(weather_data, title = "Current Temperature") {
  temp <- weather_data$temperature
  
  # Determine color based on temperature
  color <- ifelse(temp < 0, "#0066FF",  # Cold (blue)
           ifelse(temp < 10, "#00CCFF", # Cool (cyan)
           ifelse(temp < 20, "#00FF00", # Comfortable (green)
           ifelse(temp < 30, "#FFAA00", # Warm (orange)
           "#FF0000"))))                 # Hot (red)
  
  plot_ly(
    type = "indicator",
    mode = "gauge+number+delta",
    value = temp,
    title = list(text = title, font = list(size = 16, color = "#FFF")),
    delta = list(
      reference = 15,
      increasing = list(color = "#FF4444"),
      decreasing = list(color = "#4444FF"),
      suffix = "° vs baseline"
    ),
    gauge = list(
      axis = list(
        range = list(-20, 40),
        tickcolor = "#FFF",
        tickfont = list(color = "#FFF")
      ),
      bar = list(color = color, thickness = 0.15),
      bgcolor = "rgba(30, 30, 30, 0.5)",
      borderwidth = 2,
      bordercolor = "#FFF",
      steps = list(
        list(range = list(-20, 0), color = "rgba(0, 102, 255, 0.2)"),
        list(range = list(0, 10), color = "rgba(0, 204, 255, 0.2)"),
        list(range = list(10, 20), color = "rgba(0, 255, 0, 0.2)"),
        list(range = list(20, 30), color = "rgba(255, 170, 0, 0.2)"),
        list(range = list(30, 40), color = "rgba(255, 0, 0, 0.2)")
      ),
      threshold = list(
        line = list(color = "#FFF", width = 4),
        thickness = 0.75,
        value = 35
      )
    ),
    number = list(font = list(size = 40, color = color))
  ) %>%
    layout(
      plot_bgcolor = "rgba(50, 50, 50, 1)",
      paper_bgcolor = "rgba(50, 50, 50, 1)",
      font = list(family = "Arial, sans-serif", color = "#FFF", size = 12),
      margin = list(l = 40, r = 40, t = 60, b = 40)
    )
}

#' Create Weather Conditions Card
#'
#' @param weather_data List with temperature, wind_speed, humidity, etc.
#' @return Formatted string with weather info
#'
#' @details
#' Creates a nicely formatted card with temperature, wind, humidity, and icons.
#'
create_weather_card <- function(weather_data) {
  temp <- weather_data$temperature
  wind <- weather_data$wind_speed
  humidity <- weather_data$humidity
  
  # Weather code to label mapping
  weather_label <- function(code) {
    switch(as.character(code),
      "0" = "Clear",
      "1" = "Mainly clear",
      "2" = "Partly cloudy",
      "3" = "Overcast",
      "45" = "Fog",
      "48" = "Fog (rime)",
      "51" = "Light drizzle",
      "53" = "Moderate drizzle",
      "61" = "Slight rain",
      "63" = "Moderate rain",
      "65" = "Heavy rain",
      "71" = "Slight snow",
      "73" = "Moderate snow",
      "75" = "Heavy snow",
      "80" = "Rain showers",
      "82" = "Heavy rain showers",
      "95" = "Thunderstorm",
      "Unknown"
    )
  }

  emoji <- weather_label(weather_data$weather_code)
  
  list(
    emoji = emoji,
    temperature = paste0(round(temp, 1), "°C"),
    apparent_temperature = paste0(round(weather_data$apparent_temperature, 1), "°C"),
    wind_speed = paste0(round(wind, 1), " km/h"),
    humidity = paste0(humidity, "%"),
    location = weather_data$location
  )
}

# ============================================================================
# TIME & TIMEZONE VISUALIZATIONS
# ============================================================================

#' Create World Clock Display
#'
#' @param time_data List of time objects for multiple timezones (ny, london, tokyo)
#'
#' @return plotly indicator charts showing current time in each timezone
#'
#' @details
#' Creates a visual world clock showing current time in 3 major cities.
#' Each displayed as an interactive indicator.
#'
#' @examples
#' \dontrun{
#'   all_data <- fetch_all_data()
#'   create_world_clock(all_data$time)
#' }
#'
create_world_clock <- function(time_data) {
  # Extract and format times
  ny_time <- as.POSIXct(time_data$new_york$data$datetime)
  london_time <- as.POSIXct(time_data$london$data$datetime)
  tokyo_time <- as.POSIXct(time_data$tokyo$data$datetime)
  
  # Create HTML display
  html_output <- paste0(
    "<div style='display: flex; justify-content: space-around; gap: 20px; margin: 20px 0;'>",
    
    # New York
    "<div style='flex: 1; padding: 20px; background: rgba(70, 130, 180, 0.2); border-radius: 10px; border: 2px solid #4682B4; text-align: center;'>",
    "<h3 style='margin: 0 0 10px 0; color: #64B5F6;'>New York</h3>",
    "<div style='font-size: 24px; font-weight: bold; color: #FFF;'>", format(ny_time, "%H:%M:%S"), "</div>",
    "<div style='font-size: 12px; color: #BBB; margin-top: 5px;'>", format(ny_time, "%Y-%m-%d"), "</div>",
    "<div style='font-size: 11px; color: #999; margin-top: 5px;'>America/New_York</div>",
    "</div>",
    
    # London
    "<div style='flex: 1; padding: 20px; background: rgba(200, 100, 100, 0.2); border-radius: 10px; border: 2px solid #C86464; text-align: center;'>",
    "<h3 style='margin: 0 0 10px 0; color: #FF8A80;'>London</h3>",
    "<div style='font-size: 24px; font-weight: bold; color: #FFF;'>", format(london_time, "%H:%M:%S"), "</div>",
    "<div style='font-size: 12px; color: #BBB; margin-top: 5px;'>", format(london_time, "%Y-%m-%d"), "</div>",
    "<div style='font-size: 11px; color: #999; margin-top: 5px;'>Europe/London</div>",
    "</div>",
    
    # Tokyo
    "<div style='flex: 1; padding: 20px; background: rgba(100, 150, 100, 0.2); border-radius: 10px; border: 2px solid #64B464; text-align: center;'>",
    "<h3 style='margin: 0 0 10px 0; color: #81C784;'>Tokyo</h3>",
    "<div style='font-size: 24px; font-weight: bold; color: #FFF;'>", format(tokyo_time, "%H:%M:%S"), "</div>",
    "<div style='font-size: 12px; color: #BBB; margin-top: 5px;'>", format(tokyo_time, "%Y-%m-%d"), "</div>",
    "<div style='font-size: 11px; color: #999; margin-top: 5px;'>Asia/Tokyo</div>",
    "</div>",
    
    "</div>"
  )
  
  return(html_output)
}

#' Create Simple World Clock Table
#'
#' @param time_data List of time objects
#' @return data.frame formatted for table display
#'
create_world_clock_table <- function(time_data) {
  ny_time <- as.POSIXct(time_data$new_york$data$datetime)
  london_time <- as.POSIXct(time_data$london$data$datetime)
  tokyo_time <- as.POSIXct(time_data$tokyo$data$datetime)
  
  data.frame(
    City = c("New York", "London", "Tokyo"),
    Timezone = c("America/New_York", "Europe/London", "Asia/Tokyo"),
    `Current Time` = c(
      format(ny_time, "%H:%M:%S"),
      format(london_time, "%H:%M:%S"),
      format(tokyo_time, "%H:%M:%S")
    ),
    Date = c(
      format(ny_time, "%Y-%m-%d"),
      format(london_time, "%Y-%m-%d"),
      format(tokyo_time, "%Y-%m-%d")
    ),
    `UTC Offset` = c(
      time_data$new_york$data$utc_offset,
      time_data$london$data$utc_offset,
      time_data$tokyo$data$utc_offset
    ),
    check.names = FALSE
  )
}

# ============================================================================
# UTILITY VISUALIZATION FUNCTIONS
# ============================================================================

#' Create Status Badge
#'
#' @param status String: "success" or "error"
#' @param label Label text
#'
#' @return HTML badge string
#'
create_status_badge <- function(status, label) {
  if (status == "success") {
    color <- "#4CAF50"
    prefix <- "SUCCESS"
  } else {
    color <- "#F44336"
    prefix <- "ERROR"
  }

  paste0(
    "<span style='display: inline-block; padding: 5px 10px; background-color: ", color,
    "; color: white; border-radius: 4px; font-size: 12px; margin: 2px;'>",
    prefix, ": ", label, "</span>"
  )
}

#' Animate Data Update Counter
#'
#' @param minutes Minutes since last update
#'
#' @return Character string showing time since update
#'
get_update_time_display <- function(minutes = 0) {
  if (minutes == 0) {
    "Just now"
  } else if (minutes < 60) {
    paste0(minutes, " minutes ago")
  } else {
    hours <- floor(minutes / 60)
    paste0(hours, " hour", ifelse(hours > 1, "s", ""), " ago")
  }
}

# ============================================================================
# NEWS & INFORMATION VISUALIZATIONS
# ============================================================================

#' Create Hacker News Stories Table
#'
#' @param hn_data Data frame from fetch_hacker_news()
#' @return Formatted data frame
create_hacker_news_table <- function(hn_data) {
  if (is.null(hn_data) || nrow(hn_data) == 0) {
    return(data.frame(Message = "No stories available"))
  }
  
  # Format for display
  hn_data %>%
    mutate(
      Story = sprintf("[%s](%s)", title, url),
      Points = sprintf("%d", score),
      Comments = sprintf("%d", comments)
    ) %>%
    select(Rank = rank, Story, Points, Comments, Author = author)
}

#' Create Reddit Posts Table
#'
#' @param reddit_data Data frame from fetch_reddit_top()
#' @return Formatted data frame
create_reddit_table <- function(reddit_data) {
  if (is.null(reddit_data) || nrow(reddit_data) == 0) {
    return(data.frame(Message = "No posts available"))
  }
  
  # Format for display
  reddit_data %>%
    mutate(
      Post = sprintf("[%s](%s)", title, url),
      Upvotes = sprintf("%d", score),
      Comments = sprintf("%d", comments),
      Community = sprintf("r/%s", subreddit)
    ) %>%
    select(Rank = rank, Post, Community, Upvotes, Comments)
}

#' Format Wikipedia Featured Article for Display
#'
#' @param wiki_data List from fetch_wikipedia_featured()
#' @return Formatted list for display
format_wikipedia_article <- function(wiki_data) {
  if (is.null(wiki_data)) {
    return(list(title = "Not available", extract = "", url = ""))
  }
  
  list(
    title = wiki_data$title,
    description = wiki_data$description,
    extract = substr(wiki_data$extract, 1, 500),  # First 500 chars
    url = wiki_data$url,
    thumbnail = wiki_data$thumbnail
  )
}

#' Format Quote for Display
#'
#' @param quote_data List from fetch_quote_of_day()
#' @return Formatted string
format_quote_display <- function(quote_data) {
  if (is.null(quote_data)) {
    return("No quote available")
  }
  
  sprintf('> **"%s"**\n>\n> — *%s*', quote_data$text, quote_data$author)
}

#' Format Word of the Day for Display
#'
#' @param word_data List from fetch_word_of_day()
#' @return Formatted data frame
format_word_display <- function(word_data) {
  if (is.null(word_data)) {
    return(data.frame(Word = "Not available", Definition = ""))
  }
  
  data.frame(
    Word = paste0("**", toupper(word_data$word), "**"),
    Pronunciation = word_data$phonetic,
    `Part of Speech` = word_data$part_of_speech,
    Definition = word_data$definition,
    check.names = FALSE
  )
}

# ============================================================================
# SPORTS & ENTERTAINMENT VISUALIZATIONS
# ============================================================================

#' Format NBA Games Table
#'
#' @param nba_data Data from fetch_nba_scores()
#' @return Formatted data frame or message
format_nba_games <- function(nba_data) {
  if (is.null(nba_data) || !nba_data$has_games) {
    return(data.frame(Message = "No NBA games scheduled today"))
  }
  
  nba_data$games
}

#' Format F1 Standings Table
#'
#' @param f1_data Data from fetch_f1_standings()
#' @return Formatted data frame
format_f1_standings <- function(f1_data) {
  if (is.null(f1_data) || is.null(f1_data$standings)) {
    return(data.frame(Message = "No F1 standings available"))
  }
  
  f1_data$standings %>%
    mutate(
      Position = sprintf("#%d", position),
      Driver = driver,
      Team = team,
      Points = sprintf("%.0f pts", points),
      Wins = sprintf("%d", wins)
    ) %>%
    select(Position, Driver, Team, Points, Wins)
}

#' Format TV Shows Table
#'
#' @param tv_data Data frame from fetch_trending_movie()
#' @return Formatted data frame
format_tv_shows <- function(tv_data) {
  if (is.null(tv_data) || nrow(tv_data) == 0) {
    return(data.frame(Message = "No TV shows available"))
  }
  
  tv_data %>%
    mutate(
      Show = sprintf("%s", show),
      Network = network,
      `Air Time` = time,
      Rating = ifelse(rating == "N/A", rating, sprintf("%s", rating))
    ) %>%
    select(Show, Network, `Air Time`, Rating)
}

#' Format Music Charts Table
#'
#' @param music_data List from fetch_music_charts()
#' @return Formatted data frame
format_music_charts <- function(music_data) {
  if (is.null(music_data) || is.null(music_data$charts)) {
    return(data.frame(Message = "No music charts available"))
  }
  
  music_data$charts %>%
    mutate(
      Rank = sprintf("#%d", rank),
      Track = sprintf("%s", track),
      Artist = artist,
      Price = price
    ) %>%
    select(Rank, Track, Artist, Price)
}

# ============================================================================
# EXPORT VISUALIZATION FUNCTIONS
# ============================================================================

if (!exists("VISUALIZATIONS_LOADED")) {
  VISUALIZATIONS_LOADED <- TRUE
}


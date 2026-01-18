# Spotify Top Charts API (Alternative: iTunes Charts)
# Fetches top music charts (no auth required)

#' Fetch Top Music Charts
#' 
#' @param limit Number of tracks to fetch (default: 10)
#' @param country Country code (default: "us")
#' @return List with status, data, timestamp, source, and error (if any)
#' @export
fetch_music_charts <- function(limit = 10, country = "us") {
  url <- sprintf("https://itunes.apple.com/%s/rss/topsongs/limit=%d/json", 
                 country, limit)
  
  result <- safe_api_call(url, "iTunes Charts")
  
  if (is_success(result)) {
    data <- result$data
    
    # Check if feed exists
    if (is.null(data$feed) || is.null(data$feed$entry)) {
        result$data <- list(message = "No chart data available")
    } else {
        entries <- data$feed$entry
        
        # Safe extraction of complex nested JSON keys (im:name, im:artist, etc.)
        # jsonlite behavior on these keys can be tricky (often dataframes with $label columns)
        
        # Helper to extract label safely
        extract_label <- function(item, key) {
           val <- item[[key]]
           if(is.list(val) || is.data.frame(val)) {
               if("label" %in% names(val)) return(val$label)
           }
           return("Unknown")
        }
        
        # If entries is a dataframe (common with jsonlite)
        if (is.data.frame(entries)) {
             charts_df <- data.frame(
                rank = 1:nrow(entries),
                track = if("im:name" %in% names(entries)) entries$`im:name`$label else rep("Unknown", nrow(entries)),
                artist = if("im:artist" %in% names(entries)) entries$`im:artist`$label else rep("Unknown", nrow(entries)),
                price = if("im:price" %in% names(entries)) entries$`im:price`$label else rep("N/A", nrow(entries)),
                stringsAsFactors = FALSE
             )
        } else {
             # If it's a list (rare but possible with simplifyVector = FALSE or uneven structure)
             charts_df <- data.frame(
                rank = 1:length(entries),
                track = sapply(entries, extract_label, key="im:name"),
                artist = sapply(entries, extract_label, key="im:artist"),
                price = sapply(entries, extract_label, key="im:price"),
                stringsAsFactors = FALSE
             )
        }

        # Handle Album separately as it's deeper
        # For simplicity, we skip complex album extraction or do it safely
        
        result$data <- list(
            country = toupper(country),
            updated = if(!is.null(data$feed$updated$label)) data$feed$updated$label else Sys.time(),
            charts = charts_df
        )
    }
  }
  
  return(result)
}

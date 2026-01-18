# Daily Quote API
# Fetches inspirational quote of the day (no auth required)

#' Fetch quote of the day
#' 
#' @return List with status, data, timestamp, source, and error (if any)
#' @export
fetch_quote_of_day <- function() {
  url <- "https://zenquotes.io/api/today"
  
  result <- safe_api_call(url, "ZenQuotes")
  
  if (is_success(result)) {
    data <- result$data
    if (length(data) == 0) {
      return(new_api_result("error", NULL, "ZenQuotes", error = "No quote found"))
    }
    
    # Extract quote data (API returns array, take first element)
    # Note: data might be a dataframe or list depending on jsonlite simplification
    if (is.data.frame(data)) {
        q_text <- if("q" %in% names(data)) data$q[1] else "No quote available"
        q_auth <- if("a" %in% names(data)) data$a[1] else "Unknown"
    } else {
        # List of lists
        item <- data[[1]]
        q_text <- if(!is.null(item$q)) item$q else "No quote available"
        q_auth <- if(!is.null(item$a)) item$a else "Unknown"
    }

    result$data <- list(
      text = q_text,
      author = q_auth,
      date = Sys.Date()
    )
  }
  
  return(result)
}

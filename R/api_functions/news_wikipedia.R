# Wikipedia Featured Article API
# Fetches today's featured article from Wikipedia (no auth required)

#' Fetch Wikipedia's featured article of the day
#' 
#' @return List with status, data, timestamp, source, and error (if any)
#' @export
fetch_wikipedia_featured <- function() {
  today <- format(Sys.Date(), "%Y/%m/%d")
  url <- sprintf("https://en.wikipedia.org/api/rest_v1/feed/featured/%s", today)
  
  result <- safe_api_call(url, "Wikipedia Featured")
  
  if (is_success(result)) {
    data <- result$data
    if (is.null(data$tfa)) {
      return(new_api_result("error", NULL, "Wikipedia", error = "No featured article found"))
    }
    
    article <- data$tfa
    result$data <- list(
      title = ifelse(is.null(article$title), "No title", article$title),
      description = ifelse(is.null(article$description), "", article$description),
      extract = ifelse(is.null(article$extract), "", article$extract),
      url = ifelse(is.null(article$content_urls$desktop$page), 
                   "https://en.wikipedia.org",
                   article$content_urls$desktop$page),
      thumbnail = ifelse(is.null(article$thumbnail$source), 
                        NA, 
                        article$thumbnail$source),
      date = Sys.Date()
    )
  }
  
  return(result)
}

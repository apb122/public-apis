# Hacker News Top Stories API
# Fetches top stories from Hacker News (no auth required)

#' Fetch top stories from Hacker News
#' 
#' @param top_n Number of top stories to fetch (default: 5)
#' @return List with status, data, timestamp, source, and error (if any)
#' @export
fetch_hacker_news <- function(top_n = 5) {
  res_ids <- safe_api_call("https://hacker-news.firebaseio.com/v0/topstories.json", "Hacker News IDs")
  
  if (!is_success(res_ids)) return(res_ids)
  
  story_ids <- res_ids$data
  stories <- list()
  
  # Fetch details for top N stories
  count <- 0
  for (i in 1:min(top_n, length(story_ids))) {
    story_id <- story_ids[i]
    url <- sprintf("https://hacker-news.firebaseio.com/v0/item/%d.json", story_id)
    
    res_item <- safe_api_call(url, sprintf("HN Story %d", story_id))
    
    if (is_success(res_item)) {
      s <- res_item$data
      count <- count + 1
      stories[[count]] <- list(
        rank = count,
        title = ifelse(is.null(s$title), "No title", s$title),
        url = ifelse(is.null(s$url), 
                    sprintf("https://news.ycombinator.com/item?id=%d", story_id),
                    s$url),
        score = ifelse(is.null(s$score), 0, s$score),
        author = ifelse(is.null(s$by), "unknown", s$by),
        time = ifelse(is.null(s$time), NA, 
                     as.POSIXct(s$time, origin = "1970-01-01")),
        comments = ifelse(is.null(s$descendants), 0, s$descendants)
      )
    }
  }
  
  stories_df <- do.call(rbind, lapply(stories, function(s) {
    data.frame(
      rank = s$rank,
      title = s$title,
      url = s$url,
      score = s$score,
      author = s$author,
      comments = s$comments,
      stringsAsFactors = FALSE
    )
  }))
  
  new_api_result("success", stories_df, "Hacker News")
}

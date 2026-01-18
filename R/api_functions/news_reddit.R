# Reddit Top Posts API
# Fetches trending posts from Reddit (no auth required)

#' Fetch top posts from Reddit
#' 
#' @param subreddit Subreddit name (default: "all")
#' @param limit Number of posts to fetch (default: 5)
#' @return List with status, data, timestamp, source, and error (if any)
#' @export
fetch_reddit_top <- function(subreddit = "all", limit = 5) {
  url <- sprintf("https://www.reddit.com/r/%s/top.json?limit=%d&t=day", subreddit, limit)
  
  result <- safe_api_call(url, sprintf("Reddit r/%s", subreddit))
  
  if (is_success(result)) {
    posts <- result$data$data$children$data
    
    if (is.null(posts) || nrow(posts) == 0) {
      return(new_api_result("error", NULL, "Reddit", error = "No posts found"))
    }
    
    posts_df <- data.frame(
      rank = 1:nrow(posts),
      title = posts$title,
      subreddit = posts$subreddit,
      author = posts$author,
      score = posts$score,
      comments = posts$num_comments,
      url = sprintf("https://reddit.com%s", posts$permalink),
      created = as.POSIXct(posts$created_utc, origin = "1970-01-01"),
      stringsAsFactors = FALSE
    )
    result$data <- posts_df
  }
  
  return(result)
}

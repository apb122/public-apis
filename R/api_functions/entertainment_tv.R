# Trending TV API
# Fetches trending TV shows from TVMaze (no auth required)

#' Fetch Trending TV Shows
#' 
#' @return List with status, data, timestamp, source, and error (if any)
#' @export
fetch_trending_tv <- function() {
  url <- "https://api.tvmaze.com/schedule?country=US&date="
  
  # Get today's date
  today <- format(Sys.Date(), "%Y-%m-%d")
  url <- paste0(url, today)
  
  result <- safe_api_call(url, "Trending TV")
  
  if (is_success(result)) {
    data <- result$data
    
    if (length(data) == 0) {
      result$data <- list(message = "No trending shows found")
    } else {
      # TVMaze API: array of episode objects.
      # jsonlite usually simplifies to a dataframe if consistent
      
      if(is.data.frame(data)) {
          # Take top 5
          shows <- head(data, 5)
          
          # Helper for nested extraction
          extract_network <- function(idx) {
              net <- shows$show$network[idx] # This is usually a list column or nested DF
              # If it's a list:
              if (is.list(net)) {
                  if (length(net) > 0 && !is.null(net[[1]]$name)) return(net[[1]]$name)
              }
              # If it's a DF row (from jsonlite flattening)
              if (is.data.frame(net)) {
                   if ("name" %in% names(net) && !is.na(net$name)) return(net$name)
              }
              return("Streaming") 
          }
          
          # Simplified extraction
          # Depending on jsonlite version, shows$show can be a dataframe.
          show_info <- if("show" %in% names(shows)) shows$show else NULL
          
          if (!is.null(show_info) && is.data.frame(show_info)) {
               network_names <- tryCatch({
                   sapply(1:nrow(shows), function(i) {
                       net <- show_info$network[[i]]
                       if(!is.null(net) && !is.null(net$name)) net$name else "Streaming"
                   })
               }, error = function(e) rep("Streaming", nrow(shows)))
               
               rating_avg <- tryCatch({
                   sapply(1:nrow(shows), function(i) {
                       r <- show_info$rating[[i]]
                       if(!is.null(r) && !is.null(r$average)) sprintf("%.1f", r$average) else "N/A"
                   })
               }, error = function(e) rep("N/A", nrow(shows)))

               shows_df <- data.frame(
                  show = show_info$name,
                  network = network_names,
                  time = if("airstamp" %in% names(shows)) format(as.POSIXct(shows$airstamp, format="%Y-%m-%dT%H:%M:%S", tz="UTC"), "%I:%M %p") else "TBA",
                  rating = rating_avg,
                  stringsAsFactors = FALSE
               )
               result$data <- shows_df
          } else {
             result$data <- list(message = "TV Data format unexpected")
          }
      } else {
          result$data <- list(message = "Data format complex, not parsed")
      }
    }
  }
  
  return(result)
}

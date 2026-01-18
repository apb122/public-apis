# Useless Facts API
# Source: https://uselessfacts.jsph.pl (No API key required)

#' Fetch a Random Fact
#' 
#' @param language Language code (default: "en" for English)
#'
#' @return List with status, data (fact text and source), and metadata
#'
#' @details
#' Returns a random useless fact. Good for daily dashboard interest.
#' No API key required. Fast and reliable.
#'
#' @examples
#' \dontrun{
#'   result <- fetch_random_facts()
#'   if (is_success(result)) {
#'     print(result$data$text)
#'   }
#' }
#'
fetch_random_facts <- function(language = "en") {
  url <- sprintf(
    "https://uselessfacts.jsph.pl/random.json?language=%s",
    language
  )
  
  result <- safe_api_call(url, "Random Facts")
  
  if (is_success(result)) {
    # Extract fact text and source
    result$data <- list(
      text = result$data$text,
      source_url = result$data$source_url,
      permalink = result$data$permalink
    )
  }
  
  return(result)
}

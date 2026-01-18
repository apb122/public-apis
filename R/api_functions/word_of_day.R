# Word of the Day API
# Fetches a random interesting word with definition (no auth required)

#' Fetch word of the day (random interesting word)
#' 
#' @return List with status, data, timestamp, source, and error (if any)
#' @export
fetch_word_of_day <- function() {
  # Get a random word
  word_url <- "https://random-word-api.herokuapp.com/word?number=1"
  result_word <- safe_api_call(word_url, "Random Word API")
  
  if (!is_success(result_word)) return(result_word)
  
  word_data <- result_word$data
  if (length(word_data) == 0) {
    return(new_api_result("error", NULL, "Random Word API", error = "No word found"))
  }
  
  word <- word_data[1]
  
  # Get definition from Dictionary API
  dict_url <- sprintf("https://api.dictionaryapi.dev/api/v2/entries/en/%s", word)
  res_dict <- safe_api_call(dict_url, "Dictionary API")
  
  definition <- "Definition not available"
  part_of_speech <- "unknown"
  phonetic <- ""
  
  if (is_success(res_dict)) {
    dict_data <- res_dict$data
    
    # Process complex dictionary structure
    # This assumes jsonlite structure
    if (length(dict_data) > 0 && !is.null(dict_data$meanings)) {
       # Note: data might be a dataframe if simplified, or list
       first_entry <- if(is.data.frame(dict_data)) dict_data[1,] else dict_data[[1]]
       
       if (!is.null(first_entry$meanings)) {
           meanings <- first_entry$meanings
           if (is.data.frame(meanings) || is.list(meanings)) {
               # Handle nested data frames (jsonlite)
               # This is tricky without seeing exact output. 
               # We'll try to follow original logic but safely.
               pos <- tryCatch(meanings$partOfSpeech[[1]], error=function(e) NULL)
               if(!is.null(pos)) part_of_speech <- pos
               
               defs <- tryCatch(meanings$definitions[[1]], error=function(e) NULL)
               if(!is.null(defs) && !is.null(defs$definition)) definition <- defs$definition[1]
           }
       }
       
       if (!is.null(first_entry$phonetic)) phonetic <- first_entry$phonetic
    }
  }
  
  result_word$data <- list(
    word = word,
    phonetic = phonetic,
    part_of_speech = part_of_speech,
    definition = definition,
    date = Sys.Date()
  )
  
  return(result_word)
}

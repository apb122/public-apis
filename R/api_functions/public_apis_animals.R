# Public APIs - Animals, Pets, and Wildlife
# Source: https://github.com/public-apis/public-apis

#' Fetch Random Cat Fact
#'
#' @return List with status, data (fact, length), and metadata
#'
fetch_cat_fact <- function() {
  url <- "https://catfact.ninja/fact"
  result <- safe_api_call(url, "Cat Fact")
  
  if (is_success(result)) {
    result$data <- list(
      fact = result$data$fact %||% "Unknown fact",
      length = result$data$length %||% 0
    )
  }
  return(result)
}

#' Fetch Random Dog Fact
#'
#' @return List with status, data (fact, length), and metadata
#'
fetch_dog_fact <- function() {
  url <- "https://dog-facts-api.herokuapp.com/api/v1/resources/dogs?number=1"
  result <- safe_api_call(url, "Dog Fact")
  
  if (is_success(result)) {
    facts <- result$data %||% list()
    if (length(facts) > 0 && is.list(facts[[1]])) {
      fact_text <- facts[[1]]$fact %||% "Unknown fact"
    } else {
      fact_text <- "Unknown fact"
    }
    result$data <- list(
      fact = fact_text
    )
  }
  return(result)
}

#' Fetch Random Duck Image/Fact
#'
#' @return List with status, data (image_url), and metadata
#'
fetch_random_duck <- function() {
  url <- "https://random-d.uk/api/random"
  result <- safe_api_call(url, "Random Duck")
  
  if (is_success(result)) {
    result$data <- list(
      url = result$data$url %||% "Unknown",
      message = result$data$message %||% "Duck image"
    )
  }
  return(result)
}

#' Fetch Random Fox Image
#'
#' @return List with status, data (image_url), and metadata
#'
fetch_random_fox <- function() {
  url <- "https://randomfox.ca/floof/"
  result <- safe_api_call(url, "Random Fox")
  
  if (is_success(result)) {
    result$data <- list(
      url = result$data$image %||% "Unknown"
    )
  }
  return(result)
}

#' Fetch Random Dog Image
#'
#' @return List with status, data (image_url), and metadata
#'
fetch_random_dog_image <- function() {
  url <- "https://random.dog/woof.json"
  result <- safe_api_call(url, "Random Dog Image")
  
  if (is_success(result)) {
    result$data <- list(
      url = result$data$url %||% "Unknown"
    )
  }
  return(result)
}

#' Fetch Meow Facts (Multiple Cat Facts)
#'
#' @return List with status, data (facts list), and metadata
#'
fetch_meow_facts <- function() {
  url <- "https://meowfacts.herokuapp.com/?count=3"
  result <- safe_api_call(url, "Meow Facts")
  
  if (is_success(result)) {
    facts <- result$data$data %||% list()
    result$data <- list(
      facts = if (length(facts) > 0) paste(facts, collapse = " | ") else "Unknown facts",
      count = length(facts)
    )
  }
  return(result)
}

#' Fetch HTTP Status Cat
#'
#' @param status_code HTTP status code (e.g., 200, 404, 500)
#'
#' @return List with status, data (image_url), and metadata
#'
fetch_http_cat <- function(status_code = 200) {
  url <- sprintf("https://http.cat/%d", status_code)
  result <- safe_api_call(url, "HTTP Status Cat")
  
  if (is_success(result)) {
    result$data <- list(
      status = status_code,
      url = url,
      message = paste("Cat for HTTP", status_code)
    )
  }
  return(result)
}

#' Fetch HTTP Status Dog
#'
#' @param status_code HTTP status code (e.g., 200, 404, 500)
#'
#' @return List with status, data (image_url), and metadata
#'
fetch_http_dog <- function(status_code = 200) {
  url <- sprintf("https://http.dog/%d.jpg", status_code)
  result <- safe_api_call(url, "HTTP Status Dog")
  
  if (is_success(result)) {
    result$data <- list(
      status = status_code,
      url = url,
      message = paste("Dog for HTTP", status_code)
    )
  }
  return(result)
}

#' Fetch Random Shibe (Shiba Inu, Cat, or Bird)
#'
#' @param type Animal type: "shibes", "cats", "birds"
#' @param count Number of images (default 1)
#'
#' @return List with status, data (images list), and metadata
#'
fetch_random_shibe <- function(type = "shibes", count = 1) {
  url <- sprintf("https://shibe.online/api/%s?count=%d", type, count)
  result <- safe_api_call(url, paste("Random Shibe -", type))
  
  if (is_success(result)) {
    images <- result$data %||% list()
    result$data <- list(
      images = if (length(images) > 0) images else list("Unknown"),
      type = type,
      count = length(images)
    )
  }
  return(result)
}

#' Fetch Placeholder Dog Image
#'
#' @param width Image width (default 200)
#' @param height Image height (default 200)
#'
#' @return List with status, data (image_url), and metadata
#'
fetch_placeholder_dog <- function(width = 200, height = 200) {
  url <- sprintf("https://place.dog/%d/%d", width, height)
  result <- safe_api_call(url, "Placeholder Dog Image")
  
  if (is_success(result)) {
    result$data <- list(
      url = url,
      width = width,
      height = height
    )
  }
  return(result)
}

#' Fetch Placeholder Cat Image
#'
#' @param width Image width (default 200)
#' @param height Image height (default 200)
#'
#' @return List with status, data (image_url), and metadata
#'
fetch_placeholder_cat <- function(width = 200, height = 200) {
  url <- sprintf("https://placekitten.com/%d/%d", width, height)
  result <- safe_api_call(url, "Placeholder Cat Image")
  
  if (is_success(result)) {
    result$data <- list(
      url = url,
      width = width,
      height = height
    )
  }
  return(result)
}

#' Fetch Placeholder Bear Image
#'
#' @param width Image width (default 200)
#' @param height Image height (default 200)
#'
#' @return List with status, data (image_url), and metadata
#'
fetch_placeholder_bear <- function(width = 200, height = 200) {
  url <- sprintf("https://placebear.com/%d/%d", width, height)
  result <- safe_api_call(url, "Placeholder Bear Image")
  
  if (is_success(result)) {
    result$data <- list(
      url = url,
      width = width,
      height = height
    )
  }
  return(result)
}

#' Fetch Zoo Animal Fact
#'
#' @return List with status, data (animal, fact, image_url), and metadata
#'
fetch_zoo_animal <- function() {
  url <- "https://zoo-animal-api.herokuapp.com/animals/rand"
  result <- safe_api_call(url, "Zoo Animal Fact")
  
  if (is_success(result)) {
    result$data <- list(
      animal = result$data$name %||% "Unknown",
      fact = result$data$diet %||% "Unknown diet",
      scientific = result$data$latin_name %||% "Unknown"
    )
  }
  return(result)
}

# Public APIs - Games, Comics, and Trivia
# Source: https://github.com/public-apis/public-apis

#' Fetch Random Trivia Question
#'
#' @param difficulty Difficulty: "easy", "medium", "hard"
#' @param category Category ID (optional, numeric)
#'
#' @return List with status, data (question, correct_answer, incorrect_answers), and metadata
#'
fetch_trivia_question <- function(difficulty = "medium", category = NULL) {
  url <- "https://opentdb.com/api.php?amount=1"
  if (!is.null(difficulty) && difficulty != "") {
    url <- paste0(url, "&difficulty=", difficulty)
  }
  if (!is.null(category)) {
    url <- paste0(url, "&category=", category)
  }
  
  result <- safe_api_call(url, "Trivia Question")
  
  if (is_success(result)) {
    results <- result$data$results %||% list()
    if (length(results) > 0 && is.list(results[[1]])) {
      q <- results[[1]]
      result$data <- list(
        question = q$question %||% "Unknown",
        correct_answer = q$correct_answer %||% "Unknown",
        incorrect_answers = q$incorrect_answers %||% list(),
        difficulty = q$difficulty %||% "Unknown"
      )
    }
  }
  return(result)
}

#' Fetch Pokemon Information
#'
#' @param name_or_id Pokemon name or ID
#'
#' @return List with status, data (name, id, height, weight, types), and metadata
#'
fetch_pokemon <- function(name_or_id = "pikachu") {
  url <- sprintf("https://pokeapi.co/api/v2/pokemon/%s", tolower(name_or_id))
  result <- safe_api_call(url, "Pokemon Info")
  
  if (is_success(result)) {
    types <- result$data$types %||% list()
    type_names <- sapply(types, function(x) x$type$name %||% "Unknown")
    
    result$data <- list(
      name = result$data$name %||% "Unknown",
      id = result$data$id %||% 0,
      height = result$data$height %||% 0,
      weight = result$data$weight %||% 0,
      types = paste(type_names, collapse = ", "),
      image = result$data$sprites$front_default %||% "Unknown"
    )
  }
  return(result)
}

#' Fetch Magic The Gathering Card
#'
#' @param query Search query (card name, etc.)
#'
#' @return List with status, data (name, type, text, image_url), and metadata
#'
fetch_mtg_card <- function(query = "Black Lotus") {
  url <- sprintf("https://api.scryfall.com/cards/search?q=%s&unique=cards", urltools::url_encode(query))
  result <- safe_api_call(url, "MTG Card")
  
  if (is_success(result)) {
    cards <- result$data$data %||% list()
    if (length(cards) > 0 && is.list(cards[[1]])) {
      card <- cards[[1]]
      result$data <- list(
        name = card$name %||% "Unknown",
        type = card$type_line %||% "Unknown",
        text = substr(card$oracle_text %||% "No text", 1, 200),
        image_url = card$image_uris$normal %||% "Unknown",
        mana_cost = card$mana_cost %||% "0"
      )
    }
  }
  return(result)
}

#' Fetch D&D Spell Information
#'
#' @param spell_name Spell name
#'
#' @return List with status, data (name, level, school, description), and metadata
#'
fetch_dnd_spell <- function(spell_name = "fireball") {
  # Using D&D 5e API
  url <- sprintf("https://www.dnd5eapi.co/api/spells/%s", tolower(gsub(" ", "-", spell_name)))
  result <- safe_api_call(url, "D&D Spell")
  
  if (is_success(result)) {
    result$data <- list(
      name = result$data$name %||% "Unknown",
      level = result$data$level %||% 0,
      school = result$data$school$name %||% "Unknown",
      description = substr(paste(result$data$desc %||% list(), collapse = " "), 1, 300),
      casting_time = result$data$casting_time %||% "Unknown"
    )
  }
  return(result)
}

#' Fetch D&D Monster Information
#'
#' @param monster_name Monster name
#'
#' @return List with status, data (name, cr, alignment, size, type), and metadata
#'
fetch_dnd_monster <- function(monster_name = "dragon") {
  url <- sprintf("https://www.dnd5eapi.co/api/monsters/%s", tolower(gsub(" ", "-", monster_name)))
  result <- safe_api_call(url, "D&D Monster")
  
  if (is_success(result)) {
    result$data <- list(
      name = result$data$name %||% "Unknown",
      cr = result$data$challenge_rating %||% 0,
      alignment = result$data$alignment %||% "Unknown",
      size = result$data$size %||% "Unknown",
      type = result$data$type %||% "Unknown",
      hp = result$data$hit_points %||% 0
    )
  }
  return(result)
}

#' Fetch Star Wars Information
#'
#' @param resource Resource type: "people", "planets", "starships"
#' @param id Resource ID
#'
#' @return List with status, data (various depending on resource), and metadata
#'
fetch_star_wars <- function(resource = "people", id = 1) {
  url <- sprintf("https://swapi.dev/api/%s/%d/", resource, id)
  result <- safe_api_call(url, "Star Wars")
  
  if (is_success(result)) {
    result$data <- list(
      name = result$data$name %||% "Unknown",
      resource_type = resource,
      url = result$data$url %||% "Unknown",
      created = result$data$created %||% "Unknown"
    )
  }
  return(result)
}

#' Fetch Random XKCD Comic
#'
#' @return List with status, data (title, comic_url, alt_text), and metadata
#'
fetch_xkcd_comic <- function() {
  url <- "https://xkcd.com/info.0.json"
  result <- safe_api_call(url, "XKCD Comic")
  
  if (is_success(result)) {
    result$data <- list(
      title = result$data$title %||% "Unknown",
      comic_url = result$data$img %||% "Unknown",
      alt_text = substr(result$data$alt %||% "No alt text", 1, 200),
      num = result$data$num %||% 0
    )
  }
  return(result)
}

#' Fetch Yu-Gi-Oh Card
#'
#' @param card_name Card name
#'
#' @return List with status, data (name, type, description, image_url), and metadata
#'
fetch_yugioh_card <- function(card_name = "Blue Eyes White Dragon") {
  url <- sprintf("https://db.ygoprodeck.com/api/v7/cardinfo.php?name=%s", urltools::url_encode(card_name))
  result <- safe_api_call(url, "Yu-Gi-Oh Card")
  
  if (is_success(result)) {
    data <- result$data$data %||% list()
    if (length(data) > 0 && is.list(data[[1]])) {
      card <- data[[1]]
      result$data <- list(
        name = card$name %||% "Unknown",
        type = card$type %||% "Unknown",
        desc = substr(card$desc %||% "No description", 1, 200),
        image_url = card$card_images[[1]]$image_url %||% "Unknown",
        atk = card$atk %||% "N/A",
        def = card$def %||% "N/A"
      )
    }
  }
  return(result)
}

#' Fetch Chess.com Game Random
#'
#' @return List with status, data (game info), and metadata
#'
fetch_chess_game <- function() {
  url <- "https://api.chess.com/pub/streamers"
  result <- safe_api_call(url, "Chess Game")
  
  if (is_success(result)) {
    streamers <- result$data$streamers %||% list()
    if (length(streamers) > 0) {
      streamer <- streamers[[1]]
      result$data <- list(
        user_id = streamer$user_id %||% "Unknown",
        username = streamer$username %||% "Unknown",
        title = streamer$title %||% "N/A",
        url = streamer$url %||% "Unknown"
      )
    }
  }
  return(result)
}

#' Fetch Studio Ghibli Film
#'
#' @param film_id Film ID (optional)
#'
#' @return List with status, data (title, director, year, description), and metadata
#'
fetch_ghibli_film <- function(film_id = NULL) {
  if (is.null(film_id)) {
    url <- "https://ghibliapi.herokuapp.com/films"
  } else {
    url <- sprintf("https://ghibliapi.herokuapp.com/films/%s", film_id)
  }
  
  result <- safe_api_call(url, "Studio Ghibli Film")
  
  if (is_success(result)) {
    if (is.null(film_id) && is.list(result$data)) {
      films <- result$data
      if (length(films) > 0 && is.list(films[[1]])) {
        film <- films[[1]]
      } else {
        film <- list()
      }
    } else {
      film <- result$data
    }
    
    result$data <- list(
      title = film$title %||% "Unknown",
      director = film$director %||% "Unknown",
      release_date = film$release_date %||% "Unknown",
      description = substr(film$description %||% "No description", 1, 200)
    )
  }
  return(result)
}

#' Fetch Digimon Information
#'
#' @param digimon_name Digimon name
#'
#' @return List with status, data (name, level, type), and metadata
#'
fetch_digimon <- function(digimon_name = "agumon") {
  url <- sprintf("https://www.digimonapi.com/api/digimon/%s", tolower(digimon_name))
  result <- safe_api_call(url, "Digimon Info")
  
  if (is_success(result)) {
    result$data <- list(
      name = result$data$name %||% "Unknown",
      level = result$data$level %||% list() %>% paste(collapse = ", "),
      type = result$data$type %||% list() %>% paste(collapse = ", "),
      image = result$data$image %||% "Unknown"
    )
  }
  return(result)
}

#' Fetch Jeopardy Question
#'
#' @return List with status, data (question, answer, category, value), and metadata
#'
fetch_jeopardy_question <- function() {
  url <- "https://jeopardyapi.com/api/random"
  result <- safe_api_call(url, "Jeopardy Question")
  
  if (is_success(result)) {
    result$data <- list(
      question = result$data$question %||% "Unknown",
      answer = result$data$answer %||% "Unknown",
      category = result$data$category$title %||% "Unknown",
      value = result$data$value %||% 0
    )
  }
  return(result)
}

library(here)
library(furrr)
library(memoise)
library(cachem)
library(logger)

# Source core modules using here() for robust path resolution
source(here("R", "utils.R"))
source(here("R", "config.R"))

# Source all API function modules
source(here("R", "api_functions", "astronomy.R"))
source(here("R", "api_functions", "weather.R"))
source(here("R", "api_functions", "crypto.R"))
source(here("R", "api_functions", "time_info.R"))
source(here("R", "api_functions", "facts.R"))
source(here("R", "api_functions", "holidays.R"))

# News & Information APIs
source(here("R", "api_functions", "news_hn.R"))
source(here("R", "api_functions", "news_reddit.R"))
source(here("R", "api_functions", "news_wikipedia.R"))
source(here("R", "api_functions", "quotes.R"))
source(here("R", "api_functions", "word_of_day.R"))

# Sports & Entertainment APIs
source(here("R", "api_functions", "sports_nba.R"))
source(here("R", "api_functions", "sports_f1.R"))
source(here("R", "api_functions", "entertainment_movie.R"))
source(here("R", "api_functions", "entertainment_tv.R"))
source(here("R", "api_functions", "entertainment_music.R"))

# Public APIs from GitHub public-apis list (Comprehensive Implementation)
source(here("R", "api_functions", "public_apis_entertainment_quotes.R"))
source(here("R", "api_functions", "public_apis_animals.R"))
source(here("R", "api_functions", "public_apis_games.R"))
source(here("R", "api_functions", "github_public_apis.R"))
source(here("R", "api_functions", "github_public_apis_extended.R"))

#' Fetch All Current Information in One Call
#' 
#' Aggregates data from all 6 API sources:
#' - Astronomy (NASA APOD)
#' - Weather (Open-Meteo)
#' - Cryptocurrency (CoinGecko)
#' - Time/Timezone (World Time API)
#' - Random Facts (Useless Facts)
#' - Holidays (Nager.Date)
#'
#' @param timestamp Optional timestamp override (default: Sys.time())
#' @param refresh Logical, whether to force refresh of cached data (default: TRUE)
#'
#' @return List with all data and status information
#'
#' @details
#' Returns a unified data structure containing:
#' - astronomy: Picture, title, date, explanation
#' - weather: Temperature, wind, humidity for major cities
#' - crypto: Prices, market cap, volume for major coins
#' - time: Current time in multiple timezones
#' - facts: Random fact of the day
#' - holidays: Today's holidays (US, customizable)
#' - status: Overall fetch status and timestamp
#'
#' @examples
#' \dontrun{
#'   # Fetch all data
#'   all_data <- fetch_all_data()
#'   
#'   # Access individual components
#'   print(all_data$astronomy$data$title)
#'   print(all_data$weather$data$temperature)
#'   print(all_data$crypto$data$bitcoin$price)
#' }
#'
fetch_all_data <- function(timestamp = Sys.time(), refresh = TRUE) {
  cat("\n")
  cat("===============================================================\n")
  cat("FETCHING ALL CURRENT DATA\n")
  cat("Started: ", format(timestamp, "%Y-%m-%d %H:%M:%S"), "\n")
  cat("===============================================================\n\n")

  # Logging setup
  log_threshold(INFO)
  dir.create(here("logs"), showWarnings = FALSE, recursive = TRUE)
  log_appender(appender_tee(here("logs", "api.log")))

  # Parallel execution setup with safe fallback for Windows
  workers <- tryCatch(CONFIG$api$parallel_workers, error = function(...) 4)
  old_plan <- future::plan()
  on.exit({
    try(future::plan(old_plan), silent = TRUE)
  }, add = TRUE)

  if (identical(Sys.getenv("CID_SEQUENTIAL"), "1") || workers <= 1) {
    future::plan(future::sequential)
  } else {
    tryCatch({
      future::plan(future::multisession, workers = workers)
    }, error = function(e) {
      message("Parallel plan failed (", e$message, "); falling back to sequential")
      future::plan(future::sequential)
    })
  }

  # Optional caching for rate-limited APIs
  cache_ttl <- tryCatch(CONFIG$api$cache_ttl, error = function(...) 900)
  mem_cache <- cachem::cache_mem(max_age = cache_ttl)

  astronomy_cached <- memoise(fetch_astronomy_daily, cache = mem_cache)
  crypto_cached <- memoise(fetch_crypto_prices, cache = mem_cache)
  wiki_cached <- memoise(fetch_wikipedia_featured, cache = mem_cache)

  if (isTRUE(refresh)) {
    forget(astronomy_cached); forget(crypto_cached); forget(wiki_cached)
  }

  # Define all API calls with source names
  api_calls <- list(
    astronomy = list(fn = \() astronomy_cached(), name = "NASA APOD"),
    weather = list(fn = \() fetch_current_weather(), name = "Weather"),
    crypto = list(fn = \() crypto_cached(), name = "Cryptocurrency"),
    time_ny = list(fn = \() fetch_current_time(CONFIG$timezones$new_york), name = "Time (New York)"),
    time_london = list(fn = \() fetch_current_time(CONFIG$timezones$london), name = "Time (London)"),
    time_tokyo = list(fn = \() fetch_current_time(CONFIG$timezones$tokyo), name = "Time (Tokyo)"),
    facts = list(fn = \() fetch_random_facts(), name = "Random Facts"),
    holidays = list(fn = \() fetch_todays_holidays(), name = "Holidays"),
    hacker_news = list(fn = \() fetch_hacker_news(top_n = CONFIG$news$hacker_news_count), name = "Hacker News"),
    reddit = list(fn = \() fetch_reddit_top(subreddit = CONFIG$news$reddit_default_sub, limit = CONFIG$news$reddit_limit), name = "Reddit"),
    wikipedia = list(fn = \() wiki_cached(), name = "Wikipedia"),
    quote = list(fn = \() fetch_quote_of_day(), name = "Quote"),
    word = list(fn = \() fetch_word_of_day(), name = "Word of Day"),
    nba = list(fn = \() fetch_nba_scores(), name = "NBA Scores"),
    f1 = list(fn = \() fetch_f1_standings(), name = "F1 Standings"),
    tv_shows = list(fn = \() fetch_trending_tv(), name = "TV Shows"),
    movies = list(fn = \() fetch_trending_movie(), name = "Movies"),
    music = list(fn = \() fetch_music_charts(limit = 10), name = "Music Charts"),
    # Entertainment & Quotes (public_apis_entertainment_quotes.R)
    zen_quote = list(fn = \() fetch_zen_quote(), name = "Zen Quote"),
    dad_joke = list(fn = \() fetch_dad_joke(), name = "Dad Joke"),
    chuck_joke = list(fn = \() fetch_chuck_norris_joke(), name = "Chuck Norris Joke"),
    random_joke = list(fn = \() fetch_random_joke("programming"), name = "Programming Joke"),
    random_fact = list(fn = \() fetch_random_fact(), name = "Useless Fact"),
    buzz_word = list(fn = \() fetch_buzz_word(), name = "Buzz Word"),
    techy_phrase = list(fn = \() fetch_techy_phrase(), name = "Techy Phrase"),
    motivational_quote = list(fn = \() fetch_motivational_quote(), name = "Motivational Quote"),
    # Animals (public_apis_animals.R)
    cat_fact = list(fn = \() fetch_cat_fact(), name = "Cat Fact"),
    dog_fact = list(fn = \() fetch_dog_fact(), name = "Dog Fact"),
    random_duck = list(fn = \() fetch_random_duck(), name = "Random Duck"),
    random_fox = list(fn = \() fetch_random_fox(), name = "Random Fox"),
    random_dog_img = list(fn = \() fetch_random_dog_image(), name = "Random Dog Image"),
    meow_facts = list(fn = \() fetch_meow_facts(), name = "Meow Facts"),
    http_cat = list(fn = \() fetch_http_cat(200), name = "HTTP Status Cat"),
    shibe = list(fn = \() fetch_random_shibe("shibes", 1), name = "Random Shibe"),
    zoo_animal = list(fn = \() fetch_zoo_animal(), name = "Zoo Animal"),
    # Games & Trivia (public_apis_games.R)
    trivia_question = list(fn = \() fetch_trivia_question("medium"), name = "Trivia Question"),
    pokemon = list(fn = \() fetch_pokemon("pikachu"), name = "Pokemon Info"),
    dnd_spell = list(fn = \() fetch_dnd_spell("fireball"), name = "D&D Spell"),
    dnd_monster = list(fn = \() fetch_dnd_monster("dragon"), name = "D&D Monster"),
    star_wars = list(fn = \() fetch_star_wars("people", 1), name = "Star Wars Character"),
    xkcd_comic = list(fn = \() fetch_xkcd_comic(), name = "XKCD Comic"),
    chess_game = list(fn = \() fetch_chess_game(), name = "Chess Player"),
    ghibli_film = list(fn = \() fetch_ghibli_film(), name = "Studio Ghibli Film"),
    jeopardy_q = list(fn = \() fetch_jeopardy_question(), name = "Jeopardy Question")
  )

 cat("  Starting parallel fetch with", CONFIG$api$parallel_workers, "workers...\n")
  cat("  Total APIs to fetch:", length(api_calls), "\n\n")
  
  # Set global timeout for parallel execution (prevent hanging)
  options(timeout = 60)  # 60 second max per worker
  
  results <- furrr::future_map(api_calls, function(call) {
    result <- tryCatch({
      future::with_timeout(30, safe_execute(call$fn, source_name = call$name))
    }, error = function(e) {
      # If parallel execution fails, return error result
      new_api_result(
        status = "error",
        data = NULL,
        source = call$name,
        timestamp = Sys.time(),
        error = paste("Parallel execution error:", e$message)
      )
    })
    result
  }, .options = furrr::furrr_options(
    seed = TRUE,
    packages = c("logger", "httr2", "jsonlite", "purrr", "checkmate", "future"),
    globals = TRUE  # Automatically detect and export all required objects
  ))
  
  cat("\n  ✅ Parallel fetch completed\n")

# Print results summary after parallel execution completes
invisible(lapply(names(results), function(name) {
  result <- results[[name]]
  call_name <- api_calls[[name]]$name
  if (is_success(result)) {
    cat(sprintf("  ✅ %s\n", call_name))
  } else {
    cat(sprintf("  ⚠️ %s: %s\n", call_name, result$error %||% "unknown error"))
  }
}))

  # Restructure results
  all_results <- list(
    astronomy = results$astronomy,
    weather = results$weather,
    crypto = results$crypto,
    time = list(
      new_york = results$time_ny,
      london = results$time_london,
      tokyo = results$time_tokyo
    ),
    facts = results$facts,
    holidays = results$holidays,
    news = list(
      hacker_news = results$hacker_news,
      reddit = results$reddit,
      wikipedia = results$wikipedia,
      quote = results$quote,
      word = results$word
    ),
    sports = list(
      nba = results$nba,
      f1 = results$f1
    ),
    entertainment = list(
      tv = results$tv_shows,
      movie = results$movies,
      music = results$music
    ),
    entertainment_quotes = list(
      quote_quotable = results$quote_quotable,
      dad_joke = results$dad_joke,
      chuck_joke = results$chuck_joke,
      random_joke = results$random_joke,
      random_fact = results$random_fact,
      buzz_word = results$buzz_word,
      techy_phrase = results$techy_phrase,
      motivational_quote = results$motivational_quote
    ),
    animals = list(
      cat_fact = results$cat_fact,
      dog_fact = results$dog_fact,
      random_duck = results$random_duck,
      random_fox = results$random_fox,
      random_dog_img = results$random_dog_img,
      meow_facts = results$meow_facts,
      http_cat = results$http_cat,
      shibe = results$shibe,
      zoo_animal = results$zoo_animal
    ),
    games_trivia = list(
      trivia_question = results$trivia_question,
      pokemon = results$pokemon,
      dnd_spell = results$dnd_spell,
      dnd_monster = results$dnd_monster,
      star_wars = results$star_wars,
      xkcd_comic = results$xkcd_comic,
      chess_game = results$chess_game,
      ghibli_film = results$ghibli_film,
      jeopardy_q = results$jeopardy_q
    ),
    fetch_timestamp = timestamp
  )

  # Print summary
  cat("\n")
  cat("---------------------------------------------------------------\n")
  cat("FETCH SUMMARY\n")
  cat("---------------------------------------------------------------\n")
  to_print <- list(
    results$astronomy, results$weather, results$crypto,
    results$time_ny, results$facts, results$holidays,
    results$hacker_news, results$reddit, results$wikipedia,
    results$quote, results$word, results$nba, results$f1,
    results$tv_shows, results$movies, results$music,
    results$quote_quotable, results$dad_joke, results$chuck_joke,
    results$random_joke, results$random_fact, results$buzz_word,
    results$techy_phrase, results$motivational_quote,
    results$cat_fact, results$dog_fact, results$random_duck,
    results$random_fox, results$random_dog_img, results$meow_facts,
    results$http_cat, results$shibe, results$zoo_animal,
    results$trivia_question, results$pokemon, results$dnd_spell,
    results$dnd_monster, results$star_wars, results$xkcd_comic,
    results$chess_game, results$ghibli_film, results$jeopardy_q
  )
  invisible(lapply(to_print, function(r) cat(format_error(r), "\n")))
  cat("---------------------------------------------------------------\n\n")

  # Calculate success rate
  all_results_flat <- list(
    results$astronomy, results$weather, results$crypto,
    results$time_ny, results$time_london, results$time_tokyo,
    results$facts, results$holidays, results$hacker_news,
    results$reddit, results$wikipedia, results$quote,
    results$word, results$nba, results$f1, results$tv_shows,
    results$movies, results$music, results$quote_quotable,
    results$dad_joke, results$chuck_joke, results$random_joke,
    results$random_fact, results$buzz_word, results$techy_phrase,
    results$motivational_quote, results$cat_fact, results$dog_fact,
    results$random_duck, results$random_fox, results$random_dog_img,
    results$meow_facts, results$http_cat, results$shibe,
    results$zoo_animal, results$trivia_question, results$pokemon,
    results$dnd_spell, results$dnd_monster, results$star_wars,
    results$xkcd_comic, results$chess_game, results$ghibli_film,
    results$jeopardy_q
  )
  
  total_apis <- length(all_results_flat)
  success_count <- sum(sapply(all_results_flat, is_success))

  cat(sprintf("Success Rate: %d/%d APIs\n", success_count, total_apis))
  cat("===============================================================\n\n")

  return(all_results)
}  # <-- This closing brace was missing!

# Export for use in reports and other scripts
if (!exists("AGGREGATOR_LOADED")) {
  AGGREGATOR_LOADED <- TRUE
}

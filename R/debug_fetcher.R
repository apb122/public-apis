# Debug Utility for API Fetching Issues
# Run this to diagnose what's happening

library(httr2)
library(jsonlite)
library(logger)

#' Test a single API endpoint with verbose output
#' 
#' @param url API URL to test
#' @param name Friendly name for the API
#' 
test_single_api <- function(url, name = "Test API") {
  cat("\n=== Testing:", name, "===\n")
  cat("URL:", url, "\n")
  
  # Test 1: Basic connectivity
  cat("\n[1] Testing basic HTTP request...\n")
  start_time <- Sys.time()
  
  tryCatch({
    resp <- request(url) |>
      req_user_agent("CurrentInfoDashboard/1.0 (Debug Mode)") |>
      req_timeout(5) |>  # Shorter timeout for debugging
      req_error(is_error = \(r) FALSE) |>
      req_perform()
    
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))
    
    cat("✅ Request completed in", round(elapsed, 2), "seconds\n")
    cat("Status:", resp_status(resp), "\n")
    
    if (resp_status(resp) == 200) {
      cat("✅ HTTP 200 - Success\n")
      
      # Try to parse JSON
      cat("\n[2] Testing JSON parsing...\n")
      data <- tryCatch({
        resp_body_json(resp)
      }, error = function(e) {
        cat("❌ JSON parse error:", e$message, "\n")
        return(NULL)
      })
      
      if (!is.null(data)) {
        cat("✅ JSON parsed successfully\n")
        cat("Data structure:\n")
        str(data, max.level = 2, list.len = 3)
        return(list(success = TRUE, status = 200, data = data))
      } else {
        return(list(success = FALSE, status = 200, error = "JSON parse failed"))
      }
    } else {
      cat("❌ HTTP", resp_status(resp), "\n")
      return(list(success = FALSE, status = resp_status(resp)))
    }
    
  }, error = function(e) {
    cat("❌ Request failed:", e$message, "\n")
    return(list(success = FALSE, error = e$message))
  })
}

#' Test all API function files can be sourced
#' 
test_api_modules <- function() {
  cat("\n========================================\n")
  cat("TESTING API MODULE LOADING\n")
  cat("========================================\n")
  
  api_files <- c(
    "R/api_functions/astronomy.R",
    "R/api_functions/weather.R",
    "R/api_functions/crypto.R",
    "R/api_functions/public_apis_entertainment_quotes.R",
    "R/api_functions/public_apis_animals.R",
    "R/api_functions/public_apis_games.R"
  )
  
  results <- list()
  for (file in api_files) {
    cat("\nTesting:", file, "\n")
    result <- tryCatch({
      source(file)
      cat("✅ Loaded successfully\n")
      TRUE
    }, error = function(e) {
      cat("❌ Error:", e$message, "\n")
      FALSE
    })
    results[[file]] <- result
  }
  
  success_count <- sum(unlist(results))
  cat("\n========================================\n")
  cat("Result:", success_count, "/", length(results), "modules loaded\n")
  cat("========================================\n")
  
  return(results)
}

#' Quick test of core utilities
#' 
test_core_utils <- function() {
  cat("\n========================================\n")
  cat("TESTING CORE UTILITIES\n")
  cat("========================================\n")
  
  # Test 1: Can we load utils.R?
  cat("\n[1] Loading utils.R...\n")
  tryCatch({
    source("R/utils.R")
    cat("✅ utils.R loaded\n")
  }, error = function(e) {
    cat("❌ utils.R error:", e$message, "\n")
    return(FALSE)
  })
  
  # Test 2: Can we load config.R?
  cat("\n[2] Loading config.R...\n")
  tryCatch({
    source("R/config.R")
    cat("✅ config.R loaded\n")
    cat("Timeout setting:", CONFIG$api$timeout, "seconds\n")
    cat("Max retries:", CONFIG$api$max_retries, "\n")
    cat("Parallel workers:", CONFIG$api$parallel_workers, "\n")
  }, error = function(e) {
    cat("❌ config.R error:", e$message, "\n")
    return(FALSE)
  })
  
  # Test 3: Can we call safe_api_call?
  cat("\n[3] Testing safe_api_call function...\n")
  if (exists("safe_api_call")) {
    cat("✅ safe_api_call function exists\n")
    
    # Try a simple API call
    cat("\n[4] Testing safe_api_call with real API...\n")
    result <- tryCatch({
      safe_api_call("https://catfact.ninja/fact", "Debug Cat Fact")
    }, error = function(e) {
      cat("❌ safe_api_call error:", e$message, "\n")
      return(NULL)
    })
    
    if (!is.null(result)) {
      cat("✅ API call completed\n")
      cat("Status:", result$status, "\n")
      if (result$status == "success") {
        cat("Data preview:", substr(toJSON(result$data), 1, 100), "...\n")
      }
    }
  } else {
    cat("❌ safe_api_call function not found\n")
  }
}

#' Run comprehensive diagnostics
#' 
run_diagnostics <- function() {
  cat("\n")
  cat("╔════════════════════════════════════════════════════════╗\n")
  cat("║   API FETCHING DIAGNOSTICS - Debug Mode               ║\n")
  cat("╚════════════════════════════════════════════════════════╝\n")
  
  # Test 1: Core utilities
  test_core_utils()
  
  # Test 2: API modules
  Sys.sleep(1)
  test_api_modules()
  
  # Test 3: Sample API endpoints
  cat("\n========================================\n")
  cat("TESTING SAMPLE API ENDPOINTS\n")
  cat("========================================\n")
  
  test_apis <- list(
    list(url = "https://catfact.ninja/fact", name = "Cat Facts (Simple JSON)"),
    list(url = "https://api.chucknorris.io/jokes/random", name = "Chuck Norris (Simple)"),
    list(url = "https://api.quotable.io/random", name = "Quotable (Complex JSON)"),
    list(url = "https://pokeapi.co/api/v2/pokemon/pikachu", name = "Pokemon (Large JSON)"),
    list(url = "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY", name = "NASA APOD (Rate Limited)")
  )
  
  for (api in test_apis) {
    result <- test_single_api(api$url, api$name)
    Sys.sleep(0.5)  # Brief pause between tests
  }
  
  # Test 4: Parallel execution capability
  cat("\n========================================\n")
  cat("TESTING PARALLEL EXECUTION\n")
  cat("========================================\n")
  
  cat("\n[1] Checking furrr package...\n")
  if (require(furrr, quietly = TRUE)) {
    cat("✅ furrr package available\n")
    
    cat("\n[2] Testing parallel plan...\n")
    tryCatch({
      future::plan(future::multisession, workers = 2)
      cat("✅ Parallel plan set (2 workers)\n")
      
      cat("\n[3] Testing parallel API calls...\n")
      test_urls <- c(
        "https://catfact.ninja/fact",
        "https://api.chucknorris.io/jokes/random"
      )
      
      start <- Sys.time()
      results <- future_map(test_urls, ~{
        request(.x) |> 
          req_timeout(5) |> 
          req_perform() |> 
          resp_status()
      })
      elapsed <- difftime(Sys.time(), start, units = "secs")
      
      cat("✅ Parallel execution completed in", round(elapsed, 2), "seconds\n")
      cat("Results:", paste(unlist(results), collapse = ", "), "\n")
      
      # Reset to sequential
      future::plan(future::sequential)
      
    }, error = function(e) {
      cat("❌ Parallel execution error:", e$message, "\n")
      future::plan(future::sequential)
    })
  } else {
    cat("❌ furrr package not available\n")
  }
  
  cat("\n")
  cat("╔════════════════════════════════════════════════════════╗\n")
  cat("║   DIAGNOSTICS COMPLETE                                 ║\n")
  cat("╚════════════════════════════════════════════════════════╝\n")
  cat("\nTo fix issues:\n")
  cat("1. Check internet connection\n")
  cat("2. Verify API endpoints are accessible\n")
  cat("3. Check if firewalls are blocking requests\n")
  cat("4. Try: future::plan(future::sequential) to disable parallel\n")
  cat("5. Check logs in: logs/api.log\n")
}

# Quick test function for immediate feedback
quick_test <- function() {
  cat("Quick API Test...\n")
  source("R/utils.R")
  source("R/config.R")
  
  cat("\nTest 1: Cat Fact API\n")
  result <- safe_api_call("https://catfact.ninja/fact", "Cat Fact")
  cat("Status:", result$status, "\n")
  if (result$status == "success") {
    cat("Fact:", result$data$fact, "\n")
  }
  
  cat("\nTest 2: Chuck Norris API\n")
  result <- safe_api_call("https://api.chucknorris.io/jokes/random", "Chuck Norris")
  cat("Status:", result$status, "\n")
  if (result$status == "success") {
    cat("Joke:", result$data$value, "\n")
  }
}

# Export functions
if (!exists("DEBUG_LOADED")) {
  DEBUG_LOADED <- TRUE
  cat("\n✅ Debug utilities loaded. Available functions:\n")
  cat("  - run_diagnostics()  : Complete diagnostic suite\n")
  cat("  - quick_test()       : Fast API connectivity test\n")
  cat("  - test_single_api(url, name) : Test one endpoint\n")
  cat("  - test_api_modules() : Check all API files load\n")
  cat("  - test_core_utils()  : Test utils.R and config.R\n\n")
}

library(httr2)
library(jsonlite)
library(logger)
library(purrr)
library(checkmate)

# Type-safe API result constructor (S3)
new_api_result <- function(status, data, source, timestamp = Sys.time(), error = NULL) {
  structure(
    list(
      status = status,
      data = data,
      source = source,
      timestamp = timestamp,
      error = error
    ),
    class = "api_result"
  )
}

print.api_result <- function(x, ...) {
  cat(sprintf("<%s API Result>\n", x$source))
  cat(sprintf("Status: %s\n", x$status))
  if (x$status == "error") {
    cat(sprintf("Error: %s\n", x$error))
  } else {
    cat(sprintf("Fetched: %s\n", format(x$timestamp, "%Y-%m-%d %H:%M:%S")))
  }
}

# Project path initialization (centralized)
init_project_paths <- function(project_root = NULL) {
  if (is.null(project_root)) project_root <- getwd()
  list(
    root = project_root,
    r_dir = file.path(project_root, "R"),
    reports_dir = file.path(project_root, "reports"),
    output_dir = file.path(project_root, "output"),
    cache_dir = file.path(project_root, "cache"),
    logs_dir = file.path(project_root, "logs")
  )
}

# Safe API call using httr2 with retry/backoff
# Returns api_result S3 object
safe_api_call <- function(url, source_name, emoji = NULL) {
  logger::log_info("Fetching {source_name} from {url}")

  # Defaults if CONFIG not loaded

timeout_sec <- tryCatch(CONFIG$api$timeout, error = function(...) 10)
  max_retries <- tryCatch(CONFIG$api$max_retries, error = function(...) 2)  # Reduced from 3
  ua <- tryCatch(CONFIG$api$user_agent, error = function(...) "CurrentInfoDashboard/1.0")

  resp <- tryCatch({
    request(url) |>
      req_user_agent(ua) |>
      req_timeout(timeout_sec) |>
      req_retry(
        max_tries = max_retries,
        is_transient = \(r) resp_status(r) %in% c(429, 500, 502, 503),
        backoff = function(attempt) 0.3 * (1.5 ^ (attempt - 1))  # Faster: 0.3s, 0.45s, 0.675s
      ) |>
      req_error(is_error = \(r) FALSE) |>
      req_perform()
  }, error = function(e) {
    # Handle connection timeouts and other errors without waiting
    logger::log_warn("Connection error for {source_name}: {conditionMessage(e)}")
    return(NULL)
  })

  # Handle NULL response (connection failed)
  if (is.null(resp)) {
    return(new_api_result(
      status = "error",
      data = NULL,
      source = source_name,
      timestamp = Sys.time(),
      error = "Connection failed or timed out"
    ))
  }

  status <- resp_status(resp)
  if (status == 200) {
    data <- tryCatch(resp_body_json(resp), error = function(e) NULL)
    return(new_api_result(
      status = "success",
      data = data,
      source = source_name,
      timestamp = Sys.time(),
      error = NULL
    ))
  } else {
    logger::log_warn("HTTP {status} for {source_name}")
    return(new_api_result(
      status = "error",
      data = NULL,
      source = source_name,
      timestamp = Sys.time(),
      error = sprintf("HTTP %d", status)
    ))
  }
}

# Purrr-safe execution wrapper for arbitrary functions
safe_execute <- function(fn, source_name = "unknown") {
  res <- safely(fn)()
  
  if (is.null(res$error)) {
    result <- res$result
    # If the result is already an api_result, return it as-is
    if (inherits(result, "api_result")) {
      return(result)
    }
    # Otherwise wrap it in a success api_result
    return(new_api_result(
      status = "success",
      data = result,
      source = source_name,
      timestamp = Sys.time(),
      error = NULL
    ))
  } else {
    # Extract error message properly
    error_msg <- tryCatch(
      conditionMessage(res$error),
      error = function(e) as.character(res$error)
    )
    logger::log_error("Unhandled error in {source_name}: {error_msg}")
    return(new_api_result(
      status = "error",
      data = NULL,
      source = source_name,
      timestamp = Sys.time(),
      error = error_msg
    ))
  }
}

# Format message for reporting without emojis
# Format message for reporting without emojis
format_error <- function(result) {
  if (is.null(result)) {
    return("[ERROR] NULL result received")
  }
  
  if (!inherits(result, "api_result")) {
    return(sprintf("[WARNING] Non-standard result type: %s", class(result)[1]))
  }
  
  if (result$status == "success") {
    sprintf("[SUCCESS] %s (fetched at %s)", result$source,
            format(result$timestamp, "%H:%M:%S"))
  } else {
    sprintf("[ERROR] %s: %s", result$source, result$error)
  }
}

# Check if result is successful
is_success <- function(result) {
  if (is.null(result)) return(FALSE)
  if (!inherits(result, "api_result")) return(FALSE)
  identical(result$status, "success")
}

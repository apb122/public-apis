#!/usr/bin/env Rscript
# Render the daily report with modularized API functions
# Usage: Rscript render_report.R [--force-refresh] [--skip-test]

options(repos = c(CRAN = "https://cran.r-project.org/"))

# ============================================================================
# CONFIGURATION
# ============================================================================

CONFIG <- list(
  required_packages = c(
    "rmarkdown", "knitr", "kableExtra", "ggplot2", "plotly", "dplyr",
    "httr2", "jsonlite", "furrr", "memoise", "cachem", "logger", 
    "here", "checkmate", "purrr"
  ),
  report_name = "daily_report",
  output_format = "html"
)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================
print_header <- function(text) {
  width <- 65
  cat("\n")
  cat(strrep("=", width), "\n")
  cat(text, "\n")
  cat(strrep("=", width), "\n")
}

print_step <- function(icon, message) {
  cat(sprintf("%s %s\n", icon, message))
}

print_substep <- function(message) {
  cat(sprintf("   %s\n", message))
}

get_project_root <- function() {
  # Method 1: Check command line arguments (for Rscript execution)
  args <- commandArgs(trailingOnly = FALSE)
  script_file <- grep("--file=", args, value = TRUE)
  
  if (length(script_file) > 0) {
    script_path <- normalizePath(sub("--file=", "", script_file))
    script_dir <- dirname(script_path)
    # Assume script is in /scripts folder
    return(dirname(script_dir))
  }
  
  # Method 2: Use here package if available
  if (requireNamespace("here", quietly = TRUE)) {
    tryCatch({
      return(here::here())
    }, error = function(e) NULL)
  }
  
  # Method 3: Check current working directory structure
  wd <- getwd()
  if (basename(wd) == "scripts") {
    return(dirname(wd))
  }
  
  # Method 4: Look for project indicators
  indicators <- c("DESCRIPTION", ".Rproj", "R", "reports")
  current <- wd
  
  for (i in 1:5) {  # Search up to 5 levels
    if (any(file.exists(file.path(current, indicators)))) {
      return(current)
    }
    parent <- dirname(current)
    if (parent == current) break
    current <- parent
  }
  
  # Fallback to working directory
  return(wd)
}

check_packages <- function(packages) {
  missing <- c()
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      missing <- c(missing, pkg)
    }
  }
  return(missing)
}

load_packages <- function(packages) {
  for (pkg in packages) {
    suppressPackageStartupMessages(
      library(pkg, character.only = TRUE)
    )
  }
}

validate_project_structure <- function(root) {
  required_paths <- list(
    r_dir = file.path(root, "R"),
    reports_dir = file.path(root, "reports"),
    aggregator = file.path(root, "R", "aggregator.R"),
    report_rmd = file.path(root, "reports", "daily_report.Rmd")
  )
  
  errors <- c()
  for (name in names(required_paths)) {
    path <- required_paths[[name]]
    if (!file.exists(path)) {
      errors <- c(errors, sprintf("Missing: %s", path))
    }
  }
  
  return(list(
    valid = length(errors) == 0,
    errors = errors,
    paths = required_paths
  ))
}

# ============================================================================
# MAIN FUNCTIONS
# ============================================================================

test_api_functions <- function(project_root) {
  print_step("\U0001F9EA", "Testing modularized API functions...")
  
  aggregator_path <- file.path(project_root, "R", "aggregator.R")
  print_substep(sprintf("Loading: %s", aggregator_path))
  
  # Source the aggregator
  source(aggregator_path)
  
  # Test fetch
  print_substep("Fetching data (this may take a moment)...")
  test_data <- fetch_all_data()
  
  # Validate result
  if (is.null(test_data)) {
    stop("fetch_all_data() returned NULL")
  }
  
  # Count successes
  components <- c("astronomy", "weather", "crypto", "facts", "holidays")
  available <- sum(sapply(components, function(x) !is.null(test_data[[x]])))
  
  print_substep(sprintf("Data components available: %d/%d", available, length(components)))
  
  return(test_data)
}

render_report <- function(project_root, pre_fetched_data = NULL) {
  print_step("\U0001F4C4", "Rendering report...")
  
  report_path <- file.path(project_root, "reports", "daily_report.Rmd")
  output_dir <- file.path(project_root, "output")
  output_file <- sprintf("%s.%s", CONFIG$report_name, CONFIG$output_format)
  
  # Ensure output directory exists
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    print_substep(sprintf("Created output directory: %s", output_dir))
  }
  
  print_substep(sprintf("Input: %s", report_path))
  print_substep(sprintf("Output: %s", file.path(output_dir, output_file)))
  
  # Create render environment with pre-fetched data if available
  render_env <- new.env()
  if (!is.null(pre_fetched_data)) {
    render_env$prefetched_data <- pre_fetched_data
    print_substep("Using pre-fetched data")
  }
  
  # Render
  output_path <- rmarkdown::render(
    input = report_path,
    output_file = output_file,
    output_dir = output_dir,
    envir = render_env,
    quiet = TRUE
  )
  
  return(output_path)
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main <- function() {
  start_time <- Sys.time()
  
  # Parse arguments
  args <- commandArgs(trailingOnly = TRUE)
  force_refresh <- "--force-refresh" %in% args
  skip_test <- "--skip-test" %in% args
  
  print_header("Daily Report Renderer")
  
  cat(sprintf("Started: %s\n", format(start_time, "%Y-%m-%d %H:%M:%S")))
  cat(sprintf("Options: force_refresh=%s, skip_test=%s\n", force_refresh, skip_test))
  
  # Step 1: Determine project root
  print_step("\U0001F4C1", "Locating project root...")
  project_root <- get_project_root()
  print_substep(sprintf("Project root: %s", project_root))
  
  # Step 2: Validate project structure
  print_step("\U0001F50D", "Validating project structure...")
  validation <- validate_project_structure(project_root)
  
  if (!validation$valid) {
    cat("\n\u274C Project structure validation failed:\n")
    for (err in validation$errors) {
      cat(sprintf("   - %s\n", err))
    }
    quit(status = 1)
  }
  print_substep("Project structure valid")
  
  # Step 3: Check and load packages
  print_step("\U0001F4E6", "Loading required packages...")
  missing_packages <- check_packages(CONFIG$required_packages)
  
  if (length(missing_packages) > 0) {
    cat("\n\u274C Missing packages:\n")
    for (pkg in missing_packages) {
      cat(sprintf("   - %s\n", pkg))
    }
    cat("\nRun install_packages.R first, or install manually:\n")
    cat(sprintf('  install.packages(c("%s"))\n', paste(missing_packages, collapse = '", "')))
    quit(status = 1)
  }
  
  load_packages(CONFIG$required_packages)
  print_substep("All packages loaded")
  
  # Step 4: Test API functions (optional)
  test_data <- NULL
  if (!skip_test) {
    tryCatch({
      test_data <- test_api_functions(project_root)
      print_substep("\u2705 API functions working")
    }, error = function(e) {
      cat(sprintf("\n\u26A0\uFE0F  API test failed: %s\n", e$message))
      cat("Continuing with report render (report will fetch its own data)...\n\n")
    })
  } else {
    print_step("\u23ED\uFE0F", "Skipping API test (--skip-test)")
  }
  
  # Step 5: Render report
  tryCatch({
    output_path <- render_report(project_root, test_data)
    
    end_time <- Sys.time()
    duration <- round(difftime(end_time, start_time, units = "secs"), 1)
    
    print_header("SUCCESS")
    cat(sprintf("\n\u2705 Report generated: %s\n", output_path))
    cat(sprintf("   Duration: %s seconds\n", duration))
    cat(sprintf("   Completed: %s\n\n", format(end_time, "%Y-%m-%d %H:%M:%S")))
    
    # Try to open in browser (non-blocking)
    if (interactive()) {
      tryCatch({
        browseURL(output_path)
      }, error = function(e) NULL)
    }
    
  }, error = function(e) {
    print_header("ERROR")
    cat(sprintf("\n\u274C Report rendering failed:\n"))
    cat(sprintf("   %s\n\n", e$message))
    
    # Print traceback for debugging
    cat("Traceback:\n")
    traceback()
    
    quit(status = 1)
  })
}

# Run if executed directly
if (!interactive()) {
  main()
} else {
  cat("Source this file and run main() to render the report.\n")
  cat("Or run from command line: Rscript render_report.R [--skip-test] [--force-refresh]\n")
}
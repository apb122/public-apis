#!/usr/bin/env Rscript
# Install packages needed for report
# Usage: Rscript install_packages.R [--upgrade]

options(repos = c(CRAN = "https://cran.r-project.org/"))

# ============================================================================
# CONFIGURATION
# ============================================================================

packages <- list(
  # Core rendering
  core = c("rmarkdown", "knitr", "kableExtra"),
  
  # Visualization
  viz = c("ggplot2", "plotly"),
  
  # Data manipulation
  data = c("jsonlite", "dplyr", "purrr", "scales"),
  
  # HTTP and API
  api = c("httr2"),
  
  # Parallel processing and caching
  performance = c("furrr", "memoise", "cachem"),
  
  # Utilities
  utils = c("here", "logger", "checkmate")
)

# Flatten package list
all_packages <- unlist(packages, use.names = FALSE)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_header <- function(text) {
  width <- 60
  cat("\n")
  cat(strrep("=", width), "\n")
  cat(text, "\n")
  cat(strrep("=", width), "\n")
}

print_status <- function(status, pkg, message = "") {
  icon <- switch(status,
    "ok" = "\u2705",
    "install" = "\U0001F4E6",
    "error" = "\u274C",
    "skip" = "\u23ED\uFE0F",
    "\u2753"
  )
  if (nchar(message) > 0) {
    cat(sprintf("  %s %s: %s\n", icon, pkg, message))
  } else {
    cat(sprintf("  %s %s\n", icon, pkg))
  }
}

check_r_version <- function(min_version = "4.1.0") {
  current <- getRversion()
  if (current < min_version) {
    warning(sprintf(
      "R version %s detected. Version %s or higher recommended.",
      current, min_version
    ))
    return(FALSE)
  }
  return(TRUE)
}

install_package <- function(pkg, upgrade = FALSE) {
  # Check if already installed
  if (requireNamespace(pkg, quietly = TRUE)) {
    if (upgrade) {
      tryCatch({
        install.packages(pkg, quiet = TRUE)
        print_status("install", pkg, "upgraded")
        return(TRUE)
      }, error = function(e) {
        print_status("error", pkg, e$message)
        return(FALSE)
      })
    } else {
      print_status("ok", pkg, "already installed")
      return(TRUE)
    }
  }
  
  # Try to install
  tryCatch({
    install.packages(pkg, quiet = TRUE)
    if (requireNamespace(pkg, quietly = TRUE)) {
      print_status("install", pkg, "installed successfully")
      return(TRUE)
    } else {
      print_status("error", pkg, "install failed silently")
      return(FALSE)
    }
  }, error = function(e) {
    print_status("error", pkg, e$message)
    return(FALSE)
  })
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main <- function() {
  # Parse command line arguments
  args <- commandArgs(trailingOnly = TRUE)
  upgrade <- "--upgrade" %in% args
  
  print_header("R Package Installer for Current Info Dashboard")
  
  cat("\nR Version:", as.character(getRversion()), "\n")
  cat("Platform:", R.version$platform, "\n")
  cat("Upgrade mode:", ifelse(upgrade, "YES", "NO"), "\n")
  
  # Check R version
  check_r_version()
  
  # Install packages by category
  results <- list()
  
  for (category in names(packages)) {
    cat(sprintf("\n[%s]\n", toupper(category)))
    pkg_list <- packages[[category]]
    
    for (pkg in pkg_list) {
      results[[pkg]] <- install_package(pkg, upgrade = upgrade)
    }
  }
  
  # Summary
  print_header("INSTALLATION SUMMARY")
  
  success_count <- sum(unlist(results))
  total_count <- length(results)
  failed <- names(results)[!unlist(results)]
  
  cat(sprintf("\nInstalled: %d/%d packages\n", success_count, total_count))
  
  if (length(failed) > 0) {
    cat("\nFailed packages:\n")
    for (pkg in failed) {
      cat(sprintf("  - %s\n", pkg))
    }
    cat("\nTry installing failed packages manually:\n")
    cat(sprintf('  install.packages(c("%s"))\n', paste(failed, collapse = '", "')))
    quit(status = 1)
  } else {
    cat("\n\u2705 All packages ready!\n\n")
    quit(status = 0)
  }
}

# Run if executed directly
if (!interactive()) {
  main()
} else {
  cat("Run main() to install packages, or source this file and install individually.\n")
}
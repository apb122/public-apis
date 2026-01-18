# Code Optimization Report - Based on httr2 & purrr Best Practices

**Date:** January 18, 2026  
**Review Scope:** All R code - API functions, utilities, aggregator, visualizations

---

## 🎯 Key Optimizations to Implement

### 1. **Upgrade to httr2 (Modern HTTP Client)**

**Current:** Using legacy `httr` package  
**Recommended:** Migrate to `httr2` for:
- Built-in automatic retries with exponential backoff
- Rate limit handling with `Retry-After` header support
- Better timeout management
- Cleaner pipeline syntax

**Example Migration:**
```r
# Current (httr)
response <- GET(url, timeout(10))
if (status_code(response) == 200) {
  data <- fromJSON(content(response, as = "text"))
}

# Optimized (httr2)
response <- request(url) |>
  req_timeout(10) |>
  req_retry(
    max_tries = 3,
    is_transient = \(resp) resp_status(resp) %in% c(429, 500, 502, 503)
  ) |>
  req_perform()
  
data <- resp_body_json(response)
```

**Benefits:**
- Automatic retry on 429 (rate limit) errors
- Custom retry logic for transient failures
- Cleaner, more readable code

---

### 2. **Use purrr::safely() for Error Handling**

**Current:** Manual tryCatch in every function  
**Recommended:** Use `purrr::safely()` for safer functional programming

**Example:**
```r
# Current approach
tryCatch({
  response <- GET(url)
  # ... processing
}, error = function(e) {
  return(list(status = "error", ...))
})

# Optimized with purrr::safely()
safe_get <- safely(GET)
result <- safe_get(url)

if (is.null(result$error)) {
  # Success path
  response <- result$result
} else {
  # Error path - result$error contains the error
}
```

---

### 3. **Parallel API Execution with purrr**

**Current:** Sequential API calls (13 APIs = ~9 seconds)  
**Recommended:** Parallel execution with `furrr` package

**Implementation:**
```r
library(furrr)
plan(multisession, workers = 4)

# Define all API functions to call
api_calls <- list(
  astronomy = \() fetch_astronomy_daily(),
  weather = \() fetch_current_weather(),
  crypto = \() fetch_crypto_prices(),
  # ... etc
)

# Execute in parallel
all_results <- future_map(api_calls, ~.x())
```

**Expected Performance:**
- Current: 9 seconds (sequential)
- Optimized: 2-3 seconds (parallel with 4 workers)

---

### 4. **Caching with memoise**

**Current:** Every render fetches all APIs fresh  
**Recommended:** Cache results for configurable TTL

```r
library(memoise)

# Cache for 15 minutes
fetch_crypto_prices_cached <- memoise(
  fetch_crypto_prices,
  cache = cache_filesystem("cache/"),
  omit_args = "refresh"
)
```

**Benefits:**
- Reduce API load
- Avoid rate limiting
- Faster development/testing
- Option to force refresh

---

### 5. **Path Resolution - Remove Redundancy**

**Current:** Every API file has path detection logic  
**Recommended:** Centralize in utils.R, pass as parameter

**Optimized utils.R:**
```r
# Load once in aggregator, pass to functions
init_project_paths <- function(project_root = NULL) {
  if (is.null(project_root)) {
    project_root <- getwd()
  }
  
  list(
    root = project_root,
    r_dir = file.path(project_root, "R"),
    reports_dir = file.path(project_root, "reports"),
    output_dir = file.path(project_root, "output"),
    cache_dir = file.path(project_root, "cache")
  )
}
```

---

### 6. **Type-Safe Data Structures**

**Current:** Lists with inconsistent structure  
**Recommended:** Define S3 classes for return objects

```r
# Define API result class
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

# S3 method for printing
print.api_result <- function(x, ...) {
  cat(sprintf("<%s API Result>\n", x$source))
  cat(sprintf("Status: %s\n", x$status))
  if (x$status == "error") {
    cat(sprintf("Error: %s\n", x$error))
  } else {
    cat(sprintf("Fetched: %s\n", format(x$timestamp, "%Y-%m-%d %H:%M:%S")))
  }
}
```

---

### 7. **Configuration Management**

**Current:** Hard-coded defaults scattered across files  
**Recommended:** Centralized config file

**config.R:**
```r
CONFIG <- list(
  api = list(
    timeout = 10,  # seconds
    max_retries = 3,
    cache_ttl = 900,  # 15 minutes
    parallel_workers = 4
  ),
  weather = list(
    default_location = list(lat = 40.7128, lon = -74.0060),  # NYC
    cities = c("New York", "London", "Tokyo")
  ),
  crypto = list(
    default_coins = c("bitcoin", "ethereum", "cardano")
  ),
  holidays = list(
    default_country = "US"
  )
)
```

---

### 8. **Logging Instead of cat()**

**Current:** Using `cat()` for console output  
**Recommended:** Use proper logging with levels

```r
library(logger)

# Setup in aggregator.R
log_threshold(INFO)
log_appender(appender_tee("logs/api.log"))

# Usage in API functions
log_info("Fetching {source} from {url}")
log_warn("Rate limit hit for {source}, retrying in {wait_time}s")
log_error("Failed to fetch {source}: {error_msg}")
```

---

### 9. **Input Validation with checkmate**

**Current:** Minimal input validation  
**Recommended:** Explicit validation at function entry

```r
library(checkmate)

fetch_crypto_prices <- function(coins = c("bitcoin", "ethereum", "cardano")) {
  # Validate inputs
  assert_character(coins, min.len = 1, max.len = 10)
  assert_subset(coins, choices = c("bitcoin", "ethereum", "cardano", "solana", "ripple"))
  
  # ... rest of function
}
```

---

### 10. **Environment Variables for Sensitive Data**

**Current:** API keys in code (DEMO_KEY)  
**Recommended:** Use .Renviron or environment variables

```r
# .Renviron file
NASA_API_KEY=your_real_api_key_here

# In code
fetch_astronomy_daily <- function() {
  api_key <- Sys.getenv("NASA_API_KEY", unset = "DEMO_KEY")
  url <- sprintf("https://api.nasa.gov/planetary/apod?api_key=%s", api_key)
  # ...
}
```

---

## 📊 Priority Implementation Order

### Phase 1: High Impact, Low Effort
1. ✅ **Remove duplicate path detection** - 30 min
2. ✅ **Add config.R for centralized settings** - 20 min
3. ✅ **Implement caching with memoise** - 45 min

### Phase 2: Performance Boost
4. **Parallel execution with furrr** - 1 hour
5. **Migrate to httr2** - 2 hours (per API file)

### Phase 3: Code Quality
6. **Add logging with logger** - 1 hour
7. **Type-safe S3 classes** - 1.5 hours
8. **Input validation with checkmate** - 1 hour

---

## 🎯 Immediate Actions (Before Adding More APIs)

### Quick Wins (30 minutes total):

1. **Create config.R**
```r
# R/config.R
CONFIG <- list(
  api = list(timeout = 10, max_retries = 3, cache_ttl = 900),
  crypto = list(default_coins = c("bitcoin", "ethereum", "cardano")),
  weather = list(default_lat = 40.7128, default_lon = -74.0060),
  news = list(hacker_news_count = 5, reddit_limit = 5)
)
```

2. **Remove redundant path detection from all API files**
   - Already have `project_root` passed via aggregator
   - Just use `source(file.path(r_dir, "R", "utils.R"))` at top

3. **Add basic caching**
```r
# In aggregator.R
library(memoise)

# Wrap slow/rate-limited APIs
fetch_astronomy_daily <- memoise(
  fetch_astronomy_daily,
  cache = cache_filesystem(file.path(project_root, "cache"))
)
```

---

## 🚀 Long-Term Architecture (Phase 3+)

### Modular Plugin System
```
R/
├── core/
│   ├── api_client.R      # httr2 wrapper with retry/timeout
│   ├── cache_manager.R   # memoise + filesystem cache
│   ├── config.R          # Centralized configuration
│   └── logger.R          # Logging setup
├── plugins/
│   ├── news/
│   │   ├── hacker_news.R
│   │   ├── reddit.R
│   │   └── wikipedia.R
│   ├── finance/
│   ├── sports/
│   └── ...
└── aggregator.R          # Orchestrates all plugins
```

**Benefits:**
- Easy to add/remove data sources
- Each plugin is self-contained
- Testable in isolation
- Clear separation of concerns

---

## 📝 Recommendations Summary

**Must Do (Before Next Expansion):**
1. Create centralized config.R ✅
2. Remove duplicate path detection code ✅
3. Add basic caching for rate-limited APIs ✅

**Should Do (For Production):**
4. Parallel execution (3x speed boost)
5. Migrate to httr2 (better reliability)
6. Add proper logging

**Nice to Have:**
7. S3 classes for type safety
8. Input validation
9. Plugin architecture

---

**Next Step:** Implement Quick Wins (30 min), then add Sports & Entertainment APIs (4 new sources)

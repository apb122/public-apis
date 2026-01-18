# AI Agent Instructions for Current Information Dashboard Project

## 🎯 Project Overview

This R/Quarto project creates an **automated daily dashboard** that fetches real-time data from 6+ public APIs and generates a beautiful, responsive HTML report. The goal is to produce a professional information dashboard with zero manual intervention through Windows Task Scheduler automation.

**Key Components:**
- **Data Layer**: `fetch_current_data.R` - Modular API functions (astronomy, weather, crypto, time, facts, holidays)
- **Report Templates**: `reports/` - Quarto (daily_report.qmd) and RMarkdown (daily_report.Rmd)
- **Automation**: `scripts/render_report.R` - Rendering script with package management
- **Planning**: `QUARTO_REPORT_PLAN.md` - 6-phase implementation roadmap
- **Generated Reports**: `output/` - Daily rendered HTML reports

## 🏗️ Critical Architecture Patterns

### Data Fetching Pattern
Each API function in `fetch_current_data.R` follows a consistent pattern:
```r
function_name <- function(params = defaults) {
  # 1. Info message with emoji
  cat("🔍 Fetching...\n")
  
  # 2. URL construction with parameters
  url <- sprintf("https://api.example.com/endpoint?param=%s", value)
  
  # 3. Error-safe execution with tryCatch
  tryCatch({
    response <- GET(url)
    if (status_code(response) == 200) {
      data <- fromJSON(content(response, as = "text"))
      # Process and return data
      return(data)
    }
  }, error = function(e) {
    cat("Error:", e$message, "\n")
    return(NULL)
  })
}
```

**Why this matters**: Functions are designed to fail gracefully. The report must never crash if one API is down.

### Report Rendering Pattern
- `reports/daily_report.qmd` (Quarto) is the "source of truth" - use this for new sections
- `reports/daily_report.Rmd` (RMarkdown) is the fallback if Quarto CLI isn't available
- Both inlined API calls directly in code chunks (no external data files yet)
- Output always: `output/daily_report.html` (single, self-contained file with embedded resources)

### Phase 1 Refactoring Strategy (Planned)
Current monolithic approach will be split into:
```
R/
├── api_functions/
│   ├── astronomy.R       # fetch_astronomy_daily()
│   ├── weather.R         # fetch_current_weather()
│   ├── crypto.R          # fetch_crypto_prices()
│   ├── time_info.R       # fetch_current_time()
│   ├── facts.R           # fetch_random_facts()
│   └── holidays.R        # fetch_todays_holidays()
├── utils.R              # Shared error handling, formatting
└── aggregator.R         # fetch_all_data() - single data source
```

This enables:
1. Reusable functions across reports/scripts
2. Cleaner testing (each function isolated)
3. Easier to add new data sources
4. Aggregator pattern = single source of truth

## 🔄 Developer Workflows

### Rendering Reports
```bash
# R script method (recommended - auto-installs packages)
Rscript render_report.R

# Direct Quarto (requires quarto CLI installed)
quarto render daily_report.qmd

# Direct RMarkdown (from R console)
rmarkdown::render("daily_report.Rmd")
```

### Testing API Functions
```r
# Load the script
source("fetch_current_data.R")

# Test individual functions
apod <- fetch_astronomy_daily()
weather <- fetch_current_weather(latitude=YOUR_LAT, longitude=YOUR_LON)
crypto <- fetch_crypto_prices()

# All functions return lists/data frames or NULL on error
```

### Adding New Data Sources
1. Create new function in `fetch_current_data.R` following the pattern
2. Add a new code chunk in `daily_report.qmd` that calls it
3. Use `kableExtra::kable()` for tables, `ggplot2` for charts
4. Wrap in error handling: test if data is NULL before display

## 📋 Project-Specific Conventions

### Public APIs Used (All Free, No Auth Required)
| Data Source | API | Notes |
|---|---|---|
| Astronomy | NASA APOD | Uses DEMO_KEY (rate-limited) |
| Weather | Open-Meteo | No key needed, high rate limits |
| Crypto | CoinGecko | No key, free tier has good limits |
| Time | World Time API | Timezone data, no key |
| Facts | Useless Facts | Random facts, no key |
| Holidays | Nager.Date | Holiday calendar, no key |

**Important**: Keep DEMO_KEY in code for testing. For production, replace with real NASA API key or use alternative.

### Report Sections (Established Order)
1. Dashboard Overview (metadata)
2. Astronomy Picture + explanation
3. Current Weather (temperature, wind, humidity)
4. Cryptocurrency Prices (with market cap & 24h volume)
5. World Timezone Clock (4+ major cities)
6. Fun Fact + Holiday info
7. Data Quality (fetch timestamps, API status)

### HTML Output Conventions
- Theme: `darkly` (dark background, high contrast)
- Code folding: enabled (users can hide R code)
- TOC: true with depth 2
- Embed resources: true (single HTML file, no external deps)
- Self-contained is critical for sharing/archiving

## 🚀 Next Implementation Phases (From Plan)

### Phase 1: Script Refactoring (Priority)
- Move API functions to `R/api_functions/` (separate files)
- Create `R/utils.R` for shared error handling
- Create `R/aggregator.R` with `fetch_all_data()` function
- Update `daily_report.qmd` to source modularized functions

### Phase 3: Visualizations (High Value)
- Add `plotly` charts for crypto trends
- Weather gauge visualization
- World clock with multiple timezones
- Create `R/visualizations.R` with plot functions

### Phase 4: Windows Task Scheduler Automation
- Create `.bat` file: `render_daily.bat` (calls `Rscript render_report.R`)
- Schedule in Task Scheduler: Daily at 6 AM
- Output directory: `docs/daily_report.html`
- Enable retry on failure with 30-minute interval

## 🔧 Common Troubleshooting

| Issue | Solution |
|---|---|
| Package installation fails | Run `render_report.R` (auto-installs all deps) |
| Quarto not found | Use `daily_report.Rmd` instead, or install Quarto |
| API returns NULL | Check internet connection, API rate limits, or API status |
| HTML doesn't embed images | Ensure `embed-resources: true` in YAML header |
| Report generation is slow | Parallel API calls recommended in Phase 3 |

## 📁 File Responsibilities

- **fetch_current_data.R** - Pure data fetching (current monolithic version)
- **reports/daily_report.qmd** - Primary report template (Quarto format)
- **reports/daily_report.Rmd** - Fallback RMarkdown template
- **scripts/render_report.R** - Standalone rendering script (handles package deps)
- **scripts/install_packages.R** - Helper for package installation
- **R/api_functions/** - (Phase 1) Modularized API functions (astronomy, weather, crypto, etc.)
- **R/utils.R** - (Phase 1) Shared error handling and formatting utilities
- **R/aggregator.R** - (Phase 1) `fetch_all_data()` single-source function
- **output/** - Generated HTML reports saved here
- **QUARTO_REPORT_PLAN.md** - Roadmap and design decisions

## 💡 When Adding Features

1. **New API data source?** Create function in `fetch_current_data.R`, add code chunk to report
2. **New visualization?** Add to `R/visualizations.R`, call from report code chunk
3. **Automation needed?** Create `.bat` batch file + Task Scheduler entry
4. **Performance issues?** Consider moving APIs to `R/api_functions/` for parallel execution
5. **Styling changes?** Modify Quarto YAML `format.html` section (theme, fonts, colors)

---

**Last Updated**: January 18, 2026 | **Status**: MVP Report Complete, Phase 1 Refactoring Pending

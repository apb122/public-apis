# 📊 Current Information Dashboard

An automated R/Quarto report that fetches real-time data from 6+ public APIs daily and generates a beautiful, self-contained HTML dashboard.

## 🎯 Quick Start

### Generate Report Now
```bash
cd scripts
Rscript render_report.R
```
Output: `../output/daily_report.html`

### Test the APIs
```r
source("R/aggregator.R")
all_data <- fetch_all_data()
```

## 📁 Project Structure

```
ADD/
├── R/                          # Core R functions (Phase 1 ✅)
│   ├── utils.R                 # Shared error handling
│   ├── aggregator.R            # fetch_all_data() - unified interface
│   └── api_functions/          # Modularized API functions
│       ├── astronomy.R         # NASA APOD
│       ├── weather.R           # Open-Meteo
│       ├── crypto.R            # CoinGecko
│       ├── time_info.R         # World Time API
│       ├── facts.R             # Useless Facts
│       └── holidays.R          # Nager.Date
├── reports/                    # Report templates
│   ├── daily_report.qmd        # Quarto (primary)
│   └── daily_report.Rmd        # RMarkdown (refactored)
├── scripts/                    # Automation scripts
│   ├── render_report.R         # Main rendering script
│   └── install_packages.R      # Package setup
├── output/                     # Generated HTML reports
├── .github/
│   └── copilot-instructions.md # AI agent guide
├── fetch_current_data.R        # Original reference script
├── QUARTO_REPORT_PLAN.md       # 6-phase roadmap
└── PHASE_1_COMPLETE.md         # Phase 1 summary
```

## 🔌 Data Sources (All Free, No Auth)

| Source | API | Data |
|---|---|---|
| 🔭 Astronomy | NASA APOD | Daily picture + explanation |
| 🌤️ Weather | Open-Meteo | Temperature, wind, humidity |
| ₿ Crypto | CoinGecko | BTC/ETH/ADA prices + market cap |
| ⏰ Time | World Time API | Current time in 3 timezones |
| 💡 Facts | Useless Facts | Random daily fact |
| 🎉 Holidays | Nager.Date | Today's holidays (US) |

## 📊 Report Features

- **Dark Theme** - Beautiful `darkly` Quarto/RMarkdown theme
- **Interactive Charts** - Plotly visualizations (zoom, hover, pan)
- **Temperature Gauge** - Color-coded weather visualization
- **World Clock** - Real-time 3-city display (NYC, London, Tokyo)
- **Responsive** - Mobile-friendly HTML output
- **Self-Contained** - Single HTML file, no external dependencies
- **Error Resilient** - One API down? Report still works
- **Auto-Embedded** - Images and resources embedded in HTML
- **Code Folding** - Hide R code by default

## 🚀 Development Roadmap

- ✅ **Phase 1** - Script Refactoring (COMPLETE)
  - Modularized API functions
  - Unified error handling
  - Professional folder structure

- ✅ **Phase 2** - Visualizations (COMPLETE)
  - Crypto price charts (plotly)
  - Weather gauges (temperature visual)
  - World clock (3 timezones, interactive)

- 🔄 **Phase 3** - Performance & Caching
  - Parallel API calls (concurrent fetching)
  - Response caching
  - Reduced report generation time

- ⚙️ **Phase 4** - Automation
  - Windows Task Scheduler
  - Daily 6 AM execution
  - Report archiving

- 📁 **Phase 5** - Project Structure
  - Makefile/Task runners
  - Automated testing

## 🔧 Common Commands

```bash
# Generate report
cd scripts
Rscript render_report.R

# Test individual API
Rscript -e "source('../R/aggregator.R'); fetch_astronomy_daily()"

# Install dependencies
Rscript install_packages.R

# View generated report
open ../output/daily_report.html  # macOS
start ../output/daily_report.html # Windows
xdg-open ../output/daily_report.html # Linux
```

## 📚 Documentation

- **[PHASE_2_COMPLETE.md](PHASE_2_COMPLETE.md)** - Phase 2 visualizations summary
- **[PHASE_1_COMPLETE.md](PHASE_1_COMPLETE.md)** - Phase 1 refactoring summary
- **[QUARTO_REPORT_PLAN.md](QUARTO_REPORT_PLAN.md)** - Full 6-phase roadmap
- **[.github/copilot-instructions.md](.github/copilot-instructions.md)** - AI agent guide
- **[R/visualizations.R](R/visualizations.R)** - Visualization functions (documented)
- **[R/utils.R](R/utils.R)** - Utility functions (documented)
- **[R/aggregator.R](R/aggregator.R)** - Aggregator function (documented)

## 🐛 Troubleshooting

| Issue | Solution |
|---|---|
| "Package not found" | Run: `Rscript install_packages.R` |
| "Pandoc not found" | Install: `choco install pandoc` or use Quarto |
| "API timeout" | Check internet. APIs have rate limits. |
| "Missing dependencies" | See `.github/copilot-instructions.md` |

## 📝 Usage Example

```r
# Load modularized APIs
source("R/aggregator.R")

# Fetch all data
all_data <- fetch_all_data()

# Access individual components
print(all_data$astronomy$data$title)        # APOD title
print(all_data$weather$data$temperature)    # Current temp
print(all_data$crypto$data$bitcoin$price)   # BTC price
```

## 🤝 Contributing

To add a new data source:
1. Create `R/api_functions/new_source.R` with `fetch_new_source()`
2. Add to `R/aggregator.R`
3. Add section to `reports/daily_report.Rmd`
4. Run: `Rscript render_report.R`

## 📄 License

MIT - Feel free to use and modify

---

**Status:** Phase 2 Complete ✅ | **Last Updated:** January 18, 2026 | **Next:** Phase 3 (Parallel APIs or Advanced Features)

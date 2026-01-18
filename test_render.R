#!/usr/bin/env Rscript
# Simple test runner with full error output

Sys.setenv(CID_SEQUENTIAL = "1")

# Set working directory explicitly
setwd("C:/Users/Alex/ADD")

cat("=== Loading render_report script ===\n")
source("scripts/render_report.R")

cat("\n=== Starting main() ===\n")
main()

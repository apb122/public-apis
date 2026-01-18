# CoinGecko Cryptocurrency Prices API
# Source: https://www.coingecko.com/api (No API key required)

#' Fetch Cryptocurrency Prices
#' 
#' @param coins Vector of coin IDs to fetch (default: bitcoin, ethereum, cardano)
#'
#' @return List with status, data (prices with market cap and volume), and metadata
#'
#' @details
#' Returns current prices in USD with market cap and 24h trading volume.
#' No API key required. Free tier has good rate limits.
#'
#' @examples
#' \dontrun{
#'   # Default coins
#'   result <- fetch_crypto_prices()
#'   
#'   # Custom coins
#'   result <- fetch_crypto_prices(c("bitcoin", "ethereum", "solana"))
#' }
#'
fetch_crypto_prices <- function(coins = c("bitcoin", "ethereum", "cardano")) {
  if (!is.character(coins) || length(coins) < 1) {
    stop("coins must be a character vector with at least 1 element")
  }
  coin_ids <- paste(coins, collapse = ",")
  
  url <- sprintf(
    "https://api.coingecko.com/api/v3/simple/price?ids=%s&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true",
    coin_ids
  )
  
  result <- safe_api_call(url, "CoinGecko Crypto Prices")
  
  if (is_success(result)) {
    # Transform data into more usable format
    crypto_data <- lapply(result$data, function(coin) {
      list(
        price = coin$usd,
        market_cap = coin$usd_market_cap,
        volume_24h = coin$usd_24h_vol,
        change_24h = coin$usd_24h_change
      )
    })
    result$data <- crypto_data
  }
  
  return(result)
}

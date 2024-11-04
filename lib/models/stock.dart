/// Represents a stock with its symbol and current price.
class Stock {
  /// The stock symbol (e.g., AAPL, GOOG).
  final String symbol;

  /// The current price of the stock.
  double currentPrice;

  /// Constructs a [Stock] with the given symbol and price.
  Stock({required this.symbol, required this.currentPrice});
}
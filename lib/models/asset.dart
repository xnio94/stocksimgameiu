/// Represents an individual asset in the user's portfolio.
class Asset {
  /// The stock symbol (e.g., AAPL, GOOG).
  final String symbol;

  /// The quantity of the asset owned.
  final double quantity;

  /// The price at which the asset was traded.
  final double tradePrice;

  /// The type of trade performed ('Buy' or 'Sell').
  final String tradeType; // 'Buy' or 'Sell'

  /// Constructs an [Asset] instance with the required fields.
  Asset({
    required this.symbol,
    required this.quantity,
    required this.tradePrice,
    required this.tradeType,
  });
}
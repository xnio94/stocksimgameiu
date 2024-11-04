import 'asset.dart';

/// Represents a user's portfolio containing assets and available cash.
class Portfolio {
  /// List of assets owned by the user.
  final List<Asset> assets;

  /// Available cash in the portfolio.
  final double cash;

  /// Constructs a [Portfolio] with the given assets and cash.
  Portfolio({required this.assets, required this.cash});

  /// Converts the [Portfolio] instance to a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'cash': cash,
      'assets': {
        for (var asset in assets) asset.symbol: {
          'quantity': asset.quantity,
          'trade_price': asset.tradePrice,
          'trade_type': asset.tradeType,
        },
      },
    };
  }

  /// Creates a [Portfolio] instance from a Firestore map.
  factory Portfolio.fromMap(Map<String, dynamic> map) {
    List<Asset> assets = [];
    if (map['assets'] != null) {
      map['assets'].forEach((symbol, assetData) {
        assets.add(Asset(
          symbol: symbol,
          quantity: (assetData['quantity'] as num).toDouble(),
          tradePrice: (assetData['trade_price'] as num).toDouble(),
          tradeType: assetData['trade_type'] as String,
        ));
      });
    }
    double cash = (map['cash'] as num?)?.toDouble() ?? 0.0;
    return Portfolio(assets: assets, cash: cash);
  }
}
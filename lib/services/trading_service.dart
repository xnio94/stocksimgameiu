import 'package:firebase_auth/firebase_auth.dart';
import '../models/stock.dart';
import '../models/portfolio.dart';
import '../models/asset.dart';
import 'firestore_service.dart';
import 'portfolio_service.dart';
import '../global_variables.dart';

/// Service for handling trading operations such as fetching stocks and executing trades.
class TradingService {
  /// Service for interacting with Firestore.
  final FirestoreService _firestoreService = FirestoreService();

  /// Instance of FirebaseAuth.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches a list of 26 random non-mainstream stocks for trading.
  ///
  /// Returns a [List<Stock>] containing stock symbols and their initial prices.
  /// Throws an [Exception] if the operation fails.
  Future<List<Stock>> getRandomStocks() async {
    try {
      // Replace this with actual logic to fetch 26 random non-mainstream stocks.
      List<Stock> stocks = [
        Stock(symbol: 'FTEL', currentPrice: 10.5),
        Stock(symbol: 'WGS', currentPrice: 20.3),
        Stock(symbol: 'CRBP', currentPrice: 15.7),
        Stock(symbol: 'MDIA', currentPrice: 8.9),
        Stock(symbol: 'ALAR', currentPrice: 12.4),
        Stock(symbol: 'AGBA', currentPrice: 5.6),
        Stock(symbol: 'INSG', currentPrice: 9.1),
        Stock(symbol: 'LBPH', currentPrice: 14.2),
        Stock(symbol: 'LSF', currentPrice: 7.8),
        Stock(symbol: 'ROOT', currentPrice: 11.3),
        Stock(symbol: 'ELEV', currentPrice: 6.5),
        Stock(symbol: 'SEZL', currentPrice: 13.9),
        Stock(symbol: 'CADL', currentPrice: 4.4),
        Stock(symbol: 'RZLT', currentPrice: 16.0),
        Stock(symbol: 'RNA', currentPrice: 19.5),
        Stock(symbol: 'IPW', currentPrice: 3.3),
        Stock(symbol: 'BMR', currentPrice: 17.8),
        Stock(symbol: 'AEYE', currentPrice: 22.1),
        Stock(symbol: 'JAN', currentPrice: 18.6),
        Stock(symbol: 'DAVE', currentPrice: 21.4),
        Stock(symbol: 'NVDA', currentPrice: 500.0), // Example mainstream stock
        Stock(symbol: 'ANET', currentPrice: 300.0), // Example mainstream stock
        Stock(symbol: 'MU', currentPrice: 60.0), // Example mainstream stock
        Stock(symbol: 'AVGO', currentPrice: 400.0), // Example mainstream stock
        Stock(symbol: 'KLAC', currentPrice: 130.0), // Example mainstream stock
        Stock(symbol: 'QCOM', currentPrice: 150.0), // Example mainstream stock
      ];

      // Shuffle the list to randomize and take the first 26 stocks.
      stocks.shuffle();
      return stocks.take(26).toList();
    } catch (e) {
      throw Exception('Failed to fetch stocks: ${e.toString()}');
    }
  }

  /// Executes a trade (buy or sell) for a specified stock.
  ///
  /// Parameters:
  /// - [symbol]: The stock symbol.
  /// - [tradeType]: Type of trade ('Buy' or 'Sell').
  /// - [priceType]: Type of price to use ('buy' or 'sell').
  /// - [quantity]: Quantity of the stock to trade.
  /// - [currentPrice]: Current price of the stock.
  ///
  /// Returns [true] if the trade is successful.
  /// Throws an [Exception] if the trade fails.
  Future<bool> executeTrade(String symbol, String tradeType, String priceType, double quantity, double currentPrice) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      // Simulate trade execution delay for realism.
      await Future.delayed(const Duration(seconds: 2));

      // Fetch the user's current portfolio.
      PortfolioService portfolioService = PortfolioService();
      Portfolio portfolio = await portfolioService.getUserPortfolio();

      double tradePrice;
      double tradeAmount;

      if (tradeType == 'Buy') {
        // Calculate the trade price with the spread for a buy order.
        tradePrice = currentPrice * (1 + priceSpread / 2);
        tradeAmount = tradePrice * quantity;

        // Check if the user has sufficient cash to execute the buy trade.
        if (portfolio.cash < tradeAmount) {
          throw Exception('Insufficient cash to execute buy trade.');
        }

        // Deduct the trade amount from cash.
        double updatedCash = portfolio.cash - tradeAmount;

        // Check if the asset already exists in the portfolio.
        int assetIndex = portfolio.assets.indexWhere((asset) => asset.symbol == symbol);
        if (assetIndex == -1) {
          // Add the new asset if it doesn't exist.
          portfolio.assets.add(Asset(
            symbol: symbol,
            quantity: quantity,
            tradePrice: tradePrice,
            tradeType: tradeType,
          ));
        } else {
          // Update the existing asset's quantity and trade price.
          Asset existingAsset = portfolio.assets[assetIndex];
          double newQuantity = existingAsset.quantity + quantity;
          portfolio.assets[assetIndex] = Asset(
            symbol: symbol,
            quantity: newQuantity,
            tradePrice: tradePrice,
            tradeType: tradeType,
          );
        }

        // Update the portfolio's cash balance.
        portfolio = Portfolio(
          assets: portfolio.assets,
          cash: updatedCash,
        );
      } else if (tradeType == 'Sell') {
        // Calculate the trade price with the spread for a sell order.
        tradePrice = currentPrice * (1 - priceSpread / 2);
        tradeAmount = tradePrice * quantity;

        // Check if the asset exists in the portfolio.
        int assetIndex = portfolio.assets.indexWhere((asset) => asset.symbol == symbol);
        if (assetIndex == -1) {
          throw Exception('No existing position to sell.');
        }

        Asset existingAsset = portfolio.assets[assetIndex];
        if (existingAsset.quantity < quantity) {
          throw Exception('Insufficient quantity to sell.');
        }

        // Update or remove the asset based on the remaining quantity.
        double newQuantity = existingAsset.quantity - quantity;
        if (newQuantity == 0) {
          portfolio.assets.removeAt(assetIndex);
        } else {
          portfolio.assets[assetIndex] = Asset(
            symbol: symbol,
            quantity: newQuantity,
            tradePrice: tradePrice,
            tradeType: tradeType,
          );
        }

        // Add the trade amount to cash.
        double updatedCash = portfolio.cash + tradeAmount;
        portfolio = Portfolio(
          assets: portfolio.assets,
          cash: updatedCash,
        );
      } else {
        throw Exception('Invalid trade type.');
      }

      // Save the updated portfolio to Firestore.
      await portfolioService.updatePortfolio(portfolio);

      return true;
    } catch (e) {
      throw Exception('Trade execution failed: ${e.toString()}');
    }
  }
}
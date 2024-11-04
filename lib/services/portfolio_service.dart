import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/portfolio.dart';
import '../models/asset.dart';
import '../global_variables.dart';

/// Service for managing the user's portfolio in Firestore.
class PortfolioService {
  /// Instance of FirebaseFirestore.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Instance of FirebaseAuth.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retrieves the user's portfolio from Firestore.
  ///
  /// Returns [Portfolio] if found, otherwise initializes with [initialCash].
  /// Throws an [Exception] if the operation fails.
  Future<Portfolio> getUserPortfolio() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      DocumentSnapshot doc =
          await _firestore.collection('portfolios').doc(user.uid).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<Asset> assets = [];
        double cash = (data['cash'] as num?)?.toDouble() ?? initialCash;
        if (data['assets'] != null) {
          data['assets'].forEach((key, value) {
            assets.add(Asset(
              symbol: key,
              quantity: (value['quantity'] as num).toDouble(),
              tradePrice: (value['trade_price'] as num).toDouble(),
              tradeType: value['trade_type'] as String,
            ));
          });
        }
        return Portfolio(assets: assets, cash: cash);
      } else {
        // Return initial portfolio with initial cash if none exists.
        return Portfolio(assets: [], cash: initialCash);
      }
    } catch (e) {
      throw Exception('Failed to retrieve portfolio: ${e.toString()}');
    }
  }

  /// Creates the initial portfolio for a new user with [initialCash].
  ///
  /// Throws an [Exception] if the operation fails.
  Future<void> createInitialPortfolio() async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      Portfolio initialPortfolio = Portfolio(assets: [], cash: initialCash);
      await _firestore.collection('portfolios').doc(user.uid).set(initialPortfolio.toMap());
    } catch (e) {
      throw Exception('Failed to create initial portfolio: ${e.toString()}');
    }
  }

  /// Updates the user's portfolio in Firestore.
  ///
  /// Throws an [Exception] if the operation fails.
  Future<void> updatePortfolio(Portfolio portfolio) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      Map<String, dynamic> data = portfolio.toMap();
      await _firestore
          .collection('portfolios')
          .doc(user.uid)
          .set(data);
    } catch (e) {
      throw Exception('Failed to update portfolio: ${e.toString()}');
    }
  }

  /// Closes a position in a specified asset and updates the portfolio accordingly.
  ///
  /// Throws an [Exception] if the operation fails or if asset conditions are not met.
  Future<void> closePosition(String symbol, double currentPrice) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      Portfolio portfolio = await getUserPortfolio();

      Asset? assetToClose = portfolio.assets.firstWhere(
          (asset) => asset.symbol == symbol,
          orElse: () => throw Exception('Asset not found in portfolio'));

      double tradeAmount;
      if (assetToClose.tradeType == 'Buy') {
        // Calculate the amount based on current price for a buy trade.
        tradeAmount = currentPrice * assetToClose.quantity;
      } else if (assetToClose.tradeType == 'Sell') {
        // Calculate the amount based on current price for a sell trade.
        tradeAmount = currentPrice * assetToClose.quantity;
      } else {
        throw Exception('Invalid trade type.');
      }

      // Update cash based on the trade.
      double updatedCash = portfolio.cash + tradeAmount;

      // Remove the asset from the portfolio.
      List<Asset> updatedAssets = List.from(portfolio.assets);
      updatedAssets.removeWhere((asset) => asset.symbol == symbol);

      Portfolio updatedPortfolio = Portfolio(assets: updatedAssets, cash: updatedCash);

      // Update the portfolio in Firestore.
      await updatePortfolio(updatedPortfolio);
    } catch (e) {
      throw Exception('Failed to close position: ${e.toString()}');
    }
  }

  // Additional methods to manage the portfolio can be added here.
}
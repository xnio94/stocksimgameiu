import 'package:flutter/material.dart';
import '../global_variables.dart';
import '../services/portfolio_service.dart';
import '../models/portfolio.dart';
import '../models/asset.dart';
import '../services/real_time_prices.dart';

/// Represents the portfolio page where users can view and manage their assets.
class PortfolioPage extends StatefulWidget {
  /// Stream providing real-time price updates.
  final Stream<Map<String, double>> currentStream;

  const PortfolioPage({super.key, required this.currentStream});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  /// Service for handling portfolio-related operations.
  final PortfolioService _portfolioService = PortfolioService();

  /// The user's portfolio data.
  Portfolio?  _portfolio;

  /// Indicates if the portfolio is currently loading.
  bool _isLoading = true;

  /// Stores error messages to display to the user.
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Load the user's portfolio when the page initializes.
    _loadPortfolio();
  }

  /// Fetches the user's portfolio from Firestore.
  Future<void> _loadPortfolio() async {
    try {
      Portfolio fetchedPortfolio = await _portfolioService.getUserPortfolio();
      setState(() {
        _portfolio = fetchedPortfolio;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load portfolio: ${e.toString()}';
        _isLoading = false;
      });
      throw Exception('Failed to retrieve portfolio: ${e.toString()}');
    }
  }

  /// Refreshes the portfolio data.
  Future<void> _refreshPortfolio() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    await _loadPortfolio();
  }

  /// Closes a position in a specified asset.
  Future<void> _closePosition(String symbol, double currentPrice) async {
    try {
      await _portfolioService.closePosition(symbol, currentPrice);
      await _loadPortfolio();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Position in $symbol closed successfully.')),
      );
    } catch (e) {
      _showErrorDialog('Failed to close position: ${e.toString()}');
    }
  }

  /// Displays an error dialog with the provided message.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Builds the view of the portfolio with current asset data.
  Widget _buildPortfolioView(Map<String, double> currentPrices) {
    if (_portfolio == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshPortfolio,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Available Cash: \$${_portfolio!.cash.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          if (_portfolio!.assets.isNotEmpty) _buildHeader(),
          if (_portfolio!.assets.isNotEmpty)
            ..._portfolio!.assets.map((asset) {
              double currentPrice = currentPrices[asset.symbol] ?? 0.0;
              double positionValue = asset.quantity * currentPrice;
              double pl = (currentPrice - asset.tradePrice) * asset.quantity;
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(asset.symbol),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('\$${currentPrice.toStringAsFixed(2)}', textAlign: TextAlign.center),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(asset.quantity.toStringAsFixed(2), textAlign: TextAlign.center),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('\$${pl.toStringAsFixed(2)}', textAlign: TextAlign.center),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text('\$${positionValue.toStringAsFixed(2)}', textAlign: TextAlign.center),
                    ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _closePosition(asset.symbol, currentPrice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text(
                          'Close Position',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          if (_portfolio!.assets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No assets in portfolio.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the header row for the portfolio table.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      color: Colors.grey[200],
      child: Row(
        children: const [
          Expanded(
            flex: 2,
            child: Text(
              'Asset',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Current Price',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Quantity',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'P/L',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Value',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Action',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the list of portfolio assets with real-time price updates.
  Widget _buildPortfolioList(Map<String, double> currentPrices) {
    return Column(
      children: [
        _buildHeader(),
        ..._portfolio!.assets.map((asset) {
          double currentPrice = currentPrices[asset.symbol] ?? 0.0;
          double positionValue = asset.quantity * currentPrice;
          double pl = (currentPrice - asset.tradePrice) * asset.quantity;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(asset.symbol),
                ),
                Expanded(
                  flex: 3,
                  child: Text('\$${currentPrice.toStringAsFixed(2)}', textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 2,
                  child: Text(asset.quantity.toStringAsFixed(2), textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 3,
                  child: Text('\$${pl.toStringAsFixed(2)}', textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 3,
                  child: Text('\$${positionValue.toStringAsFixed(2)}', textAlign: TextAlign.center),
                ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _closePosition(asset.symbol, currentPrice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text(
                      'Close Position',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading indicator while fetching portfolio data.
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      // Display error message if there was an issue fetching the portfolio.
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return StreamBuilder<Map<String, double>>(
      stream: widget.currentStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Display error message if there was an issue with the price stream.
          return Center(
            child: Text(
              'Error loading prices: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData) {
          // Show a loading indicator while waiting for price data.
          return const Center(child: CircularProgressIndicator());
        }

        Map<String, double> currentPrices = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildPortfolioView(currentPrices),
        );
      },
    );
  }
}
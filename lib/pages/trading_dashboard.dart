import 'package:flutter/material.dart';
import '../services/trading_service.dart';
import '../models/stock.dart';
import 'trade_execution_page.dart';
import '../services/real_time_prices.dart';
import '../global_variables.dart';

/// Represents the trading dashboard where users can view and trade stocks.
class TradingDashboard extends StatefulWidget {
  /// Stream providing real-time price updates.
  final Stream<Map<String, double>> currentStream;

  const TradingDashboard({super.key, required this.currentStream});

  @override
  State<TradingDashboard> createState() => _TradingDashboardState();
}

class _TradingDashboardState extends State<TradingDashboard> {
  /// Service for handling trading operations.
  final TradingService _tradingService = TradingService();

  /// List of stocks available for trading.
  List<Stock> _stocks = [];

  /// Indicates if the stock data is currently loading.
  bool _isLoading = true;

  /// Stores error messages to display to the user.
  String _errorMessage = '';

  /// Stores previous prices to determine price changes.
  Map<String, double> _previousPrices = {}; // Store previous prices

  @override
  void initState() {
    super.initState();
    // Initialize and fetch the list of stocks.
    _initializeStocks();
  }

  /// Fetches a list of random stocks for the trading dashboard.
  Future<void> _initializeStocks() async {
    try {
      List<Stock> fetchedStocks = await _tradingService.getRandomStocks();
      setState(() {
        _stocks = fetchedStocks;
        _isLoading = false;
      });
    } catch (e) {
      _showErrorDialog('Failed to load stocks: ${e.toString()}');
      throw Exception('Failed to fetch stocks: ${e.toString()}');
    }
  }

  /// Opens the trade execution dialog for the selected stock.
  void _showTradeExecutionDialog(Stock stock) {
    showDialog(
      context: context,
      builder: (context) => TradeExecutionPage(
        stock: stock,
        currentStream: widget.currentStream,
      ),
    );
  }

  /// Opens the price history dialog for the selected stock.
  void _showPriceHistoryDialog(Stock stock) {
    showDialog(
      context: context,
      builder: (context) => PriceHistoryDialog(
        stockSymbol: stock.symbol,
        currentStream: widget.currentStream,
      ),
    );
  }

  /// Displays an error dialog with the provided message.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trading Dashboard Error'),
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

  /// Builds the header row for the trading dashboard table.
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
              'Buy Price',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Sell Price',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'History',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a row representing a single stock in the trading dashboard.
  Widget _buildStockRow(Stock stock, double currentPrice) {
    double buyPrice = currentPrice * (1 + priceSpread / 2);
    double sellPrice = currentPrice * (1 - priceSpread / 2);

    Color backgroundColor = Colors.transparent;

    // Set background color based on price changes compared to previous price.
    if (_previousPrices.containsKey(stock.symbol)) {
      double previousPrice = _previousPrices[stock.symbol]!;
      if (currentPrice > previousPrice) {
        backgroundColor = Colors.green.withOpacity(0.3);
      } else if (currentPrice < previousPrice) {
        backgroundColor = Colors.red.withOpacity(0.3);
      }
    }

    // Update the previous price for the next comparison.
    _previousPrices[stock.symbol] = currentPrice;

    return InkWell(
      onTap: () => _showTradeExecutionDialog(stock),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(stock.symbol),
            ),
            Expanded(
              flex: 3,
              child: Text('\$${buyPrice.toStringAsFixed(2)}', textAlign: TextAlign.center),
            ),
            Expanded(
              flex: 3,
              child: Text('\$${sellPrice.toStringAsFixed(2)}', textAlign: TextAlign.center),
            ),
            Expanded(
              flex: 2,
              child: IconButton(
                icon: const Icon(Icons.history),
                onPressed: () => _showPriceHistoryDialog(stock),
                tooltip: 'View Price History',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the list of stocks for the trading dashboard.
  Widget _buildStockList(Map<String, double> currentPrices) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: _stocks.length,
            itemBuilder: (context, index) {
              final stock = _stocks[index];
              final currentPrice = currentPrices[stock.symbol] ?? 0.0;
              return _buildStockRow(stock, currentPrice);
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show a loading indicator while fetching stock data.
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      // Display error message if there was an issue fetching stocks.
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
          child: _buildStockList(currentPrices),
        );
      },
    );
  }
}

/// Dialog displaying the price history for a specific stock.
class PriceHistoryDialog extends StatefulWidget {
  /// The symbol of the stock whose price history is to be displayed.
  final String stockSymbol;

  /// Stream providing real-time price updates.
  final Stream<Map<String, double>> currentStream;

  const PriceHistoryDialog({
    super.key,
    required this.stockSymbol,
    required this.currentStream,
  });

  @override
  State<PriceHistoryDialog> createState() => _PriceHistoryDialogState();
}

class _PriceHistoryDialogState extends State<PriceHistoryDialog> {
  /// List storing the historical prices of the stock.
  List<double> _priceHistory = [];

  @override
  void initState() {
    super.initState();
    // Listen to the currentStream to build the price history.
    widget.currentStream.listen((prices) {
      if (prices.containsKey(widget.stockSymbol)) {
        setState(() {
          _priceHistory.add(prices[widget.stockSymbol]!);
        });
      }
    }, onError: (error) {
      // Handle stream errors by showing a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error in price stream: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Price History for ${widget.stockSymbol}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: _priceHistory.isEmpty
            ? const Center(child: Text('No price data available.'))
            : ListView.builder(
                itemCount: _priceHistory.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text('${index + 1}'),
                    title: Text('\$${_priceHistory[index].toStringAsFixed(2)}'),
                  );
                },
              ),
      ),
      actions: [
        // Close button to exit the dialog.
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
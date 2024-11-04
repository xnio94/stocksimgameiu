import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/trading_service.dart';
import '../global_variables.dart';

/// Represents the trade execution dialog where users can execute buy or sell orders.
class TradeExecutionPage extends StatefulWidget {
  /// The stock to be traded.
  final Stock stock;

  /// Stream providing real-time price updates.
  final Stream<Map<String, double>> currentStream;

  const TradeExecutionPage({super.key, required this.stock, required this.currentStream});

  @override
  State<TradeExecutionPage> createState() => _TradeExecutionPageState();
}

class _TradeExecutionPageState extends State<TradeExecutionPage> {
  /// Service for handling trading operations.
  final TradingService _tradingService = TradingService();

  /// Controller for the quantity input field.
  final TextEditingController _quantityController = TextEditingController();

  /// Controller for the amount input field.
  final TextEditingController _amountController = TextEditingController();

  /// The type of trade ('Buy' or 'Sell').
  String _tradeType = 'Buy';

  /// Indicates if a trade execution is in progress.
  bool _isExecuting = false;

  /// Stores status messages to display to the user.
  String _statusMessage = '';

  /// Flag to prevent recursive updates when setting controller texts.
  bool _isUpdating = false;

  /// The current price of the stock.
  double _currentPrice = 0.0;

  @override
  void initState() {
    super.initState();
    // Listen to the currentStream to update the currentPrice in real-time.
    widget.currentStream.listen((prices) {
      setState(() {
        _currentPrice = prices[widget.stock.symbol] ?? 0.0;
      });
    });

    // Add listeners to synchronize quantity and amount fields.
    _quantityController.addListener(_onQuantityChanged);
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    // Remove listeners when disposing the widget.
    _quantityController.removeListener(_onQuantityChanged);
    _amountController.removeListener(_onAmountChanged);
    _quantityController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Calculates the buy price based on the current price and spread.
  double get _buyPrice => _currentPrice * (1 + priceSpread / 2);

  /// Calculates the sell price based on the current price and spread.
  double get _sellPrice => _currentPrice * (1 - priceSpread / 2);

  /// Updates the amount field based on the quantity entered.
  void _onQuantityChanged() async {
    if (_isUpdating) return;
    final quantityText = _quantityController.text;
    final quantity = double.tryParse(quantityText) ?? 0.0;
    double price = _tradeType == 'Buy' ? _buyPrice : _sellPrice;
    if (price != 0) { // Avoid division by zero.
      final amount = quantity * price;
      _isUpdating = true;
      _amountController.text = amount.toStringAsFixed(2);
      _isUpdating = false;
    }
  }

  /// Updates the quantity field based on the amount entered.
  void _onAmountChanged() async {
    if (_isUpdating) return;
    final amountText = _amountController.text;
    final amount = double.tryParse(amountText) ?? 0.0;
    double price = _tradeType == 'Buy' ? _buyPrice : _sellPrice;
    if (price != 0) { // Avoid division by zero.
      final quantity = amount / price;
      _isUpdating = true;
      _quantityController.text = quantity.toStringAsFixed(2);
      _isUpdating = false;
    }
  }

  /// Executes the trade when the user confirms the action.
  Future<void> _executeTrade() async {
    double quantity = double.tryParse(_quantityController.text) ?? 0.0;
    if (quantity <= 0.0) {
      setState(() {
        _statusMessage = 'Please enter a valid quantity.';
      });
      return;
    }

    setState(() {
      _isExecuting = true;
      _statusMessage = '';
    });

    try {
      // Determine the type of price to use based on trade type.
      String priceType = _tradeType.toLowerCase(); // 'buy' or 'sell'
      bool success = await _tradingService.executeTrade(
          widget.stock.symbol, _tradeType, priceType, quantity, _currentPrice);
      setState(() {
        _statusMessage =
            success ? 'Trade Executed Successfully!' : 'Trade Failed.';
      });

      if (success) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorDialog('An error occurred during trade execution: ${e.toString()}');
      rethrow;
    } finally {
      setState(() {
        _isExecuting = false;
      });
    }
  }

  /// Displays an error dialog with the provided message.
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trade Execution Error'),
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

  @override
  Widget build(BuildContext context) {
    String currentPriceText = _currentPrice > 0
        ? '\$${_currentPrice.toStringAsFixed(2)}'
        : 'Loading...';

    return AlertDialog(
      title: Text('Trade ${widget.stock.symbol}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Display the current price from the stream.
            StreamBuilder<Map<String, double>>(
              stream: widget.currentStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading price');
                }

                if (!snapshot.hasData) {
                  return const Text('Loading price...');
                }

                double? currentPrice = snapshot.data![widget.stock.symbol];
                if (currentPrice != null) {
                  return Text('Current Price: \$${currentPrice.toStringAsFixed(2)}');
                } else {
                  return const Text('Current Price: N/A');
                }
              },
            ),
            const SizedBox(height: 8),
            // Dropdown to select trade type.
            DropdownButtonFormField<String>(
              value: _tradeType,
              decoration: const InputDecoration(
                labelText: 'Trade Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.swap_vert),
              ),
              items: ['Buy', 'Sell']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _tradeType = value;
                    // Update amount based on new trade type.
                    _onQuantityChanged();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Input for quantity.
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.confirmation_number),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            // Input for amount in dollars.
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount \$',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            // Execute trade button or loading indicator.
            _isExecuting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _executeTrade,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Execute Trade',
                        style: TextStyle(fontSize: 18)),
                  ),
            const SizedBox(height: 16),
            // Display status message after trade execution.
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: TextStyle(
                    color: _statusMessage.contains('Successfully')
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
      actions: [
        // Cancel button to close the dialog.
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
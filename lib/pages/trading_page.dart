import 'package:flutter/material.dart';
import 'trading_dashboard.dart';

/// Represents the trading page, displaying the trading dashboard.
class TradingPage extends StatelessWidget {
  /// Stream providing real-time price updates.
  final Stream<Map<String, double>> currentStream;

  const TradingPage({super.key, required this.currentStream});

  @override
  Widget build(BuildContext context) {
    return TradingDashboard(currentStream: currentStream);
  }
}
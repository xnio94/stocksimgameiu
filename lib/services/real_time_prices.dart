import 'dart:convert';
import 'package:flutter/services.dart';
import '../global_variables.dart';

/// Service for managing and streaming real-time price data from simulation rounds.
class RealTimePrices {
  /// Stores price data for each round and stock.
  static final Map<String, Map<String, List<double>>> _roundData = {};

  /// Stream emitting current prices every second.
  static late Stream<Map<String, double>> currentStream;

  /// The current simulation round number.
  static late int currentRound;

  /// Loads and parses the price data from `assets/data.json`.
  ///
  /// The JSON file should be structured with rounds and corresponding stock price lists.
  /// Example format:
  /// {
  ///     "round_1": {
  ///         "AEYE": [24.05, 24.10, 24.15, ..., 24.50],
  ///         "AGBA": [15.30, 15.35, 15.40, ..., 15.80],
  ///         // ... other stocks
  ///     },
  ///     // ... rounds 2 to 5
  /// }
  ///
  /// Throws an [Exception] if the data fails to load or parse.
  static Future<void> loadData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/data.json');
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      jsonMap.forEach((roundKey, roundValue) {
        _roundData[roundKey] = {};
        (roundValue as Map<String, dynamic>).forEach((stock, prices) {
          _roundData[roundKey]![stock] =
              List<double>.from(prices).sublist(0, simulationDuration.inSeconds);
        });
      });
    } catch (e) {
      throw Exception('Failed to load and parse data.json: $e');
    }
  }

  /// Starts a price stream for a specified simulation round.
  ///
  /// Emits a [Map<String, double>] every second containing current prices of each stock.
  /// If the stream exceeds available data points, it continues to emit the last available prices.
  ///
  /// Throws an [Exception] if the specified round data is not found.
  static Stream<Map<String, double>> startRound(int roundNumber) {
    String roundKey = 'round_$roundNumber';
    if (!_roundData.containsKey(roundKey)) {
      throw Exception('Round $roundNumber data not found.');
    }

    final Map<String, List<double>> stocksData = _roundData[roundKey]!;

    currentRound = roundNumber;
    currentStream = Stream.periodic(Duration(seconds: 1), (t) {
      final Map<String, double> currentPrices = {};
      stocksData.forEach((stock, prices) {
        if (t < prices.length) {
          currentPrices[stock] = prices[t];
        } else {
          currentPrices[stock] = prices.last;
        }
      });
      return currentPrices;
    }).asBroadcastStream();
    return currentStream;
  }
}
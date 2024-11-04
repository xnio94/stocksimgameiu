import 'package:flutter/material.dart';

/// Displays real-time analytics and data visualizations.
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Real-Time Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
              'Real-time data visualization and analytics will be displayed here.'),
        ],
      ),
    );
  }
}
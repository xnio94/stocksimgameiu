import 'package:flutter/material.dart';
import 'user_settings.dart';

/// Represents the settings page where users can manage their account settings.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const UserSettings();
  }
}
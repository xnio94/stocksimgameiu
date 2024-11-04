import 'package:flutter/material.dart';
import 'login_page.dart';
import 'signup_page.dart';

/// Manages the authentication state, toggling between login and sign-up pages.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  /// Determines whether to show the login page or sign-up page.
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return _isLogin
        ? LoginPage(onToggle: () {
            setState(() {
              _isLogin = false;
            });
          })
        : SignUpPage(onToggle: () {
            setState(() {
              _isLogin = true;
            });
          });
  }
}
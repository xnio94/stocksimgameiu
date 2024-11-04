import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

/// Represents the login page where users can authenticate.
class LoginPage extends StatefulWidget {
  /// Callback to toggle between login and sign-up pages.
  final VoidCallback onToggle;

  const LoginPage({super.key, required this.onToggle});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  /// Service for handling authentication tasks.
  final AuthService _authService = AuthService();

  /// Controller for the email input field.
  final TextEditingController _emailController = TextEditingController(text: 'test@test.com');

  /// Controller for the password input field.
  final TextEditingController _passwordController = TextEditingController(text: '951623');

  /// Stores error messages to display to the user.
  String _errorMessage = '';

  /// Indicates if a login operation is in progress.
  bool _isLoading = false;

  /// Handles the login process when the user taps the login button.
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // Attempt to sign in with provided credentials.
      await _authService.signIn(_emailController.text.trim(), _passwordController.text.trim());
      // Navigate to the home page upon successful login.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on AuthException catch (e) {
      // Display authentication errors to the user.
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      // Handle unexpected errors.
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Stock Trading Sim - Login')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.login, size: 100, color: Colors.deepPurple),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onToggle,
                child: const Text("Don't have an account? Sign Up"),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
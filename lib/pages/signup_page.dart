import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/portfolio_service.dart';
import '../models/user_profile.dart';
import 'home_page.dart';

/// Represents the sign-up page where new users can create an account.
class SignUpPage extends StatefulWidget {
  /// Callback to toggle between sign-up and login pages.
  final VoidCallback onToggle;

  const SignUpPage({super.key, required this.onToggle});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  /// Service for handling authentication tasks.
  final AuthService _authService = AuthService();

  /// Service for interacting with Firestore.
  final FirestoreService _firestoreService = FirestoreService();

  /// Service for managing the user's portfolio.
  final PortfolioService _portfolioService = PortfolioService();

  /// Controller for the email input field.
  final TextEditingController _emailController = TextEditingController();

  /// Controller for the password input field.
  final TextEditingController _passwordController = TextEditingController();

  /// Controller for the confirm password input field.
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  /// Controller for the first name input field.
  final TextEditingController _firstNameController = TextEditingController();

  /// Controller for the last name input field.
  final TextEditingController _lastNameController = TextEditingController();

  /// Stores error messages to display to the user.
  String _errorMessage = '';

  /// Indicates if a sign-up operation is in progress.
  bool _isLoading = false;

  /// Handles the sign-up process when the user taps the sign-up button.
  Future<void> _signUp() async {
    // Validate that password and confirm password match.
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "Passwords do not match.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Attempt to create a new user with provided credentials.
      var userCredential = await _authService.signUp(
          _emailController.text.trim(), _passwordController.text.trim());

      // Generate a unique identifier for the new user.
      int uniqueId = await _firestoreService.generateUniqueId();

      // Create a user profile in Firestore.
      await _firestoreService.createUserProfile(UserProfile(
        uid: userCredential.user!.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        uniqueId: uniqueId,
      ));

      // Initialize the user's portfolio with initial cash.
      await _portfolioService.createInitialPortfolio();

      // Navigate to the home page upon successful sign-up.
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
        _errorMessage = 'An unexpected error occurred.';
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
      appBar:
          AppBar(title: const Center(child: Text('Stock Trading Sim - Sign Up'))),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.person_add, size: 100, color: Colors.deepPurple),
              const SizedBox(height: 16),
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
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
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Sign Up',
                          style: TextStyle(fontSize: 18)),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: widget.onToggle,
                child: const Text("Already have an account? Login"),
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
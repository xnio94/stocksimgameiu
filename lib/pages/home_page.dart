import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../global_variables.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_profile.dart';
import '../services/real_time_prices.dart';
import 'auth_page.dart';
import 'portfolio_page.dart';
import 'trading_page.dart';
import 'analytics_page.dart';

/// The main home page of the application, displaying user info and navigation tabs.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  /// Controller for navigating between tabs.
  late TabController _tabController;

  /// Service for handling authentication-related tasks.
  final AuthService _authService = AuthService();

  /// Service for interacting with Firestore.
  final FirestoreService _firestoreService = FirestoreService();

  /// User's first name.
  String _firstName = '';

  /// User's last name.
  String _lastName = '';

  /// User's unique identifier.
  int _uniqueId = 0;

  // Simulation state variables

  /// Current round number in the simulation.
  int _currentRound = 0;

  /// Total number of simulation rounds.
  final int _totalRounds = 5;

  /// Remaining time in seconds for the current simulation round.
  int _remainingTime = 0;

  /// Timer for counting down the simulation time.
  Timer? _timer;

  /// Flag to indicate if a simulation is currently running.
  bool _isSimulationRunning = false;

  /// Stream providing real-time price updates.
  Stream<Map<String, double>>? _currentStream;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with 3 tabs.
    _tabController = TabController(length: 3, vsync: this);
    // Load user data from Firestore.
    _loadUserData();

    // Show the start simulation dialog after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartSimulationDialog();
    });
  }

  /// Loads user data such as name and unique ID from Firestore.
  Future<void> _loadUserData() async {
    User? user = _authService.currentUser;
    if (user != null) {
      try {
        UserProfile? profile = await _firestoreService.getUserProfile(user.uid);
        if (profile != null) {
          setState(() {
            _firstName = profile.firstName;
            _lastName = profile.lastName;
            _uniqueId = profile.uniqueId;
          });
        }
      } catch (e) {
        _showErrorDialog('Failed to load user data: ${e.toString()}');
        throw Exception('Failed to load user data: ${e.toString()}');
      }
    }
  }

  /// Logs out the current user and navigates back to the authentication page.
  Future<void> _logout() async {
    await _authService.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  /// Builds and displays the user's information on the home page.
  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Welcome, $_firstName $_lastName (ID: $_uniqueId)',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
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

  /// Shows a dialog prompting the user to start a new simulation.
  Future<void> _showStartSimulationDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Start New Simulation'),
        content: const Text('Would you like to start a new simulation?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startSimulation();
            },
            child: const Text('Start New Simulation'),
          ),
        ],
      ),
    );
  }

  /// Initiates a new simulation round.
  Future<void> _startSimulation() async {
    await RealTimePrices.loadData();
    setState(() {
      _isSimulationRunning = true;
      _currentRound = 1;
      _remainingTime = simulationDuration.inSeconds;
      _currentStream = RealTimePrices.startRound(_currentRound);
    });
    _startTimer();
  }

  /// Starts the countdown timer for the simulation round.
  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isSimulationRunning = false;
        });
        if (_currentRound < _totalRounds) {
          _showRoundCompletedDialog();
        } else {
          _showFinalResultDialog();
        }
      }
    });
  }

  /// Displays a dialog indicating the completion of the current round.
  Future<void> _showRoundCompletedDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Round $_currentRound Completed'),
        content: const Text('Click "Next Round" to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNextRound();
            },
            child: const Text('Next Round'),
          ),
        ],
      ),
    );
  }

  /// Displays a dialog with the final results after all simulation rounds.
  Future<void> _showFinalResultDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Simulation Completed'),
        content: const Text('Your score: 100%'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Optionally, perform actions after completion.
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Starts the next simulation round.
  Future<void> _startNextRound() async {
    await RealTimePrices.loadData();
    setState(() {
      _currentRound++;
      _remainingTime = simulationDuration.inSeconds;
      _isSimulationRunning = true;
      _currentStream = RealTimePrices.startRound(_currentRound);
    });
    _startTimer();
  }

  /// Formats the remaining time in mm:ss format.
  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    String minsStr = mins.toString().padLeft(2, '0');
    String secsStr = secs.toString().padLeft(2, '0');
    return '$minsStr:$secsStr';
  }

  /// Builds the title for the AppBar based on simulation state.
  Widget _buildAppBarTitle() {
    if (_isSimulationRunning) {
      return Text('Round: $_currentRound | Time: ${_formatTime(_remainingTime)}');
    } else if (_currentRound > 0 && _currentRound <= _totalRounds) {
      return Text('Round: $_currentRound | Time: ${_formatTime(_remainingTime)}');
    } else {
      return const Text('Home Page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: _isSimulationRunning || (_currentRound > 0 && _currentRound <= _totalRounds)
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Trading'),
                  Tab(text: 'Portfolio'),
                  Tab(text: 'Analytics'),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          _buildUserInfo(),
          if (_isSimulationRunning || (_currentRound > 0 && _currentRound <= _totalRounds))
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Round: $_currentRound | Time: ${_formatTime(_remainingTime)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: _isSimulationRunning || (_currentRound > 0 && _currentRound <= _totalRounds)
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      TradingPage(currentStream: _currentStream!),
                      PortfolioPage(currentStream: _currentStream!),
                      const AnalyticsPage(),
                    ],
                  )
                : const Center(
                    child: Text(
                      'Start a simulation to view the tabs.',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
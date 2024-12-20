# Trade Simulation (serious/game)

Trade Simulation is a Flutter application designed to provide users with a simulated environment for trading stocks, this system will be used for conducting research on this subject and study users behaviour. The application integrates Firebase for authentication and data management, offering a comprehensive platform for users to engage in stock trading simulations, manage their portfolios, and analyze their performance through real-time analytics.

## Features

- **User Authentication:** Secure sign-up and login functionalities using Firebase Authentication.
- **Portfolio Management:** Track your assets, view real-time portfolio valuations, and manage cash balances.
- **Trading Dashboard:** Execute buy and sell trades with real-time price updates.
- **Real-Time Analytics:** Monitor your trading performance and analyze market trends.
- **Simulation Rounds:** Engage in multiple rounds of trading simulations to enhance your trading strategies.

## Getting Started

Follow these instructions to set up and run the Trade Simulation application on your local machine.

### Prerequisites

- **Flutter SDK:** Ensure that Flutter is installed on your machine. If not, follow the [Flutter installation guide](https://flutter.dev/docs/get-started/install).
- **Firebase Account:** Create a Firebase account if you don't have one. Visit the [Firebase Console](https://console.firebase.google.com/) to get started. in this project we are using the account stocksimgameiu@gmail.com.
- **FlutterFire CLI:** Install the FlutterFire CLI to configure Firebase in your Flutter project.

### Installing FlutterFire CLI (optional)

1. **Install Firebase CLI via npm:**
   ```bash
   npm install -g firebase-tools
   ```
2. **Install Dart:** Ensure Dart is installed (it should be be installed with flutter), as FlutterFire CLI relies on it. You can install Dart from the [official website](https://dart.dev/get-dart).
3. **Install FlutterFire CLI via Pub:**
   ```bash
   dart pub global activate flutterfire_cli
   ```
4. **Ensure the FlutterFire CLI is in your PATH:**
   - Add the following line to your shell's startup script (e.g., `.bashrc`, `.zshrc`):
     ```bash
     export PATH="$PATH":"$HOME/.pub-cache/bin"
     ```
   - Reload your terminal or source the startup script:
     ```bash
     source ~/.bashrc
     ```

### Setting Up Firebase (optional)

1. **Navigate to the Project Directory:**
   ```bash
   cd path_to_your_project/tradesimulation
   ```
2. **Configure Firebase with FlutterFire CLI:**
   ```bash
   flutterfire configure
   ```
   - Follow the on-screen prompts to select your Firebase project and platforms (iOS, Android, Web, etc.).
   - This command generates the `firebase_options.dart` file in the `lib/` directory.

### Running the Application

1. **unzip the codebase folder and open it**
   ```bash
   git clone https://github.com/xnio94/stocksimgameiu/
   cd tradesimulation
   ```
2. **Get Dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the Application:**
   ```bash
   flutter run
   ```
   - Ensure that you have a simulator/emulator (google chrome) running or a physical device connected.

## Project Structure

- **lib/**: Contains all Dart source files.
  - **models/**: Data models representing assets, portfolios, stocks, and user profiles.
  - **pages/**: UI pages including authentication, home, portfolio, trading, and analytics.
  - **services/**: Business logic and Firebase interactions.
  - **firebase_options.dart**: Firebase configuration generated by FlutterFire CLI.
- **assets/**: Contains static assets like `data.json` for simulation data.
- **pubspec.yaml**: Flutter configuration file managing dependencies and assets.

## Deployment
After modifying the code and adding new features, you can deploy using the following command:
  ```bash
  flutter build web
  firebase deploy
  ```

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)

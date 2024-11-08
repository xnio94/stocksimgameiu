// File generated by FlutterFire CLI.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  /// Returns the Firebase options based on the current platform.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Configuration for Web platform.
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Configuration for Android platform.
        return android;
      case TargetPlatform.iOS:
        // Configuration for iOS platform.
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        // Configuration for Windows platform.
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Firebase options for Web.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDK0W3P10NLmXZdYMs0FOk3EUwWCHzrKVU',
    appId: '1:891263935873:web:363d290b31ce969ee93480',
    messagingSenderId: '891263935873',
    projectId: 'comstocksimgameiu',
    authDomain: 'comstocksimgameiu.firebaseapp.com',
    storageBucket: 'comstocksimgameiu.firebasestorage.app',
    measurementId: 'G-08FBYR24LC',
  );

  /// Firebase options for Android.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfF72quyXIhqh9rJ5VBjOT-St9C97JB5s',
    appId: '1:891263935873:android:bb28452a6e8564fbe93480',
    messagingSenderId: '891263935873',
    projectId: 'comstocksimgameiu',
    storageBucket: 'comstocksimgameiu.firebasestorage.app',
  );

  /// Firebase options for iOS.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBswdnoHpYERZvZbKsRoJf-0hW4c7IPxyI',
    appId: '1:891263935873:ios:c899401b46ea58f9e93480',
    messagingSenderId: '891263935873',
    projectId: 'comstocksimgameiu',
    storageBucket: 'comstocksimgameiu.firebasestorage.app',
    iosBundleId: 'com.example.tradesimulation',
  );

  /// Firebase options for Windows.
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDK0W3P10NLmXZdYMs0FOk3EUwWCHzrKVU',
    appId: '1:891263935873:web:7b37215050a67e4be93480',
    messagingSenderId: '891263935873',
    projectId: 'comstocksimgameiu',
    authDomain: 'comstocksimgameiu.firebaseapp.com',
    storageBucket: 'comstocksimgameiu.firebasestorage.app',
    measurementId: 'G-T2P36712WY',
  );
}
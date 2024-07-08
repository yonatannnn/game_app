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
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC0567-CyZURzwcB07549vXMn627i_ZcLg',
    appId: '1:566363161463:web:fc38609594cd0d7eca5772',
    messagingSenderId: '566363161463',
    projectId: 'number-guessing-game-4fd28',
    authDomain: 'number-guessing-game-4fd28.firebaseapp.com',
    storageBucket: 'number-guessing-game-4fd28.appspot.com',
    measurementId: 'G-CX6PZS5S1X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAemtPExCrzYJHajQuFaigCwyg_0zzLhmQ',
    appId: '1:566363161463:android:eecc08aaad72b47dca5772',
    messagingSenderId: '566363161463',
    projectId: 'number-guessing-game-4fd28',
    storageBucket: 'number-guessing-game-4fd28.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCK6xo2U0eyeTSj7k9oOK-NO5lMC0SYrLE',
    appId: '1:566363161463:ios:e4984db46f376711ca5772',
    messagingSenderId: '566363161463',
    projectId: 'number-guessing-game-4fd28',
    storageBucket: 'number-guessing-game-4fd28.appspot.com',
    iosBundleId: 'com.example.gameApp',
  );
}

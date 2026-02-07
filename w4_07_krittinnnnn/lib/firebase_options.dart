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
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAMQU7GmE978vO4gjsnCac6P6UkHHeFDpw',
    appId: '1:57002802308:web:210114b2e329f5439c56d1',
    messagingSenderId: '57002802308',
    projectId: 'w4-krittin',
    authDomain: 'w4-krittin.firebaseapp.com',
    storageBucket: 'w4-krittin.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCVQ7FY-lqCThPOzF9sR4RwasJFEMiS4XE',
    appId: '1:57002802308:android:4ae7f6c8ff03780c9c56d1',
    messagingSenderId: '57002802308',
    projectId: 'w4-krittin',
    storageBucket: 'w4-krittin.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAtg2u2BGrNvSXOFzEA-Bw8rzHRd_6l_jE',
    appId: '1:57002802308:ios:b4d8b69000fb6e849c56d1',
    messagingSenderId: '57002802308',
    projectId: 'w4-krittin',
    storageBucket: 'w4-krittin.firebasestorage.app',
    iosBundleId: 'com.example.w407Krittinnnnn',
  );
}

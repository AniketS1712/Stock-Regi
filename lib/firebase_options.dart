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
        return macos;
      case TargetPlatform.windows:
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAOHGy6pFiVYynKinVpQY-BGa2neZ_XXBA',
    appId: '1:458836926884:web:7bbee5aace0310fb322131',
    messagingSenderId: '458836926884',
    projectId: 'stock-regi-6e9d4',
    authDomain: 'stock-regi-6e9d4.firebaseapp.com',
    storageBucket: 'stock-regi-6e9d4.firebasestorage.app',
    measurementId: 'G-YMP9JJC45C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBMPGs2HuzTDeX2qK7AAXSxbY39mB2OPwM',
    appId: '1:458836926884:android:756afca4d1262e55322131',
    messagingSenderId: '458836926884',
    projectId: 'stock-regi-6e9d4',
    storageBucket: 'stock-regi-6e9d4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBrZ_d-kwFHZtr1pgBVrwE5K7yJyIxVs3k',
    appId: '1:458836926884:ios:2b2f4aed5b901234322131',
    messagingSenderId: '458836926884',
    projectId: 'stock-regi-6e9d4',
    storageBucket: 'stock-regi-6e9d4.firebasestorage.app',
    iosBundleId: 'com.example.stockRegister',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBrZ_d-kwFHZtr1pgBVrwE5K7yJyIxVs3k',
    appId: '1:458836926884:ios:2b2f4aed5b901234322131',
    messagingSenderId: '458836926884',
    projectId: 'stock-regi-6e9d4',
    storageBucket: 'stock-regi-6e9d4.firebasestorage.app',
    iosBundleId: 'com.example.stockRegister',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAOHGy6pFiVYynKinVpQY-BGa2neZ_XXBA',
    appId: '1:458836926884:web:5774f37359269265322131',
    messagingSenderId: '458836926884',
    projectId: 'stock-regi-6e9d4',
    authDomain: 'stock-regi-6e9d4.firebaseapp.com',
    storageBucket: 'stock-regi-6e9d4.firebasestorage.app',
    measurementId: 'G-8TNHSK7QWQ',
  );
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase configuration shared with the consumer application.
class AdminFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        return web;
    }
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyAYJvaQIxkvz6sLQkzqV4jIP30C74UwH9w',
    appId: '1:20125701812:web:5b1d829fdc4a99e8b069e1',
    messagingSenderId: '20125701812',
    projectId: 'ether-cinema',
    authDomain: 'ether-cinema.firebaseapp.com',
    storageBucket: 'ether-cinema.firebasestorage.app',
  );
  static const android = FirebaseOptions(
    apiKey: 'AIzaSyAeAOeVE_ZLi68dB2gDB4ACnZ0ZqeHjCz8',
    appId: '1:20125701812:android:0e2ff73048a8e608b069e1',
    messagingSenderId: '20125701812',
    projectId: 'ether-cinema',
    storageBucket: 'ether-cinema.firebasestorage.app',
  );
  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyAYJvaQIxkvz6sLQkzqV4jIP30C74UwH9w',
    appId: '1:20125701812:ios:0e2ff73048a8e608b069e1',
    messagingSenderId: '20125701812',
    projectId: 'ether-cinema',
    storageBucket: 'ether-cinema.firebasestorage.app',
    iosBundleId: 'com.example.etherCinema',
  );
}

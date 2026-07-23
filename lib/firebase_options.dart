// File generated for Ether Cinema Enterprise Firebase Options.
// ignore_for_file: type=lint
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class FirebaseOptions {
  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String? authDomain;
  final String? storageBucket;
  final String? iosBundleId;

  const FirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    this.authDomain,
    this.storageBucket,
    this.iosBundleId,
  });
}

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAYJvaQIxkvz6sLQkzqV4jIP30C74UwH9w',
    appId: '1:20125701812:web:5b1d829fdc4a99e8b069e1',
    messagingSenderId: '20125701812',
    projectId: 'ether-cinema',
    authDomain: 'ether-cinema.firebaseapp.com',
    storageBucket: 'ether-cinema.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAeAOeVE_ZLi68dB2gDB4ACnZ0ZqeHjCz8',
    appId: '1:20125701812:android:0e2ff73048a8e608b069e1',
    messagingSenderId: '20125701812',
    projectId: 'ether-cinema',
    storageBucket: 'ether-cinema.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYJvaQIxkvz6sLQkzqV4jIP30C74UwH9w',
    appId: '1:20125701812:ios:0e2ff73048a8e608b069e1',
    messagingSenderId: '20125701812',
    projectId: 'ether-cinema',
    storageBucket: 'ether-cinema.firebasestorage.app',
    iosBundleId: 'com.example.etherCinema',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAYJvaQIxkvz6sLQkzqV4jIP30C74UwH9w',
    appId: '1:20125701812:ios:0e2ff73048a8e608b069e1',
    messagingSenderId: '20125701812',
    projectId: 'ether-cinema',
    storageBucket: 'ether-cinema.firebasestorage.app',
    iosBundleId: 'com.example.etherCinema',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAYJvaQIxkvz6sLQkzqV4jIP30C74UwH9w',
    appId: '1:20125701812:web:5b1d829fdc4a99e8b069e1',
    messagingSenderId: '20125701812',
    projectId: 'ether-cinema',
    authDomain: 'ether-cinema.firebaseapp.com',
    storageBucket: 'ether-cinema.firebasestorage.app',
  );
}

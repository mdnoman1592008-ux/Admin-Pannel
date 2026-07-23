# Ether Cinema Production Deployment Guide

## 1. Android Release Build (Google Play Store)

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
Target Artifact: `build/app/outputs/bundle/release/app-release.aab`

## 2. Flutter Web Admin Portal Build (Firebase Hosting)

```bash
cd admin_panel
flutter pub get
flutter build web --release
firebase deploy --only hosting
```
Target Artifact: `admin_panel/build/web/`

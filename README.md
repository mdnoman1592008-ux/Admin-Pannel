# Ether Cinema v18.0 FINAL Commercial Release

**Ether Cinema** is a commercial-grade, multi-platform OTT streaming ecosystem built with Flutter, Riverpod, Firebase, and Dailymotion Video Engine.

## Project Architecture

- **Consumer Streaming Application (`lib/`)**: Lightweight, high-performance Flutter Android/iOS application with zero admin code overhead.
- **Enterprise Web Admin Portal (`admin_panel/`)**: Standalone Flutter Web application for platform administrators (`super_admin`, `admin`, `moderator`).

## Production Release Checklist

- [x] **Zero Analyzer Errors** (`flutter analyze`)
- [x] **100% Test Pass Rate** (`55/55 test units passed`)
- [x] **Android Release AppBundle Built** (`.aab` output)
- [x] **Flutter Web Admin Portal Hosted** (`admin_panel/`)
- [x] **Firebase Authentication & Firestore RBAC Applied**
- [x] **120 FPS VisionOS Motion Physics & Dailymotion Engine Verified**

## Local Execution

### Run Consumer App
```bash
flutter run
```

### Run Web Admin Portal
```bash
cd admin_panel
flutter run -d chrome
```

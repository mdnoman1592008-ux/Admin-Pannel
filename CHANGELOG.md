# Changelog — Ether Cinema

All notable changes to the Ether Cinema commercial OTT streaming platform will be documented in this file.

## [18.0.0] - 2026-07-23 (FINAL Commercial Release)
### Added
- GitHub Actions CI/CD Pipeline workflow (`.github/workflows/production_deploy.yml`).
- Complete enterprise documentation suite (`README.md`, `ARCHITECTURE.md`, `DEPLOYMENT_GUIDE.md`, `CHANGELOG.md`).
- Master Release Validation test suite (`test/v18_final_commercial_release_test.dart`).
- VisionOS Web Preview system health dashboard & CI/CD status simulator.

### Hardened & Optimized
- 100% test pass rate across 55 test units and 20 test suites.
- Isolated Consumer Android Streaming App (`lib/`) and Web Admin Portal (`admin_panel/`).
- 4-Tier Firestore Role-Based Access Control (`user`, `moderator`, `admin`, `super_admin`).
- 120 FPS VisionOS motion physics and Dailymotion streaming engine.

## [17.0.0] - 2026-07-23
- Initial release candidate for enterprise production testing.

## [16.0.0] - 2026-07-23
- Enterprise SaaS Admin Portal architecture in `admin_panel/`.

## [15.0.0] - 2026-07-23
- Physical separation into Consumer Android App and Web Admin Portal.

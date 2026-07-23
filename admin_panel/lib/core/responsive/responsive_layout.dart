import 'package:flutter/material.dart';

/// Screen Size Breakpoints for Ether Cinema Web Admin Panel
class Breakpoints {
  static const double mobileMax = 600;
  static const double tabletMax = 1024;
  static const double laptopMax = 1440;
}

enum DeviceType {
  mobile,
  tablet,
  laptop,
  desktop,
}

/// Adaptive & Responsive Layout Builder Widget
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.desktop,
    this.tablet,
    this.mobile,
  });

  final Widget desktop;
  final Widget? tablet;
  final Widget? mobile;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= Breakpoints.mobileMax) return DeviceType.mobile;
    if (width <= Breakpoints.tabletMax) return DeviceType.tablet;
    if (width <= Breakpoints.laptopMax) return DeviceType.laptop;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop ||
      getDeviceType(context) == DeviceType.laptop;

  @override
  Widget build(BuildContext context) {
    final device = getDeviceType(context);

    if (device == DeviceType.mobile && mobile != null) {
      return mobile!;
    }

    if (device == DeviceType.tablet && tablet != null) {
      return tablet!;
    }

    return desktop;
  }
}

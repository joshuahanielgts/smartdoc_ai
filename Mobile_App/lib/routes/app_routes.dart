import 'package:flutter/material.dart';
import '../presentation/dashboard_screen/dashboard_screen.dart';
import '../presentation/driver_calibration_screen/driver_calibration_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/monitor_screen/monitor_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String dashboard = '/dashboard-screen';
  static const String driverCalibration = '/driver-calibration-screen';
  static const String settings = '/settings-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String monitor = '/monitor-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const OnboardingFlow(),
    dashboard: (context) => const DashboardScreen(),
    driverCalibration: (context) => const DriverCalibrationScreen(),
    settings: (context) => const SettingsScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    monitor: (context) => const MonitorScreen(),
    // TODO: Add your other routes here
  };
}

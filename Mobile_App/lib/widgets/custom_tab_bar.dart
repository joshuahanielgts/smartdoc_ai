import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom tab bar widget optimized for automotive safety applications
/// Provides clear visual hierarchy and touch-friendly navigation
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorWeight = 3.0,
    this.padding,
  });

  final List<CustomTab> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final double indicatorWeight;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? colorScheme.primary,
        labelColor: labelColor ?? colorScheme.primary,
        unselectedLabelColor:
            unselectedLabelColor ?? colorScheme.onSurfaceVariant,
        indicatorWeight: indicatorWeight,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        tabs: tabs
            .map((tab) => Tab(
                  text: tab.text,
                  icon: tab.icon,
                  iconMargin: tab.icon != null
                      ? const EdgeInsets.only(bottom: 4)
                      : EdgeInsets.zero,
                ))
            .toList(),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

/// Custom tab configuration for the tab bar
class CustomTab {
  const CustomTab({
    required this.text,
    this.icon,
  });

  final String text;
  final Widget? icon;
}

/// Predefined tab configurations for common use cases
class CustomTabBarPresets {
  CustomTabBarPresets._();

  /// Session monitoring tabs
  static List<CustomTab> get sessionTabs => [
        const CustomTab(
          text: 'Live',
          icon: Icon(Icons.radio_button_checked, size: 16),
        ),
        const CustomTab(
          text: 'History',
          icon: Icon(Icons.history, size: 16),
        ),
        const CustomTab(
          text: 'Reports',
          icon: Icon(Icons.assessment, size: 16),
        ),
      ];

  /// Settings tabs
  static List<CustomTab> get settingsTabs => [
        const CustomTab(
          text: 'General',
          icon: Icon(Icons.settings, size: 16),
        ),
        const CustomTab(
          text: 'Privacy',
          icon: Icon(Icons.privacy_tip, size: 16),
        ),
        const CustomTab(
          text: 'Alerts',
          icon: Icon(Icons.notifications, size: 16),
        ),
      ];

  /// Dashboard tabs
  static List<CustomTab> get dashboardTabs => [
        const CustomTab(
          text: 'Overview',
          icon: Icon(Icons.dashboard, size: 16),
        ),
        const CustomTab(
          text: 'Analytics',
          icon: Icon(Icons.analytics, size: 16),
        ),
        const CustomTab(
          text: 'Fleet',
          icon: Icon(Icons.local_shipping, size: 16),
        ),
      ];
}

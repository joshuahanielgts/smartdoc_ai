import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar widget optimized for automotive safety applications
/// Provides minimal distraction design with high contrast visibility
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? colorScheme.onSurface,
                letterSpacing: 0.15,
              ),
            )
          : null,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: leading ??
          (automaticallyImplyLeading && Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: foregroundColor ?? colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                )
              : null),
      actions: actions ??
          [
            // Voice command button for hands-free operation
            IconButton(
              icon: Icon(
                Icons.mic,
                size: 24,
                color: foregroundColor ?? colorScheme.onSurface,
              ),
              onPressed: () {
                // Voice command functionality would be implemented here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice command activated'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Voice Commands',
            ),
            // Settings access
            IconButton(
              icon: Icon(
                Icons.settings,
                size: 24,
                color: foregroundColor ?? colorScheme.onSurface,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/settings-screen');
              },
              tooltip: 'Settings',
            ),
          ],
      systemOverlayStyle: theme.brightness == Brightness.dark
          ? const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

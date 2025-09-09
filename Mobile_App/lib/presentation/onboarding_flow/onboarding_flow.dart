import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calibration_screen_widget.dart';
import './widgets/permissions_screen_widget.dart';
import './widgets/welcome_screen_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipToMonitor() {
    Navigator.pushReplacementNamed(context, '/monitor-screen');
  }

  void _completeOnboarding() {
    // Mark onboarding as completed and navigate to monitor screen
    Navigator.pushReplacementNamed(context, '/monitor-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Main content
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // Welcome Screen
              WelcomeScreenWidget(
                onGetStarted: _nextPage,
              ),

              // Permissions Screen
              PermissionsScreenWidget(
                onContinue: _nextPage,
                onSkip: _skipToMonitor,
              ),

              // Calibration Screen
              CalibrationScreenWidget(
                onComplete: _completeOnboarding,
                onSkip: _skipToMonitor,
              ),
            ],
          ),

          // Top navigation (Skip button)
          if (_currentPage > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 2.h,
              left: 6.w,
              child: GestureDetector(
                onTap: _previousPage,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'arrow_back_ios',
                        color: AppTheme.textPrimary,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Back',
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Page indicators
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 12.h,
            left: 0,
            right: 0,
            child: Center(
              child: DotsIndicator(
                dotsCount: _totalPages,
                position: _currentPage.toDouble(),
                decorator: DotsDecorator(
                  size: Size(2.w, 2.w),
                  activeSize: Size(6.w, 2.w),
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  activeColor: AppTheme.primary,
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  spacing: EdgeInsets.symmetric(horizontal: 1.w),
                ),
              ),
            ),
          ),

          // Progress indicator
          Positioned(
            top: MediaQuery.of(context).padding.top + 1.h,
            left: 6.w,
            right: 6.w,
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: AppTheme.border.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              minHeight: 0.5.h,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalibrationControlsWidget extends StatelessWidget {
  const CalibrationControlsWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.isCalibrating,
    required this.onStartCalibration,
    required this.onNextStep,
    required this.onPreviousStep,
    required this.onSkipStep,
    required this.onCompleteCalibration,
    this.canGoNext = false,
    this.canGoPrevious = false,
    this.canSkip = false,
  });

  final int currentStep;
  final int totalSteps;
  final bool isCalibrating;
  final VoidCallback onStartCalibration;
  final VoidCallback onNextStep;
  final VoidCallback onPreviousStep;
  final VoidCallback onSkipStep;
  final VoidCallback onCompleteCalibration;
  final bool canGoNext;
  final bool canGoPrevious;
  final bool canSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (currentStep == 0) _buildStartButton(theme),
          if (currentStep > 0 && currentStep < totalSteps)
            _buildStepControls(theme),
          if (currentStep == totalSteps) _buildCompleteButton(theme),
        ],
      ),
    );
  }

  Widget _buildStartButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: isCalibrating
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onStartCalibration();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.textPrimary,
          disabledBackgroundColor: AppTheme.border,
          disabledForegroundColor: AppTheme.textSecondary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isCalibrating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.textSecondary),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Calibrating...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'play_arrow',
                    color: AppTheme.textPrimary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Start Calibration',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStepControls(ThemeData theme) {
    return Column(
      children: [
        // Main action button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: canGoNext
                ? () {
                    HapticFeedback.mediumImpact();
                    onNextStep();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.textPrimary,
              disabledBackgroundColor: AppTheme.border,
              disabledForegroundColor: AppTheme.textSecondary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next Step',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: 'arrow_forward',
                  color:
                      canGoNext ? AppTheme.textPrimary : AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        // Secondary controls
        Row(
          children: [
            // Previous button
            if (canGoPrevious)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onPreviousStep();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: BorderSide(color: AppTheme.border),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Previous',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (canGoPrevious && canSkip) SizedBox(width: 3.w),
            // Skip button
            if (canSkip)
              Expanded(
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onSkipStep();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Skip Step',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompleteButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.heavyImpact();
          onCompleteCalibration();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.success,
          foregroundColor: AppTheme.textPrimary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.textPrimary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Complete Calibration',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

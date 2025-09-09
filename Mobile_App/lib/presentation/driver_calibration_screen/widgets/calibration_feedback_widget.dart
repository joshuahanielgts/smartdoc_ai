import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalibrationFeedbackWidget extends StatelessWidget {
  const CalibrationFeedbackWidget({
    super.key,
    required this.feedbackType,
    required this.message,
    required this.isCompleted,
    this.onRetry,
  });

  final CalibrationFeedbackType feedbackType;
  final String message;
  final bool isCompleted;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _getBackgroundColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBackgroundColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getBackgroundColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getIconName(),
                  color: _getBackgroundColor(),
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isCompleted) ...[
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: CustomIconWidget(
                    iconName: 'check',
                    color: AppTheme.success,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
          if (feedbackType == CalibrationFeedbackType.error &&
              onRetry != null) ...[
            SizedBox(height: 1.5.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRetry?.call();
                },
                style: TextButton.styleFrom(
                  foregroundColor: _getBackgroundColor(),
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                ),
                child: Text(
                  'Retry',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (feedbackType) {
      case CalibrationFeedbackType.success:
        return AppTheme.success;
      case CalibrationFeedbackType.warning:
        return AppTheme.warning;
      case CalibrationFeedbackType.error:
        return AppTheme.accent;
      case CalibrationFeedbackType.info:
        return AppTheme.primary;
    }
  }

  String _getIconName() {
    switch (feedbackType) {
      case CalibrationFeedbackType.success:
        return 'check_circle';
      case CalibrationFeedbackType.warning:
        return 'warning';
      case CalibrationFeedbackType.error:
        return 'error';
      case CalibrationFeedbackType.info:
        return 'info';
    }
  }

  String _getTitle() {
    switch (feedbackType) {
      case CalibrationFeedbackType.success:
        return 'Perfect!';
      case CalibrationFeedbackType.warning:
        return 'Adjust Position';
      case CalibrationFeedbackType.error:
        return 'Try Again';
      case CalibrationFeedbackType.info:
        return 'Instructions';
    }
  }
}

enum CalibrationFeedbackType {
  success,
  warning,
  error,
  info,
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalibrationQualityWidget extends StatelessWidget {
  const CalibrationQualityWidget({
    super.key,
    required this.qualityScore,
    required this.qualityMetrics,
    required this.showRetryOption,
    this.onRetry,
  });

  final double qualityScore;
  final Map<String, double> qualityMetrics;
  final bool showRetryOption;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qualityLevel = _getQualityLevel(qualityScore);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getQualityColor(qualityLevel).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quality score header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getQualityColor(qualityLevel).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getQualityIcon(qualityLevel),
                  color: _getQualityColor(qualityLevel),
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calibration Quality',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getQualityDescription(qualityLevel),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getQualityColor(qualityLevel).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(qualityScore * 100).toInt()}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: _getQualityColor(qualityLevel),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Quality metrics
          ...qualityMetrics.entries.map((entry) => _buildMetricRow(
                context,
                entry.key,
                entry.value,
              )),
          if (showRetryOption && onRetry != null) ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(color: AppTheme.primary),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'refresh',
                      color: AppTheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Retry Calibration',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, String label, double value) {
    final theme = Theme.of(context);
    final percentage = (value * 100).toInt();

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMetricDisplayName(label),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percentage%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          LinearProgressIndicator(
            value: value,
            backgroundColor: AppTheme.border.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getMetricColor(value),
            ),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  CalibrationQualityLevel _getQualityLevel(double score) {
    if (score >= 0.8) return CalibrationQualityLevel.excellent;
    if (score >= 0.6) return CalibrationQualityLevel.good;
    if (score >= 0.4) return CalibrationQualityLevel.fair;
    return CalibrationQualityLevel.poor;
  }

  Color _getQualityColor(CalibrationQualityLevel level) {
    switch (level) {
      case CalibrationQualityLevel.excellent:
        return AppTheme.success;
      case CalibrationQualityLevel.good:
        return AppTheme.primary;
      case CalibrationQualityLevel.fair:
        return AppTheme.warning;
      case CalibrationQualityLevel.poor:
        return AppTheme.accent;
    }
  }

  String _getQualityIcon(CalibrationQualityLevel level) {
    switch (level) {
      case CalibrationQualityLevel.excellent:
        return 'star';
      case CalibrationQualityLevel.good:
        return 'thumb_up';
      case CalibrationQualityLevel.fair:
        return 'warning';
      case CalibrationQualityLevel.poor:
        return 'error';
    }
  }

  String _getQualityDescription(CalibrationQualityLevel level) {
    switch (level) {
      case CalibrationQualityLevel.excellent:
        return 'Excellent calibration quality';
      case CalibrationQualityLevel.good:
        return 'Good calibration quality';
      case CalibrationQualityLevel.fair:
        return 'Fair calibration - consider retry';
      case CalibrationQualityLevel.poor:
        return 'Poor calibration - retry recommended';
    }
  }

  Color _getMetricColor(double value) {
    if (value >= 0.8) return AppTheme.success;
    if (value >= 0.6) return AppTheme.primary;
    if (value >= 0.4) return AppTheme.warning;
    return AppTheme.accent;
  }

  String _getMetricDisplayName(String key) {
    switch (key) {
      case 'face_detection':
        return 'Face Detection';
      case 'eye_tracking':
        return 'Eye Tracking';
      case 'head_pose':
        return 'Head Pose';
      case 'lighting':
        return 'Lighting Quality';
      case 'stability':
        return 'Position Stability';
      default:
        return key
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : word)
            .join(' ');
    }
  }
}

enum CalibrationQualityLevel {
  excellent,
  good,
  fair,
  poor,
}

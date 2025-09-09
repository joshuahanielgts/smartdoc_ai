import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MonitoringIndicatorsWidget extends StatelessWidget {
  const MonitoringIndicatorsWidget({
    super.key,
    required this.blinkRate,
    required this.yawnCount,
    required this.headDrift,
  });

  final int blinkRate;
  final int yawnCount;
  final double headDrift;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top indicators
        Positioned(
          top: 15.h,
          left: 4.w,
          child: _buildIndicatorBadge(
            icon: Icons.visibility,
            value: '$blinkRate/min',
            label: 'Blinks',
            color: _getBlinkRateColor(blinkRate),
          ),
        ),

        // Right side indicators
        Positioned(
          top: 25.h,
          right: 4.w,
          child: _buildIndicatorBadge(
            icon: Icons.sentiment_very_dissatisfied,
            value: yawnCount.toString(),
            label: 'Yawns',
            color: _getYawnColor(yawnCount),
          ),
        ),

        // Bottom indicators
        Positioned(
          bottom: 20.h,
          left: 4.w,
          child: _buildIndicatorBadge(
            icon: Icons.rotate_90_degrees_ccw,
            value: '${headDrift.toStringAsFixed(1)}°',
            label: 'Head Drift',
            color: _getHeadDriftColor(headDrift),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorBadge({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                value,
                style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBlinkRateColor(int rate) {
    if (rate < 10) return AppTheme.accent; // Too low
    if (rate > 30) return AppTheme.warning; // Too high
    return AppTheme.success; // Normal
  }

  Color _getYawnColor(int count) {
    if (count == 0) return AppTheme.success;
    if (count <= 2) return AppTheme.warning;
    return AppTheme.accent; // High yawn count
  }

  Color _getHeadDriftColor(double drift) {
    if (drift.abs() < 5) return AppTheme.success;
    if (drift.abs() < 15) return AppTheme.warning;
    return AppTheme.accent; // Significant head drift
  }
}

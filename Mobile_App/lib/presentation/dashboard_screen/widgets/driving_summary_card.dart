import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DrivingSummaryCard extends StatelessWidget {
  final double driAverage;
  final String totalDriveTime;
  final int safetyScore;

  const DrivingSummaryCard({
    super.key,
    required this.driAverage,
    required this.totalDriveTime,
    required this.safetyScore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surface,
            AppTheme.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Driving Summary",
            style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  title: "DRI Average",
                  value: driAverage.toStringAsFixed(1),
                  unit: "/10",
                  color: _getDRIColor(driAverage),
                  icon: 'analytics',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildMetricItem(
                  title: "Drive Time",
                  value: totalDriveTime,
                  unit: "",
                  color: AppTheme.primary,
                  icon: 'access_time',
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildMetricItem(
            title: "Safety Score",
            value: safetyScore.toString(),
            unit: "%",
            color: _getSafetyScoreColor(safetyScore),
            icon: 'shield',
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required String icon,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: color,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDRIColor(double dri) {
    if (dri >= 8.0) return AppTheme.success;
    if (dri >= 6.0) return AppTheme.warning;
    return AppTheme.accent;
  }

  Color _getSafetyScoreColor(int score) {
    if (score >= 90) return AppTheme.success;
    if (score >= 70) return AppTheme.warning;
    return AppTheme.accent;
  }
}

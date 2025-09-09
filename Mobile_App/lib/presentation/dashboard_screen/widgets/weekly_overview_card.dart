import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeeklyOverviewCard extends StatelessWidget {
  final Map<String, dynamic> weeklyStats;
  final String aiInsight;
  final bool isGeneratingInsight;

  const WeeklyOverviewCard({
    super.key,
    required this.weeklyStats,
    required this.aiInsight,
    this.isGeneratingInsight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weekly Overview",
                style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomIconWidget(
                iconName: 'calendar_view_week',
                color: AppTheme.primary,
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: "Total Sessions",
                  value: (weeklyStats['totalSessions'] as int).toString(),
                  icon: 'drive_eta',
                  color: AppTheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatItem(
                  title: "Avg DRI",
                  value: (weeklyStats['avgDRI'] as double).toStringAsFixed(1),
                  icon: 'speed',
                  color: _getDRIColor(weeklyStats['avgDRI'] as double),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  title: "Total Hours",
                  value:
                      "${(weeklyStats['totalHours'] as double).toStringAsFixed(1)}h",
                  icon: 'schedule',
                  color: AppTheme.warning,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatItem(
                  title: "Improvement",
                  value:
                      "${(weeklyStats['improvement'] as double) > 0 ? '+' : ''}${(weeklyStats['improvement'] as double).toStringAsFixed(1)}%",
                  icon: (weeklyStats['improvement'] as double) > 0
                      ? 'trending_up'
                      : 'trending_down',
                  color: (weeklyStats['improvement'] as double) > 0
                      ? AppTheme.success
                      : AppTheme.accent,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    isGeneratingInsight
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'psychology',
                            color: AppTheme.primary,
                            size: 20,
                          ),
                    SizedBox(width: 2.w),
                    Text(
                      "AI Safety Insight",
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (isGeneratingInsight)
                      Text(
                        "Analyzing...",
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 1.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isGeneratingInsight
                        ? "Generating personalized insights from your driving data..."
                        : aiInsight,
                    key: ValueKey(isGeneratingInsight ? 'loading' : 'content'),
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: isGeneratingInsight
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      height: 1.5,
                      fontStyle: isGeneratingInsight
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required String icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: color,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
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
}

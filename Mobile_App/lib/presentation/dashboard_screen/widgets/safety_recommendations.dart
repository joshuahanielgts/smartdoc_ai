import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SafetyRecommendations extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;

  const SafetyRecommendations({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: AppTheme.warning,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  "AI Safety Tips",
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return _buildRecommendationCard(recommendation, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
      Map<String, dynamic> recommendation, int index) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 2.h),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getPriorityColor(recommendation['priority'] as String)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName:
                      _getPriorityIcon(recommendation['priority'] as String),
                  color:
                      _getPriorityColor(recommendation['priority'] as String),
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation['title'] as String,
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(
                                recommendation['priority'] as String)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (recommendation['priority'] as String).toUpperCase(),
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: _getPriorityColor(
                              recommendation['priority'] as String),
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            recommendation['description'] as String,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          if (recommendation['actionable'] == true) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Handle action button press
                      _handleRecommendationAction(
                          recommendation['action'] as String);
                    },
                    icon: CustomIconWidget(
                      iconName: 'play_arrow',
                      color: AppTheme.primary,
                      size: 16,
                    ),
                    label: Text(
                      recommendation['actionText'] as String,
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppTheme.primary.withValues(alpha: 0.5)),
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                IconButton(
                  onPressed: () {
                    // Handle dismiss recommendation
                    _dismissRecommendation(index);
                  },
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  tooltip: 'Dismiss',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.accent;
      case 'medium':
        return AppTheme.warning;
      case 'low':
        return AppTheme.success;
      default:
        return AppTheme.primary;
    }
  }

  String _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'priority_high';
      case 'medium':
        return 'warning';
      case 'low':
        return 'info';
      default:
        return 'lightbulb';
    }
  }

  void _handleRecommendationAction(String action) {
    // Handle different recommendation actions
    switch (action) {
      case 'calibrate':
        // Navigate to calibration screen
        break;
      case 'settings':
        // Navigate to settings screen
        break;
      case 'monitor':
        // Start monitoring session
        break;
      default:
        break;
    }
  }

  void _dismissRecommendation(int index) {
    // Handle recommendation dismissal
    // This would typically update the state to remove the recommendation
  }
}

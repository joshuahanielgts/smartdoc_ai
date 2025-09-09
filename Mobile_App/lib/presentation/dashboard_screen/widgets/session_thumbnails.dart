import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SessionThumbnails extends StatelessWidget {
  final List<Map<String, dynamic>> recentSessions;

  const SessionThumbnails({
    super.key,
    required this.recentSessions,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Sessions",
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/monitor-screen');
                  },
                  child: Text(
                    "View All",
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 20.h,
            child: recentSessions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    itemCount: recentSessions.length,
                    itemBuilder: (context, index) {
                      final session = recentSessions[index];
                      return _buildSessionThumbnail(context, session, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionThumbnail(
      BuildContext context, Map<String, dynamic> session, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to session detail with shared element transition
        Navigator.pushNamed(
          context,
          '/monitor-screen',
          arguments: {'sessionId': session['id']},
        );
      },
      child: Container(
        width: 40.w,
        margin: EdgeInsets.only(right: 3.w),
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
            // Session thumbnail image
            Container(
              height: 8.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: CustomImageWidget(
                      imageUrl: session['thumbnailUrl'] as String,
                      width: double.infinity,
                      height: 8.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 1.h,
                    right: 2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getDRIColor(session['peakDRI'] as double)
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${(session['peakDRI'] as double).toStringAsFixed(1)}",
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Session details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session['date'] as String,
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'access_time',
                              color: AppTheme.textSecondary,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                session['duration'] as String,
                                style: AppTheme.darkTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: AppTheme.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'star',
                          color: _getSafetyRatingColor(
                              session['safetyRating'] as String),
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          session['safetyRating'] as String,
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: _getSafetyRatingColor(
                                session['safetyRating'] as String),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'drive_eta',
            color: AppTheme.textSecondary,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            "No sessions yet",
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Start your first monitoring session to see analytics here",
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
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

  Color _getSafetyRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'excellent':
        return AppTheme.success;
      case 'good':
        return AppTheme.primary;
      case 'fair':
        return AppTheme.warning;
      case 'poor':
        return AppTheme.accent;
      default:
        return AppTheme.textSecondary;
    }
  }
}

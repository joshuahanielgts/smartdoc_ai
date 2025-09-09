import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/gemini_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/dri_trend_chart.dart';
import './widgets/driving_summary_card.dart';
import './widgets/safety_recommendations.dart';
import './widgets/session_thumbnails.dart';
import './widgets/weekly_overview_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isRefreshing = false;
  String _aiInsight =
      "Your driving performance has improved by 12.3% this week. Morning sessions show consistently better focus levels. Consider maintaining your current sleep schedule for optimal results.";
  bool _isGeneratingInsight = false;

  // Mock data for dashboard analytics
  final List<Map<String, dynamic>> _weeklyDRIData = [
    {"day": "Mon", "dri": 7.2},
    {"day": "Tue", "dri": 8.1},
    {"day": "Wed", "dri": 6.8},
    {"day": "Thu", "dri": 7.9},
    {"day": "Fri", "dri": 8.3},
    {"day": "Sat", "dri": 7.5},
    {"day": "Sun", "dri": 8.0},
  ];

  final Map<String, dynamic> _weeklyStats = {
    "totalSessions": 12,
    "avgDRI": 7.7,
    "totalHours": 28.5,
    "improvement": 12.3,
  };

  final List<Map<String, dynamic>> _recentSessions = [
    {
      "id": 1,
      "date": "Today, 2:30 PM",
      "duration": "45 min",
      "peakDRI": 8.2,
      "safetyRating": "Excellent",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1592384/pexels-photo-1592384.jpeg?auto=compress&cs=tinysrgb&w=400",
    },
    {
      "id": 2,
      "date": "Yesterday, 9:15 AM",
      "duration": "1h 20min",
      "peakDRI": 7.1,
      "safetyRating": "Good",
      "thumbnailUrl":
          "https://images.pexels.com/photos/2365572/pexels-photo-2365572.jpeg?auto=compress&cs=tinysrgb&w=400",
    },
    {
      "id": 3,
      "date": "Dec 6, 4:45 PM",
      "duration": "32 min",
      "peakDRI": 6.8,
      "safetyRating": "Fair",
      "thumbnailUrl":
          "https://images.pexels.com/photos/1545743/pexels-photo-1545743.jpeg?auto=compress&cs=tinysrgb&w=400",
    },
  ];

  final List<Map<String, dynamic>> _safetyRecommendations = [
    {
      "title": "Calibrate Your Profile",
      "description":
          "Your baseline fatigue patterns have changed. Recalibrating will improve detection accuracy by 15-20%.",
      "priority": "high",
      "actionable": true,
      "actionText": "Start Calibration",
      "action": "calibrate",
    },
    {
      "title": "Optimal Break Timing",
      "description":
          "Based on your patterns, taking a 10-minute break every 90 minutes can reduce fatigue incidents by 35%.",
      "priority": "medium",
      "actionable": true,
      "actionText": "Set Reminders",
      "action": "settings",
    },
    {
      "title": "Morning Sessions Improvement",
      "description":
          "Your morning driving sessions show 23% better DRI scores. Consider scheduling important trips before 11 AM.",
      "priority": "low",
      "actionable": false,
      "actionText": "",
      "action": "",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Generate AI insight on first load
    _generateAIInsight();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 12.h,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.backgroundDark,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Dashboard",
                    style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: EdgeInsets.only(left: 4.w, bottom: 2.h),
                ),
                actions: [
                  // AI Insight Regenerate Button
                  IconButton(
                    onPressed: _isGeneratingInsight ? null : _generateAIInsight,
                    icon: _isGeneratingInsight
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
                            size: 24,
                          ),
                    tooltip: 'Generate AI Insight',
                  ),
                  IconButton(
                    onPressed: _exportReport,
                    icon: CustomIconWidget(
                      iconName: 'file_download',
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                    tooltip: 'Export Report',
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings-screen');
                    },
                    icon: CustomIconWidget(
                      iconName: 'settings',
                      color: AppTheme.textPrimary,
                      size: 24,
                    ),
                    tooltip: 'Settings',
                  ),
                  SizedBox(width: 2.w),
                ],
              ),

              // Dashboard Content
              SliverList(
                delegate: SliverChildListDelegate([
                  // Today's Driving Summary
                  DrivingSummaryCard(
                    driAverage: 7.8,
                    totalDriveTime: "3h 45min",
                    safetyScore: 92,
                  ),

                  // DRI Trend Chart
                  DRITrendChart(
                    weeklyData: _weeklyDRIData,
                  ),

                  // Weekly Overview with AI Insight
                  WeeklyOverviewCard(
                    weeklyStats: _weeklyStats,
                    aiInsight: _aiInsight,
                    isGeneratingInsight: _isGeneratingInsight,
                  ),

                  // Recent Sessions
                  SessionThumbnails(
                    recentSessions: _recentSessions,
                  ),

                  // Safety Recommendations
                  SafetyRecommendations(
                    recommendations: _safetyRecommendations,
                  ),

                  // Bottom spacing for floating action button
                  SizedBox(height: 10.h),
                ]),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 0, // Dashboard tab active
      ),

      // Floating Action Button for quick monitoring start
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startMonitoring,
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textPrimary,
        elevation: 4.0,
        icon: CustomIconWidget(
          iconName: 'play_arrow',
          color: AppTheme.textPrimary,
          size: 24,
        ),
        label: Text(
          "Start Monitoring",
          style: AppTheme.darkTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _generateAIInsight() async {
    setState(() {
      _isGeneratingInsight = true;
    });

    try {
      final geminiService = GeminiService();
      final aiInsight = await geminiService.client.generateDrivingDataSummary(
        weeklyStats: _weeklyStats,
        weeklyDRIData: _weeklyDRIData,
        recentSessions: _recentSessions,
      );

      if (mounted) {
        setState(() {
          _aiInsight = aiInsight;
          _isGeneratingInsight = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingInsight = false;
        });

        // Show error message with gentle fallback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'AI insight generation temporarily unavailable. Using default analysis.'),
            backgroundColor: AppTheme.warning,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Refresh AI insight along with other data
    await _generateAIInsight();

    // Simulate API call to refresh analytics data
    await Future.delayed(const Duration(seconds: 1));

    // Haptic feedback for refresh completion
    HapticFeedback.lightImpact();

    setState(() {
      _isRefreshing = false;
    });

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dashboard updated successfully'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _exportReport() {
    // Show export options dialog
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              "Export Dashboard Report",
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildExportOption(
              icon: 'picture_as_pdf',
              title: 'PDF Report',
              subtitle: 'Complete analytics with charts',
              onTap: () => _handleExport('pdf'),
            ),
            _buildExportOption(
              icon: 'table_chart',
              title: 'CSV Data',
              subtitle: 'Raw session data for analysis',
              onTap: () => _handleExport('csv'),
            ),
            _buildExportOption(
              icon: 'share',
              title: 'Share Summary',
              subtitle: 'Quick overview for sharing',
              onTap: () => _handleExport('share'),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: AppTheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'arrow_forward_ios',
        color: AppTheme.textSecondary,
        size: 16,
      ),
    );
  }

  void _handleExport(String type) {
    Navigator.pop(context);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Generating ${type.toUpperCase()} report...',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate export process
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${type.toUpperCase()} report exported successfully'),
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View',
            textColor: AppTheme.textPrimary,
            onPressed: () {
              // Handle view exported file
            },
          ),
        ),
      );
    });
  }

  void _startMonitoring() {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Navigate to monitor screen
    Navigator.pushNamed(context, '/monitor-screen');
  }
}

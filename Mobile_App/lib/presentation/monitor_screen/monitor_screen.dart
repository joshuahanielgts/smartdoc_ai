import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/alert_overlay_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/dri_meter_widget.dart';
import './widgets/emergency_button_widget.dart';
import './widgets/inference_mode_widget.dart';
import './widgets/session_timer_widget.dart';
import './widgets/start_pause_button_widget.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen>
    with TickerProviderStateMixin {
  // Session state
  bool _isRecording = false;
  bool _isOnDeviceMode = true;
  bool _batteryOptimized = false;
  Duration _sessionDuration = Duration.zero;

  // DRI and monitoring data
  double _currentDRI = 25.0;
  int _blinkRate = 18;
  int _yawnCount = 0;
  double _headDrift = 2.5;

  // Alert system
  AlertType? _currentAlertType;
  String _currentAlertMessage = '';
  bool _showAlert = false;

  // Animation controllers
  late AnimationController _driUpdateController;
  late AnimationController _alertController;

  // Mock session data for realistic simulation
  final List<Map<String, dynamic>> _mockSessionData = [
    {
      "timestamp": DateTime.now().subtract(const Duration(minutes: 5)),
      "driValue": 15.0,
      "blinkRate": 22,
      "yawnCount": 0,
      "headDrift": 1.2,
      "alertType": null,
    },
    {
      "timestamp": DateTime.now().subtract(const Duration(minutes: 3)),
      "driValue": 35.0,
      "blinkRate": 12,
      "yawnCount": 1,
      "headDrift": 8.5,
      "alertType": "distraction",
    },
    {
      "timestamp": DateTime.now().subtract(const Duration(minutes: 1)),
      "driValue": 65.0,
      "blinkRate": 8,
      "yawnCount": 2,
      "headDrift": 15.2,
      "alertType": "drowsiness",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startMockDataSimulation();
  }

  @override
  void dispose() {
    _driUpdateController.dispose();
    _alertController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _driUpdateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _alertController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _startMockDataSimulation() {
    // Simulate real-time DRI updates when recording
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (_isRecording && mounted) {
        _updateMockData();
      }
      return mounted;
    });
  }

  void _updateMockData() {
    setState(() {
      // Simulate DRI fluctuation based on time of day and session duration
      final random = DateTime.now().millisecond % 100;
      final sessionMinutes = _sessionDuration.inMinutes;

      // DRI increases with session duration (fatigue simulation)
      double baseDRI = 20.0 + (sessionMinutes * 2.0);
      _currentDRI = (baseDRI + (random / 5)).clamp(0.0, 100.0);

      // Blink rate decreases with fatigue
      _blinkRate =
          (25 - (sessionMinutes * 0.5) + (random / 10)).round().clamp(5, 35);

      // Yawn count increases with fatigue
      if (sessionMinutes > 10 && random > 80) {
        _yawnCount++;
      }

      // Head drift increases with fatigue
      _headDrift = (sessionMinutes * 0.3 + (random / 20)).clamp(0.0, 30.0);

      // Trigger alerts based on DRI level
      _checkForAlerts();
    });
  }

  void _checkForAlerts() {
    if (_currentDRI > 70) {
      _showAlertOverlay(AlertType.drowsiness,
          'High drowsiness detected! Please take a break.');
    } else if (_currentDRI > 50) {
      _showAlertOverlay(
          AlertType.fatigue, 'Fatigue levels increasing. Consider resting.');
    } else if (_yawnCount > 3) {
      _showAlertOverlay(
          AlertType.fatigue, 'Multiple yawns detected. You may be tired.');
    } else if (_headDrift > 10) {
      _showAlertOverlay(
          AlertType.distraction, 'Head position drift detected. Stay focused.');
    }
  }

  void _showAlertOverlay(AlertType type, String message) {
    setState(() {
      _currentAlertType = type;
      _currentAlertMessage = message;
      _showAlert = true;
    });

    // Trigger haptic feedback
    HapticFeedback.heavyImpact();

    // Auto-dismiss alert after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showAlert = false;
        });
      }
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        // Reset counters when stopping
        _yawnCount = 0;
        _sessionDuration = Duration.zero;
      }
    });

    // Provide voice confirmation
    _announceSessionState();
  }

  void _announceSessionState() {
    final message = _isRecording ? 'Monitoring started' : 'Monitoring paused';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: _isRecording ? AppTheme.success : AppTheme.warning,
      ),
    );
  }

  void _toggleInferenceMode() {
    setState(() {
      _isOnDeviceMode = !_isOnDeviceMode;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOnDeviceMode
              ? 'Switched to On-Device processing'
              : 'Switched to Cloud processing',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onTimerUpdate(Duration duration) {
    setState(() {
      _sessionDuration = duration;
    });
  }

  void _showDRIDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Risk Index Details',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            _buildDetailRow('Current DRI', '${_currentDRI.toInt()}',
                _getDRIColor(_currentDRI)),
            _buildDetailRow('Blink Rate', '$_blinkRate/min',
                _getBlinkRateColor(_blinkRate)),
            _buildDetailRow(
                'Yawn Count', _yawnCount.toString(), _getYawnColor(_yawnCount)),
            _buildDetailRow('Head Drift', '${_headDrift.toStringAsFixed(1)}°',
                _getHeadDriftColor(_headDrift)),
            _buildDetailRow('Session Time', _formatDuration(_sessionDuration),
                AppTheme.primary),
            SizedBox(height: 2.h),
            Text(
              'DRI Scale: 0-30 Alert, 31-70 Caution, 71-100 Danger',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            value,
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDRIColor(double value) {
    if (value <= 30) return AppTheme.success;
    if (value <= 70) return AppTheme.warning;
    return AppTheme.accent;
  }

  Color _getBlinkRateColor(int rate) {
    if (rate < 10 || rate > 30) return AppTheme.accent;
    if (rate < 15 || rate > 25) return AppTheme.warning;
    return AppTheme.success;
  }

  Color _getYawnColor(int count) {
    if (count == 0) return AppTheme.success;
    if (count <= 2) return AppTheme.warning;
    return AppTheme.accent;
  }

  Color _getHeadDriftColor(double drift) {
    if (drift.abs() < 5) return AppTheme.success;
    if (drift.abs() < 15) return AppTheme.warning;
    return AppTheme.accent;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _onCameraFrame(CameraImage image) {
    // In a real implementation, this would process the camera frame
    // for face detection and fatigue analysis using ML models
    // For now, we simulate this with mock data updates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview (full screen)
            Positioned.fill(
              child: CameraPreviewWidget(
                onCameraInitialized: () {
                  // Camera ready for monitoring
                },
                onFrameProcessed: _onCameraFrame,
              ),
            ),

            // Top-left: Session timer and recording indicator
            Positioned(
              top: 2.h,
              left: 4.w,
              child: SessionTimerWidget(
                isRecording: _isRecording,
                onTimerUpdate: _onTimerUpdate,
              ),
            ),

            // Top-right: Inference mode toggle and battery status
            Positioned(
              top: 2.h,
              right: 4.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InferenceModeWidget(
                    isOnDevice: _isOnDeviceMode,
                    onToggle: _toggleInferenceMode,
                    batteryOptimized: _batteryOptimized,
                  ),
                ],
              ),
            ),

            // Emergency button (top-right corner)
            EmergencyButtonWidget(
              onPressed: () {
                // Emergency services integration would go here
              },
            ),

            // Center: DRI Meter
            Center(
              child: DRIMeterWidget(
                driValue: _currentDRI,
                size: 50.w,
                onLongPress: _showDRIDetails,
              ),
            ),

            // Monitoring indicators around screen edges
            Positioned(
              top: 15.h,
              left: 4.w,
              child: _buildIndicatorBadge(
                icon: Icons.visibility,
                value: '$_blinkRate/min',
                label: 'Blinks',
                color: _getBlinkRateColor(_blinkRate),
              ),
            ),

            Positioned(
              top: 25.h,
              right: 4.w,
              child: _buildIndicatorBadge(
                icon: Icons.sentiment_very_dissatisfied,
                value: _yawnCount.toString(),
                label: 'Yawns',
                color: _getYawnColor(_yawnCount),
              ),
            ),

            Positioned(
              bottom: 20.h,
              left: 4.w,
              child: _buildIndicatorBadge(
                icon: Icons.rotate_90_degrees_ccw,
                value: '${_headDrift.toStringAsFixed(1)}°',
                label: 'Head Drift',
                color: _getHeadDriftColor(_headDrift),
              ),
            ),

            // Bottom: Start/Pause button
            Positioned(
              bottom: 8.h,
              left: 0,
              right: 0,
              child: Center(
                child: StartPauseButtonWidget(
                  isRecording: _isRecording,
                  onPressed: _toggleRecording,
                ),
              ),
            ),

            // Alert overlay
            if (_showAlert && _currentAlertType != null)
              Positioned(
                top: 12.h,
                left: 0,
                right: 0,
                child: AlertOverlayWidget(
                  alertType: _currentAlertType!,
                  message: _currentAlertMessage,
                  isVisible: _showAlert,
                  onDismiss: () {
                    setState(() {
                      _showAlert = false;
                    });
                  },
                ),
              ),

            // Bottom navigation hint
            Positioned(
              bottom: 1.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'dashboard',
                        color: AppTheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/dashboard-screen'),
                        child: Text(
                          'View Dashboard',
                          style: AppTheme.darkTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      CustomIconWidget(
                        iconName: 'settings',
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/settings-screen'),
                        child: Text(
                          'Settings',
                          style: AppTheme.darkTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
}

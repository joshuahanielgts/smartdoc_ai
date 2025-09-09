import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calibration_controls_widget.dart';
import './widgets/calibration_feedback_widget.dart';
import './widgets/calibration_progress_widget.dart';
import './widgets/calibration_quality_widget.dart';
import './widgets/camera_preview_widget.dart';

class DriverCalibrationScreen extends StatefulWidget {
  const DriverCalibrationScreen({super.key});

  @override
  State<DriverCalibrationScreen> createState() =>
      _DriverCalibrationScreenState();
}

class _DriverCalibrationScreenState extends State<DriverCalibrationScreen>
    with TickerProviderStateMixin {
  // Calibration state
  int _currentStep = 0;
  final int _totalSteps = 5;
  bool _isCalibrating = false;
  bool _isCameraInitialized = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Calibration data
  final List<CalibrationStep> _calibrationSteps = [
    CalibrationStep(
      title: 'Welcome to Calibration',
      description:
          'We\'ll personalize fatigue detection for your unique facial features',
      instruction: 'Position yourself comfortably in front of the camera',
      duration: 0,
    ),
    CalibrationStep(
      title: 'Normal Alertness Baseline',
      description: 'Look directly at the camera with normal alertness',
      instruction: 'Keep your eyes open and look straight ahead for 30 seconds',
      duration: 30,
    ),
    CalibrationStep(
      title: 'Blink Pattern Training',
      description: 'Help us learn your natural blink patterns',
      instruction:
          'Blink naturally 10 times, then close your eyes for 3 seconds',
      duration: 20,
    ),
    CalibrationStep(
      title: 'Head Movement Range',
      description: 'Define your comfortable head movement boundaries',
      instruction: 'Slowly turn your head left, right, up, and down',
      duration: 25,
    ),
    CalibrationStep(
      title: 'Yawn Detection Training',
      description: 'Train the system to recognize your yawn patterns',
      instruction: 'Simulate 3 yawns with 5-second intervals between each',
      duration: 20,
    ),
  ];

  // Mock calibration data
  final Map<String, dynamic> _mockCalibrationData = {
    "user_id": "driver_001",
    "calibration_timestamp": "2025-09-08T18:10:13.793244",
    "baseline_metrics": {
      "eye_aspect_ratio": 0.28,
      "blink_frequency": 15.2,
      "head_pose_range": {
        "yaw": {"min": -25.0, "max": 25.0},
        "pitch": {"min": -15.0, "max": 15.0},
        "roll": {"min": -10.0, "max": 10.0}
      },
      "yawn_threshold": 0.65,
      "drowsiness_sensitivity": 0.75
    },
    "quality_metrics": {
      "face_detection": 0.92,
      "eye_tracking": 0.88,
      "head_pose": 0.85,
      "lighting": 0.78,
      "stability": 0.91
    },
    "personalization_score": 0.87
  };

  CalibrationFeedbackType _currentFeedbackType = CalibrationFeedbackType.info;
  String _currentFeedbackMessage = '';
  bool _stepCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateFeedback();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _updateFeedback() {
    final step = _calibrationSteps[_currentStep];

    setState(() {
      if (_currentStep == 0) {
        _currentFeedbackType = CalibrationFeedbackType.info;
        _currentFeedbackMessage =
            'Make sure you\'re in a well-lit area and position your face within the guide';
      } else if (_isCalibrating) {
        _currentFeedbackType = CalibrationFeedbackType.info;
        _currentFeedbackMessage =
            'Following instructions... ${step.instruction}';
      } else if (_stepCompleted) {
        _currentFeedbackType = CalibrationFeedbackType.success;
        _currentFeedbackMessage = 'Step completed successfully! Great job.';
      } else {
        _currentFeedbackType = CalibrationFeedbackType.info;
        _currentFeedbackMessage = step.instruction;
      }
    });
  }

  void _onCameraInitialized() {
    setState(() {
      _isCameraInitialized = true;
    });
  }

  void _startCalibration() {
    setState(() {
      _currentStep = 1;
      _isCalibrating = true;
      _stepCompleted = false;
    });

    _updateFeedback();
    _simulateCalibrationStep();
  }

  void _simulateCalibrationStep() {
    final step = _calibrationSteps[_currentStep];

    // Simulate calibration process
    Future.delayed(Duration(seconds: step.duration), () {
      if (mounted && _isCalibrating) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isCalibrating = false;
          _stepCompleted = true;
        });
        _updateFeedback();
      }
    });
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        _isCalibrating = true;
        _stepCompleted = false;
      });

      _updateFeedback();
      _simulateCalibrationStep();
    } else {
      _completeCalibration();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
        _isCalibrating = false;
        _stepCompleted = true;
      });
      _updateFeedback();
    }
  }

  void _skipStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
        _isCalibrating = false;
        _stepCompleted = false;
      });
      _updateFeedback();
    }
  }

  void _completeCalibration() {
    HapticFeedback.heavyImpact();

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.success,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Text(
              'Calibration Complete!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your personalized fatigue detection is now ready. The system has been optimized for your unique facial features.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Personalization Score: ${(_mockCalibrationData['personalization_score'] * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/dashboard-screen');
            },
            child: Text(
              'Go to Dashboard',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/monitor-screen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.textPrimary,
            ),
            child: Text(
              'Start Monitoring',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _retryCalibration() {
    setState(() {
      _currentStep = 1;
      _isCalibrating = false;
      _stepCompleted = false;
    });
    _updateFeedback();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = _calibrationSteps[_currentStep];

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Driver Calibration',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: AppTheme.textSecondary,
              size: 20,
            ),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),
                        // Progress indicator
                        CalibrationProgressWidget(
                          currentStep: _currentStep,
                          totalSteps: _totalSteps,
                          stepTitle: step.title,
                          stepDescription: step.description,
                        ),
                        SizedBox(height: 2.h),
                        // Camera preview
                        if (_currentStep > 0)
                          CameraPreviewWidget(
                            onCameraInitialized: _onCameraInitialized,
                            showFaceMesh: _isCalibrating,
                            showPositioningGuides:
                                !_isCalibrating && !_stepCompleted,
                          ),
                        SizedBox(height: 2.h),
                        // Feedback widget
                        CalibrationFeedbackWidget(
                          feedbackType: _currentFeedbackType,
                          message: _currentFeedbackMessage,
                          isCompleted: _stepCompleted,
                          onRetry: _currentFeedbackType ==
                                  CalibrationFeedbackType.error
                              ? _retryCalibration
                              : null,
                        ),
                        SizedBox(height: 2.h),
                        // Quality metrics (show after completion)
                        if (_currentStep == _totalSteps)
                          CalibrationQualityWidget(
                            qualityScore:
                                _mockCalibrationData['personalization_score'],
                            qualityMetrics: Map<String, double>.from(
                                _mockCalibrationData['quality_metrics']),
                            showRetryOption:
                                _mockCalibrationData['personalization_score'] <
                                    0.7,
                            onRetry: _retryCalibration,
                          ),
                        SizedBox(height: 2.h),
                      ],
                    ),
                  ),
                ),
                // Controls
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: CalibrationControlsWidget(
                    currentStep: _currentStep,
                    totalSteps: _totalSteps,
                    isCalibrating: _isCalibrating,
                    onStartCalibration: _startCalibration,
                    onNextStep: _nextStep,
                    onPreviousStep: _previousStep,
                    onSkipStep: _skipStep,
                    onCompleteCalibration: _completeCalibration,
                    canGoNext: _stepCompleted && !_isCalibrating,
                    canGoPrevious: _currentStep > 1 && !_isCalibrating,
                    canSkip: _currentStep > 1 &&
                        _currentStep < _totalSteps &&
                        !_isCalibrating,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'help',
              color: AppTheme.primary,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Text(
              'Calibration Help',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('Position yourself 18-24 inches from the camera'),
            _buildHelpItem('Ensure good lighting on your face'),
            _buildHelpItem('Follow each step\'s instructions carefully'),
            _buildHelpItem('Stay still during calibration periods'),
            _buildHelpItem('You can retry if quality is poor'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalibrationStep {
  final String title;
  final String description;
  final String instruction;
  final int duration; // in seconds

  CalibrationStep({
    required this.title,
    required this.description,
    required this.instruction,
    required this.duration,
  });
}

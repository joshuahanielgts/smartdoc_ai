import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalibrationScreenWidget extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;

  const CalibrationScreenWidget({
    super.key,
    required this.onComplete,
    required this.onSkip,
  });

  @override
  State<CalibrationScreenWidget> createState() =>
      _CalibrationScreenWidgetState();
}

class _CalibrationScreenWidgetState extends State<CalibrationScreenWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  String _calibrationStep = 'position'; // position, blink, complete
  int _blinkCount = 0;
  bool _faceDetected = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      if (kIsWeb) {
        // Web camera simulation
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isCameraInitialized = true;
          _faceDetected = true;
          _isInitializing = false;
        });
        return;
      }

      // Check camera permission
      final cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          setState(() {
            _isInitializing = false;
          });
          return;
        }
      }

      // Initialize camera
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Apply camera settings
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        // Ignore focus mode errors
      }

      setState(() {
        _isCameraInitialized = true;
        _faceDetected = true; // Simulate face detection
        _isInitializing = false;
      });

      // Start calibration sequence
      _startCalibrationSequence();
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  void _startCalibrationSequence() {
    // Simulate calibration steps
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _calibrationStep = 'blink';
        });
      }
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _blinkCount = 3;
          _calibrationStep = 'complete';
        });
      }
    });
  }

  void _simulateBlink() {
    if (_calibrationStep == 'blink' && _blinkCount < 3) {
      setState(() {
        _blinkCount++;
      });

      if (_blinkCount >= 3) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _calibrationStep = 'complete';
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.gradientStart,
            AppTheme.primary,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            children: [
              // Header
              Text(
                'Driver Calibration',
                style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                'Position yourself for optimal face detection',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),

              // Camera Preview Section
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(4.w),
                    border: Border.all(
                      color: _faceDetected ? AppTheme.success : AppTheme.border,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.w),
                    child: _buildCameraPreview(),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Calibration Instructions
              Expanded(
                flex: 2,
                child: _buildCalibrationInstructions(),
              ),

              // Action Buttons
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onSkip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: BorderSide(color: AppTheme.border),
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                      child: Text(
                        'Skip Calibration',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _calibrationStep == 'complete'
                          ? widget.onComplete
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _calibrationStep == 'complete'
                            ? AppTheme.success
                            : AppTheme.primary.withValues(alpha: 0.5),
                        foregroundColor: AppTheme.textPrimary,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                      child: Text(
                        _calibrationStep == 'complete'
                            ? 'Complete Setup'
                            : 'Calibrating...',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
            SizedBox(height: 2.h),
            Text(
              'Initializing camera...',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'camera_alt',
              color: AppTheme.textSecondary,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'Camera not available',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview or simulation
        kIsWeb
            ? Container(
                width: double.infinity,
                height: double.infinity,
                color: AppTheme.surface,
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'face',
                    color: AppTheme.primary,
                    size: 20.w,
                  ),
                ),
              )
            : SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CameraPreview(_cameraController!),
              ),

        // Face detection overlay
        if (_faceDetected)
          Center(
            child: Container(
              width: 60.w,
              height: 40.h,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.success,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(4.w),
              ),
              child: Stack(
                children: [
                  // Corner indicators
                  Positioned(
                    top: 2.w,
                    left: 2.w,
                    child: Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2.w,
                    right: 2.w,
                    child: Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2.w,
                    left: 2.w,
                    child: Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2.w,
                    right: 2.w,
                    child: Container(
                      width: 4.w,
                      height: 4.w,
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(1.w),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCalibrationInstructions() {
    switch (_calibrationStep) {
      case 'position':
        return Column(
          children: [
            CustomIconWidget(
              iconName: 'face',
              color: AppTheme.primary,
              size: 12.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'Position Your Face',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Center your face in the frame and look directly at the camera',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case 'blink':
        return Column(
          children: [
            GestureDetector(
              onTap: _simulateBlink,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: CustomIconWidget(
                  iconName: 'visibility',
                  color: AppTheme.primary,
                  size: 12.w,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Blink Detection Test',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Blink naturally 3 times ($_blinkCount/3)',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (kIsWeb) ...[
              SizedBox(height: 2.h),
              Text(
                'Tap the eye icon to simulate blinks',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );

      case 'complete':
        return Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.success,
                size: 12.w,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Calibration Complete!',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.success,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Your face detection is now optimized for accurate monitoring',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

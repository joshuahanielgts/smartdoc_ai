import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({
    super.key,
    required this.onCameraInitialized,
    required this.showFaceMesh,
    required this.showPositioningGuides,
  });

  final VoidCallback onCameraInitialized;
  final bool showFaceMesh;
  final bool showPositioningGuides;

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  String? _errorMessage;

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
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available on this device';
        });
        return;
      }

      // Use front camera for face detection
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Apply camera settings
      await _applyCameraSettings();

      setState(() {
        _isCameraInitialized = true;
      });

      widget.onCameraInitialized();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  Future<void> _applyCameraSettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      // Ignore settings that aren't supported
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return _buildLoadingWidget();
    }

    return Stack(
      children: [
        // Camera preview
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
        // Face mesh overlay
        if (widget.showFaceMesh) _buildFaceMeshOverlay(),
        // Positioning guides
        if (widget.showPositioningGuides) _buildPositioningGuides(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'camera_alt_outlined',
            color: AppTheme.accent,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'Camera Error',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              _errorMessage ?? 'Unknown camera error',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          SizedBox(height: 2.h),
          Text(
            'Initializing Camera...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceMeshOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: FaceMeshPainter(),
      ),
    );
  }

  Widget _buildPositioningGuides() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Center face guide
            Center(
              child: Container(
                width: 60.w,
                height: 35.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.8),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Center(
                  child: Text(
                    'Position your face here',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            // Distance indicator
            Positioned(
              top: 2.h,
              left: 4.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'visibility',
                      color: AppTheme.success,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Good distance',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w500,
                          ),
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
}

class FaceMeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw sample face mesh points
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Face outline points
    final facePoints = [
      Offset(centerX - 80, centerY - 100),
      Offset(centerX - 60, centerY - 120),
      Offset(centerX, centerY - 130),
      Offset(centerX + 60, centerY - 120),
      Offset(centerX + 80, centerY - 100),
      Offset(centerX + 90, centerY - 50),
      Offset(centerX + 85, centerY),
      Offset(centerX + 75, centerY + 50),
      Offset(centerX + 50, centerY + 80),
      Offset(centerX, centerY + 90),
      Offset(centerX - 50, centerY + 80),
      Offset(centerX - 75, centerY + 50),
      Offset(centerX - 85, centerY),
      Offset(centerX - 90, centerY - 50),
    ];

    // Draw face outline
    for (int i = 0; i < facePoints.length; i++) {
      final start = facePoints[i];
      final end = facePoints[(i + 1) % facePoints.length];
      canvas.drawLine(start, end, paint);
    }

    // Draw eye points
    canvas.drawCircle(Offset(centerX - 30, centerY - 30), 3, paint);
    canvas.drawCircle(Offset(centerX + 30, centerY - 30), 3, paint);

    // Draw nose point
    canvas.drawCircle(Offset(centerX, centerY), 2, paint);

    // Draw mouth points
    canvas.drawCircle(Offset(centerX - 20, centerY + 30), 2, paint);
    canvas.drawCircle(Offset(centerX + 20, centerY + 30), 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

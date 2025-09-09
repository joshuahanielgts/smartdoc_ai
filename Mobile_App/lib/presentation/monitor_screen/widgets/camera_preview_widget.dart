import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({
    super.key,
    this.onCameraInitialized,
    this.onFrameProcessed,
  });

  final VoidCallback? onCameraInitialized;
  final Function(CameraImage)? onFrameProcessed;

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _hasPermission = false;
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

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true; // Browser handles permissions

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      _hasPermission = await _requestCameraPermission();
      if (!_hasPermission) {
        setState(() {
          _errorMessage = 'Camera permission denied';
        });
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      // Select front camera for driver monitoring
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      // Initialize camera controller
      _cameraController = CameraController(
        frontCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Apply camera settings (skip unsupported features on web)
      await _applyCameraSettings();

      // Start image stream for ML processing
      if (widget.onFrameProcessed != null) {
        _cameraController!.startImageStream(widget.onFrameProcessed!);
      }

      setState(() {
        _isInitialized = true;
      });

      widget.onCameraInitialized?.call();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  Future<void> _applyCameraSettings() async {
    if (_cameraController == null) return;

    try {
      // Set focus mode (skip on web if unsupported)
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {
      // Ignore focus mode errors on web
    }

    // Skip flash and zoom settings on web
    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.off);
      } catch (e) {
        // Ignore flash errors
      }
    }
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized || _cameraController == null) {
      return Container(
        color: AppTheme.backgroundDark,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Initializing Camera...',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: AspectRatio(
        aspectRatio: _cameraController!.value.aspectRatio,
        child: CameraPreview(_cameraController!),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: AppTheme.backgroundDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage ?? 'Camera unavailable',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    return Stack(
      children: [
        _buildCameraPreview(),

        // Camera overlay for face detection guidance
        if (_isInitialized)
          Positioned.fill(
            child: CustomPaint(
              painter: FaceDetectionOverlayPainter(),
            ),
          ),
      ],
    );
  }
}

class FaceDetectionOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw face detection guide oval
    final center = Offset(size.width / 2, size.height / 2 - 20);
    final faceOval = Rect.fromCenter(
      center: center,
      width: size.width * 0.6,
      height: size.height * 0.4,
    );

    canvas.drawOval(faceOval, paint);

    // Draw corner guides
    final cornerPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final cornerLength = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(faceOval.left, faceOval.top + cornerLength),
      Offset(faceOval.left, faceOval.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(faceOval.left, faceOval.top),
      Offset(faceOval.left + cornerLength, faceOval.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(faceOval.right - cornerLength, faceOval.top),
      Offset(faceOval.right, faceOval.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(faceOval.right, faceOval.top),
      Offset(faceOval.right, faceOval.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(faceOval.left, faceOval.bottom - cornerLength),
      Offset(faceOval.left, faceOval.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(faceOval.left, faceOval.bottom),
      Offset(faceOval.left + cornerLength, faceOval.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(faceOval.right - cornerLength, faceOval.bottom),
      Offset(faceOval.right, faceOval.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(faceOval.right, faceOval.bottom - cornerLength),
      Offset(faceOval.right, faceOval.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PermissionsScreenWidget extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const PermissionsScreenWidget({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<PermissionsScreenWidget> createState() =>
      _PermissionsScreenWidgetState();
}

class _PermissionsScreenWidgetState extends State<PermissionsScreenWidget> {
  bool _cameraGranted = false;
  bool _microphoneGranted = false;
  bool _locationGranted = false;
  bool _isRequestingPermissions = false;

  final List<Map<String, dynamic>> _permissions = [
    {
      'icon': 'camera_alt',
      'title': 'Camera Access',
      'description':
          'Required for real-time face detection and fatigue monitoring',
      'required': true,
      'permission': Permission.camera,
      'granted': false,
    },
    {
      'icon': 'mic',
      'title': 'Microphone Access',
      'description':
          'Enables voice alerts and audio feedback for safety warnings',
      'required': false,
      'permission': Permission.microphone,
      'granted': false,
    },
    {
      'icon': 'location_on',
      'title': 'Location Access',
      'description':
          'Identifies high-risk driving zones and provides location-based insights',
      'required': false,
      'permission': Permission.locationWhenInUse,
      'granted': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkExistingPermissions();
  }

  Future<void> _checkExistingPermissions() async {
    if (kIsWeb) {
      // Web permissions are handled by browser
      setState(() {
        _cameraGranted = true;
        _microphoneGranted = true;
        _locationGranted = true;
        _permissions[0]['granted'] = true;
        _permissions[1]['granted'] = true;
        _permissions[2]['granted'] = true;
      });
      return;
    }

    for (int i = 0; i < _permissions.length; i++) {
      final permission = _permissions[i]['permission'] as Permission;
      final status = await permission.status;
      setState(() {
        _permissions[i]['granted'] = status.isGranted;
        if (i == 0) _cameraGranted = status.isGranted;
        if (i == 1) _microphoneGranted = status.isGranted;
        if (i == 2) _locationGranted = status.isGranted;
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    if (kIsWeb) {
      widget.onContinue();
      return;
    }

    setState(() {
      _isRequestingPermissions = true;
    });

    try {
      for (int i = 0; i < _permissions.length; i++) {
        final permission = _permissions[i]['permission'] as Permission;
        final status = await permission.request();

        setState(() {
          _permissions[i]['granted'] = status.isGranted;
          if (i == 0) _cameraGranted = status.isGranted;
          if (i == 1) _microphoneGranted = status.isGranted;
          if (i == 2) _locationGranted = status.isGranted;
        });
      }

      // Check if camera permission is granted (required)
      if (_cameraGranted) {
        widget.onContinue();
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      // Handle permission request errors gracefully
      if (_cameraGranted) {
        widget.onContinue();
      } else {
        _showPermissionDialog();
      }
    } finally {
      setState(() {
        _isRequestingPermissions = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.dialogDark,
        title: Text(
          'Camera Permission Required',
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Camera access is essential for fatigue detection. Please enable it in your device settings to continue.',
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(
              'Open Settings',
              style: TextStyle(color: AppTheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Permissions Setup',
                style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Grant permissions to enable full safety monitoring capabilities',
                style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),

              // Permissions List
              Expanded(
                child: ListView.separated(
                  itemCount: _permissions.length,
                  separatorBuilder: (context, index) => SizedBox(height: 3.h),
                  itemBuilder: (context, index) {
                    final permission = _permissions[index];
                    return _buildPermissionCard(permission);
                  },
                ),
              ),

              // Action Buttons
              SizedBox(height: 4.h),
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
                        'Skip',
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
                      onPressed: _isRequestingPermissions
                          ? null
                          : _requestAllPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.textPrimary,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                      child: _isRequestingPermissions
                          ? SizedBox(
                              width: 5.w,
                              height: 5.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.textPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Grant Permissions',
                              style: AppTheme.darkTheme.textTheme.titleMedium
                                  ?.copyWith(
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

  Widget _buildPermissionCard(Map<String, dynamic> permission) {
    final bool isGranted = permission['granted'] as bool;
    final bool isRequired = permission['required'] as bool;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: isGranted
              ? AppTheme.success.withValues(alpha: 0.3)
              : (isRequired
                  ? AppTheme.accent.withValues(alpha: 0.3)
                  : AppTheme.border),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: isGranted
                  ? AppTheme.success.withValues(alpha: 0.2)
                  : AppTheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: CustomIconWidget(
              iconName: permission['icon'] as String,
              color: isGranted ? AppTheme.success : AppTheme.primary,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        permission['title'] as String,
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isRequired)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: Text(
                          'Required',
                          style:
                              AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  permission['description'] as String,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Status Icon
          SizedBox(width: 2.w),
          CustomIconWidget(
            iconName: isGranted ? 'check_circle' : 'radio_button_unchecked',
            color: isGranted ? AppTheme.success : AppTheme.textSecondary,
            size: 6.w,
          ),
        ],
      ),
    );
  }
}

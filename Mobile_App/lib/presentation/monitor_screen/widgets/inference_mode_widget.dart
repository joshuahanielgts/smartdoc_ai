import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InferenceModeWidget extends StatelessWidget {
  const InferenceModeWidget({
    super.key,
    required this.isOnDevice,
    required this.onToggle,
    this.batteryOptimized = false,
  });

  final bool isOnDevice;
  final VoidCallback onToggle;
  final bool batteryOptimized;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOnDevice ? AppTheme.success : AppTheme.primary,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: isOnDevice ? 'phone_android' : 'cloud',
              color: isOnDevice ? AppTheme.success : AppTheme.primary,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              isOnDevice ? 'On-Device' : 'Cloud',
              style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 11.sp,
              ),
            ),
            if (batteryOptimized) ...[
              SizedBox(width: 1.w),
              CustomIconWidget(
                iconName: 'battery_saver',
                color: AppTheme.warning,
                size: 12,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

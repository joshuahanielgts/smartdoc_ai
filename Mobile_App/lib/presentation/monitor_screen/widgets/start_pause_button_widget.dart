import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class StartPauseButtonWidget extends StatefulWidget {
  const StartPauseButtonWidget({
    super.key,
    required this.isRecording,
    required this.onPressed,
  });

  final bool isRecording;
  final VoidCallback onPressed;

  @override
  State<StartPauseButtonWidget> createState() => _StartPauseButtonWidgetState();
}

class _StartPauseButtonWidgetState extends State<StartPauseButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePress() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Haptic feedback
    // HapticFeedback.mediumImpact();

    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handlePress,
            child: Container(
              width: 20.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: widget.isRecording ? AppTheme.accent : AppTheme.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isRecording
                            ? AppTheme.accent
                            : AppTheme.success)
                        .withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isRecording ? Icons.pause : Icons.play_arrow,
                    color: AppTheme.textPrimary,
                    size: 32,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    widget.isRecording ? 'PAUSE' : 'START',
                    style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DRIMeterWidget extends StatefulWidget {
  const DRIMeterWidget({
    super.key,
    required this.driValue,
    this.size = 200,
    this.onLongPress,
  });

  final double driValue;
  final double size;
  final VoidCallback? onLongPress;

  @override
  State<DRIMeterWidget> createState() => _DRIMeterWidgetState();
}

class _DRIMeterWidgetState extends State<DRIMeterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.driValue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(DRIMeterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driValue != widget.driValue) {
      _animation = Tween<double>(
        begin: oldWidget.driValue,
        end: widget.driValue,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getDRIColor(double value) {
    if (value <= 30) {
      return AppTheme.success;
    } else if (value <= 70) {
      return AppTheme.warning;
    } else {
      return AppTheme.accent;
    }
  }

  String _getDRIStatus(double value) {
    if (value <= 30) {
      return 'ALERT';
    } else if (value <= 70) {
      return 'CAUTION';
    } else {
      return 'DANGER';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      child: Container(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final currentValue = _animation.value;
            final color = _getDRIColor(currentValue);

            return CustomPaint(
              painter: DRIMeterPainter(
                value: currentValue,
                color: color,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DRI',
                      style: AppTheme.darkTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      currentValue.toInt().toString(),
                      style:
                          AppTheme.darkTheme.textTheme.displayMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 32.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getDRIStatus(currentValue),
                      style: AppTheme.darkTheme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DRIMeterPainter extends CustomPainter {
  const DRIMeterPainter({
    required this.value,
    required this.color,
  });

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppTheme.border.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (value / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Gradient overlay for visual enhancement
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius - 10, gradientPaint);
  }

  @override
  bool shouldRepaint(DRIMeterPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}

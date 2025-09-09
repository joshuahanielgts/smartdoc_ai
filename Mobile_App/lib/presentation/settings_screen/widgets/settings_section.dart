import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsSection extends StatefulWidget {
  final String title;
  final List<SettingsItem> items;
  final bool isCollapsible;
  final bool initiallyExpanded;

  const SettingsSection({
    super.key,
    required this.title,
    required this.items,
    this.isCollapsible = true,
    this.initiallyExpanded = true,
  });

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: widget.isCollapsible
                ? () => setState(() => _isExpanded = !_isExpanded)
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (widget.isCollapsible)
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: CustomIconWidget(
                        iconName: 'keyboard_arrow_down',
                        color: AppTheme.textSecondary,
                        size: 24,
                      ),
                    ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isExpanded ? null : 0,
            child: _isExpanded
                ? Column(
                    children: widget.items
                        .map((item) => _buildSettingsItem(item))
                        .toList(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(SettingsItem item) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.border.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        leading: item.icon != null
            ? CustomIconWidget(
                iconName: item.icon!,
                color: item.iconColor ?? AppTheme.textSecondary,
                size: 24,
              )
            : null,
        title: Text(
          item.title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: item.subtitle != null
            ? Text(
                item.subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              )
            : null,
        trailing: _buildTrailingWidget(item),
        onTap: item.onTap,
      ),
    );
  }

  Widget? _buildTrailingWidget(SettingsItem item) {
    switch (item.type) {
      case SettingsItemType.toggle:
        return Switch(
          value: item.value as bool? ?? false,
          onChanged:
              item.onChanged != null ? (value) => item.onChanged!(value) : null,
        );
      case SettingsItemType.slider:
        return SizedBox(
          width: 30.w,
          child: Slider(
            value: (item.value as double? ?? 0.5).clamp(0.0, 1.0),
            onChanged: item.onChanged != null
                ? (value) => item.onChanged!(value)
                : null,
          ),
        );
      case SettingsItemType.navigation:
        return CustomIconWidget(
          iconName: 'chevron_right',
          color: AppTheme.textSecondary,
          size: 20,
        );
      case SettingsItemType.action:
        return item.actionWidget ??
            CustomIconWidget(
              iconName: 'launch',
              color: AppTheme.primary,
              size: 20,
            );
      default:
        return null;
    }
  }
}

class SettingsItem {
  final String title;
  final String? subtitle;
  final String? icon;
  final Color? iconColor;
  final SettingsItemType type;
  final dynamic value;
  final Function(dynamic)? onChanged;
  final VoidCallback? onTap;
  final Widget? actionWidget;

  const SettingsItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    required this.type,
    this.value,
    this.onChanged,
    this.onTap,
    this.actionWidget,
  });
}

enum SettingsItemType {
  toggle,
  slider,
  navigation,
  action,
  info,
}

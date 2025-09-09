import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.onSearchChanged,
    this.hintText = 'Search settings...',
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          color: _isSearchActive
              ? AppTheme.primary.withValues(alpha: 0.5)
              : AppTheme.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          widget.onSearchChanged(value);
          setState(() {
            _isSearchActive = value.isNotEmpty;
          });
        },
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color:
                  _isSearchActive ? AppTheme.primary : AppTheme.textSecondary,
              size: 20,
            ),
          ),
          suffixIcon: _isSearchActive
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                    setState(() {
                      _isSearchActive = false;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 3.w,
          ),
        ),
      ),
    );
  }
}

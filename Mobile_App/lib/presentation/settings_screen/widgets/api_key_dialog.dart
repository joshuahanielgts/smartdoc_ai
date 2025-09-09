import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ApiKeyDialog extends StatefulWidget {
  final String currentApiKey;
  final Function(String) onApiKeyChanged;

  const ApiKeyDialog({
    super.key,
    required this.currentApiKey,
    required this.onApiKeyChanged,
  });

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  late TextEditingController _apiKeyController;
  bool _isObscured = true;
  bool _isTestingConnection = false;
  bool? _connectionTestResult;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.currentApiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (_apiKeyController.text.trim().isEmpty) {
      setState(() {
        _connectionTestResult = false;
      });
      return;
    }

    setState(() {
      _isTestingConnection = true;
      _connectionTestResult = null;
    });

    // Simulate API key validation
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isTestingConnection = false;
      // Mock validation - in real app, this would validate against Gemini API
      _connectionTestResult = _apiKeyController.text.trim().length > 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        constraints: BoxConstraints(
          maxWidth: 90.w,
          maxHeight: 70.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'key',
                  color: AppTheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Gemini API Key',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Enter your Gemini API key for AI-powered safety insights and session analysis.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 3.h),
            TextField(
              controller: _apiKeyController,
              obscureText: _isObscured,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontFamily: 'monospace',
              ),
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: 'AIzaSy...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'vpn_key',
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () =>
                          setState(() => _isObscured = !_isObscured),
                      icon: CustomIconWidget(
                        iconName: _isObscured ? 'visibility' : 'visibility_off',
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    if (_connectionTestResult != null)
                      Padding(
                        padding: EdgeInsets.only(right: 3.w),
                        child: CustomIconWidget(
                          iconName:
                              _connectionTestResult! ? 'check_circle' : 'error',
                          color: _connectionTestResult!
                              ? AppTheme.success
                              : AppTheme.accent,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.border,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isTestingConnection ? null : _testConnection,
                icon: _isTestingConnection
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      )
                    : CustomIconWidget(
                        iconName: 'wifi_protected_setup',
                        color: AppTheme.primary,
                        size: 16,
                      ),
                label: Text(
                    _isTestingConnection ? 'Testing...' : 'Test Connection'),
              ),
            ),
            if (_connectionTestResult != null) ...[
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: (_connectionTestResult!
                          ? AppTheme.success
                          : AppTheme.accent)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (_connectionTestResult!
                            ? AppTheme.success
                            : AppTheme.accent)
                        .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName:
                          _connectionTestResult! ? 'check_circle' : 'error',
                      color: _connectionTestResult!
                          ? AppTheme.success
                          : AppTheme.accent,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        _connectionTestResult!
                            ? 'API key is valid and connection successful'
                            : 'Invalid API key or connection failed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _connectionTestResult!
                              ? AppTheme.success
                              : AppTheme.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApiKeyChanged(_apiKeyController.text.trim());
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

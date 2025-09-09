import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/api_key_dialog.dart';
import './widgets/confirmation_dialog.dart';
import './widgets/search_bar_widget.dart';
import './widgets/settings_section.dart';
import './widgets/user_profile_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _searchQuery = '';

  // Settings state variables
  bool _isOnDeviceInference = true;
  double _alertSensitivity = 0.7;
  bool _voiceAlertsEnabled = true;
  bool _localOnlyMode = false;
  bool _locationTrackingEnabled = true;
  bool _emergencyAlertsEnabled = true;
  bool _quietHoursEnabled = false;
  bool _cloudSyncEnabled = true;
  String _geminiApiKey = '';

  final List<Map<String, dynamic>> _mockEmergencyContacts = [
    {
      "name": "Emergency Services",
      "phone": "911",
      "type": "Emergency",
    },
    {
      "name": "Sarah Rodriguez",
      "phone": "+1 (555) 123-4567",
      "type": "Family",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const UserProfileCard(),
                    SearchBarWidget(
                      onSearchChanged: (query) {
                        setState(() {
                          _searchQuery = query.toLowerCase();
                        });
                      },
                    ),
                    SizedBox(height: 2.h),
                    ..._buildFilteredSections(),
                    SizedBox(height: 10.h), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildAppBar() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.border.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'arrow_back_ios',
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              'Settings',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {
              // Voice command functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voice commands activated'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'mic',
              color: AppTheme.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredSections() {
    final sections = _getAllSections();

    if (_searchQuery.isEmpty) {
      return sections;
    }

    return sections.where((section) {
      if (section is SettingsSection) {
        return section.title.toLowerCase().contains(_searchQuery) ||
            section.items.any((item) =>
                item.title.toLowerCase().contains(_searchQuery) ||
                (item.subtitle?.toLowerCase().contains(_searchQuery) ?? false));
      }
      return false;
    }).toList();
  }

  List<Widget> _getAllSections() {
    return [
      _buildMonitoringSection(),
      _buildPrivacySection(),
      _buildNotificationsSection(),
      _buildAccountSection(),
      _buildAdvancedSection(),
      _buildHelpSection(),
    ];
  }

  Widget _buildMonitoringSection() {
    return SettingsSection(
      title: 'Monitoring',
      items: [
        SettingsItem(
          title: 'Inference Mode',
          subtitle: _isOnDeviceInference
              ? 'On-device processing'
              : 'Cloud processing',
          icon: 'memory',
          type: SettingsItemType.toggle,
          value: _isOnDeviceInference,
          onChanged: (value) {
            setState(() {
              _isOnDeviceInference = value;
            });
          },
        ),
        SettingsItem(
          title: 'Alert Sensitivity',
          subtitle: 'Adjust fatigue detection sensitivity',
          icon: 'tune',
          type: SettingsItemType.slider,
          value: _alertSensitivity,
          onChanged: (value) {
            setState(() {
              _alertSensitivity = value;
            });
          },
        ),
        SettingsItem(
          title: 'Voice Alerts',
          subtitle: 'Enable voice notifications',
          icon: 'record_voice_over',
          type: SettingsItemType.toggle,
          value: _voiceAlertsEnabled,
          onChanged: (value) {
            setState(() {
              _voiceAlertsEnabled = value;
            });
          },
        ),
        SettingsItem(
          title: 'Driver Calibration',
          subtitle: 'Reset personalized monitoring settings',
          icon: 'face_retouching_natural',
          type: SettingsItemType.navigation,
          onTap: () =>
              Navigator.pushNamed(context, '/driver-calibration-screen'),
        ),
        SettingsItem(
          title: 'Battery Optimization',
          subtitle: 'Adjust monitoring frequency to save battery',
          icon: 'battery_saver',
          type: SettingsItemType.navigation,
          onTap: () => _showBatteryOptimizationDialog(),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return SettingsSection(
      title: 'Privacy & Data',
      items: [
        SettingsItem(
          title: 'Local-Only Mode',
          subtitle: 'Keep all data on device only',
          icon: 'shield',
          iconColor: _localOnlyMode ? AppTheme.success : null,
          type: SettingsItemType.toggle,
          value: _localOnlyMode,
          onChanged: (value) {
            setState(() {
              _localOnlyMode = value;
              if (value) {
                _cloudSyncEnabled = false;
              }
            });
          },
        ),
        SettingsItem(
          title: 'Data Retention',
          subtitle: 'Automatically delete old sessions',
          icon: 'auto_delete',
          type: SettingsItemType.navigation,
          onTap: () => _showDataRetentionDialog(),
        ),
        SettingsItem(
          title: 'Location Tracking',
          subtitle: 'Enable location-based risk analysis',
          icon: 'location_on',
          type: SettingsItemType.toggle,
          value: _locationTrackingEnabled,
          onChanged: (value) {
            setState(() {
              _locationTrackingEnabled = value;
            });
          },
        ),
        SettingsItem(
          title: 'Export Data',
          subtitle: 'Download your driving data',
          icon: 'download',
          type: SettingsItemType.action,
          onTap: () => _exportUserData(),
        ),
        SettingsItem(
          title: 'Delete All Data',
          subtitle: 'Permanently remove all stored data',
          icon: 'delete_forever',
          iconColor: AppTheme.accent,
          type: SettingsItemType.action,
          onTap: () => _showDeleteDataConfirmation(),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return SettingsSection(
      title: 'Notifications',
      items: [
        SettingsItem(
          title: 'Emergency Alerts',
          subtitle: 'Critical safety notifications',
          icon: 'emergency',
          type: SettingsItemType.toggle,
          value: _emergencyAlertsEnabled,
          onChanged: (value) {
            setState(() {
              _emergencyAlertsEnabled = value;
            });
          },
        ),
        SettingsItem(
          title: 'Quiet Hours',
          subtitle: _quietHoursEnabled ? '10:00 PM - 6:00 AM' : 'Disabled',
          icon: 'bedtime',
          type: SettingsItemType.toggle,
          value: _quietHoursEnabled,
          onChanged: (value) {
            setState(() {
              _quietHoursEnabled = value;
            });
          },
        ),
        SettingsItem(
          title: 'Emergency Contacts',
          subtitle: '${_mockEmergencyContacts.length} contacts configured',
          icon: 'contact_emergency',
          type: SettingsItemType.navigation,
          onTap: () => _showEmergencyContactsDialog(),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return SettingsSection(
      title: 'Account & Sync',
      items: [
        SettingsItem(
          title: 'Cloud Sync',
          subtitle: _localOnlyMode
              ? 'Disabled (Local-only mode)'
              : (_cloudSyncEnabled ? 'Enabled' : 'Disabled'),
          icon: 'cloud_sync',
          type: SettingsItemType.toggle,
          value: _cloudSyncEnabled && !_localOnlyMode,
          onChanged: _localOnlyMode
              ? null
              : (value) {
                  setState(() {
                    _cloudSyncEnabled = value;
                  });
                },
        ),
        SettingsItem(
          title: 'Account Type',
          subtitle: 'Premium Account - Expires Dec 2025',
          icon: 'account_circle',
          type: SettingsItemType.navigation,
          onTap: () => _showAccountDetailsDialog(),
        ),
        SettingsItem(
          title: 'Backup Settings',
          subtitle: 'Save settings to cloud',
          icon: 'backup',
          type: SettingsItemType.action,
          onTap: () => _backupSettings(),
        ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return SettingsSection(
      title: 'Advanced',
      items: [
        SettingsItem(
          title: 'Gemini API Key',
          subtitle: _geminiApiKey.isEmpty ? 'Not configured' : 'Configured',
          icon: 'key',
          type: SettingsItemType.action,
          onTap: () => _showApiKeyDialog(),
        ),
        SettingsItem(
          title: 'Debug Mode',
          subtitle: 'Enable detailed logging',
          icon: 'bug_report',
          type: SettingsItemType.navigation,
          onTap: () => _showDebugModeDialog(),
        ),
        SettingsItem(
          title: 'Reset All Settings',
          subtitle: 'Restore default configuration',
          icon: 'restore',
          iconColor: AppTheme.warning,
          type: SettingsItemType.action,
          onTap: () => _showResetSettingsConfirmation(),
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    return SettingsSection(
      title: 'Help & Support',
      items: [
        SettingsItem(
          title: 'User Guide',
          subtitle: 'Learn how to use LucidDrive AI',
          icon: 'help',
          type: SettingsItemType.navigation,
          onTap: () => _openUserGuide(),
        ),
        SettingsItem(
          title: 'Contact Support',
          subtitle: 'Get help from our team',
          icon: 'support_agent',
          type: SettingsItemType.navigation,
          onTap: () => _contactSupport(),
        ),
        SettingsItem(
          title: 'Privacy Policy',
          subtitle: 'Review our privacy practices',
          icon: 'privacy_tip',
          type: SettingsItemType.navigation,
          onTap: () => _openPrivacyPolicy(),
        ),
        SettingsItem(
          title: 'App Version',
          subtitle: 'v1.2.3 (Build 456)',
          icon: 'info',
          type: SettingsItemType.info,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowDark.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                  'dashboard', 'Dashboard', '/dashboard-screen', false),
              _buildNavItem('monitor', 'Monitor', '/monitor-screen', false),
              _buildNavItem(
                  'tune', 'Calibrate', '/driver-calibration-screen', false),
              _buildNavItem('settings', 'Settings', '/settings-screen', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      String iconName, String label, String route, bool isSelected) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: isSelected ? null : () => Navigator.pushNamed(context, route),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: iconName,
                size: 24,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => ApiKeyDialog(
        currentApiKey: _geminiApiKey,
        onApiKeyChanged: (apiKey) {
          setState(() {
            _geminiApiKey = apiKey;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('API key updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDataConfirmation() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete All Data',
        message:
            'This will permanently delete all your driving sessions, settings, and personal data. This action cannot be undone.',
        confirmText: 'Delete',
        isDestructive: true,
        icon: Icons.delete_forever,
        onConfirm: () {
          // Simulate data deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data has been deleted'),
              duration: Duration(seconds: 3),
            ),
          );
        },
      ),
    );
  }

  void _showResetSettingsConfirmation() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Reset Settings',
        message:
            'This will restore all settings to their default values. Your driving data will not be affected.',
        confirmText: 'Reset',
        icon: Icons.restore,
        onConfirm: () {
          setState(() {
            _isOnDeviceInference = true;
            _alertSensitivity = 0.7;
            _voiceAlertsEnabled = true;
            _localOnlyMode = false;
            _locationTrackingEnabled = true;
            _emergencyAlertsEnabled = true;
            _quietHoursEnabled = false;
            _cloudSyncEnabled = true;
            _geminiApiKey = '';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Settings have been reset to defaults'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  void _showBatteryOptimizationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Battery Optimization',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose monitoring frequency:',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            SizedBox(height: 2.h),
            ListTile(
              title: Text('High Performance',
                  style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: Text('30 FPS - Best accuracy',
                  style: TextStyle(color: AppTheme.textSecondary)),
              leading: Radio<int>(
                value: 0,
                groupValue: 0,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: Text('Balanced',
                  style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: Text('15 FPS - Good accuracy',
                  style: TextStyle(color: AppTheme.textSecondary)),
              leading: Radio<int>(
                value: 1,
                groupValue: 0,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: Text('Power Saver',
                  style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: Text('5 FPS - Extended battery',
                  style: TextStyle(color: AppTheme.textSecondary)),
              leading: Radio<int>(
                value: 2,
                groupValue: 0,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Battery optimization updated'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showDataRetentionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Data Retention',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Automatically delete sessions older than:',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            SizedBox(height: 2.h),
            ListTile(
              title:
                  Text('Never', style: TextStyle(color: AppTheme.textPrimary)),
              leading: Radio<int>(
                value: 0,
                groupValue: 1,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: Text('30 days',
                  style: TextStyle(color: AppTheme.textPrimary)),
              leading: Radio<int>(
                value: 1,
                groupValue: 1,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: Text('90 days',
                  style: TextStyle(color: AppTheme.textPrimary)),
              leading: Radio<int>(
                value: 2,
                groupValue: 1,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title:
                  Text('1 year', style: TextStyle(color: AppTheme.textPrimary)),
              leading: Radio<int>(
                value: 3,
                groupValue: 1,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data retention policy updated'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Emergency Contacts',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _mockEmergencyContacts.map((contact) {
              return ListTile(
                leading: CustomIconWidget(
                  iconName:
                      contact['type'] == 'Emergency' ? 'emergency' : 'person',
                  color: contact['type'] == 'Emergency'
                      ? AppTheme.accent
                      : AppTheme.primary,
                  size: 24,
                ),
                title: Text(
                  contact['name'],
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                subtitle: Text(
                  contact['phone'],
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                trailing: CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add new contact functionality
            },
            child: const Text('Add Contact'),
          ),
        ],
      ),
    );
  }

  void _showAccountDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Account Details',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountDetailRow('Name', 'Michael Rodriguez'),
            _buildAccountDetailRow('Email', 'michael.rodriguez@email.com'),
            _buildAccountDetailRow('Account Type', 'Premium'),
            _buildAccountDetailRow('Member Since', 'January 2024'),
            _buildAccountDetailRow('Expires', 'December 2025'),
            _buildAccountDetailRow('Total Sessions', '1,247'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Manage subscription functionality
            },
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showDebugModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Debug Mode',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Debug mode will enable detailed logging and diagnostic information. This may impact performance and battery life.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Debug mode enabled'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _exportUserData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing data export... Download will start shortly'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _backupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings backed up to cloud successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openUserGuide() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening user guide...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening support chat...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening privacy policy...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

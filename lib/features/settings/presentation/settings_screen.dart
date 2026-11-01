import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../reminders/services/notification_service.dart';
import '../../vehicle/data/vehicle_repository.dart';

// State Providers for User Personalisation Settings
class DistanceUnitNotifier extends Notifier<String> {
  @override
  String build() => 'Kilometers (km)';

  void setUnit(String unit) => state = unit;
}

final distanceUnitProvider = NotifierProvider<DistanceUnitNotifier, String>(() => DistanceUnitNotifier());

class DateFormatNotifier extends Notifier<String> {
  @override
  String build() => 'dd/MM/yyyy';

  void setFormat(String format) => state = format;
}

final dateFormatProvider = NotifierProvider<DateFormatNotifier, String>(() => DateFormatNotifier());

class NotificationsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle(bool enabled) => state = enabled;
}

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledNotifier, bool>(() => NotificationsEnabledNotifier());

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeVehicle = ref.watch(activeVehicleProvider);
    final distanceUnit = ref.watch(distanceUnitProvider);
    final dateFormat = ref.watch(dateFormatProvider);
    final notifsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Garage Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // Vehicle Profile & Multi-Vehicle Section
            _buildSectionHeader('VEHICLE PROFILE & FLEET'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => context.push('/vehicles'),
                    child: _buildSettingRow(
                      icon: Icons.garage_rounded,
                      title: 'Active Vehicle Profile',
                      subtitle: activeVehicle != null
                          ? '${activeVehicle.nickname} (${activeVehicle.manufacturer} ${activeVehicle.model})'
                          : 'MG Comet EV (Plush)',
                      trailing: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Manage', style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.accent),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () => context.push('/odometer'),
                    child: _buildSettingRow(
                      icon: Icons.speed_rounded,
                      title: 'Odometer History Log',
                      subtitle: activeVehicle != null
                          ? '${NumberFormat('#,###').format(activeVehicle.currentOdometer)} km recorded'
                          : '4,280 km',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Smart Reminders & Documents Section
            _buildSectionHeader('MAINTENANCE & VAULT'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => context.push('/reminders'),
                    child: _buildSettingRow(
                      icon: Icons.notifications_active_outlined,
                      title: 'Smart Maintenance Reminders',
                      subtitle: 'Service intervals, tyre inspection, PUC & insurance renewal',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
                    ),
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () => context.push('/documents'),
                    child: _buildSettingRow(
                      icon: Icons.folder_shared_outlined,
                      title: 'Vehicle Document Vault',
                      subtitle: 'Encrypted offline storage for RC, PUC, and Insurance',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personalisation & Formatting
            _buildSectionHeader('PERSONALISATION & PREFERENCES'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.straighten_rounded,
                    title: 'Distance Units',
                    subtitle: distanceUnit,
                    trailing: DropdownButton<String>(
                      value: distanceUnit,
                      dropdownColor: AppColors.elevatedSurface,
                      underline: const SizedBox.shrink(),
                      style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600),
                      items: const [
                        DropdownMenuItem(value: 'Kilometers (km)', child: Text('km')),
                        DropdownMenuItem(value: 'Miles (mi)', child: Text('miles')),
                      ],
                      onChanged: (val) {
                        if (val != null) ref.read(distanceUnitProvider.notifier).setUnit(val);
                      },
                    ),
                  ),
                  const Divider(),
                  _buildSettingRow(
                    icon: Icons.calendar_month_outlined,
                    title: 'Date Display Format',
                    subtitle: dateFormat,
                    trailing: DropdownButton<String>(
                      value: dateFormat,
                      dropdownColor: AppColors.elevatedSurface,
                      underline: const SizedBox.shrink(),
                      style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600),
                      items: const [
                        DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('dd/MM/yyyy')),
                        DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/dd/yyyy')),
                        DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('yyyy-MM-dd')),
                      ],
                      onChanged: (val) {
                        if (val != null) ref.read(dateFormatProvider.notifier).setFormat(val);
                      },
                    ),
                  ),
                  const Divider(),
                  _buildSettingRow(
                    icon: Icons.alarm_on_rounded,
                    title: 'Local Scheduled Notifications',
                    subtitle: notifsEnabled ? 'Enabled (Offline Android alarms)' : 'Disabled',
                    trailing: Switch(
                      value: notifsEnabled,
                      activeThumbColor: AppColors.accent,
                      onChanged: (val) async {
                        if (val) {
                          await ref.read(notificationServiceProvider).requestPermissions();
                        } else {
                          await ref.read(notificationServiceProvider).cancelAllNotifications();
                        }
                        ref.read(notificationsEnabledProvider.notifier).toggle(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Backup & Restore
            _buildSectionHeader('DATA BACKUP & PRIVACY'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => context.push('/backup'),
                    child: _buildSettingRow(
                      icon: Icons.archive_outlined,
                      title: 'Offline Backup & Restore',
                      subtitle: 'Export/import versioned ZIP archives with integrity checks',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
                    ),
                  ),
                  const Divider(),
                  _buildSettingRow(
                    icon: Icons.cloud_off_rounded,
                    title: 'Zero Telemetry & Cloud Freedom',
                    subtitle: '100% private. All data and files remain locally on your device.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Information
            _buildSectionHeader('ABOUT MYGARAGE'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.verified_user_outlined,
                    title: 'Version',
                    subtitle: '1.4.0-sprint4 (Build 4)',
                  ),
                  const Divider(),
                  _buildSettingRow(
                    icon: Icons.code_rounded,
                    title: 'Architecture',
                    subtitle: 'Flutter 3.44 + Drift SQLite v4 + Riverpod + GoRouter',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.tertiaryText,
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

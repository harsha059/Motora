import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Garage Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          children: [
            // Vehicle Information Section
            _buildSectionHeader('VEHICLE PROFILE'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.electric_car_rounded,
                    title: 'Vehicle Model',
                    subtitle: 'MG Comet EV (2024)',
                  ),
                  const Divider(),
                  _buildSettingRow(
                    icon: Icons.battery_charging_full_rounded,
                    title: 'Battery Capacity',
                    subtitle: '17.3 kWh Lithium-ion (Prismatic Cells)',
                  ),
                  const Divider(),
                  _buildSettingRow(
                    icon: Icons.speed_rounded,
                    title: 'Odometer (Current)',
                    subtitle: '4,280 km',
                  ),
                  const Divider(),
                  _buildSettingRow(
                    icon: Icons.confirmation_number_outlined,
                    title: 'VIN / Chassis Identifier',
                    subtitle: 'MBL-EVCOMET-2024-0891',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Appearance & Themes
            _buildSectionHeader('INTERFACE & THEME'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.dark_mode_rounded,
                    title: 'Theme Mode',
                    subtitle: 'Automotive Cyber Dark (Fixed)',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentDim,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DARK',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent),
                      ),
                    ),
                  ),
                  const Divider(),
                  _buildSettingRow(
                    icon: Icons.color_lens_outlined,
                    title: 'Accent Palette',
                    subtitle: 'Electric Cyan (#36E1BD)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data & Storage
            _buildSectionHeader('DATA & EXPORT'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.storage_rounded,
                    title: 'Database Engine',
                    subtitle: 'SQLite via Drift (Offline-first)',
                  ),
                  const Divider(),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exporting service logs as PDF/JSON will be available in future release'),
                        ),
                      );
                    },
                    child: _buildSettingRow(
                      icon: Icons.file_download_outlined,
                      title: 'Export Service Log',
                      subtitle: 'Generate PDF or JSON for technician',
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryText),
                    ),
                  ),
                  const Divider(),
                  _buildSettingRow(
                    icon: Icons.cloud_off_rounded,
                    title: 'Cloud Dependencies',
                    subtitle: 'Zero telemetry / 100% private & local',
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
                    subtitle: '1.0.0-sprint0 (Build 1)',
                  ),
                  const Divider(),
                  _buildSettingRow(
                    icon: Icons.code_rounded,
                    title: 'Architecture',
                    subtitle: 'Flutter 3.44 + Drift SQLite + Riverpod + GoRouter',
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

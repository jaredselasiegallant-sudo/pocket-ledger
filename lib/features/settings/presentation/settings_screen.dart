import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/constants/app_constants.dart';
import 'package:pocket_ledger/core/utils/export_engine.dart';
import 'package:pocket_ledger/features/auto_capture/presentation/auto_capture_confirm_dialog.dart';
import 'package:pocket_ledger/features/settings/presentation/about_screen.dart';
import 'package:pocket_ledger/features/settings/presentation/quick_expense_modal.dart';
import 'package:pocket_ledger/main.dart' show themeModeProvider;

/// Settings Screen - Stitch Expressive
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTypography.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Auto-Capture Section ───
          _SettingsSection(
            title: 'Auto-Capture',
            children: [
              _SettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Notification Listener',
                subtitle: 'Auto-detect MoMo & bank alerts',
                onTap: () {
                  _showAutoCaptureDemo(context);
                },
              ),
              _SettingsTile(
                icon: Icons.sms_rounded,
                title: 'SMS Reader',
                subtitle: 'Scan SMS for transaction texts',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.speed_rounded,
                title: 'Quick Log',
                subtitle: 'Alt+Space quick expense entry',
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const QuickExpenseModal(),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── Appearance Section ───
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: themeMode == ThemeMode.dark ? 'On' : 'Off',
                value: themeMode == ThemeMode.dark,
                onChanged: (val) {
                  ref.read(themeModeProvider.notifier).state =
                      val ? ThemeMode.dark : ThemeMode.light;
                },
              ),
              _SettingsTile(
                icon: Icons.palette_rounded,
                title: 'Accent Color',
                subtitle: 'Ghana Green',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── Currency Section ───
          _SettingsSection(
            title: 'Currency',
            children: [
              _SettingsTile(
                icon: Icons.attach_money_rounded,
                title: 'Default Currency',
                subtitle: '${AppConstants.defaultCurrencyName} (${AppConstants.defaultCurrencyCode})',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.currency_exchange_rounded,
                title: 'Offline Exchange Rates',
                subtitle: 'USD, EUR, GBP, NGN, KES, ZAR',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── Data & Export Section ───
          _SettingsSection(
            title: 'Data & Export',
            children: [
              _SettingsTile(
                icon: Icons.file_download_rounded,
                title: 'Export as Excel',
                subtitle: 'Download .xlsx spreadsheet',
                onTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Exporting to Excel...'),
                      backgroundColor: colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  try {
                    final path = await ExportEngine.exportToExcel(transactions: [
                      {'date': '2026-07-30', 'title': 'MTN MoMo Transfer', 'type': 'DEBIT', 'category': 'Transport', 'amount': -250.0, 'provider': 'MTN MoMo', 'reference': '', 'notes': ''},
                      {'date': '2026-07-30', 'title': 'Salary Credit', 'type': 'CREDIT', 'category': 'Salary', 'amount': 5500.0, 'provider': 'GCB Bank', 'reference': '', 'notes': ''},
                    ]);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Exported to: $path'),
                          backgroundColor: AppColors.income,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Export failed: $e'),
                          backgroundColor: AppColors.expense,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
              _SettingsTile(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Export as PDF',
                subtitle: 'Download formatted statement',
                onTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Generating PDF statement...'),
                      backgroundColor: colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  try {
                    final path = await ExportEngine.exportToPdf(
                      transactions: [
                        {'date': '2026-07-30', 'title': 'MTN MoMo Transfer', 'type': 'debit', 'amount': -250.0},
                        {'date': '2026-07-30', 'title': 'Salary Credit', 'type': 'credit', 'amount': 5500.0},
                      ],
                      totalIncome: 5500.0,
                      totalExpenses: 250.0,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Exported to: $path'),
                          backgroundColor: AppColors.income,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Export failed: $e'),
                          backgroundColor: AppColors.expense,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
              _SettingsTile(
                icon: Icons.backup_rounded,
                title: 'Backup & Restore',
                subtitle: 'Local backup to device storage',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── Accounts Section ───
          _SettingsSection(
            title: 'Accounts',
            children: [
              _SettingsTile(
                icon: Icons.account_balance_rounded,
                title: 'Manage Accounts',
                subtitle: 'MTN MoMo, GCB, Telecel, etc.',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ─── About Section ───
          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: AppConstants.appName,
                subtitle: 'Version ${AppConstants.appVersion} • Made in Ghana',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AboutScreen(),
                    ),
                  );
                },
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy',
                subtitle: 'All data stays on your device',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showAutoCaptureDemo(BuildContext context) {
    AutoCaptureConfirmDialog.show(
      context,
      amount: 250.00,
      provider: 'MTN MoMo',
      type: 'debit',
      recipient: 'John Mensah',
      reference: 'MOMO123456789',
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: AppTypography.labelLarge.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: colorScheme.primary,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/constants/app_constants.dart';
import 'package:pocket_ledger/core/utils/export_engine.dart';
import 'package:pocket_ledger/core/providers.dart';
import 'package:pocket_ledger/features/auto_capture/data/auto_capture_service.dart';
import 'package:pocket_ledger/features/settings/presentation/about_screen.dart';
import 'package:pocket_ledger/features/settings/presentation/quick_expense_modal.dart';
import 'package:pocket_ledger/features/settings/presentation/update_dialog.dart';
import 'package:pocket_ledger/core/utils/update_service.dart';
import 'package:pocket_ledger/main.dart' show themeModeProvider;

/// Settings Screen
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final currencyCode = ref.watch(currencyProvider);
    final currencyName = ref.watch(currencyNameProvider);

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
          _SettingsSection(
            title: 'Auto-Capture',
            children: [
              _SettingsTile(
                icon: Icons.notifications_active_rounded,
                title: 'Notification Listener',
                subtitle: 'Auto-detect MoMo & bank alerts',
                onTap: () => _showAutoCaptureDemo(context),
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

          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsSwitchTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: themeMode == ThemeMode.dark ? 'On' : 'Off',
                value: themeMode == ThemeMode.dark,
                onChanged: (val) {
                  ref.read(themeModeProvider.notifier).setTheme(
                        val ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SettingsSection(
            title: 'Currency',
            children: [
              _SettingsTile(
                icon: Icons.attach_money_rounded,
                title: 'Default Currency',
                subtitle: '$currencyName ($currencyCode)',
                onTap: () => _showCurrencyPicker(context, ref, currencyCode),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SettingsSection(
            title: 'Data & Export',
            children: [
              _SettingsTile(
                icon: Icons.file_download_rounded,
                title: 'Export as Excel',
                subtitle: 'Download .xlsx spreadsheet',
                onTap: () => _exportExcel(context, ref),
              ),
              _SettingsTile(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Export as PDF',
                subtitle: 'Download formatted statement',
                onTap: () => _exportPdf(context, ref),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _SettingsSection(
            title: 'About',
            children: [
              _SettingsTile(
                icon: Icons.system_update_rounded,
                title: 'Check for Updates',
                subtitle: 'See if a new version is available',
                onTap: () => _checkForUpdates(context),
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: AppConstants.appName,
                subtitle:
                    'Version ${AppConstants.appVersion} • Made in Ghana',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AboutScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showAutoCaptureDemo(BuildContext context) async {
    final service = AutoCaptureService();
    final isEnabled = await service.isNotificationListenerEnabled();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: Theme.of(ctx).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Notification Listener',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.income.withValues(alpha: 0.08)
                    : Theme.of(ctx).colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    isEnabled ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    color: isEnabled ? AppColors.income : Theme.of(ctx).colorScheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEnabled
                          ? 'Notification listener is active'
                          : 'Notification listener is disabled',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(ctx).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'PocketLedger reads notifications from MoMo, bank, and mobile money apps to automatically log your transactions. '
              'No data ever leaves your device.',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (!isEnabled)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await service.openNotificationSettings();
                  },
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Enable in Settings'),
                ),
              ),
            if (isEnabled)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await service.openNotificationSettings();
                  },
                  icon: const Icon(Icons.settings_rounded),
                  label: const Text('Manage in Settings'),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Checking for updates...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    final info = await UpdateService.checkForUpdate();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    if (info == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You\'re running the latest version!'),
          backgroundColor: AppColors.income,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => UpdateDialog(updateInfo: info),
      );
    }
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, String currentCode) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Currency',
              style: AppTypography.headlineSmall.copyWith(
                color: Theme.of(ctx).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...AppConstants.supportedCurrencies.entries.map((entry) {
              final code = entry.key;
              final name = entry.value['name']!;
              final symbol = entry.value['symbol']!;
              final isSelected = code == currentCode;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(ctx).colorScheme.primaryContainer
                        : Theme.of(ctx).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      symbol,
                      style: AppTypography.titleMedium.copyWith(
                        color: isSelected
                            ? Theme.of(ctx).colorScheme.primary
                            : Theme.of(ctx).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  code,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded,
                        color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(currencyProvider.notifier).setCurrency(code);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _exportExcel(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting to Excel...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    try {
      final summary = ref.read(currentMonthSummaryProvider).valueOrNull;
      final txns = summary?.transactions ?? [];
      final txData = txns.map((t) => {
        'date': DateFormat('yyyy-MM-dd').format(t.transactionDate),
        'title': t.title,
        'type': t.type.toUpperCase(),
        'category': t.category,
        'amount': t.amount,
        'provider': t.provider ?? '',
        'reference': t.reference ?? '',
        'notes': t.description ?? '',
      }).toList();

      final path = await ExportEngine.exportToExcel(transactions: txData);
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
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Generating PDF statement...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    try {
      final summary = ref.read(currentMonthSummaryProvider).valueOrNull;
      final txns = summary?.transactions ?? [];
      final txData = txns.map((t) => {
        'date': DateFormat('yyyy-MM-dd').format(t.transactionDate),
        'title': t.title,
        'type': t.type,
        'amount': t.amount,
      }).toList();

      final path = await ExportEngine.exportToPdf(
        transactions: txData,
        totalIncome: summary?.income ?? 0,
        totalExpenses: summary?.expenses ?? 0,
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

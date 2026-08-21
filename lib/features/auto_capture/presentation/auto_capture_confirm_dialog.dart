import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/core/providers/app_providers.dart';

/// Auto-Capture Confirmation Popup
/// Shows when a transaction is detected from notification/SMS
class AutoCaptureConfirmDialog extends ConsumerWidget {
  const AutoCaptureConfirmDialog({
    super.key,
    required this.amount,
    required this.provider,
    required this.type,
    this.sender,
    this.recipient,
    this.reference,
  });

  final double amount;
  final String provider;
  final String type;
  final String? sender;
  final String? recipient;
  final String? reference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isCredit = type == 'credit';
    final color = isCredit ? AppColors.income : AppColors.expense;
    final icon = isCredit
        ? Icons.arrow_downward_rounded
        : type == 'transfer'
            ? Icons.swap_horiz_rounded
            : Icons.arrow_upward_rounded;

    return Dialog(
      backgroundColor: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ).animate().scale(
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 16),

            Text(
              isCredit ? 'Payment Received' : 'Transaction Detected',
              style: AppTypography.titleMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider,
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              '${isCredit ? '+' : '-'}${CurrencyFormatter.formatGhs(amount)}',
              style: AppTypography.currencyDisplay.copyWith(color: color),
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (sender != null)
                    _DetailRow(
                      label: 'From',
                      value: sender!,
                      colorScheme: colorScheme,
                    ),
                  if (recipient != null)
                    _DetailRow(
                      label: 'To',
                      value: recipient!,
                      colorScheme: colorScheme,
                    ),
                  if (reference != null)
                    _DetailRow(
                      label: 'Reference',
                      value: reference!,
                      colorScheme: colorScheme,
                    ),
                  _DetailRow(
                    label: 'Time',
                    value: _formatTime(DateTime.now()),
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, 'discard'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      side: BorderSide(
                          color: colorScheme.outlineVariant),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, 'edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await _confirmTransaction(ref);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmTransaction(WidgetRef ref) async {
    try {
      final txnRepo = ref.read(transactionRepositoryProvider);
      await txnRepo.addTransaction(
        title: type == 'credit'
            ? 'Received from ${sender ?? provider}'
            : 'Payment via $provider',
        amount: amount,
        type: type,
        category: 'Other',
        vendor: sender ?? recipient,
        reference: reference,
        provider: provider,
      );
    } catch (_) {}
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static Future<String?> show(
    BuildContext context, {
    required double amount,
    required String provider,
    required String type,
    String? sender,
    String? recipient,
    String? reference,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AutoCaptureConfirmDialog(
        amount: amount,
        provider: provider,
        type: type,
        sender: sender,
        recipient: recipient,
        reference: reference,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

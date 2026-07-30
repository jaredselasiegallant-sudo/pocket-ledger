import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';

/// Auto-Capture Confirmation Card
/// Precision Utilitarian design - detected from notification
class AutoCaptureConfirmDialog extends StatefulWidget {
  const AutoCaptureConfirmDialog({
    super.key,
    required this.amount,
    required this.provider,
    required this.type,
    this.merchant,
    this.location,
    this.sender,
    this.recipient,
    this.reference,
    this.accountLast4,
  });

  final double amount;
  final String provider;
  final String type; // 'credit', 'debit', 'transfer'
  final String? merchant;
  final String? location;
  final String? sender;
  final String? recipient;
  final String? reference;
  final String? accountLast4;

  static Future<String?> show(
    BuildContext context, {
    required double amount,
    required String provider,
    required String type,
    String? merchant,
    String? location,
    String? sender,
    String? recipient,
    String? reference,
    String? accountLast4,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AutoCaptureConfirmDialog(
        amount: amount,
        provider: provider,
        type: type,
        merchant: merchant,
        location: location,
        sender: sender,
        recipient: recipient,
        reference: reference,
        accountLast4: accountLast4,
      ),
    );
  }

  @override
  State<AutoCaptureConfirmDialog> createState() =>
      _AutoCaptureConfirmDialogState();
}

class _AutoCaptureConfirmDialogState extends State<AutoCaptureConfirmDialog> {
  bool _isProcessing = false;
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isCredit = widget.type == 'credit';
    final typeLabel = isCredit ? 'Credit' : 'Debit';
    final typeIcon = isCredit ? Icons.savings_outlined : Icons.credit_card;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Detected Badge ───
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 16,
                    color: colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Detected from Notification',
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Main Confirmation Card ───
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Vendor Header ───
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Store Icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Icon(
                            Icons.storefront_outlined,
                            size: 32,
                            color: colorScheme.onSurface,
                          ),
                        ).animate().scale(
                              duration: 300.ms,
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 16),

                        // Merchant Name
                        Text(
                          widget.merchant ?? widget.provider,
                          style: AppTypography.headlineSmall.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 4),

                        // Location + Time
                        Text(
                          [
                            if (widget.location != null) widget.location,
                            'Just Now',
                          ].join(' • '),
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // ─── Divider ───
                  Divider(
                    height: 1,
                    color: colorScheme.surfaceContainer,
                  ),

                  // ─── Transaction Details ───
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Amount
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'AMOUNT',
                              style: AppTypography.labelSmall.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatGhs(widget.amount),
                              style: AppTypography.currencyDisplay.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(
                              duration: 400.ms,
                              delay: 100.ms,
                            ),

                        const SizedBox(height: 16),

                        // Type & Account Row
                        Row(
                          children: [
                            // Type
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TYPE',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        typeIcon,
                                        size: 18,
                                        color: colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        typeLabel,
                                        style: AppTypography.titleMedium
                                            .copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Account
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'ACCOUNT',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.accountLast4 != null
                                        ? 'Checking (*${widget.accountLast4})'
                                        : 'Checking',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── Action Buttons ───
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: [
                        // Confirm Button (Success Green)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isProcessing || _isConfirmed
                                ? null
                                : () => _handleConfirm(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isConfirmed
                                  ? colorScheme.tertiaryContainer
                                  : colorScheme.tertiary,
                              foregroundColor: _isConfirmed
                                  ? colorScheme.onTertiaryContainer
                                  : colorScheme.onPrimary,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isProcessing
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.onPrimary,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isConfirmed
                                            ? Icons.check
                                            : Icons.check_circle,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isConfirmed ? 'Confirmed' : 'Confirm',
                                        style: AppTypography.titleMedium
                                            .copyWith(
                                          color: _isConfirmed
                                              ? AppColors.lightOnTertiaryContainer
                                              : colorScheme.onPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Edit & Ignore Row
                        Row(
                          children: [
                            // Edit
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton(
                                  onPressed: _isProcessing
                                      ? null
                                      : () => Navigator.pop(context, 'edit'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorScheme.onSurface,
                                    side: BorderSide(
                                      color: colorScheme.outline,
                                    ),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Edit',
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Ignore
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton(
                                onPressed: _isProcessing
                                    ? null
                                    : () => Navigator.pop(context, 'discard'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: colorScheme.error,
                                  side: BorderSide(
                                    color: colorScheme.error,
                                  ),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.block_outlined,
                                        size: 18,
                                        color: colorScheme.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ignore',
                                        style:
                                            AppTypography.bodyMedium.copyWith(
                                          color: colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── Map Indicator (Optional) ───
                  if (widget.location != null)
                    Container(
                      width: double.infinity,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Grayscale map background
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHigh,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                          ),
                          // Location badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: colorScheme.onSurface,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Verified Location',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ─── Utility Footer ───
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text.rich(
                TextSpan(
                  text: 'Mistake? ',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: 'Flag as incorrect merchant',
                      style: AppTypography.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleConfirm(BuildContext context) async {
    setState(() => _isProcessing = true);

    // Simulate processing
    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      _isProcessing = false;
      _isConfirmed = true;
    });

    // Close after confirmation
    await Future.delayed(const Duration(milliseconds: 800));

    if (context.mounted) {
      Navigator.pop(context, 'confirm');
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/core/providers/app_providers.dart';
import 'package:pocket_ledger/core/constants/app_constants.dart';

/// Windows Quick Expense Logging Modal
/// Triggered via global hotkey (Alt+Space)
class QuickExpenseModal extends ConsumerStatefulWidget {
  const QuickExpenseModal({super.key});

  @override
  ConsumerState<QuickExpenseModal> createState() => _QuickExpenseModalState();
}

class _QuickExpenseModalState extends ConsumerState<QuickExpenseModal> {
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food & Dining';
  String _selectedAccount = 'MTN MoMo';
  bool _isSaving = false;

  static const _categories = AppConstants.defaultCategories;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final accountsAsync = ref.watch(activeAccountsStreamProvider);
    final accounts = accountsAsync.valueOrNull ?? [];
    final accountNames = accounts.map((a) => a.name).toList();
    if (accountNames.isNotEmpty && !accountNames.contains(_selectedAccount)) {
      _selectedAccount = accountNames.first;
    }

    return Dialog(
      backgroundColor: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.flash_on_rounded,
                        color: colorScheme.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Log',
                      style: AppTypography.titleMedium.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _amountController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTypography.headlineMedium.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: 'GH₵ ',
                prefixStyle: AppTypography.headlineMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: accountNames.contains(_selectedAccount)
                            ? _selectedAccount
                            : (accountNames.isNotEmpty
                                ? accountNames.first
                                : _selectedAccount),
                        isExpanded: true,
                        isDense: true,
                        dropdownColor: colorScheme.surfaceContainerLow,
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        items: (accountNames.isNotEmpty
                                ? accountNames
                                : AppConstants.mobileMoneyProviders
                                    .followedBy(
                                        AppConstants.bankProviders)
                                    .toList())
                            .map((acc) {
                          return DropdownMenuItem(
                            value: acc,
                            child: Text(acc),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedAccount = val);
                          }
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                SizedBox(
                  height: 40,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveQuickExpense,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Save'),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Press Alt+Space anywhere to open',
                style: AppTypography.labelSmall.copyWith(
                  color:
                      colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveQuickExpense() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final txnRepo = ref.read(transactionRepositoryProvider);
      await txnRepo.addTransaction(
        title: _selectedCategory,
        amount: amount,
        type: 'debit',
        category: _selectedCategory,
        account: _selectedAccount,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logged: ${CurrencyFormatter.formatGhs(amount)} - $_selectedCategory',
            ),
            backgroundColor: AppColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

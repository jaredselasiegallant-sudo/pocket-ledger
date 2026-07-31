import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/constants/app_constants.dart';
import 'package:pocket_ledger/core/providers.dart';

/// Full Add Transaction Screen
/// Supports credit, debit, and transfer with category picker,
/// account selector, date picker, and notes
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Food & Dining';
  String _selectedAccount = 'MTN MoMo';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  bool _isSaving = false;

  static const _categories = AppConstants.defaultCategories;
  static const _accounts = [
    'MTN MoMo',
    'Telecel Cash',
    'AT Money',
    'GCB Bank',
    'Cash Wallet',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Transaction',
          style: AppTypography.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveTransaction,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: AppTypography.labelLarge.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _AmountInput(
              controller: _amountController,
              colorScheme: colorScheme,
              currencySymbol: currencySymbol,
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

            const SizedBox(height: 24),

            _TransactionTypeTabs(
              tabController: _tabController,
              colorScheme: colorScheme,
            ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

            const SizedBox(height: 24),

            TextFormField(
              controller: _titleController,
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'What was this for?',
                prefixIcon: Icon(
                  Icons.description_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

            const SizedBox(height: 20),

            _CategoryPicker(
              selected: _selectedCategory,
              categories: _categories,
              colorScheme: colorScheme,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

            const SizedBox(height: 20),

            _AccountPicker(
              selected: _selectedAccount,
              accounts: _accounts,
              colorScheme: colorScheme,
              onSelected: (acc) => setState(() => _selectedAccount = acc),
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

            const SizedBox(height: 20),

            _DatePicker(
              selectedDate: _selectedDate,
              colorScheme: colorScheme,
              onPicked: (date) => setState(() => _selectedDate = date),
            ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

            const SizedBox(height: 20),

            TextFormField(
              controller: _notesController,
              style: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface,
              ),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Icon(
                    Icons.notes_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

            const SizedBox(height: 20),

            _RecurringToggle(
              isRecurring: _isRecurring,
              colorScheme: colorScheme,
              onChanged: (val) => setState(() => _isRecurring = val),
            ).animate().fadeIn(duration: 300.ms, delay: 350.ms),

            const SizedBox(height: 32),

            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: _isSaving ? null : _saveTransaction,
                style: FilledButton.styleFrom(
                  backgroundColor: _getTransactionColor(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _getSaveButtonText(),
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 400.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Color _getTransactionColor() {
    switch (_tabController.index) {
      case 0:
        return AppColors.expense;
      case 1:
        return AppColors.income;
      case 2:
        return AppColors.transfer;
      default:
        return AppColors.expense;
    }
  }

  String _getSaveButtonText() {
    switch (_tabController.index) {
      case 0:
        return 'Record Expense';
      case 1:
        return 'Record Income';
      case 2:
        return 'Record Transfer';
      default:
        return 'Save Transaction';
    }
  }

  String _getTransactionType() {
    switch (_tabController.index) {
      case 0:
        return 'debit';
      case 1:
        return 'credit';
      case 2:
        return 'transfer';
      default:
        return 'debit';
    }
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: AppColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final txRepo = ref.read(transactionRepositoryProvider);
      await txRepo.addTransaction(
        title: _titleController.text.isNotEmpty
            ? _titleController.text
            : _getSaveButtonText(),
        amount: amount,
        type: _getTransactionType(),
        category: _selectedCategory,
        vendor: _selectedAccount,
        account: _selectedAccount,
        description: _notesController.text.isNotEmpty ? _notesController.text : null,
        transactionDate: _selectedDate,
      );

      // Record spending in budget if it's an expense
      if (_getTransactionType() == 'debit') {
        final budgetRepo = ref.read(budgetRepositoryProvider);
        await budgetRepo.recordSpending(_selectedCategory, amount);
      }

      // Refresh data
      ref.invalidate(currentMonthSummaryProvider);
      ref.invalidate(totalBalanceProvider);
      ref.invalidate(categorySpendingProvider);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_getSaveButtonText()}: ${_amountController.text} - $_selectedCategory',
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
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _AmountInput extends StatelessWidget {
  const _AmountInput({
    required this.controller,
    required this.colorScheme,
    required this.currencySymbol,
  });

  final TextEditingController controller;
  final ColorScheme colorScheme;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            currencySymbol,
            style: AppTypography.headlineLarge.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: true,
              style: AppTypography.headlineLarge.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: AppTypography.headlineLarge.copyWith(
                  color:
                      colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w800,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTypeTabs extends StatelessWidget {
  const _TransactionTypeTabs({
    required this.tabController,
    required this.colorScheme,
  });

  final TabController tabController;
  final ColorScheme colorScheme;

  static const _types = [
    ('Expense', Icons.arrow_upward_rounded, AppColors.expense),
    ('Income', Icons.arrow_downward_rounded, AppColors.income),
    ('Transfer', Icons.swap_horiz_rounded, AppColors.transfer),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _types[tabController.index].$3,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: AppTypography.labelMedium,
        tabs: _types.map((type) {
          final (label, icon, _) = type;
          return Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 6),
                Text(label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.selected,
    required this.categories,
    required this.colorScheme,
    required this.onSelected,
  });

  final String selected;
  final List<String> categories;
  final ColorScheme colorScheme;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = cat == selected;
            return GestureDetector(
              onTap: () => onSelected(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  cat,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AccountPicker extends StatelessWidget {
  const _AccountPicker({
    required this.selected,
    required this.accounts,
    required this.colorScheme,
    required this.onSelected,
  });

  final String selected;
  final List<String> accounts;
  final ColorScheme colorScheme;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: AppTypography.labelLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              dropdownColor: colorScheme.surfaceContainerLow,
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurface,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
              items: accounts.map((acc) {
                return DropdownMenuItem(value: acc, child: Text(acc));
              }).toList(),
              onChanged: (val) {
                if (val != null) onSelected(val);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.selectedDate,
    required this.colorScheme,
    required this.onPicked,
  });

  final DateTime selectedDate;
  final ColorScheme colorScheme;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: now,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context)
                    .colorScheme
                    .copyWith(primary: colorScheme.primary),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              isToday
                  ? 'Today'
                  : DateFormat('dd/MM/yyyy').format(selectedDate),
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecurringToggle extends StatelessWidget {
  const _RecurringToggle({
    required this.isRecurring,
    required this.colorScheme,
    required this.onChanged,
  });

  final bool isRecurring;
  final ColorScheme colorScheme;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.repeat_rounded,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recurring Transaction',
                  style: AppTypography.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Repeat this transaction weekly or monthly',
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isRecurring,
            onChanged: onChanged,
            activeThumbColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

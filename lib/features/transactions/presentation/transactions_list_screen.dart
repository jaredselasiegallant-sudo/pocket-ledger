import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/core/providers/app_providers.dart';
import 'package:pocket_ledger/features/transactions/presentation/add_transaction_screen.dart';

/// Transactions List Screen with filters, search, and swipe actions
class TransactionsListScreen extends ConsumerStatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState
    extends ConsumerState<TransactionsListScreen> {
  String _selectedFilter = 'All';
  String _selectedPeriod = 'This Month';
  bool _isSearching = false;
  final _searchController = TextEditingController();

  static const _filters = ['All', 'Income', 'Expenses', 'Transfers'];
  static const _periods = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _filterToType(String filter) {
    switch (filter) {
      case 'Income':
        return 'credit';
      case 'Expenses':
        return 'debit';
      case 'Transfers':
        return 'transfer';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final incomeAsync = ref.watch(monthlyIncomeProvider);
    final expensesAsync = ref.watch(monthlyExpensesProvider);
    final balanceAsync = ref.watch(totalBalanceProvider);

    final allTransactions = transactionsAsync.valueOrNull ?? [];
    final totalIncome = incomeAsync.valueOrNull ?? 0.0;
    final totalExpenses = expensesAsync.valueOrNull ?? 0.0;
    final totalBalance = balanceAsync.valueOrNull ?? 0.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    List filtered = allTransactions.where((txn) {
      final txnDate = txn.transactionDate;
      final txnDay = DateTime(txnDate.year, txnDate.month, txnDate.day);

      switch (_selectedPeriod) {
        case 'Today':
          if (txnDay != today) return false;
          break;
        case 'This Week':
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          if (txnDay.isBefore(weekStart)) return false;
          break;
        case 'This Month':
          if (txnDate.month != now.month || txnDate.year != now.year) {
            return false;
          }
          break;
        case 'This Year':
          if (txnDate.year != now.year) return false;
          break;
      }

      final typeFilter = _filterToType(_selectedFilter);
      if (typeFilter.isNotEmpty && txn.type != typeFilter) return false;

      if (_isSearching && _searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final title = txn.title.toLowerCase();
        final category = (txn.category ?? '').toLowerCase();
        if (!title.contains(query) && !category.contains(query)) return false;
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : Text(
                'Transactions',
                style: AppTypography.titleLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _PeriodSelector(
            selected: _selectedPeriod,
            periods: _periods,
            colorScheme: colorScheme,
            onSelected: (p) => setState(() => _selectedPeriod = p),
          ),

          _SummaryRow(
            colorScheme: colorScheme,
            income: totalIncome,
            expenses: totalExpenses,
            balance: totalBalance,
          ),

          _FilterChips(
            selected: _selectedFilter,
            filters: _filters,
            colorScheme: colorScheme,
            onSelected: (f) => setState(() => _selectedFilter = f),
          ),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: AppTypography.titleMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedFilter != 'All'
                              ? 'Try changing your filter'
                              : 'Add a transaction to get started',
                          style: AppTypography.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : _TransactionList(
                    colorScheme: colorScheme,
                    transactions: filtered,
                    txnRepo: ref.read(transactionRepositoryProvider),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add_rounded),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
    );
  }
}

/// Period Selector Row
class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.selected,
    required this.periods,
    required this.colorScheme,
    required this.onSelected,
  });

  final String selected;
  final List<String> periods;
  final ColorScheme colorScheme;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: periods.length,
        itemBuilder: (context, index) {
          final period = periods[index];
          final isSelected = period == selected;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(period),
              selected: isSelected,
              onSelected: (_) => onSelected(period),
              selectedColor: colorScheme.primaryContainer,
              labelStyle: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Income/Expense Summary Row
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.colorScheme,
    required this.income,
    required this.expenses,
    required this.balance,
  });

  final ColorScheme colorScheme;
  final double income;
  final double expenses;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Income',
            amount: income,
            color: AppColors.income,
            icon: Icons.arrow_downward_rounded,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            label: 'Expenses',
            amount: expenses,
            color: AppColors.expense,
            icon: Icons.arrow_upward_rounded,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            label: 'Balance',
            amount: balance,
            color: colorScheme.primary,
            icon: Icons.account_balance_wallet_rounded,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.formatCompact(amount),
              style: AppTypography.titleSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter Chips
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.filters,
    required this.colorScheme,
    required this.onSelected,
  });

  final String selected;
  final List<String> filters;
  final ColorScheme colorScheme;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selected;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => onSelected(filter),
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.primary,
              labelStyle: AppTypography.labelMedium.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Transaction List with date grouping - Real Data
class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.colorScheme,
    required this.transactions,
    required this.txnRepo,
  });

  final ColorScheme colorScheme;
  final List<dynamic> transactions;
  final dynamic txnRepo;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<dynamic>>{};
    for (final txn in transactions) {
      final date = txn.transactionDate as DateTime;
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(txn);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: sortedKeys.length,
      itemBuilder: (context, sectionIndex) {
        final dateKey = sortedKeys[sectionIndex];
        final txns = grouped[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                _formatDateKey(dateKey),
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ...txns.asMap().entries.map((entry) {
              final txn = entry.value;
              return _TransactionTile(
                data: txn,
                colorScheme: colorScheme,
                onDelete: () async {
                  await txnRepo.delete(txn.id);
                },
              ).animate().fadeIn(
                    duration: 250.ms,
                    delay: (sectionIndex * 50 + entry.key * 30).ms,
                  );
            }),
          ],
        );
      },
    );
  }

  String _formatDateKey(String key) {
    final parts = key.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
  }
}

/// Single Transaction Tile
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.data,
    required this.colorScheme,
    required this.onDelete,
  });

  final dynamic data;
  final ColorScheme colorScheme;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCredit = data.type == 'credit';
    final color = isCredit ? AppColors.income : AppColors.expense;
    final amount = data.amount as double;

    return Dismissible(
      key: Key('txn_${data.id}'),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.expense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: AppColors.expense,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${data.title} deleted'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isCredit
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: color,
            size: 22,
          ),
        ),
        title: Text(
          data.title,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          data.category ?? 'Other',
          style: AppTypography.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'}${CurrencyFormatter.formatGhs(amount)}',
              style: AppTypography.transactionAmount.copyWith(
                color: color,
              ),
            ),
            Text(
              data.account ?? '',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

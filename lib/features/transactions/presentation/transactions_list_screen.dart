import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/core/providers.dart';
import 'package:pocket_ledger/data/database/app_database.dart';
import 'package:pocket_ledger/features/transactions/presentation/add_transaction_screen.dart';

class TransactionsListScreen extends ConsumerStatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  ConsumerState<TransactionsListScreen> createState() =>
      _TransactionsListScreenState();
}

class _TransactionsListScreenState
    extends ConsumerState<TransactionsListScreen> {
  String _selectedFilter = 'All';
  bool _isSearching = false;
  final _searchController = TextEditingController();

  static const _filters = ['All', 'Income', 'Expenses', 'Transfers'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summaryAsync = ref.watch(currentMonthSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style:
                    AppTypography.bodyLarge.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: AppTypography.bodyMedium
                      .copyWith(color: colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : Text(
                'Transactions',
                style: AppTypography.titleLarge
                    .copyWith(color: colorScheme.onSurface),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching
                ? Icons.close_rounded
                : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) {
          var filtered = summary.transactions;

          // Filter by type
          switch (_selectedFilter) {
            case 'Income':
              filtered = filtered.where((t) => t.type == 'credit').toList();
            case 'Expenses':
              filtered = filtered.where((t) => t.type == 'debit').toList();
            case 'Transfers':
              filtered =
                  filtered.where((t) => t.type == 'transfer').toList();
          }

          // Filter by search
          if (_isSearching && _searchController.text.isNotEmpty) {
            final query = _searchController.text.toLowerCase();
            filtered = filtered.where((t) {
              return t.title.toLowerCase().contains(query) ||
                  t.category.toLowerCase().contains(query) ||
                  (t.vendor?.toLowerCase().contains(query) ?? false);
            }).toList();
          }

          return Column(
            children: [
              // Summary
              _SummaryRow(
                colorScheme: colorScheme,
                income: summary.income,
                expenses: summary.expenses,
                balance: summary.balance,
              ),

              // Filter chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = filter == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedFilter = filter),
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.primary,
                        labelStyle: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  },
                ),
              ),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 64,
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.4)),
                            const SizedBox(height: 16),
                            Text('No transactions found',
                                style: AppTypography.titleMedium.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      )
                    :               _TransactionList(
                        transactions: filtered,
                        colorScheme: colorScheme,
                        onTap: (txn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(existingTransaction: txn),
                            ),
                          );
                        },
                        onDelete: (txn) async {
                          await ref
                              .read(transactionRepositoryProvider)
                              .delete(txn.id);
                          ref.invalidate(currentMonthSummaryProvider);
                          ref.invalidate(totalBalanceProvider);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
              icon: Icons.arrow_downward_rounded),
          const SizedBox(width: 12),
          _SummaryCard(
              label: 'Expenses',
              amount: expenses,
              color: AppColors.expense,
              icon: Icons.arrow_upward_rounded),
          const SizedBox(width: 12),
          _SummaryCard(
              label: 'Balance',
              amount: balance,
              color: colorScheme.primary,
              icon: Icons.account_balance_wallet_rounded),
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
            borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(label,
                  style: AppTypography.labelSmall.copyWith(color: color))
            ]),
            const SizedBox(height: 4),
            Text(CurrencyFormatter.formatCompact(amount),
                style: AppTypography.titleSmall.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.transactions,
    required this.colorScheme,
    required this.onTap,
    required this.onDelete,
  });

  final List<Transaction> transactions;
  final ColorScheme colorScheme;
  final ValueChanged<Transaction> onTap;
  final ValueChanged<Transaction> onDelete;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Transaction>>{};
    for (final txn in transactions) {
      final key = _dateKey(txn.transactionDate);
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
              child: Text(_formatDateKey(dateKey),
                  style: AppTypography.labelLarge
                      .copyWith(color: colorScheme.onSurfaceVariant)),
            ),
            ...txns.map((txn) => Dismissible(
                  key: Key('txn_${txn.id}'),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child:
                        Icon(Icons.delete_rounded, color: AppColors.expense),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Transaction'),
                        content: Text(
                            'Delete "${txn.title}"? This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text('Delete',
                                style: TextStyle(color: AppColors.expense)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => onDelete(txn),
                  child: GestureDetector(
                    onTap: () => onTap(txn),
                    child: _TransactionTile(
                        transaction: txn, colorScheme: colorScheme),
                  ),
                )),
          ],
        );
      },
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatDateKey(String key) {
    final parts = key.split('-');
    final date = DateTime(
        int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('dd MMM yyyy').format(date);
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.colorScheme,
  });

  final Transaction transaction;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == 'credit';
    final color = isCredit ? AppColors.income : AppColors.expense;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(
            isCredit
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: color,
            size: 22),
      ),
      title: Text(transaction.title,
          style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface)),
      subtitle: Text(transaction.category,
          style: AppTypography.bodySmall
              .copyWith(color: colorScheme.onSurfaceVariant)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
              '${isCredit ? '+' : '-'}${CurrencyFormatter.formatGhs(transaction.amount.abs())}',
              style:
                  AppTypography.transactionAmount.copyWith(color: color)),
          Text(transaction.provider ?? '',
              style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}

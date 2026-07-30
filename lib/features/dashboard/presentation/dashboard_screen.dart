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
import 'package:pocket_ledger/features/transactions/presentation/transactions_list_screen.dart';

/// Dashboard / Home Screen
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summaryAsync = ref.watch(currentMonthSummaryProvider);
    final balanceAsync = ref.watch(totalBalanceProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              background: summaryAsync.when(
                data: (summary) => _BalanceHeader(
                  colorScheme: colorScheme,
                  balance: balanceAsync.valueOrNull ?? 0,
                  income: summary.income,
                  expenses: summary.expenses,
                ),
                loading: () => _BalanceHeader(
                  colorScheme: colorScheme,
                  balance: 0,
                  income: 0,
                  expenses: 0,
                ),
                error: (_, _) => _BalanceHeader(
                  colorScheme: colorScheme,
                  balance: 0,
                  income: 0,
                  expenses: 0,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'PocketLedger',
                style: AppTypography.titleLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _QuickActions(colorScheme: colorScheme)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: AppTypography.titleMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionsListScreen(),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),
          summaryAsync.when(
            data: (summary) {
              if (summary.transactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 64,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                          const SizedBox(height: 16),
                          Text('No transactions yet',
                              style: AppTypography.titleMedium
                                  .copyWith(color: colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 8),
                          Text('Tap + to add your first transaction',
                              style: AppTypography.bodySmall
                                  .copyWith(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                );
              }
              final recent = summary.transactions.take(5).toList();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final txn = recent[index];
                    return _TransactionTile(
                      transaction: txn,
                      colorScheme: colorScheme,
                    ).animate().fadeIn(
                          duration: 300.ms,
                          delay: (index * 50).ms,
                        );
                  },
                  childCount: recent.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              )),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Transaction'),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({
    required this.colorScheme,
    required this.balance,
    required this.income,
    required this.expenses,
  });

  final ColorScheme colorScheme;
  final double balance;
  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 60, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: AppTypography.bodyMedium.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatGhs(balance),
            style: AppTypography.currencyDisplay.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _BalanceChip(
                label: 'Income',
                amount: income,
                icon: Icons.arrow_downward_rounded,
                color: AppColors.income,
              ),
              const SizedBox(width: 12),
              _BalanceChip(
                label: 'Expenses',
                amount: expenses,
                icon: Icons.arrow_upward_rounded,
                color: AppColors.expense,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatCompact(amount),
                    style: AppTypography.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.send_rounded, 'Send', AppColors.expense),
      (Icons.arrow_downward_rounded, 'Receive', AppColors.income),
      (Icons.swap_horiz_rounded, 'Transfer', AppColors.transfer),
      (Icons.receipt_long_rounded, 'Pay Bill', AppColors.pending),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: actions.map((action) {
          final (icon, label, color) = action;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionScreen(),
                  ),
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (isCredit ? AppColors.income : AppColors.expense)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: isCredit ? AppColors.income : AppColors.expense,
          size: 22,
        ),
      ),
      title: Text(
        transaction.title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        transaction.category,
        style: AppTypography.bodySmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isCredit ? '+' : '-'}${CurrencyFormatter.formatGhs(transaction.amount.abs())}',
            style: AppTypography.transactionAmount.copyWith(
              color: isCredit ? AppColors.income : AppColors.expense,
            ),
          ),
          Text(
            _formatDate(transaction.transactionDate),
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('dd MMM').format(date);
  }
}

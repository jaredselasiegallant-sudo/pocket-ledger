import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/features/transactions/presentation/add_transaction_screen.dart';
import 'package:pocket_ledger/features/transactions/presentation/transactions_list_screen.dart';

/// Dashboard / Home Screen - Stitch Expressive Layout
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              background: _BalanceHeader(colorScheme: colorScheme),
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _TransactionTile(
                  colorScheme: colorScheme,
                  index: index,
                ).animate().fadeIn(
                      duration: 300.ms,
                      delay: (index * 50).ms,
                    );
              },
              childCount: 5,
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
  const _BalanceHeader({required this.colorScheme});
  final ColorScheme colorScheme;

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
            CurrencyFormatter.formatGhs(12450.75),
            style: AppTypography.currencyDisplay.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _BalanceChip(
                label: 'Income',
                amount: 18500.00,
                icon: Icons.arrow_downward_rounded,
                color: AppColors.income,
              ),
              const SizedBox(width: 12),
              _BalanceChip(
                label: 'Expenses',
                amount: 6049.25,
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

/// Quick Actions - all wired to AddTransactionScreen
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.send_rounded, 'Send', AppColors.expense, 'expense'),
      (Icons.arrow_downward_rounded, 'Receive', AppColors.income, 'income'),
      (Icons.swap_horiz_rounded, 'Transfer', AppColors.transfer, 'transfer'),
      (Icons.receipt_long_rounded, 'Pay Bill', AppColors.pending, 'expense'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: actions.map((action) {
          final (icon, label, color, type) = action;
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

/// Transaction List Tile with tap handler
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.colorScheme, required this.index});
  final ColorScheme colorScheme;
  final int index;

  static final _demoData = [
    ('MTN MoMo Transfer', 'Mobile Money Transfer', -250.00, 'MTN MoMo'),
    ('Salary Credit', 'Monthly Salary Credit', 5500.00, 'GCB Bank'),
    ('Vodafone Cash', 'Airtime Purchase', -15.00, 'Telecel Cash'),
    ('Ecobank', 'ATM Withdrawal', -500.00, 'Ecobank'),
    ('Fidelity Bank', 'POS Payment', -89.50, 'Fidelity'),
  ];

  @override
  Widget build(BuildContext context) {
    final data = _demoData[index % _demoData.length];
    final (title, subtitle, amount, provider) = data;
    final isCredit = amount > 0;

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
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isCredit ? '+' : '-'}${CurrencyFormatter.formatGhs(amount.abs())}',
            style: AppTypography.transactionAmount.copyWith(
              color: isCredit ? AppColors.income : AppColors.expense,
            ),
          ),
          Text(
            'Today',
            style: AppTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        );
      },
    );
  }
}

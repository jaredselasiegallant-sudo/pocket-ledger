import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/core/providers/app_providers.dart';
import 'package:pocket_ledger/core/constants/app_constants.dart';

/// Budget Tracking Screen - Stitch Expressive
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final budgetsAsync = ref.watch(activeBudgetsStreamProvider);
    final spendingAsync = ref.watch(monthlySpendingByCategoryProvider);

    final budgets = budgetsAsync.valueOrNull ?? [];
    final spending = spendingAsync.valueOrNull ?? [];
    final spendingMap = {for (final e in spending) e.key: e.value};

    final totalBudget = budgets.fold<double>(0, (s, b) => s + b.limitAmount);
    final totalSpent = budgets.fold<double>(0, (s, b) => s + b.spentAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Budget',
          style: AppTypography.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateBudgetSheet(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MonthlyOverviewCard(
            colorScheme: colorScheme,
            totalBudget: totalBudget,
            totalSpent: totalSpent,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

          const SizedBox(height: 20),

          Text(
            'Category Budgets',
            style: AppTypography.titleMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          if (budgets.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 48,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No budgets yet',
                        style: AppTypography.titleMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Create a budget to track your spending',
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...budgets.asMap().entries.map((entry) {
              final i = entry.key;
              final budget = entry.value;
              final dbSpent = spendingMap[budget.category] ?? budget.spentAmount;
              return _BudgetCategoryCard(
                category: budget.category,
                spent: dbSpent,
                limit: budget.limitAmount,
                color: _getCategoryColor(budget.category),
                icon: _getCategoryIcon(budget.category),
                colorScheme: colorScheme,
              ).animate().fadeIn(
                    duration: 300.ms,
                    delay: ((i + 1) * 50).ms,
                  );
            }),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBudgetSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Budget'),
      ),
    );
  }

  void _showCreateBudgetSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CreateBudgetSheet(ref: ref),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Dining':
        return AppColors.food;
      case 'Transport':
        return AppColors.transport;
      case 'Utilities':
        return AppColors.utilities;
      case 'Health':
        return AppColors.health;
      case 'Education':
        return AppColors.education;
      case 'Entertainment':
        return AppColors.entertainment;
      case 'Shopping':
        return AppColors.income;
      case 'Communication':
        return AppColors.savings;
      case 'Savings':
        return AppColors.savings;
      case 'Investment':
        return AppColors.investment;
      default:
        return AppColors.investment;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Utilities':
        return Icons.bolt_rounded;
      case 'Health':
        return Icons.local_hospital_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Communication':
        return Icons.phone_rounded;
      case 'Savings':
        return Icons.savings_rounded;
      case 'Investment':
        return Icons.trending_up_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}

/// Monthly Overview Card
class _MonthlyOverviewCard extends StatelessWidget {
  const _MonthlyOverviewCard({
    required this.colorScheme,
    required this.totalBudget,
    required this.totalSpent,
  });

  final ColorScheme colorScheme;
  final double totalBudget;
  final double totalSpent;

  @override
  Widget build(BuildContext context) {
    final utilization = totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day;
    final dailyAverage = now.day > 0 ? totalSpent / now.day : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.75),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_monthName(now.month)} ${now.year} Budget',
                style: AppTypography.titleMedium.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(utilization * 100).toInt()}% used',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            CurrencyFormatter.formatGhs(totalSpent),
            style: AppTypography.currencyDisplay.copyWith(
              color: Colors.white,
            ),
          ),
          Text(
            totalBudget > 0
                ? 'of ${CurrencyFormatter.formatGhs(totalBudget)} budget'
                : 'No budget set',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: utilization,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                utilization > 0.9
                    ? AppColors.expense
                    : utilization > 0.7
                        ? AppColors.pending
                        : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BudgetStat(
                label: 'Remaining',
                amount: (totalBudget - totalSpent).clamp(0, double.infinity),
                color: Colors.white,
              ),
              const SizedBox(width: 24),
              _BudgetStat(
                label: 'Daily Average',
                amount: dailyAverage,
                color: Colors.white,
              ),
              const SizedBox(width: 24),
              _BudgetStat(
                label: 'Days Left',
                amount: daysLeft.toDouble(),
                color: Colors.white,
                isDays: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }
}

class _BudgetStat extends StatelessWidget {
  const _BudgetStat({
    required this.label,
    required this.amount,
    required this.color,
    this.isDays = false,
  });

  final String label;
  final double amount;
  final Color color;
  final bool isDays;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color.withValues(alpha: 0.7),
          ),
        ),
        Text(
          isDays ? '${amount.toInt()}' : CurrencyFormatter.formatCompact(amount),
          style: AppTypography.titleSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Budget Category Card with Progress Bar
class _BudgetCategoryCard extends StatelessWidget {
  const _BudgetCategoryCard({
    required this.category,
    required this.spent,
    required this.limit,
    required this.color,
    required this.icon,
    required this.colorScheme,
  });

  final String category;
  final double spent;
  final double limit;
  final Color color;
  final IconData icon;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final utilization = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > limit;
    final isNearLimit = utilization > 0.8 && !isOverBudget;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.formatGhs(spent)} of ${CurrencyFormatter.formatGhs(limit)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOverBudget)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Over Budget',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.expense,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else if (isNearLimit)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.pending.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Almost Full',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.pending,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: utilization,
                minHeight: 8,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget
                      ? AppColors.expense
                      : isNearLimit
                          ? AppColors.pending
                          : color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(utilization * 100).toInt()}% used',
                  style: AppTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${CurrencyFormatter.formatGhs((limit - spent).clamp(0, double.infinity))} left',
                  style: AppTypography.labelSmall.copyWith(
                    color: isOverBudget
                        ? AppColors.expense
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Create Budget Bottom Sheet
class _CreateBudgetSheet extends StatefulWidget {
  const _CreateBudgetSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_CreateBudgetSheet> createState() => _CreateBudgetSheetState();
}

class _CreateBudgetSheetState extends State<_CreateBudgetSheet> {
  String _selectedCategory = 'Food & Dining';
  String _selectedPeriod = 'monthly';
  final _amountController = TextEditingController();
  bool _isSaving = false;

  static const _categories = AppConstants.defaultCategories;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Create Budget',
                style: AppTypography.headlineSmall.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Category',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat),
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Budget Amount (GH₵)',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: AppTypography.titleLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: 'GH₵ ',
                  prefixStyle: AppTypography.titleLarge.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Period',
                style: AppTypography.labelLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'weekly', label: Text('Weekly')),
                  ButtonSegment(value: 'monthly', label: Text('Monthly')),
                  ButtonSegment(value: 'yearly', label: Text('Yearly')),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (val) =>
                    setState(() => _selectedPeriod = val.first),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSaving ? null : _createBudget,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Budget'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createBudget() async {
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
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate;

      switch (_selectedPeriod) {
        case 'weekly':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          endDate = startDate.add(const Duration(days: 6));
          break;
        case 'yearly':
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0);
      }

      final budgetRepo = widget.ref.read(budgetRepositoryProvider);
      await budgetRepo.createBudget(
        name: _selectedCategory,
        category: _selectedCategory,
        limitAmount: amount,
        period: _selectedPeriod,
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Budget created: $_selectedCategory - ${CurrencyFormatter.formatGhs(amount)}',
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
            content: Text('Error creating budget: $e'),
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

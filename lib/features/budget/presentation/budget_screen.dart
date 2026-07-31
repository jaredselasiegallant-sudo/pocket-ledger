import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/core/constants/app_constants.dart';
import 'package:pocket_ledger/core/providers.dart';

/// Budget Tracking Screen
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final budgetsAsync = ref.watch(activeBudgetsProvider);
    final totalBudgetAsync = ref.watch(totalBudgetProvider);
    final totalSpentAsync = ref.watch(totalSpentProvider);

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
          // ─── Monthly Overview Card ───
          totalBudgetAsync.when(
            data: (totalBudget) => totalSpentAsync.when(
              data: (totalSpent) => _MonthlyOverviewCard(
                colorScheme: colorScheme,
                totalBudget: totalBudget,
                totalSpent: totalSpent,
              ),
              loading: () => _MonthlyOverviewCard(
                  colorScheme: colorScheme, totalBudget: 0, totalSpent: 0),
              error: (_, _) => _MonthlyOverviewCard(
                  colorScheme: colorScheme, totalBudget: 0, totalSpent: 0),
            ),
            loading: () => _MonthlyOverviewCard(
                colorScheme: colorScheme, totalBudget: 0, totalSpent: 0),
            error: (_, _) => _MonthlyOverviewCard(
                colorScheme: colorScheme, totalBudget: 0, totalSpent: 0),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05),

          const SizedBox(height: 20),

          Text(
            'Category Budgets',
            style: AppTypography.titleMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          budgetsAsync.when(
            data: (budgets) {
              if (budgets.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.savings_rounded,
                              size: 48,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text('No budgets yet',
                              style: AppTypography.titleMedium.copyWith(
                                  color: colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text('Create a budget to track spending',
                              style: AppTypography.bodySmall.copyWith(
                                  color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: List.generate(budgets.length, (i) {
                  final budget = budgets[i];
                  return _BudgetCategoryCard(
                    category: budget.category,
                    spent: budget.spentAmount,
                    limit: budget.limitAmount,
                    color: _getCategoryColor(budget.category),
                    icon: _getCategoryIcon(budget.category),
                    colorScheme: colorScheme,
                  ).animate().fadeIn(
                      duration: 300.ms, delay: (i * 50).ms);
                }),
              );
            },
            loading: () => const Center(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator())),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),

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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food & Dining':
        return AppColors.food;
      case 'Transport':
        return AppColors.transport;
      case 'Utilities':
        return AppColors.utilities;
      case 'Entertainment':
        return AppColors.entertainment;
      case 'Health':
        return AppColors.health;
      case 'Communication':
        return AppColors.savings;
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
      case 'Entertainment':
        return Icons.movie_rounded;
      case 'Health':
        return Icons.local_hospital_rounded;
      case 'Communication':
        return Icons.phone_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  void _showCreateBudgetSheet(BuildContext context, WidgetRef ref) {
    final currencySymbol = ref.read(currencySymbolProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CreateBudgetSheet(
        currencySymbol: currencySymbol,
        onCreated: () {
          ref.invalidate(activeBudgetsProvider);
          ref.invalidate(totalBudgetProvider);
          ref.invalidate(totalSpentProvider);
        },
      ),
    );
  }
}

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
    final daysElapsed = now.day;
    final daysLeft = daysInMonth - daysElapsed;
    final dailyAverage = daysElapsed > 0 ? totalSpent / daysElapsed : 0.0;
    final monthLabel = DateFormat('MMMM yyyy').format(now);

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
                '$monthLabel Budget',
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
            'of ${CurrencyFormatter.formatGhs(totalBudget)} budget',
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
                  _BudgetBadge(
                    text: 'Over Budget',
                    color: AppColors.expense,
                  )
                else if (isNearLimit)
                  _BudgetBadge(
                    text: 'Almost Full',
                    color: AppColors.pending,
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
                  '${CurrencyFormatter.formatGhs(limit > spent ? limit - spent : 0)} left',
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

class _BudgetBadge extends StatelessWidget {
  const _BudgetBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CreateBudgetSheet extends StatefulWidget {
  const _CreateBudgetSheet({required this.onCreated, required this.currencySymbol});

  final VoidCallback onCreated;
  final String currencySymbol;

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
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
                'Budget Amount (${widget.currencySymbol})',
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
                  prefixText: '${widget.currencySymbol} ',
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
                              strokeWidth: 2, color: Colors.white))
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
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Use a ProviderContainer to read the repo
      final container = ProviderContainer();
      final budgetRepo = container.read(budgetRepositoryProvider);
      await budgetRepo.createBudget(
        name: _selectedCategory,
        category: _selectedCategory,
        limitAmount: amount,
        period: _selectedPeriod,
        startDate: start,
        endDate: end,
      );
      container.dispose();

      widget.onCreated();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Budget created: $_selectedCategory - ${widget.currencySymbol} ${_amountController.text}',
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
            content: Text('Failed to create budget: $e'),
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

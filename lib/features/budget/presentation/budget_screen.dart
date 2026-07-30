import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';

/// Budget Tracking Screen - Stitch Expressive
/// Shows budget overview, per-category progress, and spending insights
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            onPressed: () => _showCreateBudgetSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Monthly Overview Card ───
          _MonthlyOverviewCard(colorScheme: colorScheme)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05),

          const SizedBox(height: 20),

          // ─── Category Budgets ───
          Text(
            'Category Budgets',
            style: AppTypography.titleMedium.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          _BudgetCategoryCard(
            category: 'Food & Dining',
            spent: 2450.00,
            limit: 3000.00,
            color: AppColors.food,
            icon: Icons.restaurant_rounded,
            colorScheme: colorScheme,
          ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

          _BudgetCategoryCard(
            category: 'Transport',
            spent: 800.00,
            limit: 1500.00,
            color: AppColors.transport,
            icon: Icons.directions_car_rounded,
            colorScheme: colorScheme,
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          _BudgetCategoryCard(
            category: 'Utilities',
            spent: 350.00,
            limit: 500.00,
            color: AppColors.utilities,
            icon: Icons.bolt_rounded,
            colorScheme: colorScheme,
          ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

          _BudgetCategoryCard(
            category: 'Entertainment',
            spent: 420.00,
            limit: 400.00,
            color: AppColors.entertainment,
            icon: Icons.movie_rounded,
            colorScheme: colorScheme,
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

          _BudgetCategoryCard(
            category: 'Health',
            spent: 100.00,
            limit: 800.00,
            color: AppColors.health,
            icon: Icons.local_hospital_rounded,
            colorScheme: colorScheme,
          ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

          _BudgetCategoryCard(
            category: 'Communication',
            spent: 75.00,
            limit: 200.00,
            color: AppColors.savings,
            icon: Icons.phone_rounded,
            colorScheme: colorScheme,
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),

          const SizedBox(height: 20),

          // ─── Insights ───
          _BudgetInsightsCard(colorScheme: colorScheme)
              .animate()
              .fadeIn(duration: 300.ms, delay: 350.ms),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBudgetSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Budget'),
      ),
    );
  }

  void _showCreateBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _CreateBudgetSheet(),
    );
  }
}

/// Monthly Overview Card
class _MonthlyOverviewCard extends StatelessWidget {
  const _MonthlyOverviewCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    const totalBudget = 10000.0;
    const totalSpent = 4195.0;
    final utilization = totalSpent / totalBudget;

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
                'June 2026 Budget',
                style: AppTypography.titleMedium.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          // Progress bar
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
                amount: totalBudget - totalSpent,
                color: Colors.white,
              ),
              const SizedBox(width: 24),
              _BudgetStat(
                label: 'Daily Average',
                amount: totalSpent / 29,
                color: Colors.white,
              ),
              const SizedBox(width: 24),
              _BudgetStat(
                label: 'Days Left',
                amount: 1, // placeholder
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
    final utilization = (spent / limit).clamp(0.0, 1.0);
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  '${CurrencyFormatter.formatGhs(limit - spent)} left',
                  style: AppTypography.labelSmall.copyWith(
                    color: isOverBudget ? AppColors.expense : colorScheme.onSurfaceVariant,
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

/// Budget Insights Card
class _BudgetInsightsCard extends StatelessWidget {
  const _BudgetInsightsCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Spending Insights',
                  style: AppTypography.titleSmall.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InsightItem(
              icon: Icons.warning_amber_rounded,
              color: AppColors.expense,
              text: 'Entertainment budget exceeded by GH₵ 20.00',
              colorScheme: colorScheme,
            ),
            _InsightItem(
              icon: Icons.trending_down_rounded,
              color: AppColors.income,
              text: 'Transport spending is 15% lower than last month',
              colorScheme: colorScheme,
            ),
            _InsightItem(
              icon: Icons.info_outline_rounded,
              color: colorScheme.primary,
              text: 'At current rate, food budget will last 22 days',
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  const _InsightItem({
    required this.icon,
    required this.color,
    required this.text,
    required this.colorScheme,
  });

  final IconData icon;
  final Color color;
  final String text;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Create Budget Bottom Sheet
class _CreateBudgetSheet extends StatefulWidget {
  const _CreateBudgetSheet();

  @override
  State<_CreateBudgetSheet> createState() => _CreateBudgetSheetState();
}

class _CreateBudgetSheetState extends State<_CreateBudgetSheet> {
  String _selectedCategory = 'Food & Dining';
  String _selectedPeriod = 'monthly';
  final _amountController = TextEditingController();

  static const _categories = [
    'Food & Dining',
    'Transport',
    'Utilities',
    'Health',
    'Education',
    'Entertainment',
    'Shopping',
    'Communication',
    'Other',
  ];

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
                    onSelected: (_) => setState(() => _selectedCategory = cat),
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
                onSelectionChanged: (val) => setState(() {
                  _selectedPeriod = val.first;
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Budget created: $_selectedCategory - GH₵ ${_amountController.text}',
                        ),
                        backgroundColor: AppColors.income,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  child: const Text('Create Budget'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

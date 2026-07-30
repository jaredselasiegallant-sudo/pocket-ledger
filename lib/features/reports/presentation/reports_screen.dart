import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/core/utils/export_engine.dart';
import 'package:pocket_ledger/core/providers.dart';

/// Reports / Analytics Screen
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  int _touchedPieIndex = -1;

  static const _periods = ['This Week', 'This Month', 'This Year'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categorySpendingAsync = ref.watch(categorySpendingProvider);
    final summaryAsync = ref.watch(currentMonthSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: AppTypography.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_rounded),
            onPressed: () => _exportPdf(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<String>(
            segments: _periods.map((p) {
              return ButtonSegment(value: p, label: Text(p));
            }).toList(),
            selected: {_selectedPeriod},
            onSelectionChanged: (val) =>
                setState(() => _selectedPeriod = val.first),
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // ─── Summary Cards ───
          summaryAsync.when(
            data: (summary) => _AnalyticsSummary(
              colorScheme: colorScheme,
              income: summary.income,
              expenses: summary.expenses,
            ),
            loading: () => const SizedBox(
                height: 80, child: Center(child: CircularProgressIndicator())),
            error: (_, _) => const SizedBox.shrink(),
          ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

          const SizedBox(height: 24),

          // ─── Category Pie Chart ───
          categorySpendingAsync.when(
            data: (data) {
              if (data.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.pie_chart_rounded,
                              size: 48,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text('No spending data yet',
                              style: AppTypography.titleMedium.copyWith(
                                  color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
                );
              }
              final categoryData = data.map((e) => _CategoryData(
                e.key,
                e.value,
                _getCategoryColor(e.key),
              )).toList();
              return _PieChartCard(
                colorScheme: colorScheme,
                data: categoryData,
                touchedIndex: _touchedPieIndex,
                onTouch: (i) => setState(() => _touchedPieIndex = i),
              );
            },
            loading: () => const SizedBox(
                height: 300, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Center(child: Text('Error: $e')),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          const SizedBox(height: 20),

          // ─── Top Spending ───
          categorySpendingAsync.when(
            data: (data) {
              if (data.isEmpty) return const SizedBox.shrink();
              final sorted = data.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              return _TopSpendingCard(
                colorScheme: colorScheme,
                categories: sorted,
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Generating PDF report...'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    try {
      final summary = ref.read(currentMonthSummaryProvider).valueOrNull;
      final txns = summary?.transactions ?? [];
      final txData = txns.map((t) => {
        'date': DateFormat('yyyy-MM-dd').format(t.transactionDate),
        'title': t.title,
        'type': t.type,
        'amount': t.amount,
      }).toList();

      final path = await ExportEngine.exportToPdf(
        transactions: txData,
        totalIncome: summary?.income ?? 0,
        totalExpenses: summary?.expenses ?? 0,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report exported: $path'),
            backgroundColor: AppColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
      case 'Salary':
        return AppColors.income;
      case 'Savings':
        return AppColors.savings;
      case 'Investment':
        return AppColors.investment;
      default:
        return AppColors.pending;
    }
  }
}

class _AnalyticsSummary extends StatelessWidget {
  const _AnalyticsSummary({
    required this.colorScheme,
    required this.income,
    required this.expenses,
  });

  final ColorScheme colorScheme;
  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    final savings = income - expenses;
    return Row(
      children: [
        _SummaryMini(
          label: 'Income',
          amount: income,
          color: AppColors.income,
        ),
        const SizedBox(width: 12),
        _SummaryMini(
          label: 'Expenses',
          amount: expenses,
          color: AppColors.expense,
        ),
        const SizedBox(width: 12),
        _SummaryMini(
          label: 'Savings',
          amount: savings,
          color: AppColors.savings,
        ),
      ],
    );
  }
}

class _SummaryMini extends StatelessWidget {
  const _SummaryMini({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

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
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(color: color),
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

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({
    required this.colorScheme,
    required this.data,
    required this.touchedIndex,
    required this.onTouch,
  });

  final ColorScheme colorScheme;
  final List<_CategoryData> data;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, d) => sum + d.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: AppTypography.titleMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      if (event is FlTapUpEvent &&
                          pieTouchResponse?.touchedSection != null) {
                        onTouch(pieTouchResponse!
                            .touchedSection!.touchedSectionIndex);
                      }
                    },
                  ),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: data.asMap().entries.map((entry) {
                    final i = entry.key;
                    final d = entry.value;
                    final isTouched = i == touchedIndex;
                    final radius = isTouched ? 55.0 : 45.0;
                    final pct = total > 0 ? d.amount / total * 100 : 0.0;

                    return PieChartSectionData(
                      color: d.color,
                      value: d.amount,
                      title: isTouched ? '${pct.toInt()}%' : '',
                      radius: radius,
                      titleStyle: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: data.map((d) {
                final pct = total > 0 ? (d.amount / total * 100).toInt() : 0;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: d.color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${d.name} ($pct%)',
                      style: AppTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopSpendingCard extends StatelessWidget {
  const _TopSpendingCard({
    required this.colorScheme,
    required this.categories,
  });

  final ColorScheme colorScheme;
  final List<MapEntry<String, double>> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final maxAmount = categories.first.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Spending',
              style: AppTypography.titleMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...categories.asMap().entries.map((entry) {
              final i = entry.key;
              final name = entry.value.key;
              final amount = entry.value.value;
              final barWidth = maxAmount > 0 ? amount / maxAmount : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: AppTypography.labelMedium.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatGhs(amount),
                          style: AppTypography.transactionAmount.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: barWidth,
                        minHeight: 4,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CategoryData {
  final String name;
  final double amount;
  final Color color;

  const _CategoryData(this.name, this.amount, this.color);
}

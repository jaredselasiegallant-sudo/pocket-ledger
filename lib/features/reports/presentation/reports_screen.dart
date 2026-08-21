import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/core/providers/app_providers.dart';

/// Reports / Analytics Screen - Stitch Expressive
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

    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final spendingAsync = ref.watch(monthlySpendingByCategoryProvider);
    final incomeAsync = ref.watch(monthlyIncomeProvider);
    final expensesAsync = ref.watch(monthlyExpensesProvider);

    final transactions = transactionsAsync.valueOrNull ?? [];
    final spending = spendingAsync.valueOrNull ?? [];
    final totalIncome = incomeAsync.valueOrNull ?? 0.0;
    final totalExpenses = expensesAsync.valueOrNull ?? 0.0;

    final categoryData = spending
        .map((e) => _CategoryData(e.key, e.value, _getCategoryColor(e.key)))
        .where((d) => d.amount > 0)
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final topMerchants = _computeTopMerchants(transactions);

    final totalSavings = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: AppTypography.titleLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PeriodChip(
            selected: _selectedPeriod,
            periods: _periods,
            colorScheme: colorScheme,
            onSelected: (p) => setState(() => _selectedPeriod = p),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          _AnalyticsSummary(
            colorScheme: colorScheme,
            income: totalIncome,
            expenses: totalExpenses,
            savings: totalSavings,
          ).animate().fadeIn(duration: 300.ms, delay: 50.ms),

          const SizedBox(height: 24),

          if (categoryData.isNotEmpty)
            _PieChartCard(
              colorScheme: colorScheme,
              data: categoryData,
              touchedIndex: _touchedPieIndex,
              onTouch: (i) => setState(() => _touchedPieIndex = i),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms)
          else
            _EmptyChartCard(
              colorScheme: colorScheme,
              title: 'Spending by Category',
              message: 'Add expense transactions to see category breakdown',
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          const SizedBox(height: 20),

          if (transactions.isNotEmpty)
            _BarChartCard(
              colorScheme: colorScheme,
              transactions: transactions,
            ).animate().fadeIn(duration: 300.ms, delay: 150.ms)
          else
            _EmptyChartCard(
              colorScheme: colorScheme,
              title: 'Monthly Trend',
              message: 'Add transactions to see income vs expenses trend',
            ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

          const SizedBox(height: 20),

          if (transactions.isNotEmpty)
            _LineChartCard(
              colorScheme: colorScheme,
              transactions: transactions,
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms)
          else
            _EmptyChartCard(
              colorScheme: colorScheme,
              title: 'Balance Over Time',
              message: 'Add transactions to see balance trend',
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

          const SizedBox(height: 20),

          if (topMerchants.isNotEmpty)
            _TopSpendingCard(
              colorScheme: colorScheme,
              merchants: topMerchants,
            ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<_MerchantData> _computeTopMerchants(List<dynamic> transactions) {
    final merchantMap = <String, _MerchantData>{};

    for (final txn in transactions) {
      if (txn.type == 'credit') continue;
      final name = txn.vendor ?? txn.account ?? 'Unknown';
      final existing = merchantMap[name];
      if (existing != null) {
        merchantMap[name] = _MerchantData(
          name,
          txn.category ?? 'Other',
          existing.amount + (txn.amount as double),
          existing.txnCount + 1,
        );
      } else {
        merchantMap[name] = _MerchantData(
          name,
          txn.category ?? 'Other',
          txn.amount as double,
          1,
        );
      }
    }

    final sorted = merchantMap.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(5).toList();
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
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
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
    return SegmentedButton<String>(
      segments: periods.map((p) {
        return ButtonSegment(value: p, label: Text(p));
      }).toList(),
      selected: {selected},
      onSelectionChanged: (val) => onSelected(val.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _AnalyticsSummary extends StatelessWidget {
  const _AnalyticsSummary({
    required this.colorScheme,
    required this.income,
    required this.expenses,
    required this.savings,
  });

  final ColorScheme colorScheme;
  final double income;
  final double expenses;
  final double savings;

  @override
  Widget build(BuildContext context) {
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

class _EmptyChartCard extends StatelessWidget {
  const _EmptyChartCard({
    required this.colorScheme,
    required this.title,
    required this.message,
  });

  final ColorScheme colorScheme;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.titleMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.bar_chart_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
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

                    return PieChartSectionData(
                      color: d.color,
                      value: d.amount,
                      title: isTouched
                          ? '${(d.amount / total * 100).toInt()}%'
                          : '',
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
                final pct = (d.amount / total * 100).toInt();
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

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({
    required this.colorScheme,
    required this.transactions,
  });

  final ColorScheme colorScheme;
  final List<dynamic> transactions;

  @override
  Widget build(BuildContext context) {
    final monthlyData = _computeMonthlyData(transactions);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Trend',
                  style: AppTypography.titleMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    _LegendDot(color: colorScheme.primary, label: 'Income'),
                    const SizedBox(width: 12),
                    _LegendDot(color: AppColors.expense, label: 'Expenses'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _maxY(monthlyData),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          CurrencyFormatter.formatGhs(rod.toY),
                          AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < monthlyData.length) {
                            return Text(
                              monthlyData[idx].month,
                              style: AppTypography.labelSmall.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: monthlyData.asMap().entries.map((entry) {
                    final i = entry.key;
                    final d = entry.value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: d.income,
                          color: colorScheme.primary,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: d.expenses,
                          color: AppColors.expense,
                          width: 12,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MonthlyData> _computeMonthlyData(List<dynamic> transactions) {
    final now = DateTime.now();
    final monthlyMap = <String, _MonthlyData>{};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = _monthShort(month.month);
      monthlyMap[key] = _MonthlyData(key, 0, 0);
    }

    for (final txn in transactions) {
      final date = txn.transactionDate as DateTime;
      final key = _monthShort(date.month);
      if (!monthlyMap.containsKey(key)) continue;

      final existing = monthlyMap[key]!;
      if (txn.type == 'credit') {
        monthlyMap[key] = _MonthlyData(
          key,
          existing.income + (txn.amount as double),
          existing.expenses,
        );
      } else {
        monthlyMap[key] = _MonthlyData(
          key,
          existing.income,
          existing.expenses + (txn.amount as double),
        );
      }
    }

    return monthlyMap.values.toList();
  }

  double _maxY(List<_MonthlyData> data) {
    double max = 0;
    for (final d in data) {
      if (d.income > max) max = d.income;
      if (d.expenses > max) max = d.expenses;
    }
    return (max * 1.2).ceilToDouble();
  }

  String _monthShort(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard({
    required this.colorScheme,
    required this.transactions,
  });

  final ColorScheme colorScheme;
  final List<dynamic> transactions;

  @override
  Widget build(BuildContext context) {
    final spots = _computeBalanceSpots(transactions);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance Over Time',
              style: AppTypography.titleMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final months = [
                            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'
                          ];
                          final idx = value.toInt();
                          if (idx < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[idx],
                                style: AppTypography.labelSmall.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _computeBalanceSpots(List<dynamic> transactions) {
    final now = DateTime.now();
    final monthlyTotals = <int, double>{};

    for (int i = 5; i >= 0; i--) {
      final monthIdx = 5 - i;
      final month = DateTime(now.year, now.month - i, 1);
      double balance = 0;

      for (final txn in transactions) {
        final date = txn.transactionDate as DateTime;
        if (date.year == month.year && date.month == month.month) {
          if (txn.type == 'credit') {
            balance += txn.amount as double;
          } else {
            balance -= txn.amount as double;
          }
        }
      }

      monthlyTotals[monthIdx] = balance;
    }

    double cumulative = 0;
    final spots = <FlSpot>[];
    for (int i = 0; i < 6; i++) {
      cumulative += monthlyTotals[i] ?? 0;
      spots.add(FlSpot(i.toDouble(), cumulative));
    }

    return spots;
  }
}

class _TopSpendingCard extends StatelessWidget {
  const _TopSpendingCard({
    required this.colorScheme,
    required this.merchants,
  });

  final ColorScheme colorScheme;
  final List<_MerchantData> merchants;

  @override
  Widget build(BuildContext context) {
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
            ...merchants.asMap().entries.map((entry) {
              final i = entry.key;
              final merchant = entry.value;
              final maxAmount = merchants.first.amount;
              final barWidth = merchant.amount / maxAmount;

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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                merchant.name,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${merchant.txnCount} transactions • ${merchant.category}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatGhs(merchant.amount),
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
                        backgroundColor:
                            colorScheme.surfaceContainerHighest,
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

class _MonthlyData {
  final String month;
  final double income;
  final double expenses;

  const _MonthlyData(this.month, this.income, this.expenses);
}

class _MerchantData {
  final String name;
  final String category;
  final double amount;
  final int txnCount;

  const _MerchantData(this.name, this.category, this.amount, this.txnCount);
}

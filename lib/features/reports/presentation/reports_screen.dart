import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/core/utils/export_engine.dart';

/// Reports / Analytics Screen - Stitch Expressive
/// Charts: Pie chart for category breakdown, bar chart for monthly trend,
/// line chart for balance over time, top spending merchants
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  int _touchedPieIndex = -1;

  static const _periods = ['This Week', 'This Month', 'This Year'];

  // Demo data
  static final _categoryBreakdown = [
    _CategoryData('Food & Dining', 2450.0, AppColors.food),
    _CategoryData('Transport', 800.0, AppColors.transport),
    _CategoryData('Utilities', 350.0, AppColors.utilities),
    _CategoryData('Entertainment', 420.0, AppColors.entertainment),
    _CategoryData('Health', 100.0, AppColors.health),
    _CategoryData('Communication', 75.0, AppColors.savings),
    _CategoryData('Other', 200.0, AppColors.investment),
  ];

  static final _monthlyTrend = [
    _MonthlyData('Jan', 8500, 6200),
    _MonthlyData('Feb', 9200, 7100),
    _MonthlyData('Mar', 7800, 5900),
    _MonthlyData('Apr', 10500, 8200),
    _MonthlyData('May', 9800, 7500),
    _MonthlyData('Jun', 18500, 4195),
  ];

  static final _topMerchants = [
    ('MTN MoMo', 'Mobile Money', 3200.0, 15),
    ('GCB Bank', 'Bank Transfer', 2800.0, 8),
    ('Ecobank', 'ATM/POS', 1500.0, 12),
    ('Vodafone', 'Airtime/Bills', 450.0, 20),
    ('Shoprite', 'Groceries', 380.0, 6),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Generating PDF report...'),
                  backgroundColor: colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              try {
                final path = await ExportEngine.exportToPdf(
                  transactions: [
                    {'date': '2026-07-30', 'title': 'MTN MoMo Transfer', 'type': 'debit', 'amount': -250.0},
                    {'date': '2026-07-30', 'title': 'Salary Credit', 'type': 'credit', 'amount': 5500.0},
                  ],
                  totalIncome: 18500.0,
                  totalExpenses: 4195.0,
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
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Period Selector ───
          _PeriodChip(
            selected: _selectedPeriod,
            periods: _periods,
            colorScheme: colorScheme,
            onSelected: (p) => setState(() => _selectedPeriod = p),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // ─── Summary Cards ───
          _AnalyticsSummary(colorScheme: colorScheme)
              .animate()
              .fadeIn(duration: 300.ms, delay: 50.ms),

          const SizedBox(height: 24),

          // ─── Category Pie Chart ───
          _PieChartCard(
            colorScheme: colorScheme,
            data: _categoryBreakdown,
            touchedIndex: _touchedPieIndex,
            onTouch: (i) => setState(() => _touchedPieIndex = i),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),

          const SizedBox(height: 20),

          // ─── Monthly Trend Bar Chart ───
          _BarChartCard(
            colorScheme: colorScheme,
            data: _monthlyTrend,
          ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

          const SizedBox(height: 20),

          // ─── Income vs Expense Line Chart ───
          _LineChartCard(colorScheme: colorScheme)
              .animate()
              .fadeIn(duration: 300.ms, delay: 200.ms),

          const SizedBox(height: 20),

          // ─── Top Spending ───
          _TopSpendingCard(
            colorScheme: colorScheme,
            merchants: _topMerchants,
          ).animate().fadeIn(duration: 300.ms, delay: 250.ms),

          const SizedBox(height: 80),
        ],
      ),
    );
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
  const _AnalyticsSummary({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryMini(
          label: 'Income',
          amount: 18500.0,
          color: AppColors.income,
          change: '+12%',
          isPositive: true,
        ),
        const SizedBox(width: 12),
        _SummaryMini(
          label: 'Expenses',
          amount: 4195.0,
          color: AppColors.expense,
          change: '-8%',
          isPositive: true,
        ),
        const SizedBox(width: 12),
        _SummaryMini(
          label: 'Savings',
          amount: 14305.0,
          color: AppColors.savings,
          change: '+25%',
          isPositive: true,
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
    required this.change,
    required this.isPositive,
  });

  final String label;
  final double amount;
  final Color color;
  final String change;
  final bool isPositive;

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
              style: AppTypography.labelSmall.copyWith(
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.formatCompact(amount),
              style: AppTypography.titleSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? AppColors.income : AppColors.expense,
                  size: 12,
                ),
                const SizedBox(width: 2),
                Text(
                  change,
                  style: AppTypography.labelSmall.copyWith(
                    color: isPositive ? AppColors.income : AppColors.expense,
                    fontWeight: FontWeight.w600,
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
    required this.data,
  });

  final ColorScheme colorScheme;
  final List<_MonthlyData> data;

  @override
  Widget build(BuildContext context) {
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
                  maxY: 20000,
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
                          if (idx < data.length) {
                            return Text(
                              data[idx].month,
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
                  barGroups: data.asMap().entries.map((entry) {
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
  const _LineChartCard({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final spots = [
      FlSpot(0, 10000),
      FlSpot(1, 12500),
      FlSpot(2, 11200),
      FlSpot(3, 14800),
      FlSpot(4, 13500),
      FlSpot(5, 12450),
    ];

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
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
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
}

class _TopSpendingCard extends StatelessWidget {
  const _TopSpendingCard({
    required this.colorScheme,
    required this.merchants,
  });

  final ColorScheme colorScheme;
  final List<(String, String, double, int)> merchants;

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
              final (name, type, amount, txnCount) = entry.value;
              final maxAmount = merchants.first.$3;
              final barWidth = amount / maxAmount;

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
                                name,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '$txnCount transactions • $type',
                                style: AppTypography.bodySmall.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
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

class _MonthlyData {
  final String month;
  final double income;
  final double expenses;

  const _MonthlyData(this.month, this.income, this.expenses);
}

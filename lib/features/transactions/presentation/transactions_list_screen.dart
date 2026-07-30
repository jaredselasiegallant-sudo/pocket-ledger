import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pocket_ledger/core/theme/colors/app_colors.dart';
import 'package:pocket_ledger/core/theme/typography/app_typography.dart';
import 'package:pocket_ledger/core/utils/currency_formatter.dart';
import 'package:pocket_ledger/features/transactions/presentation/add_transaction_screen.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  String _selectedFilter = 'All';
  String _selectedPeriod = 'This Month';
  bool _isSearching = false;
  final _searchController = TextEditingController();

  static const _filters = ['All', 'Income', 'Expenses', 'Transfers'];
  static const _periods = ['Today', 'This Week', 'This Month', 'This Year', 'Custom'];

  // Demo transaction data (mutable for swipe-delete)
  final List<_TxnData> _transactions = [
    _TxnData('MTN MoMo Transfer', 'Sent to John', -250.00, 'MTN MoMo', 'debit', DateTime.now()),
    _TxnData('Salary Credit', 'Monthly salary from GCB', 5500.00, 'GCB Bank', 'credit', DateTime.now()),
    _TxnData('Vodafone Airtime', 'Airtime purchase', -15.00, 'Telecel Cash', 'debit', DateTime.now().subtract(const Duration(hours: 2))),
    _TxnData('Ecobank ATM', 'Cash withdrawal', -500.00, 'Ecobank', 'debit', DateTime.now().subtract(const Duration(hours: 5))),
    _TxnData('POS Payment', 'Fidelity POS at Shoprite', -89.50, 'Fidelity', 'debit', DateTime.now().subtract(const Duration(days: 1))),
    _TxnData('Received from Ama', 'Mobile money credit', 200.00, 'MTN MoMo', 'credit', DateTime.now().subtract(const Duration(days: 1))),
    _TxnData('Transfer to Savings', 'Monthly savings', -500.00, 'GCB Bank', 'transfer', DateTime.now().subtract(const Duration(days: 2))),
    _TxnData('Business Income', 'Client payment', 3200.00, 'Ecobank', 'credit', DateTime.now().subtract(const Duration(days: 2))),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_TxnData> get _filteredTransactions {
    return _transactions.where((txn) {
      // Filter by type
      switch (_selectedFilter) {
        case 'Income':
          if (txn.type != 'credit') return false;
        case 'Expenses':
          if (txn.type != 'debit') return false;
        case 'Transfers':
          if (txn.type != 'transfer') return false;
      }
      // Filter by search
      if (_isSearching && _searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        return txn.title.toLowerCase().contains(query) ||
            txn.subtitle.toLowerCase().contains(query) ||
            txn.provider.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: AppTypography.bodyLarge.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              )
            : Text(
                'Transactions',
                style: AppTypography.titleLarge.copyWith(color: colorScheme.onSurface),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
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
          _SummaryRow(colorScheme: colorScheme),
          _FilterChips(
            selected: _selectedFilter,
            filters: _filters,
            colorScheme: colorScheme,
            onSelected: (f) => setState(() => _selectedFilter = f),
          ),
          Expanded(
            child: _TransactionList(
              colorScheme: colorScheme,
              transactions: _filteredTransactions,
              onDismissed: (index) {
                setState(() {
                  _transactions.removeAt(index);
                });
              },
              onTap: (txn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                );
              },
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterBottomSheet(
        colorScheme: Theme.of(context).colorScheme,
        selectedFilter: _selectedFilter,
        onFilterChanged: (f) => setState(() => _selectedFilter = f),
      ),
    );
  }
}

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
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _SummaryCard(label: 'Income', amount: 18500.00, color: AppColors.income, icon: Icons.arrow_downward_rounded),
          const SizedBox(width: 12),
          _SummaryCard(label: 'Expenses', amount: 6049.25, color: AppColors.expense, icon: Icons.arrow_upward_rounded),
          const SizedBox(width: 12),
          _SummaryCard(label: 'Balance', amount: 12450.75, color: colorScheme.primary, icon: Icons.account_balance_wallet_rounded),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.amount, required this.color, required this.icon});
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: color, size: 16), const SizedBox(width: 4), Text(label, style: AppTypography.labelSmall.copyWith(color: color))]),
            const SizedBox(height: 4),
            Text(CurrencyFormatter.formatCompact(amount), style: AppTypography.titleSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.filters, required this.colorScheme, required this.onSelected});
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
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        },
      ),
    );
  }
}

/// Transaction List with swipe-delete and tap
class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.colorScheme, required this.transactions, required this.onDismissed, required this.onTap});
  final ColorScheme colorScheme;
  final List<_TxnData> transactions;
  final ValueChanged<int> onDismissed;
  final ValueChanged<_TxnData> onTap;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<_TxnData>>{};
    for (final txn in transactions) {
      final key = _dateKey(txn.date);
      grouped.putIfAbsent(key, () => []).add(txn);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text('No transactions found', style: AppTypography.titleMedium.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

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
              child: Text(_formatDateKey(dateKey), style: AppTypography.labelLarge.copyWith(color: colorScheme.onSurfaceVariant)),
            ),
            ...txns.asMap().entries.map((entry) {
              final txn = entry.value;
              final globalIndex = transactions.indexOf(txn);
              return Dismissible(
                key: Key('${txn.title}_${txn.amount}_${txn.date}'),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.expense.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.delete_rounded, color: AppColors.expense),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => onDismissed(globalIndex),
                child: _TransactionTile(data: txn, colorScheme: colorScheme, onTap: () => onTap(txn)),
              );
            }),
          ],
        );
      },
    );
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatDateKey(String key) {
    final parts = key.split('-');
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) return 'Today';
    if (target == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month]} ${date.year}';
  }
}

class _TxnData {
  final String title;
  final String subtitle;
  final double amount;
  final String provider;
  final String type;
  final DateTime date;
  _TxnData(this.title, this.subtitle, this.amount, this.provider, this.type, this.date);
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.data, required this.colorScheme, this.onTap});
  final _TxnData data;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = data.amount > 0;
    final color = isCredit ? AppColors.income : AppColors.expense;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 22),
      ),
      title: Text(data.title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
      subtitle: Text(data.subtitle, style: AppTypography.bodySmall.copyWith(color: colorScheme.onSurfaceVariant)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${isCredit ? '+' : '-'}${CurrencyFormatter.formatGhs(data.amount.abs())}', style: AppTypography.transactionAmount.copyWith(color: color)),
          Text(data.provider, style: AppTypography.labelSmall.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6))),
        ],
      ),
      onTap: onTap,
    );
  }
}

/// Filter Bottom Sheet with interactive category chips
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({required this.colorScheme, required this.selectedFilter, required this.onFilterChanged});
  final ColorScheme colorScheme;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  String _selectedCategory = 'All';
  RangeValues _range = const RangeValues(0, 10000);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: widget.colorScheme.onSurfaceVariant.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Text('Filter Transactions', style: AppTypography.headlineSmall.copyWith(color: widget.colorScheme.onSurface)),
          const SizedBox(height: 20),
          Text('Category', style: AppTypography.labelLarge.copyWith(color: widget.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['All', 'Food', 'Transport', 'Utilities', 'Salary', 'Other'].map((cat) {
              final isSelected = cat == _selectedCategory;
              return ChoiceChip(
                label: Text(cat),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedCategory = cat),
                selectedColor: widget.colorScheme.primaryContainer,
                labelStyle: AppTypography.labelMedium.copyWith(
                  color: isSelected ? widget.colorScheme.primary : widget.colorScheme.onSurfaceVariant,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Amount Range', style: AppTypography.labelLarge.copyWith(color: widget.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          RangeSlider(
            values: _range,
            min: 0,
            max: 50000,
            divisions: 50,
            labels: RangeLabels(CurrencyFormatter.formatGhs(_range.start), CurrencyFormatter.formatGhs(_range.end)),
            activeColor: widget.colorScheme.primary,
            onChanged: (val) => setState(() => _range = val),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                widget.onFilterChanged(_selectedCategory == 'All' ? 'All' : _selectedCategory);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}

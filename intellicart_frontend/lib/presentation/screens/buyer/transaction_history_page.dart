import 'package:flutter/material.dart';

/// A presentational Transaction History screen inspired by the provided HTML/image.
/// It includes:
/// - Segmented control (All, Purchases, Refunds, Top-ups)
/// - Search bar to filter by title/id
/// - A styled list of transaction cards
///
/// This screen is self-contained and uses in-memory sample data. It can be
/// later wired to a Bloc/Repository that provides real transactions.
class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

enum _TxnType { purchase, refund, topUp }

class _TransactionItem {
  final String id;
  final String title;
  final DateTime date;
  final double amount; // Positive for refund/top-up, negative for purchase
  final _TxnType type;
  final String status; // e.g., Completed

  const _TransactionItem({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.type,
    this.status = 'Completed',
  });
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  // Palette from the mock
  static const _bg = Color(0xFFFFFAF0);

  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedIndex = 0; // 0: All, 1: Purchases, 2: Refunds, 3: Top-ups

  // Sample data matching the mock
  final List<_TransactionItem> _all = [
    _TransactionItem(
      id: 'ABCDEF',
      title: 'Order #ABCDEF - 3 Items',
      date: DateTime(2023, 10, 26),
      amount: -49.99,
      type: _TxnType.purchase,
    ),
    _TransactionItem(
      id: 'TOPUP1',
      title: 'Wallet Top-up via Credit Card',
      date: DateTime(2023, 10, 25),
      amount: 50.00,
      type: _TxnType.topUp,
    ),
    _TransactionItem(
      id: 'REFUND1',
      title: 'Refund for Item XYZ',
      date: DateTime(2023, 10, 25),
      amount: 25.00,
      type: _TxnType.refund,
    ),
    _TransactionItem(
      id: 'GHIJKL',
      title: 'Order #GHIJKL - T-shirt',
      date: DateTime(2023, 10, 24),
      amount: -15.00,
      type: _TxnType.purchase,
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransactions();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.of(context).maybePop()),
            _SegmentedControl(
              selectedIndex: _selectedIndex,
              onChanged: (i) => setState(() => _selectedIndex = i),
            ),
            _SearchBar(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
            ),
            // Rebuild when search changes
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: filtered.isEmpty
                    ? _EmptyState()
                    : ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final tx = filtered[index];
                          return _TransactionCard(item: tx);
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<_TransactionItem> _filteredTransactions() {
    Iterable<_TransactionItem> items = _all;

    // Filter by segment
    switch (_selectedIndex) {
      case 1:
        items = items.where((e) => e.type == _TxnType.purchase);
        break;
      case 2:
        items = items.where((e) => e.type == _TxnType.refund);
        break;
      case 3:
        items = items.where((e) => e.type == _TxnType.topUp);
        break;
      default:
        break;
    }

    // Filter by search query
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) =>
          e.title.toLowerCase().contains(q) || e.id.toLowerCase().contains(q));
    }

    return items.toList();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  static const _bg = Color(0xFFFFFAF0);
  static const _text = Color(0xFF4A3728);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: _text,
            onPressed: onBack,
            tooltip: 'Back',
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Transaction History',
                style: TextStyle(
                  color: _text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Spacer to balance the back button
        ],
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _bg = Color(0xFFFFFAF0);
  static const _chipBg = Color(0xFFFDEFE3);
  static const _primary = Color(0xFFFF6600);
  static const _muted = Color(0xFFBF8B67);

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, int index) {
      final selected = selectedIndex == index;
      return Expanded(
        child: InkWell(
          onTap: () => onChanged(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? _primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _primary.withOpacity(0.4),
                        blurRadius: 4,
                      )
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _muted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _chipBg,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            chip('All', 0),
            chip('Purchases', 1),
            chip('Refunds', 2),
            chip('Top-ups', 3),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  static const _bg = Color(0xFFFFFAF0);
  static const _chipBg = Color(0xFFFDEFE3);
  static const _text = Color(0xFF4A3728);
  static const _muted = Color(0xFFBF8B67);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: _chipBg,
            prefixIcon: const Icon(Icons.search, color: _muted),
            hintText: 'Search transactions',
            hintStyle: const TextStyle(color: _muted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          style: const TextStyle(color: _text),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.item});
  final _TransactionItem item;

  static const _primary = Color(0xFFFF6600);
  static const _iconBg = Color(0xFFFDEFE3);
  static const _text = Color(0xFF4A3728);
  static const _muted = Color(0xFFBF8B67);

  @override
  Widget build(BuildContext context) {
    final isPositive = item.amount >= 0;
    final amountColor = isPositive ? Colors.green.shade700 : Colors.red.shade600;
    final icon = switch (item.type) {
      _TxnType.purchase => Icons.shopping_cart,
      _TxnType.refund => Icons.autorenew,
      _TxnType.topUp => Icons.credit_card,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _fmtDate(item.date),
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmtAmount(item.amount),
                style: TextStyle(
                  color: amountColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.status,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) => d.toIso8601String().split('T').first;
  static String _fmtAmount(double a) {
    final sign = a >= 0 ? '+' : '-';
    final abs = a.abs().toStringAsFixed(2);
    return '$sign\$$abs';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFFBF8B67);
    const text = Color(0xFF4A3728);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, size: 72, color: muted),
            const SizedBox(height: 12),
            const Text(
              'No transactions yet!\nYour transaction history will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: text, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

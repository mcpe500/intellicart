import 'package:flutter/material.dart';

/// Order Tracking screen inspired by the provided HTML mock.
/// - Search orders
/// - Segmented control: Active Orders, Completed, Canceled
/// - List of order rows with status pills and chevron
class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

enum _OrderStatus { packaged, sent, done, canceled }

class _OrderRow {
  final String id; // e.g., XYZ123
  final DateTime date;
  final _OrderStatus status;

  const _OrderRow({required this.id, required this.date, required this.status});
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  // Palette from mock
  static const Color bg = Color(0xFFFCF9F7);
  // other palette constants are declared in child widgets where needed

  final TextEditingController _searchCtrl = TextEditingController();
  int _segment = 0; // 0: Active, 1: Completed, 2: Canceled

  final List<_OrderRow> _all = [
    _OrderRow(id: 'XYZ123', date: DateTime(2023, 10, 26), status: _OrderStatus.packaged),
    _OrderRow(id: 'ABC456', date: DateTime(2023, 10, 20), status: _OrderStatus.sent),
    _OrderRow(id: 'DEF789', date: DateTime(2023, 10, 15), status: _OrderStatus.done),
    _OrderRow(id: 'GHI012', date: DateTime(2023, 10, 10), status: _OrderStatus.canceled),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered();
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => Navigator.of(context).maybePop()),
            _SearchBar(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
            ),
            _Segmented(
              index: _segment,
              onChanged: (i) => setState(() => _segment = i),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _OrderTile(row: items[i]),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<_OrderRow> _filtered() {
    Iterable<_OrderRow> items = _all;

    switch (_segment) {
      case 0:
        items = items.where((e) => e.status == _OrderStatus.packaged || e.status == _OrderStatus.sent);
        break;
      case 1:
        items = items.where((e) => e.status == _OrderStatus.done);
        break;
      case 2:
        items = items.where((e) => e.status == _OrderStatus.canceled);
        break;
    }

    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) => e.id.toLowerCase().contains(q));
    }
    return items.toList();
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});
  final VoidCallback onBack;

  static const Color bg = Color(0xFFFCF9F7);
  static const Color textDark = Color(0xFF181411);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: textDark,
            onPressed: onBack,
            tooltip: 'Back',
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Order Tracking',
                style: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  static const Color fieldBg = Color(0xFFF5F2F0);
  static const Color muted = Color(0xFF8A7260);
  static const Color textDark = Color(0xFF181411);
  static const Color bg = Color(0xFFFCF9F7);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldBg,
            prefixIcon: const Icon(Icons.search, color: muted),
            hintText: 'Search orders',
            hintStyle: const TextStyle(color: muted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          style: const TextStyle(color: textDark),
        ),
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  static const Color fieldBg = Color(0xFFF5F2F0);
  static const Color textDark = Color(0xFF181411);
  static const Color muted = Color(0xFF8A7260);

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, int i) {
      final selected = i == index;
      return Expanded(
        child: InkWell(
          onTap: () => onChanged(i),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                      )
                    ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(color: selected ? textDark : muted, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(color: fieldBg, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            chip('Active Orders', 0),
            chip('Completed', 1),
            chip('Canceled', 2),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.row});
  final _OrderRow row;

  static const Color textDark = Color(0xFF181411);
  static const Color muted = Color(0xFF8A7260);

  @override
  Widget build(BuildContext context) {
    final pill = _statusPill(row.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${row.id}', style: const TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 4),
                Text(_fmtDate(row.date), style: const TextStyle(color: muted, fontSize: 13)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: pill.bg, borderRadius: BorderRadius.circular(999)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(pill.label, style: TextStyle(color: pill.fg, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: textDark),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    // Format like `Oct 26, 2023`
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[d.month - 1];
    return '$m ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }

  ({String label, Color bg, Color fg}) _statusPill(_OrderStatus s) {
    switch (s) {
      case _OrderStatus.packaged:
        return (label: 'Packaged', bg: Colors.blue.shade100, fg: Colors.blue.shade700);
      case _OrderStatus.sent:
        return (label: 'Sent', bg: Colors.green.shade100, fg: Colors.green.shade700);
      case _OrderStatus.done:
        return (label: 'Done', bg: Colors.teal.shade100, fg: Colors.teal.shade700);
      case _OrderStatus.canceled:
        return (label: 'Canceled', bg: Colors.red.shade100, fg: Colors.red.shade700);
    }
  }
}

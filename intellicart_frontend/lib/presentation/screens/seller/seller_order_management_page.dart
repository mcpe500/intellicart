// lib/screens/seller/seller_order_management_page.dart
import 'package:flutter/material.dart';

/// Seller Order Management screen based on the provided mock.
/// Includes:
/// - Search by order id or customer name
/// - Tabs: Incoming, Pending, Completed
/// - Order cards with buyer, items, total, "Contact Buyer" and "View Details" actions
class SellerOrderManagementPage extends StatefulWidget {
  const SellerOrderManagementPage({super.key});

  @override
  State<SellerOrderManagementPage> createState() => _SellerOrderManagementPageState();
}

enum _SellerStage { incoming, pending, completed }

class _SellerOrderItem {
  final String orderId;
  final String buyerName;
  final int items;
  final double total;
  final DateTime when; // relative time shown as Today/Yesterday for mock fidelity
  final _SellerStage stage;
  final bool isNew;

  const _SellerOrderItem({
    required this.orderId,
    required this.buyerName,
    required this.items,
    required this.total,
    required this.when,
    required this.stage,
    this.isNew = false,
  });
}

class _SellerOrderManagementPageState extends State<SellerOrderManagementPage> {
  // Palette
  static const Color backgroundLight = Color(0xFFF8F7F5);
  static const Color headerText = Color(0xFF1A3A5E);
  // primary accent available in child widgets as needed

  final TextEditingController _search = TextEditingController();
  int _tab = 0; // 0: Incoming, 1: Pending, 2: Completed

  final List<_SellerOrderItem> _all = [
    _SellerOrderItem(
      orderId: 'IC-12345',
      buyerName: 'John Doe',
      items: 3,
      total: 125.50,
      when: DateTime.now(),
      stage: _SellerStage.incoming,
      isNew: true,
    ),
    _SellerOrderItem(
      orderId: 'IC-12344',
      buyerName: 'Jane Smith',
      items: 1,
      total: 45.00,
      when: DateTime.now().subtract(const Duration(days: 1, hours: -3, minutes: -15)),
      stage: _SellerStage.incoming,
      isNew: true,
    ),
    _SellerOrderItem(
      orderId: 'IC-12001',
      buyerName: 'Mark Wayne',
      items: 2,
      total: 80.00,
      when: DateTime(2023, 10, 20, 10, 0),
      stage: _SellerStage.pending,
    ),
    _SellerOrderItem(
      orderId: 'IC-11888',
      buyerName: 'Alice Johnson',
      items: 5,
      total: 240.00,
      when: DateTime(2023, 10, 10, 12, 0),
      stage: _SellerStage.completed,
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: headerText),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Order Management', style: TextStyle(color: headerText, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(Icons.more_vert, color: headerText),
          )
        ],
      ),
      body: Column(
        children: [
          _SearchHeader(controller: _search, onChanged: (_) => setState(() {})),
          _Tabs(index: _tab, onChanged: (i) => setState(() => _tab = i)),
          const Divider(height: 1),
          Expanded(
            child: Container(
              color: backgroundLight,
              child: filtered.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _OrderCard(item: filtered[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<_SellerOrderItem> _filtered() {
    Iterable<_SellerOrderItem> items = _all;
    switch (_tab) {
      case 0:
        items = items.where((e) => e.stage == _SellerStage.incoming);
        break;
      case 1:
        items = items.where((e) => e.stage == _SellerStage.pending);
        break;
      case 2:
        items = items.where((e) => e.stage == _SellerStage.completed);
        break;
    }
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) => e.orderId.toLowerCase().contains(q) || e.buyerName.toLowerCase().contains(q));
    }
    return items.toList();
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.controller, this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  static const Color fieldBg = Color(0xFFF8F7F5);
  static const Color muted = Color(0xFF8A7260);
  static const Color headerText = Color(0xFF1A3A5E);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldBg,
            prefixIcon: const Icon(Icons.search, color: headerText),
            hintText: 'Search by order ID or customer name',
            hintStyle: const TextStyle(color: muted),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          style: const TextStyle(color: headerText),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, int i) {
      final selected = i == index;
      return Expanded(
        child: InkWell(
          onTap: () => onChanged(i),
          child: Column(
            children: [
              const SizedBox(height: 14),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? const Color(0xFF1A3A5E) : Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 3,
                color: selected ? const Color(0xFFFF7A00) : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          tab('Incoming', 0),
          tab('Pending', 1),
          tab('Completed', 2),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.item});
  final _SellerOrderItem item;

  static const Color headerText = Color(0xFF1A3A5E);
  static const Color chipBg = Color(0xFFFFC107);
  // primary accent color is applied directly on button

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order #${item.orderId}', style: const TextStyle(color: headerText, fontSize: 18, fontWeight: FontWeight.bold)),
              if (item.isNew)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(999)),
                  child: const Text('New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(_fmtRelative(item.when), style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.buyerName, style: const TextStyle(color: headerText, fontWeight: FontWeight.w600, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${item.items} item${item.items == 1 ? '' : 's'} • \$${item.total.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 15)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _contact(context, item),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: headerText),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Text('Contact Buyer', style: TextStyle(color: headerText, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _details(context, item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('View Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmtRelative(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);
    if (diff.inDays == 0) {
      return 'Today, ${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) {
      return 'Yesterday, ${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}';
    }
    return '${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
  }

  void _contact(BuildContext context, _SellerOrderItem i) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contacting ${i.buyerName}...')),
    );
  }

  void _details(BuildContext context, _SellerOrderItem i) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening details for ${i.orderId}')), 
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.inventory_2_outlined, size: 96, color: Color(0xFF1A3A5E)),
            SizedBox(height: 12),
            Text('No new orders yet.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A5E))),
            SizedBox(height: 4),
            Text('Keep up the great work!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

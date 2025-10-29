// lib/presentation/screens/buyer/liked_products_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/presentation/bloc/buyer/product_bloc.dart';

/// Displays products the user has liked previously.
/// Likes are read from SharedPreferences under the key 'liked_product_ids'.
/// This screen mirrors the provided HTML (two-column grid, heart overlay,
/// and an Add to Cart button). The cart action is a placeholder SnackBar.
class LikedProductsPage extends StatefulWidget {
  const LikedProductsPage({super.key});

  @override
  State<LikedProductsPage> createState() => _LikedProductsPageState();
}

class _LikedProductsPageState extends State<LikedProductsPage> {
  Set<String> _likedIds = {};
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadLikedIds();

    // Ensure we have products
    final bloc = context.read<ProductBloc>();
    if (bloc.state is! ProductLoaded && bloc.state is! ProductLoading) {
      bloc.add(LoadProducts());
    }
  }

  Future<void> _loadLikedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('liked_product_ids') ??
        prefs.getStringList('liked_products') ??
        <String>[];
    setState(() {
      _likedIds = list.toSet();
      _loadingPrefs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Palette from mock
    const bg = Color(0xFFFDFBF8);
    const title = Color(0xFF4D3827);
    const muted = Color(0xFF8B796C);
    const coral = Color(0xFFFF6F61);
    const coralHover = Color(0xFFE66256);
    const price = Color(0xFFA0522D);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Liked Products',
          style: TextStyle(
            color: title,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search, color: title),
            onPressed: () {},
          ),
        ],
      ),
      body: _loadingPrefs
          ? const Center(child: CircularProgressIndicator())
          : BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading || state is ProductInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(state.message, style: const TextStyle(color: title)),
                    ),
                  );
                }

                final products = (state is ProductLoaded) ? state.products : <Product>[];
                final liked = products
                    .where((p) => _likedIds.contains(p.id?.toString() ?? p.name))
                    .toList();

                if (liked.isEmpty) {
                  return _EmptyLikes(bg: bg, title: title, muted: muted, coral: coral);
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    // Slightly taller tiles to avoid overflow in tests
                    childAspectRatio: 0.70,
                  ),
                  itemCount: liked.length,
                  itemBuilder: (context, i) {
                    final p = liked[i];
                    return _LikedCard(
                      product: p,
                      priceColor: price,
                      coral: coral,
                      coralHover: coralHover,
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: _BottomNav(bg: bg, muted: muted, coral: coral),
    );
  }
}

class _LikedCard extends StatelessWidget {
  final Product product;
  final Color priceColor;
  final Color coral;
  final Color coralHover;
  const _LikedCard({
    required this.product,
    required this.priceColor,
    required this.coral,
    required this.coralHover,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Center(
                      child: Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.favorite, color: coral, size: 20),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF4D3827),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          product.price,
          style: TextStyle(color: priceColor, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.pressed)) return coralHover;
                return coral;
              }),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to cart')),
              );
            },
            child: const Text(
              'Add to Cart',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyLikes extends StatelessWidget {
  final Color bg;
  final Color title;
  final Color muted;
  final Color coral;
  const _EmptyLikes({required this.bg, required this.title, required this.muted, required this.coral});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.heart_broken, color: coral, size: 80),
            const SizedBox(height: 12),
            Text('No liked products yet!', style: TextStyle(color: title, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Start browsing now!', style: TextStyle(color: muted)),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: coral),
              onPressed: () => Navigator.maybePop(context),
              child: const Text('Browse Products', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final Color bg;
  final Color muted;
  final Color coral;
  const _BottomNav({required this.bg, required this.muted, required this.coral});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: const Color(0xFFF5EFEA))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          _NavItem(icon: Icons.home_outlined, label: 'Home', color: muted),
          _NavItem(icon: Icons.sell_outlined, label: 'Categories', color: muted),
          _NavItem(icon: Icons.favorite, label: 'Liked', color: coral, bold: true),
          _NavItem(icon: Icons.person_outline, label: 'Profile', color: muted),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool bold;
  const _NavItem({required this.icon, required this.label, required this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: bold ? FontWeight.bold : FontWeight.w500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

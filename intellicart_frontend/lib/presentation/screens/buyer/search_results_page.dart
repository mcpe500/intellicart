// lib/presentation/screens/buyer/search_results_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intellicart/models/product.dart';
import 'package:intellicart/presentation/bloc/buyer/product_bloc.dart';

/// A buyer-facing screen that displays search results in a grid, inspired by
/// the provided HTML mock. It reads products from ProductBloc and filters them
/// by [initialQuery]. Filter chips are presentational for now.
class SearchResultsPage extends StatefulWidget {
  final String initialQuery;

  const SearchResultsPage({super.key, this.initialQuery = 'Smartwatch'});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);

    // Ensure products are loaded (no-op if already loading/loaded upstream)
    final bloc = context.read<ProductBloc>();
    if (bloc.state is! ProductLoaded && bloc.state is! ProductLoading) {
      bloc.add(LoadProducts());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Palette derived from the mock
    const cream = Color(0xFFFFFCF9);
    const brown = Color(0xFF4D2C00);
    const brownMuted = Color(0xFF8C5A2B);
    const inputBg = Color(0xFFFFF7F0);
    const accent = Color(0xFFFB8500);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: cream,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back, color: brown),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          'Search Results',
          style: TextStyle(
            color: brown,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Cart',
            icon: const Icon(Icons.shopping_cart_outlined, color: brown),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 48,
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  prefixIcon: const Icon(Icons.search, color: brownMuted),
                  filled: true,
                  fillColor: inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Filter chips row (non-functional placeholders)
          SizedBox(
            height: 40,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: const [
                _FilterChipStub(icon: Icons.tune, label: 'Filter'),
                SizedBox(width: 8),
                _FilterChipStub(icon: Icons.swap_vert, label: 'Relevance'),
                SizedBox(width: 8),
                _FilterChipStub(icon: Icons.sell_outlined, label: 'Under \$50'),
                SizedBox(width: 8),
                _FilterChipStub(label: 'Electronics'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading || state is ProductInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: brown),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final products = (state is ProductLoaded)
                    ? state.products
                    : <Product>[];

                final query = _controller.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? products
                    : products
                        .where((p) => p.name.toLowerCase().contains(query))
                        .toList();

                if (filtered.isEmpty) {
                  return _EmptyResults(query: _controller.text);
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _ProductCard(
                      product: filtered[index],
                      accent: accent,
                      brown: brown,
                      brownMuted: brownMuted,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipStub extends StatelessWidget {
  final IconData? icon;
  final String label;
  const _FilterChipStub({this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    const chipBg = Color(0xFFFFE8D1);
    const brown = Color(0xFF4D2C00);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: brown, size: 16),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: brown,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final Color accent;
  final Color brown;
  final Color brownMuted;
  const _ProductCard({
    required this.product,
    required this.accent,
    required this.brown,
    required this.brownMuted,
  });

  double? _avgRating() {
    if (product.reviews.isEmpty) return null;
    final total = product.reviews.fold<int>(0, (s, r) => s + (r.rating));
    return (total / product.reviews.length).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final rating = _avgRating();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.white),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Center(
                  child: Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: brown,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          product.price.startsWith('\$') ? product.price : '\$${product.price}',
          style: TextStyle(
            color: accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.star, size: 16, color: Colors.amber[600]),
            const SizedBox(width: 4),
            Text(
              rating != null ? rating.toStringAsFixed(1) : '-',
              style: TextStyle(color: brownMuted),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final String query;
  const _EmptyResults({required this.query});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFB8500);
    const brown = Color(0xFF4D2C00);
    const brownMuted = Color(0xFF8C5A2B);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 72, color: accent),
            const SizedBox(height: 12),
            Text(
              "No results found for '$query'.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: brown,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different search or browse our popular categories.',
              textAlign: TextAlign.center,
              style: TextStyle(color: brownMuted),
            ),
          ],
        ),
      ),
    );
  }
}
